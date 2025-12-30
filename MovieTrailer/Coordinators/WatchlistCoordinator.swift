//
//  WatchlistCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI
import Combine

/// Coordinator for the Watchlist tab
@MainActor
final class WatchlistCoordinator: ObservableObject, NavigationCoordinator {
    
    // MARK: - Published Properties
    
    @Published var navigationPath = NavigationPath()
    @Published var showingShareSheet = false
    @Published var selectedMovie: Movie?
    @Published var showingMovieDetail = false
    
    // MARK: - Dependencies
    
    let watchlistManager: WatchlistManager
    let liveActivityManager: LiveActivityManager
    let tmdbService: TMDBService
    
    // MARK: - Initialization
    
    init(
        watchlistManager: WatchlistManager,
        liveActivityManager: LiveActivityManager,
        tmdbService: TMDBService
    ) {
        self.watchlistManager = watchlistManager
        self.liveActivityManager = liveActivityManager
        self.tmdbService = tmdbService
    }
    
    // MARK: - Coordinator Protocol
    
    var body: some View {
        WatchlistCoordinatorView(coordinator: self)
    }
    
    func start() {
        // Initialize if needed
    }
    
    // MARK: - Navigation
    
    func showMovieDetail(for item: WatchlistItem) {
        selectedMovie = item.toMovie()
        showingMovieDetail = true
    }
    
    func shareWatchlist() {
        showingShareSheet = true
    }
}

// MARK: - Coordinator View Wrapper

struct WatchlistCoordinatorView: View {
    @ObservedObject var coordinator: WatchlistCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            WatchlistView(
                viewModel: WatchlistViewModel(
                    watchlistManager: coordinator.watchlistManager,
                    liveActivityManager: coordinator.liveActivityManager
                ),
                onItemTap: { item in
                    coordinator.showMovieDetail(for: item)
                },
                onBrowseMovies: {
                    // Tab switching handled by parent TabCoordinator
                },
                onDiscover: {
                    // Tab switching handled by parent TabCoordinator
                }
            )
        }
        .fullScreenCover(isPresented: $coordinator.showingMovieDetail) {
            if let movie = coordinator.selectedMovie {
                MovieDetailView(
                    movie: movie,
                    isInWatchlist: true, // Always true for watchlist items
                    onWatchlistToggle: {
                        coordinator.watchlistManager.toggle(movie)
                        // If removed, detail view stays open but state changes
                    },
                    onClose: {
                        coordinator.showingMovieDetail = false
                    },
                    tmdbService: coordinator.tmdbService
                )
            }
        }
    }
}
