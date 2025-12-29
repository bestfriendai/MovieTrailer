//
//  MovieSwipeViewModel.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  ViewModel for Tinder-style movie swiping
//

import Foundation
import Combine

@MainActor
final class MovieSwipeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var movieQueue: [Movie] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading = false
    @Published var error: NetworkError?

    @Published var likedMovies: [Movie] = []
    @Published var skippedMovies: [Movie] = []
    @Published var watchLaterMovies: [Movie] = []

    @Published var matchAnimation: Movie?
    @Published var showStats = false

    // Taste profile for display
    @Published var tasteProfile: TasteProfile?

    // MARK: - Dependencies

    private let tmdbService: TMDBService
    private let watchlistManager: WatchlistManager
    private let preferences: UserPreferences
    private let recommendationEngine: RecommendationEngine
    private let offlineCache: OfflineMovieCache

    private var currentPage = 1
    private var totalPages = 1

    // MARK: - Computed Properties

    var currentMovie: Movie? {
        guard currentIndex < movieQueue.count else { return nil }
        return movieQueue[currentIndex]
    }

    var nextMovie: Movie? {
        guard currentIndex + 1 < movieQueue.count else { return nil }
        return movieQueue[currentIndex + 1]
    }

    var remainingCount: Int {
        max(0, movieQueue.count - currentIndex)
    }

    var likePercentage: Double {
        let total = likedMovies.count + skippedMovies.count
        guard total > 0 else { return 0 }
        return Double(likedMovies.count) / Double(total) * 100
    }

    // MARK: - Initialization

    init(
        tmdbService: TMDBService = .shared,
        watchlistManager: WatchlistManager,
        preferences: UserPreferences = .shared,
        recommendationEngine: RecommendationEngine = .shared,
        offlineCache: OfflineMovieCache = .shared
    ) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
        self.preferences = preferences
        self.recommendationEngine = recommendationEngine
        self.offlineCache = offlineCache
    }

    // MARK: - Public Methods

    /// Load initial movies for swiping
    func loadMovies() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil
        currentPage = 1

        do {
            // Fetch from multiple sources - prioritize RECENT movies
            async let trending = tmdbService.fetchTrending(page: currentPage)
            async let nowPlaying = tmdbService.fetchNowPlaying(page: currentPage)
            async let recentMovies = tmdbService.fetchRecentMovies(page: currentPage)

            let (trendingResult, nowPlayingResult, recentResult) = try await (trending, nowPlaying, recentMovies)

            // Combine and prioritize recent/current movies
            var allMovies: [Movie] = []
            // Add trending first (usually current/popular movies)
            allMovies.append(contentsOf: trendingResult.results)
            // Add now playing (movies in theaters)
            allMovies.append(contentsOf: nowPlayingResult.results)
            // Add recent movies discovered in last 6 months
            allMovies.append(contentsOf: recentResult.results)

            // Remove duplicates while preserving order
            var seen = Set<Int>()
            let uniqueMovies = allMovies.filter { movie in
                guard !seen.contains(movie.id) else { return false }
                seen.insert(movie.id)
                return true
            }

            // Filter by user preferences
            let filteredMovies = filterByPreferences(uniqueMovies)

            // Filter out already swiped movies using recommendation engine
            let unseenMovies = await recommendationEngine.filterSwipedMovies(filteredMovies)

            // Sort by recommendation score for personalized experience
            let sortedMovies = await recommendationEngine.sortByRecommendation(unseenMovies)

            // Cache movies for offline use
            await offlineCache.cacheMovies(sortedMovies, category: .trending)

            movieQueue = sortedMovies
            currentIndex = 0

            totalPages = min(trendingResult.totalPages, 10) // Cap at 10 pages

            // Update taste profile for display
            tasteProfile = await recommendationEngine.getTasteProfile()

            isLoading = false
        } catch let networkError as NetworkError {
            // Try to load from cache if offline
            await loadFromCacheIfAvailable()
            error = networkError
            isLoading = false
        } catch {
            await loadFromCacheIfAvailable()
            self.error = .unknown
            isLoading = false
        }
    }

    /// Load movies from offline cache
    private func loadFromCacheIfAvailable() async {
        let cachedMovies = await offlineCache.getMovies(for: .trending)
        if !cachedMovies.isEmpty {
            let unseenMovies = await recommendationEngine.filterSwipedMovies(cachedMovies)
            movieQueue = unseenMovies
            currentIndex = 0
        }
    }

    /// Load more movies when running low
    func loadMoreIfNeeded() async {
        // Load more when 5 movies remaining
        guard remainingCount <= 5 else { return }
        guard !isLoading else { return }
        guard currentPage < totalPages else { return }

        currentPage += 1
        isLoading = true

        do {
            // Fetch from multiple recent sources
            async let trending = tmdbService.fetchTrending(page: currentPage)
            async let recent = tmdbService.fetchRecentMovies(page: currentPage)

            let (trendingResult, recentResult) = try await (trending, recent)

            var allMovies: [Movie] = []
            allMovies.append(contentsOf: trendingResult.results)
            allMovies.append(contentsOf: recentResult.results)

            // Filter and append, removing duplicates
            let filtered = filterByPreferences(allMovies)
            let existingIds = Set(movieQueue.map(\.id))
            let newMovies = filtered.filter { !existingIds.contains($0.id) }

            movieQueue.append(contentsOf: newMovies.shuffled())
            isLoading = false
        } catch {
            isLoading = false
        }
    }

    /// Handle swipe action
    func handleSwipe(_ direction: SwipeCard.SwipeDirection) {
        guard let movie = currentMovie else { return }

        // Record preference
        let action: UserPreferences.SwipeAction
        let recommendationAction: SwipeAction
        switch direction {
        case .right:
            likedMovies.append(movie)
            action = .liked
            recommendationAction = .liked
            // Check for "match" animation (high rating + liked)
            if movie.voteAverage >= 8.0 && Bool.random() {
                matchAnimation = movie
            }
        case .left:
            skippedMovies.append(movie)
            action = .skipped
            recommendationAction = .skipped
        case .up:
            watchLaterMovies.append(movie)
            watchlistManager.add(movie)
            action = .superLiked
            recommendationAction = .superLiked
        }

        // Save preference for recommendations
        let preference = UserPreferences.SwipePreference(
            movieId: movie.id,
            action: action,
            timestamp: Date(),
            genres: movie.genreIds ?? [],
            rating: movie.voteAverage
        )
        preferences.saveSwipePreference(preference)

        // Record swipe in recommendation engine for personalization
        Task {
            await recommendationEngine.recordSwipe(movie: movie, action: recommendationAction)
            // Update taste profile
            tasteProfile = await recommendationEngine.getTasteProfile()
        }

        // Move to next movie
        currentIndex += 1

        // Load more if needed
        Task {
            await loadMoreIfNeeded()
        }
    }

    /// Skip current movie (button action)
    func skip() {
        handleSwipe(.left)
    }

    /// Like current movie (button action)
    func like() {
        handleSwipe(.right)
    }

    /// Add to watch later (button action)
    func watchLater() {
        handleSwipe(.up)
    }

    /// Undo last swipe
    func undo() {
        guard currentIndex > 0 else { return }

        currentIndex -= 1

        // Remove from appropriate list
        if let lastLiked = likedMovies.last, lastLiked.id == currentMovie?.id {
            likedMovies.removeLast()
        } else if let lastSkipped = skippedMovies.last, lastSkipped.id == currentMovie?.id {
            skippedMovies.removeLast()
        } else if let lastWatchLater = watchLaterMovies.last, lastWatchLater.id == currentMovie?.id {
            watchLaterMovies.removeLast()
            if let movie = currentMovie {
                watchlistManager.remove(movie)
            }
        }

        Haptics.shared.lightImpact()
    }

    /// Reset and start over
    func reset() async {
        likedMovies.removeAll()
        skippedMovies.removeAll()
        watchLaterMovies.removeAll()
        movieQueue.removeAll()
        currentIndex = 0
        await loadMovies()
    }

    /// Dismiss match animation
    func dismissMatch() {
        matchAnimation = nil
    }

    // MARK: - Private Methods

    private func filterByPreferences(_ movies: [Movie]) -> [Movie] {
        var filtered = movies

        // Filter by adult content preference
        if !preferences.includeAdultContent {
            filtered = filtered.filter { !($0.adult ?? false) }
        }

        // Filter out already swiped movies
        let swipedIds = Set(likedMovies.map(\.id) + skippedMovies.map(\.id) + watchLaterMovies.map(\.id))
        filtered = filtered.filter { !swipedIds.contains($0.id) }

        return filtered
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension MovieSwipeViewModel {
    static func mock() -> MovieSwipeViewModel {
        let viewModel = MovieSwipeViewModel(
            tmdbService: .shared,
            watchlistManager: .mock()
        )
        viewModel.movieQueue = Movie.samples
        return viewModel
    }
}
#endif
