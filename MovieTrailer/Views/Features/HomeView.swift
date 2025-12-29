//
//  HomeView.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Apple TV-inspired home screen
//

import SwiftUI

struct HomeView: View {

    // MARK: - Properties

    @StateObject private var viewModel: HomeViewModel
    let onMovieTap: (Movie) -> Void
    let onPlayTrailer: (Movie) -> Void

    // MARK: - Initialization

    init(
        viewModel: HomeViewModel,
        onMovieTap: @escaping (Movie) -> Void,
        onPlayTrailer: @escaping (Movie) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMovieTap = onMovieTap
        self.onPlayTrailer = onPlayTrailer
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // Cinematic Hero Carousel
                if !viewModel.featuredMovies.isEmpty {
                    CinematicHeroCarousel(
                        movies: viewModel.featuredMovies,
                        onPlay: onPlayTrailer,
                        onAddToList: { movie in
                            viewModel.toggleWatchlist(for: movie)
                        },
                        onTap: onMovieTap
                    )
                }

                // Continue Watching (if any in watchlist)
                if !viewModel.watchlistMovies.isEmpty {
                    LargePosterRow(
                        title: "Continue Watching",
                        movies: viewModel.watchlistMovies,
                        onMovieTap: onMovieTap
                    )
                }

                // Top 10 Movies
                if !viewModel.topRatedMovies.isEmpty {
                    Top10Row(
                        title: "Top 10 Movies Today",
                        movies: viewModel.topRatedMovies,
                        onMovieTap: onMovieTap
                    )
                }

                // Trending Now
                if !viewModel.trendingMovies.isEmpty {
                    ContentRow(
                        title: "Trending Now",
                        subtitle: "What everyone's watching",
                        movies: viewModel.trendingMovies,
                        onMovieTap: onMovieTap
                    )
                }

                // Popular Movies
                if !viewModel.popularMovies.isEmpty {
                    ContentRow(
                        title: "Popular Movies",
                        movies: viewModel.popularMovies,
                        onMovieTap: onMovieTap
                    )
                }

                // New Releases
                if !viewModel.newReleases.isEmpty {
                    ContentRow(
                        title: "New Releases",
                        subtitle: "Fresh arrivals",
                        movies: viewModel.newReleases,
                        onMovieTap: onMovieTap
                    )
                }

                // Action Movies
                if !viewModel.actionMovies.isEmpty {
                    CompactMovieRow(
                        title: "Action & Adventure",
                        icon: "bolt.fill",
                        movies: viewModel.actionMovies,
                        onMovieTap: onMovieTap
                    )
                }

                // Comedy Movies
                if !viewModel.comedyMovies.isEmpty {
                    CompactMovieRow(
                        title: "Comedy",
                        icon: "face.smiling.fill",
                        movies: viewModel.comedyMovies,
                        onMovieTap: onMovieTap
                    )
                }

                // Drama Movies
                if !viewModel.dramaMovies.isEmpty {
                    CompactMovieRow(
                        title: "Drama",
                        icon: "theatermasks.fill",
                        movies: viewModel.dramaMovies,
                        onMovieTap: onMovieTap
                    )
                }

                // Bottom padding for tab bar
                Spacer()
                    .frame(height: 100)
            }
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadContent()
        }
        .overlay {
            if viewModel.isLoading && viewModel.trendingMovies.isEmpty {
                loadingOverlay
            }
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.textSecondary)

                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - Home View Model

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var featuredMovies: [Movie] = []
    @Published var trendingMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    @Published var topRatedMovies: [Movie] = []
    @Published var newReleases: [Movie] = []
    @Published var watchlistMovies: [Movie] = []

    // Genre-specific
    @Published var actionMovies: [Movie] = []
    @Published var comedyMovies: [Movie] = []
    @Published var dramaMovies: [Movie] = []
    @Published var horrorMovies: [Movie] = []

    @Published var isLoading = false
    @Published var error: NetworkError?

    // MARK: - Dependencies

    private let tmdbService: TMDBService
    private let watchlistManager: WatchlistManager

    // MARK: - Initialization

    init(tmdbService: TMDBService, watchlistManager: WatchlistManager) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
    }

    // MARK: - Public Methods

    func loadContent() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        // Load watchlist
        loadWatchlist()

        // Load all content in parallel
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTrending() }
            group.addTask { await self.loadPopular() }
            group.addTask { await self.loadTopRated() }
        }

        // Filter by genres
        filterByGenres()

        isLoading = false
    }

    func refresh() async {
        await loadContent()
    }

    func toggleWatchlist(for movie: Movie) {
        watchlistManager.toggle(movie)
        loadWatchlist()
        Haptics.shared.addedToWatchlist()
    }

    func isInWatchlist(_ movie: Movie) -> Bool {
        watchlistManager.contains(movie)
    }

    // MARK: - Private Methods

    private func loadWatchlist() {
        watchlistMovies = watchlistManager.items.prefix(10).map { $0.toMovie() }
    }

    private func loadTrending() async {
        do {
            let response = try await tmdbService.fetchTrending(page: 1)
            trendingMovies = response.results
            // Use trending for featured
            featuredMovies = Array(response.results.prefix(5))
        } catch {
            // Silent fail
        }
    }

    private func loadPopular() async {
        do {
            let response = try await tmdbService.fetchPopular(page: 1)
            popularMovies = response.results
            // Recent releases
            newReleases = response.results.filter { movie in
                guard let date = movie.releaseDate else { return false }
                let year = String(date.prefix(4))
                return year == "2024" || year == "2025"
            }
        } catch {
            // Silent fail
        }
    }

    private func loadTopRated() async {
        do {
            let response = try await tmdbService.fetchTopRated(page: 1)
            topRatedMovies = response.results
        } catch {
            // Silent fail
        }
    }

    private func filterByGenres() {
        let allMovies = trendingMovies + popularMovies + topRatedMovies
        let uniqueMovies = Array(Set(allMovies))

        // Action (28)
        actionMovies = uniqueMovies.filter { $0.genreIds.contains(28) }

        // Comedy (35)
        comedyMovies = uniqueMovies.filter { $0.genreIds.contains(35) }

        // Drama (18)
        dramaMovies = uniqueMovies.filter { $0.genreIds.contains(18) }

        // Horror (27)
        horrorMovies = uniqueMovies.filter { $0.genreIds.contains(27) }
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension HomeViewModel {
    static func mock() -> HomeViewModel {
        let viewModel = HomeViewModel(
            tmdbService: .shared,
            watchlistManager: .mock()
        )
        viewModel.featuredMovies = Movie.samples
        viewModel.trendingMovies = Movie.samples
        viewModel.popularMovies = Movie.samples
        viewModel.topRatedMovies = Movie.samples
        return viewModel
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            viewModel: .mock(),
            onMovieTap: { _ in },
            onPlayTrailer: { _ in }
        )
    }
}
#endif
