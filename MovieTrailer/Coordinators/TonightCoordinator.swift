//
//  TonightCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI
import Combine

/// Coordinator for the Tonight recommendation tab
@MainActor
final class TonightCoordinator: ObservableObject, NavigationCoordinator {
    
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
    
    // MARK: - View
    
    private func placeholderView() -> some View {
        let viewModel = TonightViewModel(
            tmdbService: tmdbService,
            watchlistManager: watchlistManager
        )
        return TonightView(viewModel: viewModel)
    }
}
