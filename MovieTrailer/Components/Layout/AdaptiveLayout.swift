//
//  AdaptiveLayout.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Adaptive layout components for iPad and large screens
//

import SwiftUI

// MARK: - Device Type

enum DeviceType {
    case phone
    case phoneLandscape
    case tablet
    case tabletLandscape

    static var current: DeviceType {
        let idiom = UIDevice.current.userInterfaceIdiom
        let orientation = UIDevice.current.orientation

        switch idiom {
        case .pad:
            return orientation.isLandscape ? .tabletLandscape : .tablet
        case .phone:
            return orientation.isLandscape ? .phoneLandscape : .phone
        default:
            return .phone
        }
    }
}

// MARK: - Adaptive Grid

struct AdaptiveMovieGrid<Content: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    let movies: [Movie]
    let content: (Movie) -> Content

    private var columns: [GridItem] {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            // iPad
            return Array(repeating: GridItem(.flexible(), spacing: 16), count: 5)
        case (.regular, .compact):
            // iPad landscape or large iPhone landscape
            return Array(repeating: GridItem(.flexible(), spacing: 16), count: 6)
        case (.compact, .regular):
            // iPhone portrait
            return Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
        default:
            // iPhone landscape
            return Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
        }
    }

    private var spacing: CGFloat {
        horizontalSizeClass == .regular ? 20 : 12
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(movies) { movie in
                content(movie)
            }
        }
    }
}

// MARK: - Adaptive Movie Row

struct AdaptiveMovieRow: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let title: String
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onSeeAll: (() -> Void)?

    private var cardWidth: CGFloat {
        horizontalSizeClass == .regular ? 160 : 120
    }

    private var cardHeight: CGFloat {
        horizontalSizeClass == .regular ? 240 : 180
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(title)
                    .font(horizontalSizeClass == .regular ? .title2.bold() : .headline2)
                    .foregroundColor(.textPrimary)

                Spacer()

                if let onSeeAll = onSeeAll {
                    Button("See All") {
                        Haptics.shared.lightImpact()
                        onSeeAll()
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, horizontalSizeClass == .regular ? 24 : 20)

            // Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: horizontalSizeClass == .regular ? 16 : 12) {
                    ForEach(movies) { movie in
                        ParallaxMovieCard(movie: movie, onTap: { onMovieTap(movie) })
                            .frame(width: cardWidth, height: cardHeight)
                    }
                }
                .padding(.horizontal, horizontalSizeClass == .regular ? 24 : 20)
            }
        }
    }
}

// MARK: - Split View Container

struct SplitViewContainer<Sidebar: View, Content: View, Detail: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let sidebar: Sidebar
    let content: Content
    let detail: Detail?

    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content,
        @ViewBuilder detail: () -> Detail
    ) {
        self.sidebar = sidebar()
        self.content = content()
        self.detail = detail()
    }

    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                sidebar
                    .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
            } content: {
                content
                    .navigationSplitViewColumnWidth(min: 400, ideal: 500, max: 600)
            } detail: {
                if let detail = detail {
                    detail
                } else {
                    ContentUnavailableView(
                        "Select a Movie",
                        systemImage: "film",
                        description: Text("Choose a movie to see its details")
                    )
                }
            }
        } else {
            // Compact: use regular navigation
            content
        }
    }
}

// MARK: - Sidebar without detail

extension SplitViewContainer where Detail == EmptyView {
    init(
        @ViewBuilder sidebar: () -> Sidebar,
        @ViewBuilder content: () -> Content
    ) {
        self.sidebar = sidebar()
        self.content = content()
        self.detail = nil
    }
}

// MARK: - Adaptive Padding

struct AdaptivePadding: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let edges: Edge.Set
    let compactPadding: CGFloat
    let regularPadding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(edges, horizontalSizeClass == .regular ? regularPadding : compactPadding)
    }
}

extension View {
    func adaptivePadding(
        _ edges: Edge.Set = .all,
        compact: CGFloat = 16,
        regular: CGFloat = 24
    ) -> some View {
        modifier(AdaptivePadding(
            edges: edges,
            compactPadding: compact,
            regularPadding: regular
        ))
    }
}

// MARK: - Adaptive Font

