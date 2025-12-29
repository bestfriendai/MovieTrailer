//
//  TabCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//  Redesigned with Apple TV aesthetic by Claude Code on 29/12/2025.
//

import SwiftUI
import Combine

/// Coordinator for managing the main tab bar with Apple TV design
@MainActor
final class TabCoordinator: ObservableObject, TabCoordinatorProtocol {

    // MARK: - Published Properties

    @Published var selectedTab: Int = 0
    @Published var childCoordinators: [any Coordinator] = []

    // MARK: - Dependencies

    let tmdbService: TMDBService
    let watchlistManager: WatchlistManager
    let liveActivityManager: LiveActivityManager

    // MARK: - Tab Enum

    enum Tab: Int, CaseIterable {
        case home = 0
        case swipe = 1
        case search = 2
        case library = 3

        var title: String {
            switch self {
            case .home: return "Home"
            case .swipe: return "Swipe"
            case .search: return "Search"
            case .library: return "Library"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house"
            case .swipe: return "rectangle.stack"
            case .search: return "magnifyingglass"
            case .library: return "books.vertical"
            }
        }

        var iconFilled: String {
            switch self {
            case .home: return "house.fill"
            case .swipe: return "rectangle.stack.fill"
            case .search: return "magnifyingglass"
            case .library: return "books.vertical.fill"
            }
        }
    }

    // MARK: - Initialization

    init(
        tmdbService: TMDBService,
        watchlistManager: WatchlistManager,
        liveActivityManager: LiveActivityManager
    ) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
        self.liveActivityManager = liveActivityManager
    }

    // MARK: - Coordinator Protocol

    var body: some View {
        TabCoordinatorView(coordinator: self)
    }
}

// MARK: - Tab Coordinator View

struct TabCoordinatorView: View {
    @ObservedObject var coordinator: TabCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            // Home Tab
            coordinator.homeTabView
                .tabItem {
                    Label(
                        TabCoordinator.Tab.home.title,
                        systemImage: coordinator.selectedTab == 0
                            ? TabCoordinator.Tab.home.iconFilled
                            : TabCoordinator.Tab.home.icon
                    )
                }
                .tag(TabCoordinator.Tab.home.rawValue)

            // Swipe Tab
            coordinator.swipeTabView
                .tabItem {
                    Label(
                        TabCoordinator.Tab.swipe.title,
                        systemImage: coordinator.selectedTab == 1
                            ? TabCoordinator.Tab.swipe.iconFilled
                            : TabCoordinator.Tab.swipe.icon
                    )
                }
                .tag(TabCoordinator.Tab.swipe.rawValue)

            // Search Tab
            coordinator.searchTabView
                .tabItem {
                    Label(
                        TabCoordinator.Tab.search.title,
                        systemImage: TabCoordinator.Tab.search.icon
                    )
                }
                .tag(TabCoordinator.Tab.search.rawValue)

            // Library Tab
            coordinator.libraryTabView
                .tabItem {
                    Label(
                        TabCoordinator.Tab.library.title,
                        systemImage: coordinator.selectedTab == 3
                            ? TabCoordinator.Tab.library.iconFilled
                            : TabCoordinator.Tab.library.icon
                    )
                }
                .tag(TabCoordinator.Tab.library.rawValue)
        }
        .tint(.white)
        .preferredColorScheme(.dark)
        .onAppear {
            // Dark tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance

            coordinator.start()
        }
    }
}

extension TabCoordinator {

    // MARK: - Tab Views

    var homeTabView: some View {
        HomeView(
            viewModel: HomeViewModel(
                tmdbService: tmdbService,
                watchlistManager: watchlistManager
            ),
            onMovieTap: { movie in
                self.showMovieDetail(movie)
            },
            onPlayTrailer: { movie in
                self.playTrailer(movie)
            }
        )
    }

    var swipeTabView: some View {
        MovieSwipeView(
            viewModel: MovieSwipeViewModel(
                tmdbService: tmdbService,
                watchlistManager: watchlistManager
            ),
            onMovieTap: { movie in
                self.showMovieDetail(movie)
            }
        )
    }

    var searchTabView: some View {
        SearchView(
            viewModel: SearchViewModel(
                tmdbService: tmdbService,
                watchlistManager: watchlistManager
            ),
            onMovieTap: { movie in
                self.showMovieDetail(movie)
            }
        )
    }

    var libraryTabView: some View {
        WatchlistView(
            viewModel: WatchlistViewModel(
                watchlistManager: watchlistManager,
                liveActivityManager: liveActivityManager
            ),
            onItemTap: { item in
                let movie = item.toMovie()
                self.showMovieDetail(movie)
            }
        )
    }

    // MARK: - Navigation Helpers

    func showMovieDetail(_ movie: Movie) {
        NotificationCenter.default.post(
            name: .showMovieDetail,
            object: nil,
            userInfo: ["movieId": movie.id]
        )
    }

    func playTrailer(_ movie: Movie) {
        NotificationCenter.default.post(
            name: .showMovieDetail,
            object: nil,
            userInfo: ["movieId": movie.id, "playTrailer": true]
        )
    }

    func start() {
        // Initialization complete
    }

    func finish() {
        removeAllChildren()
    }

    // MARK: - Tab Selection

    func switchToTab(_ index: Int) {
        selectedTab = index
    }

    /// Select a specific tab
    func selectTab(_ tab: Tab) {
        selectedTab = tab.rawValue
    }

    /// Select tab by index
    func selectTab(index: Int) {
        selectedTab = index
    }
}
