//
//  TabCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI
import Combine

/// Coordinator for managing the main tab bar
@MainActor
final class TabCoordinator: ObservableObject, TabCoordinatorProtocol {
    
    // MARK: - Published Properties
    
    @Published var selectedTab: Int = 0
    @Published var childCoordinators: [any Coordinator] = []
    
    // MARK: - Dependencies
    
    let tmdbService: TMDBService
    let watchlistManager: WatchlistManager
    let liveActivityManager: LiveActivityManager
    
    // MARK: - Child Coordinators
    
    private(set) var discoverCoordinator: DiscoverCoordinator?
    private(set) var tonightCoordinator: TonightCoordinator?
    private(set) var searchCoordinator: SearchCoordinator?
    private(set) var watchlistCoordinator: WatchlistCoordinator?
    
    // MARK: - Tab Enum
    
    enum Tab: Int, CaseIterable {
        case discover = 0
        case tonight = 1
        case search = 2
        case watchlist = 3
        
        var title: String {
            switch self {
            case .discover: return "Discover"
            case .tonight: return "Tonight"
            case .search: return "Search"
            case .watchlist: return "Watchlist"
            }
        }
        
        var icon: String {
            switch self {
            case .discover: return "film"
            case .tonight: return "star.circle"
            case .search: return "magnifyingglass"
            case .watchlist: return "bookmark"
            }
        }
        
        var iconFilled: String {
            switch self {
            case .discover: return "film.fill"
            case .tonight: return "star.circle.fill"
            case .search: return "magnifyingglass"
            case .watchlist: return "bookmark.fill"
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
        
        // Initialize child coordinators immediately
        self.discoverCoordinator = DiscoverCoordinator(
            tmdbService: tmdbService,
            watchlistManager: watchlistManager
        )
        
        self.tonightCoordinator = TonightCoordinator(
            tmdbService: tmdbService,
            watchlistManager: watchlistManager
        )
        
        self.searchCoordinator = SearchCoordinator(
            tmdbService: tmdbService,
            watchlistManager: watchlistManager
        )
        
        self.watchlistCoordinator = WatchlistCoordinator(
            watchlistManager: watchlistManager,
            liveActivityManager: liveActivityManager,
            tmdbService: tmdbService
        )
    }
    
    // MARK: - Coordinator Protocol
    
    var body: some View {
        TabView(selection: Binding(
            get: { self.selectedTab },
            set: { self.selectedTab = $0 }
        )) {
            // Discover Tab
            discoverTab()
                .tabItem {
                    Label(Tab.discover.title, systemImage: selectedTab == Tab.discover.rawValue ? Tab.discover.iconFilled : Tab.discover.icon)
                }
                .tag(Tab.discover.rawValue)
            
            // Tonight Tab
            tonightTab()
                .tabItem {
                    Label(Tab.tonight.title, systemImage: selectedTab == Tab.tonight.rawValue ? Tab.tonight.iconFilled : Tab.tonight.icon)
                }
                .tag(Tab.tonight.rawValue)
            
            // Search Tab
            searchTab()
                .tabItem {
                    Label(Tab.search.title, systemImage: Tab.search.icon)
                }
                .tag(Tab.search.rawValue)
            
            // Watchlist Tab
            watchlistTab()
                .tabItem {
                    Label(Tab.watchlist.title, systemImage: selectedTab == Tab.watchlist.rawValue ? Tab.watchlist.iconFilled : Tab.watchlist.icon)
                }
                .tag(Tab.watchlist.rawValue)
        }
        .onAppear {
            self.start()
        }
    }
    
    func start() {
        // Add coordinators to child array
        if let discover = discoverCoordinator { addChild(discover) }
        if let tonight = tonightCoordinator { addChild(tonight) }
        if let search = searchCoordinator { addChild(search) }
        if let watchlist = watchlistCoordinator { addChild(watchlist) }
    }
    
    func finish() {
        removeAllChildren()
    }

    // MARK: - Tab Selection

    /// Select a specific tab
    func selectTab(_ tab: Tab) {
        selectedTab = tab.rawValue
    }

    /// Select tab by index
    func selectTab(index: Int) {
        guard index >= 0 && index < Tab.allCases.count else { return }
        selectedTab = index
    }

    // MARK: - Tab Views
    
    @ViewBuilder
    private func discoverTab() -> some View {
        if let coordinator = discoverCoordinator {
            coordinator.body
        } else {
            placeholderView(for: .discover)
        }
    }
    
    @ViewBuilder
    private func tonightTab() -> some View {
        if let coordinator = tonightCoordinator {
            coordinator.body
        } else {
            placeholderView(for: .tonight)
        }
    }
    
    @ViewBuilder
    private func searchTab() -> some View {
        if let coordinator = searchCoordinator {
            coordinator.body
        } else {
            placeholderView(for: .search)
        }
    }
    
    @ViewBuilder
    private func watchlistTab() -> some View {
        if let coordinator = watchlistCoordinator {
            coordinator.body
        } else {
            placeholderView(for: .watchlist)
        }
    }
    
    // MARK: - Placeholder
    
    private func placeholderView(for tab: Tab) -> some View {
        VStack(spacing: 20) {
            Image(systemName: tab.iconFilled)
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(tab.title)
                .font(.title.bold())
            
            Text("Coming soon...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}
