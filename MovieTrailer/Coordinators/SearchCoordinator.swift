//
//  SearchCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI
import Combine

/// Coordinator for the Search tab
@MainActor
final class SearchCoordinator: ObservableObject, NavigationCoordinator {
    
    // MARK: - Published Properties
    
    @Published var navigationPath = NavigationPath()
    
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
    
    func showMovieDetail(for movie: Movie) {
        navigate(to: movie)
    }
    
    // MARK: - Placeholder
    
    private func placeholderView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Search")
                .font(.title.bold())
            
            Text("Find your favorite movies")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Search")
    }
}
