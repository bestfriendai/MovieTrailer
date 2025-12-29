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

    // MARK: - Dependencies

    private let tmdbService: TMDBService
    private let watchlistManager: WatchlistManager
    private let preferences: UserPreferences

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
        preferences: UserPreferences = .shared
    ) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
        self.preferences = preferences
    }

    // MARK: - Public Methods

    /// Load initial movies for swiping
    func loadMovies() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil
        currentPage = 1

        do {
            // Fetch from multiple sources for variety
            async let trending = tmdbService.fetchTrending(page: currentPage)
            async let popular = tmdbService.fetchPopular(page: currentPage)
            async let topRated = tmdbService.fetchTopRated(page: currentPage)

            let (trendingResult, popularResult, topRatedResult) = try await (trending, popular, topRated)

            // Combine and shuffle
            var allMovies: [Movie] = []
            allMovies.append(contentsOf: trendingResult.results)
            allMovies.append(contentsOf: popularResult.results)
            allMovies.append(contentsOf: topRatedResult.results)

            // Remove duplicates
            let uniqueMovies = Array(Set(allMovies))

            // Filter by user preferences
            let filteredMovies = filterByPreferences(uniqueMovies)

            // Shuffle for variety
            movieQueue = filteredMovies.shuffled()
            currentIndex = 0

            totalPages = min(trendingResult.totalPages, 10) // Cap at 10 pages

            isLoading = false
        } catch let networkError as NetworkError {
            error = networkError
            isLoading = false
        } catch {
            self.error = .unknown
            isLoading = false
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
            let response = try await tmdbService.fetchTrending(page: currentPage)

            // Filter and append
            let filtered = filterByPreferences(response.results)
            let newMovies = filtered.filter { newMovie in
                !movieQueue.contains { $0.id == newMovie.id }
            }

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
        switch direction {
        case .right:
            likedMovies.append(movie)
            action = .liked
            // Check for "match" animation (high rating + liked)
            if movie.voteAverage >= 8.0 && Bool.random() {
                matchAnimation = movie
            }
        case .left:
            skippedMovies.append(movie)
            action = .skipped
        case .up:
            watchLaterMovies.append(movie)
            watchlistManager.add(movie)
            action = .superLiked
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