struct AdaptiveFont: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let compactSize: CGFloat
    let regularSize: CGFloat
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content
            .font(.system(
                size: horizontalSizeClass == .regular ? regularSize : compactSize,
                weight: weight
            ))
    }
}

extension View {
    func adaptiveFont(
        compact: CGFloat,
        regular: CGFloat,
        weight: Font.Weight = .regular
    ) -> some View {
        modifier(AdaptiveFont(
            compactSize: compact,
            regularSize: regular,
            weight: weight
        ))
    }
}

// MARK: - iPad Sidebar

struct iPadSidebar: View {
    @Binding var selectedCategory: MovieCategory?
    let onCategorySelect: (MovieCategory) -> Void

    enum MovieCategory: String, CaseIterable, Identifiable {
        case trending = "Trending"
        case popular = "Popular"
        case topRated = "Top Rated"
        case nowPlaying = "In Theaters"
        case upcoming = "Upcoming"
        case recent = "New Releases"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .trending: return "flame"
            case .popular: return "star"
            case .topRated: return "trophy"
            case .nowPlaying: return "film"
            case .upcoming: return "calendar"
            case .recent: return "sparkles"
            }
        }
    }

    var body: some View {
        List(selection: $selectedCategory) {
            Section("Browse") {
                ForEach(MovieCategory.allCases) { category in
                    Label(category.rawValue, systemImage: category.icon)
                        .tag(category)
                }
            }

            Section("Genres") {
                ForEach(popularGenres, id: \.id) { genre in
                    Label(genre.name, systemImage: genre.icon)
                }
            }

            Section("Library") {
                Label("Watchlist", systemImage: "bookmark")
                Label("Favorites", systemImage: "heart")
                Label("History", systemImage: "clock")
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Movies")
    }

    private var popularGenres: [(id: Int, name: String, icon: String)] {
        [
            (28, "Action", "bolt.fill"),
            (35, "Comedy", "face.smiling"),
            (18, "Drama", "theatermasks"),
            (27, "Horror", "moon.fill"),
            (878, "Sci-Fi", "atom"),
            (10749, "Romance", "heart.fill"),
            (16, "Animation", "sparkles"),
            (53, "Thriller", "exclamationmark.triangle")
        ]
    }
}

// MARK: - Adaptive Hero Height

struct AdaptiveHeroModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    func body(content: Content) -> some View {
        content
            .frame(height: heroHeight)
    }

    private var heroHeight: CGFloat {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular):
            return 550 // iPad portrait
        case (.regular, .compact):
            return 400 // iPad landscape
        case (.compact, .compact):
            return 300 // iPhone landscape
        default:
            return 480 // iPhone portrait
        }
    }
}

extension View {
    func adaptiveHeroHeight() -> some View {
        modifier(AdaptiveHeroModifier())
    }
}

// MARK: - Two Column Layout

struct TwoColumnLayout<Leading: View, Trailing: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let leading: Leading
    let trailing: Trailing
    let splitRatio: CGFloat

    init(
        splitRatio: CGFloat = 0.4,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.splitRatio = splitRatio
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        if horizontalSizeClass == .regular {
            GeometryReader { geometry in
                HStack(spacing: 20) {
                    leading
                        .frame(width: geometry.size.width * splitRatio)

                    trailing
                        .frame(width: geometry.size.width * (1 - splitRatio) - 20)
                }
            }
        } else {
            VStack(spacing: 20) {
                leading
                trailing
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct AdaptiveLayout_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPad Preview
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        AdaptiveMovieRow(
                            title: "Trending Now",
                            movies: Movie.samples,
                            onMovieTap: { _ in },
                            onSeeAll: {}
                        )

                        AdaptiveMovieGrid(movies: Movie.samples) { movie in
                            ParallaxMovieCard(movie: movie, onTap: {})
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color.appBackground)
            }
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
            .previewDisplayName("iPad")

            // iPhone Preview
            NavigationStack {
                ScrollView {
                    AdaptiveMovieRow(
                        title: "Trending Now",
                        movies: Movie.samples,
                        onMovieTap: { _ in },
                        onSeeAll: {}
                    )
                }
                .background(Color.appBackground)
            }
            .previewDevice("iPhone 15 Pro")
            .previewDisplayName("iPhone")
        }
        .preferredColorScheme(.dark)
    }
}
#endif
