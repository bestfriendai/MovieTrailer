//
//  DiscoverCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI
import Combine

/// Coordinator for the Discover tab
@MainActor
final class DiscoverCoordinator: ObservableObject, NavigationCoordinator {
    
    // MARK: - Published Properties
    
    @Published var navigationPath = NavigationPath()
    @Published var selectedMovie: Movie?
    @Published var showingMovieDetail = false
    
    // MARK: - Dependencies
    
    let tmdbService: TMDBService
    let watchlistManager: WatchlistManager
    
    // MARK: - Initialization
    
    init(tmdbService: TMDBService, watchlistManager: WatchlistManager) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
    }
    
    // MARK: - Coordinator Protocol
    
    var body: some View {
        DiscoverCoordinatorView(coordinator: self)
    }
    
    func start() {
        // Initialize if needed
    }
    
    // MARK: - Navigation
    
    func showMovieDetail(for movie: Movie) {
        print("🎬 DiscoverCoordinator: Showing detail for \(movie.title)")
        selectedMovie = movie
        showingMovieDetail = true
    }
}

// MARK: - Coordinator View Wrapper

struct DiscoverCoordinatorView: View {
    @ObservedObject var coordinator: DiscoverCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            DiscoverView(
                viewModel: DiscoverViewModel(
                    tmdbService: coordinator.tmdbService,
                    watchlistManager: coordinator.watchlistManager
                ),
                onMovieTap: { movie in
                    print("🎬 DiscoverView: Movie tapped - \(movie.title)")
                    coordinator.showMovieDetail(for: movie)
                }
            )
        }
        .fullScreenCover(isPresented: $coordinator.showingMovieDetail) {
            if let movie = coordinator.selectedMovie {
                MovieDetailView(
                    movie: movie,
                    isInWatchlist: coordinator.watchlistManager.contains(movie),
                    onWatchlistToggle: {
                        coordinator.watchlistManager.toggle(movie)
                    },
                )
            }
        }
    }
}
