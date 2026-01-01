//
//  GlassTabBar.swift
//  MovieTrailer
//
//  Apple 2025 Premium Glass Tab Bar
//  Floating glassmorphic navigation with haptics
//

import SwiftUI

// MARK: - Tab Definition

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case swipe = "Discover"
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
        case .library: return "bookmark"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home: return "house.fill"
        case .swipe: return "rectangle.stack.fill"
        case .search: return "magnifyingglass"
        case .library: return "bookmark.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .home: return .accentPrimary
        case .swipe: return .swipeLove
        case .search: return .accentSecondary
        case .library: return .orange
        }
    }
}

// MARK: - Premium Glass Tab Bar

struct GlassTabBar: View {

    @Binding var selectedTab: AppTab
    @Namespace private var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                premiumTabButton(for: tab)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.sm)
        .background(premiumGlassBackground)
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.sm)
    }

    private func premiumTabButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(AppTheme.Animation.bouncy) {
                Haptics.shared.tabTapped()
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    // Selection indicator
                    if selectedTab == tab {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [tab.accentColor.opacity(0.3), tab.accentColor.opacity(0.15)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 64, height: 32)
                            .matchedGeometryEffect(id: "tabPill", in: animation)
                    }

                    // Icon
                    Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? tab.accentColor : .textTertiary)
                        .symbolEffect(.bounce, value: selectedTab == tab)
                }
                .frame(height: 32)

                // Label
                Text(tab.rawValue)
                    .font(.system(size: 10, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? tab.accentColor : .textTertiary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }

    private var premiumGlassBackground: some View {
        ZStack {
            // Base blur
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xxl)
                .fill(.ultraThinMaterial)

            // Gradient overlay
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xxl)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Border
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xxl)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.5
                )
        }
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Apple TV Style Tab Bar

struct AppleTVTabBar: View {

    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.top, Spacing.sm)
        .padding(.bottom, Spacing.sm)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
                )
                .shadow(color: .black.opacity(0.6), radius: 14, y: -6)
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

// MARK: - Minimalist Pill Tab Bar

struct PillTabBar: View {

    @Binding var selectedTab: AppTab
    @Namespace private var animation

    var body: some View {
        HStack(spacing: Spacing.xl) {
            ForEach(AppTab.allCases) { tab in
                pillButton(for: tab)
            }
        }
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.xl)
        .background(pillBackground)
        .padding(.horizontal, Spacing.xl)
        .padding(.bottom, Spacing.sm)
    }

    private func pillButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(AppTheme.Animation.bouncy) {
                Haptics.shared.tabTapped()
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? tab.accentColor : .textTertiary)
                    .scaleEffect(selectedTab == tab ? 1.15 : 1.0)

                // Indicator dot
                Circle()
                    .fill(selectedTab == tab ? tab.accentColor : Color.clear)
                    .frame(width: 5, height: 5)
            }
            .frame(width: 44)
        }
        .buttonStyle(.plain)
    }

    private var pillBackground: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay(
                Capsule()
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Floating Action Tab Bar

struct FloatingTabBar: View {

    @Binding var selectedTab: AppTab
    @Namespace private var animation

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Left tabs
            HStack(spacing: Spacing.md) {
                floatingTabButton(for: .home)
                floatingTabButton(for: .swipe)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(tabGroupBackground)

            // Right tabs
            HStack(spacing: Spacing.md) {
                floatingTabButton(for: .search)
                floatingTabButton(for: .library)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(tabGroupBackground)
        }
        .padding(.bottom, Spacing.sm)
    }

    private func floatingTabButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(AppTheme.Animation.bouncy) {
                Haptics.shared.tabTapped()
                selectedTab = tab
            }
        } label: {
            ZStack {
                if selectedTab == tab {
                    Circle()
                        .fill(tab.accentColor)
                        .frame(width: 48, height: 48)
                        .matchedGeometryEffect(id: "floatingTab", in: animation)
                }

                Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? .white : .textTertiary)
            }
            .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
    }

    private var tabGroupBackground: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .overlay(
                Capsule()
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
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
                .padding(.bottom, 90)

            GlassTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Preview

#if DEBUG
struct GlassTabBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 40) {
                    Text("Glass Tab Bar")
                        .foregroundColor(.textSecondary)
                    GlassTabBar(selectedTab: .constant(.home))

                    Text("Pill Tab Bar")
                        .foregroundColor(.textSecondary)
                    PillTabBar(selectedTab: .constant(.swipe))

                    Text("Floating Tab Bar")
                        .foregroundColor(.textSecondary)
                    FloatingTabBar(selectedTab: .constant(.search))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
#endif
