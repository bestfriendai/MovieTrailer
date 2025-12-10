//
//  AppCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI

/// Root coordinator for the entire app
@MainActor
final class AppCoordinator: ObservableObject {
    
    // MARK: - Dependencies
    
    /// Shared TMDB service
    let tmdbService: TMDBService
    
    /// Shared watchlist manager
    let watchlistManager: WatchlistManager
    
    /// Shared Live Activity manager
    let liveActivityManager: LiveActivityManager
    
    // MARK: - Child Coordinators
    
    private(set) var tabCoordinator: TabCoordinator?
    
    // MARK: - Initialization
    
    init(
        tmdbService: TMDBService = .shared,
        watchlistManager: WatchlistManager = WatchlistManager(),
        liveActivityManager: LiveActivityManager = .shared
    ) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
        self.liveActivityManager = liveActivityManager
    }
    
    // MARK: - Public Methods
    
    /// Start the app coordinator
    func start() -> some View {
        let tabCoordinator = TabCoordinator(
            tmdbService: tmdbService,
            watchlistManager: watchlistManager,
            liveActivityManager: liveActivityManager
        )
        self.tabCoordinator = tabCoordinator
        
        return tabCoordinator.body
    }
    
    /// Handle deep link
    func handleDeepLink(_ url: URL) {
        // Handle deep links here
        // Example: movietrailer://movie/123
        print("📱 Deep link received: \(url)")
    }
}
