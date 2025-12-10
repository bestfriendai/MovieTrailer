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
    
    @Published var isLoadingTrending = false
    @Published var isLoadingPopular = false
    @Published var isLoadingTopRated = false
    
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
    
    /// Load all discover content
    func loadContent() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTrending() }
            group.addTask { await self.loadPopular() }
            group.addTask { await self.loadTopRated() }
        }
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
