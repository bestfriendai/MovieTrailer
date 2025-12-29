//
//  GlassTabBar.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Apple TV-inspired tab bar
//

import SwiftUI

// MARK: - Tab Definition

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case swipe = "Swipe"
    case search = "Search"
    case library = "Library"

    var id: String { rawValue }

    var tabIndex: Int {
        switch self {
        case .home: return 0
        case .swipe: return 1
        case .search: return 2
        case .library: return 3
        }
    }

    static func from(index: Int) -> AppTab {
        switch index {
        case 0: return .home
        case 1: return .swipe
        case 2: return .search
        case 3: return .library
        default: return .home
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

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .swipe: return "rectangle.stack.fill"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical.fill"
        }
    }
}

// MARK: - Apple TV Tab Bar

struct AppleTVTabBar: View {

    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Rectangle()
                .fill(Color.appBackground)
                .shadow(color: .black.opacity(0.5), radius: 10, y: -5)
        )
    }

    private func tabButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                Haptics.shared.tabTapped()
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(selectedTab == tab ? .accentPrimary : .textTertiary)

                Text(tab.rawValue)
                    .font(.caption2)
                    .foregroundColor(selectedTab == tab ? .accentPrimary : .textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }
}

// MARK: - Glass Tab Bar (Alternative)

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

    private func tabButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(AppTheme.Animation.bouncy) {
                Haptics.shared.tabTapped()
                selectedTab = tab
            }
        } label: {
            VStack(spacing: Spacing.xxs) {
                ZStack {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .fill(Color.accentPrimary.opacity(0.15))
                            .frame(width: 56, height: 36)
                            .matchedGeometryEffect(id: "tabBackground", in: animation)
                    }

                    Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? .accentPrimary : .textTertiary)
                        .symbolEffect(.bounce, value: selectedTab == tab)
                }
                .frame(height: 36)

                Text(tab.rawValue)
                    .font(.caption2.weight(selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? .accentPrimary : .textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }

    private var glassBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
            .fill(Color.surfaceElevated.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                    .stroke(Color.separator, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Pill Tab Bar

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
                .fill(Color.surfaceElevated)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
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
                    .foregroundColor(selectedTab == tab ? .accentPrimary : .textTertiary)
                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)

                Circle()
                    .fill(selectedTab == tab ? Color.accentPrimary : Color.clear)
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
                .padding(.bottom, 80)

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

            AppleTVTabBar(selectedTab: .constant(.home))

            Spacer().frame(height: 40)

            GlassTabBar(selectedTab: .constant(.swipe))
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
