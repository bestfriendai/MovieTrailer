//
//  GlassTabBar.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Floating glass-effect tab bar
//

import SwiftUI

// MARK: - Tab Definition

enum AppTab: String, CaseIterable, Identifiable {
    case discover = "Discover"
    case swipe = "Swipe"
    case search = "Search"
    case watchlist = "Watchlist"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .discover: return "sparkles"
        case .swipe: return "rectangle.stack"
        case .search: return "magnifyingglass"
        case .watchlist: return "bookmark"
        }
    }

    var selectedIcon: String {
        switch self {
        case .discover: return "sparkles"
        case .swipe: return "rectangle.stack.fill"
        case .search: return "magnifyingglass"
        case .watchlist: return "bookmark.fill"
        }
    }

    var color: Color {
        switch self {
        case .discover: return .purple
        case .swipe: return .pink
        case .search: return .blue
        case .watchlist: return .orange
        }
    }
}

// MARK: - Glass Tab Bar

struct GlassTabBar: View {

    @Binding var selectedTab: AppTab
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(glassBackground)
        .padding(.horizontal, Spacing.horizontal)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Tab Button

    private func tabButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(AppTheme.Animation.bouncy) {
                Haptics.shared.tabTapped()
                selectedTab = tab
            }
        } label: {
            VStack(spacing: Spacing.xxs) {
                ZStack {
                    // Selection background
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .fill(tab.color.opacity(0.15))
                            .frame(width: 56, height: 36)
                            .matchedGeometryEffect(id: "tabBackground", in: animation)
                    }

                    // Icon
                    Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? tab.color : .secondary)
                        .symbolEffect(.bounce, value: selectedTab == tab)
                }
                .frame(height: 36)

                // Label
                Text(tab.rawValue)
                    .font(.caption2.weight(selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? tab.color : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }

    // MARK: - Glass Background

    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Pill Tab Bar (Compact Alternative)

struct PillTabBar: View {

    @Binding var selectedTab: AppTab
    @Namespace private var animation

    var body: some View {
        HStack(spacing: Spacing.lg) {
            ForEach(AppTab.allCases) { tab in
                pillButton(for: tab)
            }
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.lg)
        .background(
            Capsule()
                .fill(.ultraThickMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
    }

    private func pillButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(AppTheme.Animation.bouncy) {
                Haptics.shared.tabTapped()
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? tab.color : .secondary)
                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)

                // Indicator dot
                Circle()
                    .fill(selectedTab == tab ? tab.color : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(width: 50)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab Bar Container

struct TabBarContainer<Content: View>: View {

    @Binding var selectedTab: AppTab
    let content: Content

    init(selectedTab: Binding<AppTab>, @ViewBuilder content: () -> Content) {
        self._selectedTab = selectedTab
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .padding(.bottom, 80) // Space for tab bar

            GlassTabBar(selectedTab: $selectedTab)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct GlassTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()

            GlassTabBar(selectedTab: .constant(.discover))

            Spacer().frame(height: 40)

            PillTabBar(selectedTab: .constant(.swipe))
        }
        .background(Color(.systemBackground))
    }
}
#endif
