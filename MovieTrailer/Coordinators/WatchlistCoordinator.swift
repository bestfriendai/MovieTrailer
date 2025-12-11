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
    
    // MARK: - Dependencies
    
    let watchlistManager: WatchlistManager
    let liveActivityManager: LiveActivityManager
    
    // MARK: - Initialization
    
    init(
        watchlistManager: WatchlistManager,
        liveActivityManager: LiveActivityManager
    ) {
        self.watchlistManager = watchlistManager
        self.liveActivityManager = liveActivityManager
    }
    
    // MARK: - Coordinator Protocol
    
    var body: some View {
        NavigationStack(path: Binding(
            get: { self.navigationPath },
            set: { self.navigationPath = $0 }
        )) {
            placeholderView()
        }
    }
    
    func start() {
        // Initialize if needed
    }
    
    // MARK: - Navigation
    
    func showMovieDetail(for item: WatchlistItem) {
        let movie = item.toMovie()
        navigate(to: movie)
    }
    
    func shareWatchlist() {
        showingShareSheet = true
    }
    
    // MARK: - View
    
    private func placeholderView() -> some View {
        let viewModel = WatchlistViewModel(
            watchlistManager: watchlistManager,
            liveActivityManager: liveActivityManager
        )
        return WatchlistView(viewModel: viewModel)
    }
}
