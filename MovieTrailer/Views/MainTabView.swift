//
//  MainTabView.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Implemented by Claude Code Audit on 28/12/2025.
//

import SwiftUI

/// Main tab bar view for app navigation
struct MainTabView: View {

    // MARK: - Properties

    @State private var selectedTab: Tab = .discover
    @State private var tabBarVisible = true

    // Injected dependencies
    let tmdbService: TMDBService
    let watchlistManager: WatchlistManager

    // Navigation callbacks
    var onMovieTap: ((Movie) -> Void)?

    // MARK: - Tab Definition

    enum Tab: String, CaseIterable {
        case discover = "Discover"
        case tonight = "Tonight"
        case search = "Search"
        case watchlist = "Watchlist"

        var icon: String {
            switch self {
            case .discover: return "sparkles"
            case .tonight: return "moon.stars"
            case .search: return "magnifyingglass"
            case .watchlist: return "bookmark"
            }
        }

        var selectedIcon: String {
            switch self {
            case .discover: return "sparkles"
            case .tonight: return "moon.stars.fill"
            case .search: return "magnifyingglass"
            case .watchlist: return "bookmark.fill"
            }
        }

        var color: Color {
            switch self {
            case .discover: return .purple
            case .tonight: return .orange
            case .search: return .blue
            case .watchlist: return .pink
            }
        }
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            // Discover Tab
            discoverTab
                .tabItem {
                    Label(Tab.discover.rawValue, systemImage: selectedTab == .discover ? Tab.discover.selectedIcon : Tab.discover.icon)
                }
                .tag(Tab.discover)

            // Tonight Tab
            tonightTab
                .tabItem {
                    Label(Tab.tonight.rawValue, systemImage: selectedTab == .tonight ? Tab.tonight.selectedIcon : Tab.tonight.icon)
                }
                .tag(Tab.tonight)

            // Search Tab
            searchTab
                .tabItem {
                    Label(Tab.search.rawValue, systemImage: selectedTab == .search ? Tab.search.selectedIcon : Tab.search.icon)
                }
                .tag(Tab.search)

            // Watchlist Tab
            watchlistTab
                .tabItem {
                    Label(Tab.watchlist.rawValue, systemImage: selectedTab == .watchlist ? Tab.watchlist.selectedIcon : Tab.watchlist.icon)
                }
                .tag(Tab.watchlist)
        }
        .tint(.primary)
        .onChange(of: selectedTab) { _, newTab in
            HapticManager.shared.lightImpact()
        }
    }

    // MARK: - Tab Views

    private var discoverTab: some View {
        NavigationStack {
            DiscoverView(
                viewModel: DiscoverViewModel(
                    tmdbService: tmdbService,
                    watchlistManager: watchlistManager
                ),
                onMovieTap: { movie in
                    onMovieTap?(movie)
                }
            )
        }
    }

    private var tonightTab: some View {
        NavigationStack {
            TonightView(
                viewModel: TonightViewModel(
                    tmdbService: tmdbService,
                    watchlistManager: watchlistManager
                ),
                onMovieTap: { movie in
                    onMovieTap?(movie)
                }
            )
        }
    }

    private var searchTab: some View {
        NavigationStack {
            SearchView(
                viewModel: SearchViewModel(
                    tmdbService: tmdbService,
                    watchlistManager: watchlistManager
                ),
                onMovieTap: { movie in
                    onMovieTap?(movie)
                }
            )
        }
    }

    private var watchlistTab: some View {
        NavigationStack {
            WatchlistView(
                viewModel: WatchlistViewModel(
                    watchlistManager: watchlistManager
                ),
                onItemTap: { item in
                    // Convert WatchlistItem to Movie for navigation
                    let movie = item.toMovie()
                    onMovieTap?(movie)
                }
            )
        }
    }
}

// MARK: - Custom Tab Bar (Alternative)

struct CustomTabBar: View {

    @Binding var selectedTab: MainTabView.Tab
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
    }

    private func tabButton(for tab: MainTabView.Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                HapticManager.shared.lightImpact()
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == tab {
                        Circle()
                            .fill(tab.color.opacity(0.2))
                            .frame(width: 48, height: 48)
                            .matchedGeometryEffect(id: "background", in: animation)
                    }

                    Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? tab.color : .secondary)
                }

                Text(tab.rawValue)
                    .font(.caption2)
                    .fontWeight(selectedTab == tab ? .semibold : .regular)
                    .foregroundColor(selectedTab == tab ? tab.color : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }
}

// MARK: - Floating Tab Bar

struct FloatingTabBar: View {

    @Binding var selectedTab: MainTabView.Tab

    var body: some View {
        HStack(spacing: 20) {
            ForEach(MainTabView.Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        HapticManager.shared.lightImpact()
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                            .foregroundColor(selectedTab == tab ? tab.color : .gray)
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)

                        if selectedTab == tab {
                            Circle()
                                .fill(tab.color)
                                .frame(width: 5, height: 5)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(width: 60)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
            Capsule()
                .fill(.ultraThickMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - Tab Bar Badge

struct TabBarBadge: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.caption2.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.red)
                )
                .offset(x: 12, y: -8)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(
            tmdbService: .shared,
            watchlistManager: WatchlistManager()
        )

        // Custom tab bar preview
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(.discover))
        }
        .previewDisplayName("Custom Tab Bar")

        // Floating tab bar preview
        VStack {
            Spacer()
            FloatingTabBar(selectedTab: .constant(.tonight))
                .padding(.bottom, 30)
        }
        .previewDisplayName("Floating Tab Bar")
    }
}
#endif
