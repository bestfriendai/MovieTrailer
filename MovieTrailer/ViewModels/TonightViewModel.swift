//
//  TonightViewModel.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import Foundation
import Combine

/// ViewModel for the "What to Watch Tonight" recommendation engine
@MainActor
final class TonightViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var recommendations: [Movie] = []
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
    
    /// Generate personalized recommendations
    func generateRecommendations() async {
        isLoading = true
        error = nil
        
        do {
            // Get user's top genres from watchlist
            let topGenres = watchlistManager.topGenres(limit: 3)
            
            // Fetch trending movies
            let trendingResponse = try await tmdbService.fetchTrending(page: 1)
            
            // Fetch popular movies
            let popularResponse = try await tmdbService.fetchPopular(page: 1)
            
            // Combine and filter
            var allMovies = trendingResponse.results + popularResponse.results
            
            // Remove duplicates
            allMovies = Array(Set(allMovies))
            
            // Filter by user's preferred genres if available
            if !topGenres.isEmpty {
                allMovies = allMovies.filter { movie in
                    !Set(movie.genreIds).isDisjoint(with: Set(topGenres))
                }
            }
            
            // Remove movies already in watchlist
            allMovies = allMovies.filter { !watchlistManager.contains($0) }
            
            // Sort by rating and take top 12
            recommendations = allMovies
                .sorted { $0.voteAverage > $1.voteAverage }
                .prefix(12)
                .map { $0 }
            
            isLoading = false
        } catch let networkError as NetworkError {
            error = networkError
            isLoading = false
        } catch {
            self.error = .unknown
            isLoading = false
        }
    }
    
    /// Refresh recommendations
    func refresh() async {
        await generateRecommendations()
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
extension TonightViewModel {
    static func mock() -> TonightViewModel {
        let viewModel = TonightViewModel(
            tmdbService: .shared,
            watchlistManager: .mock()
        )
        viewModel.recommendations = Movie.samples
        return viewModel
    }
}
#endif
