//
//  MovieDetailViewModel.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Implemented by Claude Code Audit on 28/12/2025.
//

import Foundation
import Combine

/// ViewModel for Movie Detail screen with trailers, similar movies, and watchlist management
@MainActor
final class MovieDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var movie: Movie
    @Published private(set) var trailers: [Video] = []
    @Published private(set) var similarMovies: [Movie] = []
    @Published private(set) var recommendedMovies: [Movie] = []
    @Published private(set) var watchProviders: WatchProviderInfo = .empty

    @Published private(set) var isLoadingTrailers = false
    @Published private(set) var isLoadingSimilar = false
    @Published private(set) var isLoadingRecommended = false
    @Published private(set) var isLoadingProviders = false

    @Published var isInWatchlist: Bool = false
    @Published var selectedTrailer: Video?
    @Published var showingTrailer = false
    @Published var showingFullOverview = false

    @Published var error: NetworkError?

    // MARK: - Dependencies

    private let tmdbService: TMDBService
    private let watchlistManager: WatchlistManager
    private let liveActivityManager: LiveActivityManager

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    /// Primary trailer (official, YouTube)
    var primaryTrailer: Video? {
        trailers.first { $0.isOfficialYouTubeTrailer } ?? trailers.first
    }

    /// Whether we have content to show
    var hasAdditionalContent: Bool {
        !trailers.isEmpty || !similarMovies.isEmpty || !recommendedMovies.isEmpty || !watchProviders.isEmpty
    }

    // MARK: - Initialization

    init(
        movie: Movie,
        tmdbService: TMDBService = .shared,
        watchlistManager: WatchlistManager,
        liveActivityManager: LiveActivityManager = .shared
    ) {
        self.movie = movie
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
        self.liveActivityManager = liveActivityManager

        // Check initial watchlist status
        self.isInWatchlist = watchlistManager.contains(movie)

        // Observe watchlist changes
        setupWatchlistObserver()
    }

    // MARK: - Public Methods

    /// Load all movie detail content
    func loadContent() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTrailers() }
            group.addTask { await self.loadSimilarMovies() }
            group.addTask { await self.loadRecommendedMovies() }
            group.addTask { await self.loadWatchProviders() }
        }
    }

    /// Load trailers for the movie
    func loadTrailers() async {
        isLoadingTrailers = true
        error = nil

        do {
            let response = try await tmdbService.fetchVideos(for: movie.id)
            trailers = response.allTrailers
            isLoadingTrailers = false
        } catch let networkError as NetworkError {
            error = networkError
            isLoadingTrailers = false
        } catch {
            self.error = .unknown
            isLoadingTrailers = false
        }
    }

    /// Load similar movies
    func loadSimilarMovies() async {
        isLoadingSimilar = true

        do {
            let response = try await tmdbService.fetchSimilarMovies(for: movie.id)
            similarMovies = Array(response.results.prefix(10))
            isLoadingSimilar = false
        } catch {
            isLoadingSimilar = false
            // Silently fail - similar movies are optional
        }
    }

    /// Load recommended movies
    func loadRecommendedMovies() async {
        isLoadingRecommended = true

        do {
            let response = try await tmdbService.fetchRecommendations(for: movie.id)
            recommendedMovies = Array(response.results.prefix(10))
            isLoadingRecommended = false
        } catch {
            isLoadingRecommended = false
            // Silently fail - recommendations are optional
        }
    }

    /// Load watch providers (streaming platforms)
    func loadWatchProviders() async {
        isLoadingProviders = true

        do {
            watchProviders = try await tmdbService.fetchWatchProviders(for: movie.id)
            isLoadingProviders = false
        } catch {
            isLoadingProviders = false
            // Silently fail - watch providers are optional
        }
    }

    /// Refresh all content
    func refresh() async {
        await loadContent()
    }

    /// Reload movie details (useful for deep links)
    func reloadMovieDetails() async {
        do {
            let updatedMovie = try await tmdbService.fetchMovieDetails(id: movie.id)
            movie = updatedMovie
            isInWatchlist = watchlistManager.contains(movie)
        } catch {
            // Keep existing movie data if refresh fails
        }
    }

    // MARK: - Trailer Actions

    /// Play the primary trailer
    func playPrimaryTrailer() {
        guard let trailer = primaryTrailer else { return }
        playTrailer(trailer)
    }

    /// Play a specific trailer
    func playTrailer(_ trailer: Video) {
        HapticManager.shared.openedDetail()
        selectedTrailer = trailer
        showingTrailer = true
    }

    /// Close trailer player
    func closeTrailer() {
        showingTrailer = false
        selectedTrailer = nil
    }

    // MARK: - Watchlist Actions

    /// Toggle watchlist status
    func toggleWatchlist() {
        if isInWatchlist {
            removeFromWatchlist()
        } else {
            addToWatchlist()
        }
    }

    /// Add movie to watchlist
    func addToWatchlist() {
        watchlistManager.add(movie)
        isInWatchlist = true
        HapticManager.shared.addedToWatchlist()

        // Start Live Activity
        Task {
            await liveActivityManager.startActivity(for: movie)
        }
    }

    /// Remove movie from watchlist
    func removeFromWatchlist() {
        watchlistManager.remove(movie)
        isInWatchlist = false
        HapticManager.shared.removedFromWatchlist()

        // End Live Activity if this movie's activity is running
        Task {
            await liveActivityManager.endActivity()
        }
    }

    /// Check if a movie is in watchlist
    func isMovieInWatchlist(_ movie: Movie) -> Bool {
        watchlistManager.contains(movie)
    }

    /// Toggle watchlist for a specific movie (for similar/recommended movies)
    func toggleWatchlist(for movie: Movie) {
        watchlistManager.toggle(movie)
    }

    // MARK: - Share

    /// Create share content for the movie
    func shareContent() -> String {
        var content = "Check out \"\(movie.title)\""

        if let year = movie.releaseYear {
            content += " (\(year))"
        }

        content += " - Rated \(movie.formattedRating)/10"
        content += "\n\n\(movie.overview)"

        // Add TMDB link
        content += "\n\nhttps://www.themoviedb.org/movie/\(movie.id)"

        return content
    }

    /// Create URL for sharing
    func shareURL() -> URL? {
        URL(string: "https://www.themoviedb.org/movie/\(movie.id)")
    }

    // MARK: - Private Methods

    private func setupWatchlistObserver() {
        // Observe watchlist changes to update UI
        watchlistManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isInWatchlist = self.watchlistManager.contains(self.movie)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Static Factory Methods

extension MovieDetailViewModel {
    /// Create view model for a movie ID (fetches details)
    static func fromMovieId(
        _ id: Int,
        tmdbService: TMDBService = .shared,
        watchlistManager: WatchlistManager,
        liveActivityManager: LiveActivityManager = .shared
    ) async throws -> MovieDetailViewModel {
        let movie = try await tmdbService.fetchMovieDetails(id: id)
        return MovieDetailViewModel(
            movie: movie,
            tmdbService: tmdbService,
            watchlistManager: watchlistManager,
            liveActivityManager: liveActivityManager
        )
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension MovieDetailViewModel {
    /// Mock view model for previews
    static func mock(
        movie: Movie = .sample,
        isInWatchlist: Bool = false
    ) -> MovieDetailViewModel {
        let viewModel = MovieDetailViewModel(
            movie: movie,
            tmdbService: .shared,
            watchlistManager: .mock(),
            liveActivityManager: .shared
        )
        viewModel.isInWatchlist = isInWatchlist
        viewModel.similarMovies = Movie.samples
        viewModel.recommendedMovies = Movie.samples
        return viewModel
    }
}
#endif
