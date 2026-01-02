//
//  SearchViewModel.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import Foundation
import Combine

/// ViewModel for the Search tab
@MainActor
final class SearchViewModel: ObservableObject {
    
    // MARK: - Published Properties

    @Published var searchQuery = ""
    @Published var searchResults: [Movie] = []
    @Published var isSearching = false
    @Published var error: NetworkError?
    @Published var trendingSearches: [String] = []
    @Published var isLoadingTrending = false

    // MARK: - Dependencies

    private let tmdbService: TMDBService
    private let watchlistManager: WatchlistManager

    // MARK: - Private Properties

    private var searchTask: Task<Void, Never>?

    // MARK: - Initialization

    init(tmdbService: TMDBService, watchlistManager: WatchlistManager) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
    }

    // MARK: - Trending Searches

    /// Load trending movie titles for search suggestions
    func loadTrendingSearches() async {
        guard trendingSearches.isEmpty else { return }
        isLoadingTrending = true

        do {
            let response = try await tmdbService.fetchTrending(page: 1)
            // Extract unique movie titles from trending
            let titles = response.results.prefix(10).map { $0.title }
            trendingSearches = Array(Set(titles)).prefix(8).map { $0 }
            isLoadingTrending = false
        } catch {
            // Fallback to popular searches if trending fails
            trendingSearches = ["Avatar", "Dune", "Marvel", "Star Wars", "Batman", "Spider-Man", "Action", "Comedy"]
            isLoadingTrending = false
        }
    }
    
    // MARK: - Public Methods
    
    /// Perform search with debouncing
    func search() {
        // Cancel previous search
        searchTask?.cancel()
        
        // Clear results if query is empty
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        
        // Debounce search
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            
            guard !Task.isCancelled else { return }
            
            await performSearch()
        }
    }
    
    /// Perform the actual search
    private func performSearch() async {
        isSearching = true
        error = nil
        
        do {
            let response = try await tmdbService.searchMovies(
                query: searchQuery,
                page: 1
            )
            // Sort results by popularity for better relevance
            searchResults = response.results.sorted { $0.popularity > $1.popularity }
            isSearching = false
        } catch let networkError as NetworkError {
            error = networkError
            isSearching = false
        } catch {
            self.error = .unknown
            isSearching = false
        }
    }
    
    /// Clear search
    func clearSearch() {
        searchTask?.cancel()
        searchQuery = ""
        searchResults = []
        error = nil
    }

    // MARK: - Quick Actions (Direct TMDB Endpoints)

    /// Fetch trending movies directly from TMDB trending endpoint
    func fetchTrending() async {
        isSearching = true
        error = nil
        searchQuery = "Trending Now"

        do {
            let response = try await tmdbService.fetchTrending(page: 1)
            searchResults = response.results
            isSearching = false
        } catch let networkError as NetworkError {
            error = networkError
            isSearching = false
        } catch {
            self.error = .unknown
            isSearching = false
        }
    }

    /// Fetch new releases from TMDB discover endpoint
    func fetchNewReleases() async {
        isSearching = true
        error = nil
        searchQuery = "New Releases"

        do {
            let response = try await tmdbService.fetchRecentMovies(page: 1)
            searchResults = response.results
            isSearching = false
        } catch let networkError as NetworkError {
            error = networkError
            isSearching = false
        } catch {
            self.error = .unknown
            isSearching = false
        }
    }

    /// Fetch top rated movies from TMDB top-rated endpoint
    func fetchTopRated() async {
        isSearching = true
        error = nil
        searchQuery = "Top Rated"

        do {
            let response = try await tmdbService.fetchTopRated(page: 1)
            searchResults = response.results
            isSearching = false
        } catch let networkError as NetworkError {
            error = networkError
            isSearching = false
        } catch {
            self.error = .unknown
            isSearching = false
        }
    }

    /// Fetch upcoming movies from TMDB upcoming endpoint
    func fetchUpcoming() async {
        isSearching = true
        error = nil
        searchQuery = "Coming Soon"

        do {
            let response = try await tmdbService.fetchUpcoming(page: 1)
            searchResults = response.results
            isSearching = false
        } catch let networkError as NetworkError {
            error = networkError
            isSearching = false
        } catch {
            self.error = .unknown
            isSearching = false
        }
    }

    /// Fetch movies by genre from TMDB discover endpoint
    func fetchByGenre(_ genreId: Int, genreName: String) async {
        isSearching = true
        error = nil
        searchQuery = genreName

        do {
            let response = try await tmdbService.fetchMoviesByGenre(genreId, page: 1)
            searchResults = response.results
            isSearching = false
        } catch let networkError as NetworkError {
            error = networkError
            isSearching = false
        } catch {
            self.error = .unknown
            isSearching = false
        }
    }

    /// Fetch movies available on a streaming provider using TMDB discover API
    func fetchByStreamingProvider(_ providerId: Int, providerName: String) async {
        isSearching = true
        error = nil
        searchQuery = providerName

        do {
            var filters = DiscoverFilters()
            filters.withWatchProviders = [providerId]
            filters.watchRegion = "US"
            filters.sortBy = .popularityDesc
            
            let response = try await tmdbService.discoverMovies(filters: filters)
            searchResults = response.results
            isSearching = false
        } catch let networkError as NetworkError {
            error = networkError
            isSearching = false
        } catch {
            self.error = .unknown
            isSearching = false
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
}

// MARK: - Preview Helpers

#if DEBUG
extension SearchViewModel {
    static func mock() -> SearchViewModel {
        let viewModel = SearchViewModel(
            tmdbService: .shared,
            watchlistManager: .mock()
        )
        viewModel.searchResults = Movie.samples
        return viewModel
    }
}
#endif
