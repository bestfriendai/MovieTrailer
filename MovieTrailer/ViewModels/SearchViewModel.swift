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
    
    /// Clear search
    func clearSearch() {
        searchTask?.cancel()
        searchQuery = ""
        searchResults = []
        error = nil
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
