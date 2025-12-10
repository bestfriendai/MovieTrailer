//
//  WatchlistCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI

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
        NavigationStack(path: $navigationPath) {
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
    
    // MARK: - Placeholder
    
    private func placeholderView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "bookmark.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Watchlist")
                .font(.title.bold())
            
            Text("Your saved movies")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !watchlistManager.isEmpty {
                Text("\(watchlistManager.count) movies")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Watchlist")
        .toolbar {
            if !watchlistManager.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        shareWatchlist()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
