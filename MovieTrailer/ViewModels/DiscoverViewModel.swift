//
//  DiscoverViewModel.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import Foundation
import Combine

/// ViewModel for the Discover tab
@MainActor
final class DiscoverViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var trendingMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    @Published var topRatedMovies: [Movie] = []
    @Published var categoryMovies: [Movie]?

    @Published var isLoadingTrending = false
    @Published var isLoadingPopular = false
    @Published var isLoadingTopRated = false
    @Published var isLoadingCategory = false

    @Published var error: NetworkError?

    @Published private var selectedCategory: MovieCategory = .all

    // MARK: - Dependencies

    private let tmdbService: TMDBService
    private let watchlistManager: WatchlistManager

    // MARK: - Computed Properties

    /// Filtered trending movies based on category and streaming preferences
    var filteredTrendingMovies: [Movie] {
        filterMovies(trendingMovies)
    }

    /// Filtered popular movies based on category and streaming preferences
    var filteredPopularMovies: [Movie] {
        filterMovies(popularMovies)
    }

    /// Filtered top rated movies based on category and streaming preferences
    var filteredTopRatedMovies: [Movie] {
        filterMovies(topRatedMovies)
    }

    // MARK: - Initialization

    init(tmdbService: TMDBService, watchlistManager: WatchlistManager) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
    }

    // MARK: - Public Methods

    /// Load all discover content
    func loadContent() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTrending() }
            group.addTask { await self.loadPopular() }
            group.addTask { await self.loadTopRated() }
        }
    }

    /// Load content for a specific category
    func loadForCategory(_ category: MovieCategory) async {
        selectedCategory = category

        guard category != .all else {
            categoryMovies = nil
            return
        }

        // Check if category has specific genre IDs
        guard let genreIds = category.genreIds else {
            // Handle special categories
            switch category {
            case .new:
                await loadNewReleases()
            case .classics:
                await loadClassics()
            case .tvShows:
                // Future: Load TV shows from different endpoint
                categoryMovies = nil
            default:
                categoryMovies = nil
            }
            return
        }

        await loadByGenre(genreIds)
    }

    /// Load trending movies
    func loadTrending() async {
        isLoadingTrending = true
        error = nil

        do {
            let response = try await tmdbService.fetchTrending(page: 1)
            trendingMovies = response.results
            isLoadingTrending = false
        } catch let networkError as NetworkError {
            error = networkError
            isLoadingTrending = false
        } catch {
            self.error = .unknown
            isLoadingTrending = false
        }
    }

    /// Load popular movies
    func loadPopular() async {
        isLoadingPopular = true

        do {
            let response = try await tmdbService.fetchPopular(page: 1)
            popularMovies = response.results
            isLoadingPopular = false
        } catch {
            isLoadingPopular = false
        }
    }

    /// Load top rated movies
    func loadTopRated() async {
        isLoadingTopRated = true

        do {
            let response = try await tmdbService.fetchTopRated(page: 1)
            topRatedMovies = response.results
            isLoadingTopRated = false
        } catch {
            isLoadingTopRated = false
        }
    }

    /// Refresh all content
    func refresh() async {
        await loadContent()
        if selectedCategory != .all {
            await loadForCategory(selectedCategory)
        }
    }

    /// Check if movie is in watchlist
    func isInWatchlist(_ movie: Movie) -> Bool {
        watchlistManager.contains(movie)
    }

    /// Toggle movie in watchlist
    func toggleWatchlist(for movie: Movie) {
        watchlistManager.toggle(movie)
    }

    // MARK: - Private Methods

    /// Filter movies based on selected category genres
    private func filterMovies(_ movies: [Movie]) -> [Movie] {
        guard selectedCategory != .all else {
            return movies
        }

        guard let genreIds = selectedCategory.genreIds else {
            // For special categories, return all movies (will be handled separately)
            return movies
        }

        return movies.filter { movie in
            let movieGenres = movie.genreIds
            guard !movieGenres.isEmpty else { return false }
            return !Set(movieGenres).isDisjoint(with: Set(genreIds))
        }
    }

    /// Load new releases (movies from last 3 months)
    private func loadNewReleases() async {
        isLoadingCategory = true

        do {
            // Use trending as a proxy for new releases
            let response = try await tmdbService.fetchTrending(page: 1)
            // Filter to only recent releases (last 6 months)
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            categoryMovies = response.results.filter { movie in
                guard let releaseDateStr = movie.releaseDate,
                      let releaseDate = dateFormatter.date(from: releaseDateStr) else {
                    return false
                }
                return releaseDate >= sixMonthsAgo
            }
            isLoadingCategory = false
        } catch {
            isLoadingCategory = false
        }
    }

    /// Load classic movies (before 2000 with high ratings)
    private func loadClassics() async {
        isLoadingCategory = true

        do {
            // Use top rated and filter by year
            let response = try await tmdbService.fetchTopRated(page: 1)
            categoryMovies = response.results.filter { movie in
                guard let releaseDate = movie.releaseDate,
                      let year = Int(releaseDate.prefix(4)) else {
                    return false
                }
                return year < 2000
            }
            isLoadingCategory = false
        } catch {
            isLoadingCategory = false
        }
    }

    /// Load movies by genre ID
    private func loadByGenre(_ genreIds: [Int]) async {
        isLoadingCategory = true

        // For now, filter existing movies. Future: Use discover API with genre filter
        let allMovies = trendingMovies + popularMovies + topRatedMovies
        let uniqueMovies = Array(Set(allMovies))

        categoryMovies = uniqueMovies.filter { movie in
            let movieGenres = movie.genreIds
            guard !movieGenres.isEmpty else { return false }
            return !Set(movieGenres).isDisjoint(with: Set(genreIds))
        }.sorted { ($0.voteAverage) > ($1.voteAverage) }

        isLoadingCategory = false
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension DiscoverViewModel {
    static func mock() -> DiscoverViewModel {
        let viewModel = DiscoverViewModel(
            tmdbService: .shared,
            watchlistManager: .mock()
        )
        viewModel.trendingMovies = Movie.samples
        viewModel.popularMovies = Movie.samples
        viewModel.topRatedMovies = Movie.samples
        return viewModel
    }
}
#endif
