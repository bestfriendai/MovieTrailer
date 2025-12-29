//
//  DiscoverView.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//  Redesigned with Apple 2025 design language
//

import SwiftUI

struct DiscoverView: View {

    @StateObject private var viewModel: DiscoverViewModel
    @ObservedObject private var preferences = UserPreferences.shared
    let onMovieTap: (Movie) -> Void
    let onWatchTrailer: ((Movie) -> Void)?

    init(
        viewModel: DiscoverViewModel,
        onMovieTap: @escaping (Movie) -> Void,
        onWatchTrailer: ((Movie) -> Void)? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMovieTap = onMovieTap
        self.onWatchTrailer = onWatchTrailer
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Filter header
                filterHeader
                    .padding(.top, Spacing.sm)

                // Hero carousel for featured movies
                if !viewModel.trendingMovies.isEmpty {
                    HeroCarousel(
                        movies: viewModel.trendingMovies,
                        isInWatchlist: viewModel.isInWatchlist,
                        onMovieTap: onMovieTap,
                        onWatchTrailer: { movie in
                            onWatchTrailer?(movie)
                        },
                        onWatchlistToggle: viewModel.toggleWatchlist
                    )
                }

                // Content sections based on category
                contentSections
            }
            .padding(.bottom, Spacing.xxxl + 60) // Extra space for tab bar
        }
        .background(Color(.systemBackground))
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            Haptics.shared.pulledToRefresh()
            await viewModel.refresh()
        }
        .task {
            if viewModel.trendingMovies.isEmpty {
                await viewModel.loadContent()
            }
        }
        .overlay {
            if let error = viewModel.error, viewModel.trendingMovies.isEmpty {
                ErrorView(error: error) {
                    Task {
                        await viewModel.loadContent()
                    }
                }
            }
        }
        .onChange(of: preferences.selectedCategory) { _ in
            Task {
                await viewModel.loadForCategory(preferences.selectedCategory)
            }
        }
    }

    // MARK: - Filter Header

    private var filterHeader: some View {
        VStack(spacing: Spacing.md) {
            // Category pills
            CategoryScrollView(selectedCategory: $preferences.selectedCategory)

            // Streaming filter button
            HStack {
                StreamingFilterButton(preferences: preferences)
                Spacer()

                // Sort button (future enhancement)
                Button(action: {
                    Haptics.shared.lightImpact()
                }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
                .buttonStyle(PillButtonStyle())
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }

    // MARK: - Content Sections

    @ViewBuilder
    private var contentSections: some View {
        VStack(spacing: Spacing.xxl) {
            // Trending Section (hide if showing in hero)
            if preferences.selectedCategory != .new {
                GlassMovieSection(
                    title: "Trending This Week",
                    icon: "flame.fill",
                    iconColor: .categoryNew,
                    movies: viewModel.filteredTrendingMovies,
                    isLoading: viewModel.isLoadingTrending,
                    isInWatchlist: viewModel.isInWatchlist,
                    onMovieTap: onMovieTap,
                    onWatchlistToggle: viewModel.toggleWatchlist
                )
            }

            // Popular Section
            GlassMovieSection(
                title: "Popular Now",
                icon: "star.fill",
                iconColor: .yellow,
                movies: viewModel.filteredPopularMovies,
                isLoading: viewModel.isLoadingPopular,
                isInWatchlist: viewModel.isInWatchlist,
                onMovieTap: onMovieTap,
                onWatchlistToggle: viewModel.toggleWatchlist
            )

            // Top Rated Section
            GlassMovieSection(
                title: "Top Rated",
                icon: "trophy.fill",
                iconColor: .purple,
                movies: viewModel.filteredTopRatedMovies,
                isLoading: viewModel.isLoadingTopRated,
                isInWatchlist: viewModel.isInWatchlist,
                onMovieTap: onMovieTap,
                onWatchlistToggle: viewModel.toggleWatchlist
            )

            // Category-specific section
            if let categoryMovies = viewModel.categoryMovies, !categoryMovies.isEmpty {
                GlassMovieSection(
                    title: "\(preferences.selectedCategory.rawValue) Movies",
                    icon: preferences.selectedCategory.icon,
                    iconColor: preferences.selectedCategory.color,
                    movies: categoryMovies,
                    isLoading: viewModel.isLoadingCategory,
                    isInWatchlist: viewModel.isInWatchlist,
                    onMovieTap: onMovieTap,
                    onWatchlistToggle: viewModel.toggleWatchlist
                )
            }
        }
    }
}

// MARK: - Glass Movie Section

struct GlassMovieSection: View {

    let title: String
    let icon: String
    let iconColor: Color
    let movies: [Movie]
    let isLoading: Bool
    let isInWatchlist: (Movie) -> Bool
    let onMovieTap: (Movie) -> Void
    let onWatchlistToggle: (Movie) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Section header
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(title)
                    .font(.sectionTitle)
                    .foregroundColor(.primary)

                Spacer()

                // See all button
                Button(action: {
                    Haptics.shared.lightImpact()
                }) {
                    HStack(spacing: Spacing.xxs) {
                        Text("See All")
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, Spacing.horizontal)

            // Movies scroll
            if isLoading && movies.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(0..<5, id: \.self) { _ in
                            GlassMovieCardSkeleton()
                        }
                    }
                    .padding(.horizontal, Spacing.horizontal)
                }
            } else if movies.isEmpty {
                emptyState
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(movies) { movie in
                            GlassMovieCard(
                                movie: movie,
                                isInWatchlist: isInWatchlist(movie),
                                size: .standard,
                                onTap: { onMovieTap(movie) },
                                onWatchlistToggle: { onWatchlistToggle(movie) }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.horizontal)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "film")
                .font(.largeTitle)
                .foregroundColor(.secondary.opacity(0.5))
            Text("No movies found")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xl)
    }
}

// MARK: - Glass Skeleton Loader

struct GlassMovieCardSkeleton: View {

    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Poster skeleton
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.3),
                            Color.gray.opacity(0.1),
                            Color.gray.opacity(0.3)
                        ],
                        startPoint: isAnimating ? .leading : .trailing,
                        endPoint: isAnimating ? .trailing : .leading
                    )
                )
                .aspectRatio(AspectRatio.poster, contentMode: .fill)
                .frame(width: Size.movieCardStandard)

            // Title skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: Size.movieCardStandard, height: 16)

            // Year skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.15))
                .frame(width: 60, height: 12)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Legacy Section (kept for compatibility)

struct MovieSection: View {

    let title: String
    let icon: String
    let iconColor: Color
    let movies: [Movie]
    let isLoading: Bool
    let isInWatchlist: (Movie) -> Bool
    let onMovieTap: (Movie) -> Void
    let onWatchlistToggle: (Movie) -> Void

    var body: some View {
        GlassMovieSection(
            title: title,
            icon: icon,
            iconColor: iconColor,
            movies: movies,
            isLoading: isLoading,
            isInWatchlist: isInWatchlist,
            onMovieTap: onMovieTap,
            onWatchlistToggle: onWatchlistToggle
        )
    }
}

// MARK: - Preview

#if DEBUG
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiscoverView(viewModel: .mock(), onMovieTap: { _ in })
        }
    }
}
#endif
