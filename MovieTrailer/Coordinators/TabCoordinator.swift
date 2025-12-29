//
//  TabCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//  Redesigned with Apple TV aesthetic by Claude Code on 29/12/2025.
//  Phase 3: Refactored navigation - removed NotificationCenter
//

import SwiftUI
import Combine

/// Coordinator for managing the main tab bar with Apple TV design
@MainActor
final class TabCoordinator: ObservableObject, TabCoordinatorProtocol {

    // MARK: - Published Properties

    @Published var selectedTab: Int = 0
    @Published var childCoordinators: [any Coordinator] = []

    // Navigation state
    @Published var selectedMovie: Movie?
    @Published var showMovieDetailSheet = false
    @Published var shouldPlayTrailer = false

    // Search state for deep link support
    @Published var pendingSearchQuery: String?

    // Loading state for movie fetch
    @Published var isLoadingMovie = false

    // MARK: - Navigation Router

    let router = NavigationRouter()

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
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            coordinator.homeTabView
                .tabItem {
                    Label(
                        TabCoordinator.Tab.home.title,
                        systemImage: selectedTab == 0
                            ? TabCoordinator.Tab.home.iconFilled
                            : TabCoordinator.Tab.home.icon
                    )
                }
                .tag(0)

            // Swipe Tab
            coordinator.swipeTabView
                .tabItem {
                    Label(
                        TabCoordinator.Tab.swipe.title,
                        systemImage: selectedTab == 1
                            ? TabCoordinator.Tab.swipe.iconFilled
                            : TabCoordinator.Tab.swipe.icon
                    )
                }
                .tag(1)

            // Search Tab
            coordinator.searchTabView
                .tabItem {
                    Label(
                        TabCoordinator.Tab.search.title,
                        systemImage: TabCoordinator.Tab.search.icon
                    )
                }
                .tag(2)

            // Library Tab
            coordinator.libraryTabView
                .tabItem {
                    Label(
                        TabCoordinator.Tab.library.title,
                        systemImage: selectedTab == 3
                            ? TabCoordinator.Tab.library.iconFilled
                            : TabCoordinator.Tab.library.icon
                    )
                }
                .tag(3)
        }
        .tint(.white)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $coordinator.showMovieDetailSheet) {
            if let movie = coordinator.selectedMovie {
                MovieDetailView(
                    movie: movie,
                    isInWatchlist: coordinator.watchlistManager.contains(movie),
                    onWatchlistToggle: {
                        coordinator.toggleWatchlist(for: movie)
                    },
                    onClose: {
                        coordinator.dismissMovieDetail()
                    },
                    tmdbService: coordinator.tmdbService
                )
            }
        }
        .onChange(of: selectedTab) { _, newValue in
            coordinator.selectedTab = newValue
            Haptics.shared.selectionChanged()
        }
        .onAppear {
            // Native iOS liquid glass tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            appearance.backgroundColor = UIColor.black.withAlphaComponent(0.2)

            // Tab item colors
            appearance.stackedLayoutAppearance.selected.iconColor = .white
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.6)]

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
            },
            onPlayTrailer: { movie in
                self.playTrailer(movie)
            }
        )
    }

    var searchTabView: some View {
        SearchViewWrapper(
            coordinator: self,
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
        Haptics.shared.lightImpact()
        selectedMovie = movie
        shouldPlayTrailer = false
        showMovieDetailSheet = true
    }

    func playTrailer(_ movie: Movie) {
        Haptics.shared.lightImpact()
        selectedMovie = movie
        shouldPlayTrailer = true
        showMovieDetailSheet = true
    }

    func dismissMovieDetail() {
        showMovieDetailSheet = false
        selectedMovie = nil
        shouldPlayTrailer = false
    }

    func toggleWatchlist(for movie: Movie) {
        if watchlistManager.contains(movie) {
            watchlistManager.remove(movie)
            Haptics.shared.lightImpact()
        } else {
            watchlistManager.add(movie)
            Haptics.shared.success()
        }
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

    // MARK: - Deep Link Navigation

    /// Navigate to movie detail by ID (fetches movie data first)
    func navigateToMovie(id: Int) async {
        print("📱 TabCoordinator: Navigating to movie ID: \(id)")

        isLoadingMovie = true

        do {
            let movie = try await tmdbService.fetchMovieDetails(id: id)
            isLoadingMovie = false
            showMovieDetail(movie)
        } catch {
            isLoadingMovie = false
            print("❌ Failed to fetch movie \(id): \(error.localizedDescription)")
        }
    }

    /// Perform search with query (switches to search tab)
    func performSearch(query: String) {
        print("📱 TabCoordinator: Performing search for: \(query)")

        selectTab(.search)
        pendingSearchQuery = query
    }

    /// Clear pending search query after it's been consumed
    func clearPendingSearchQuery() {
        pendingSearchQuery = nil
    }
}

// MARK: - Search View Wrapper

/// Wrapper view that handles deep link search queries
struct SearchViewWrapper: View {
    @ObservedObject var coordinator: TabCoordinator
    let onMovieTap: (Movie) -> Void

    @StateObject private var viewModel: SearchViewModel

    init(coordinator: TabCoordinator, onMovieTap: @escaping (Movie) -> Void) {
        self.coordinator = coordinator
        self.onMovieTap = onMovieTap
        _viewModel = StateObject(wrappedValue: SearchViewModel(
            tmdbService: coordinator.tmdbService,
            watchlistManager: coordinator.watchlistManager
        ))
    }

    var body: some View {
        SearchView(viewModel: viewModel, onMovieTap: onMovieTap)
            .onChange(of: coordinator.pendingSearchQuery) { _, newQuery in
                if let query = newQuery, !query.isEmpty {
                    viewModel.searchQuery = query
                    viewModel.search()
                    coordinator.clearPendingSearchQuery()
                }
            }
    }
}
