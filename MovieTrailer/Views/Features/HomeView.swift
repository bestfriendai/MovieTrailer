//
//  HomeView.swift
//  MovieTrailer
//
//  Apple 2025 Premium Home Experience
//  Apple TV-inspired cinematic home screen
//

import SwiftUI

// MARK: - Quick Filter Type

enum QuickFilter: String, CaseIterable {
    case none = "None"
    case tonight = "Tonight"
    case dateNight = "Date Night"
    case family = "Family"
    case newReleases = "New"

    var icon: String {
        switch self {
        case .none: return "xmark"
        case .tonight: return "moon.stars.fill"
        case .dateNight: return "heart.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .newReleases: return "star.fill"
        }
    }

    var genreIds: [Int] {
        switch self {
        case .none: return []
        case .tonight: return [28, 53, 27, 878] // Action, Thriller, Horror, Sci-Fi
        case .dateNight: return [10749, 35, 18] // Romance, Comedy, Drama
        case .family: return [10751, 16, 12, 14] // Family, Animation, Adventure, Fantasy
        case .newReleases: return [] // Uses release date filter instead
        }
    }
}

// MARK: - Category Movies View

struct CategoryMoviesView: View {

    let category: MovieCategory
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void

    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header with category info
                categoryHeader

                // Movies grid
                LazyVGrid(columns: columns, spacing: Spacing.lg) {
                    ForEach(movies) { movie in
                        CategoryMovieCard(movie: movie) {
                            onMovieTap(movie)
                        }
                    }
                }
                .padding(.horizontal, Spacing.horizontal)

                // Bottom padding
                Spacer()
                    .frame(height: 100)
            }
        }
        .background(Color.appBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(category.rawValue)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.6), .white.opacity(0.1))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Category Header

    private var categoryHeader: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [category.color.opacity(0.4), category.color.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: category.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(category.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)

                Text("\(movies.count) movies")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.horizontal)
        .padding(.top, Spacing.md)
    }
}

// MARK: - Category Movie Card

struct CategoryMovieCard: View {

    let movie: Movie
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            Haptics.shared.cardTapped()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Poster
                ZStack(alignment: .topTrailing) {
                    KFImage(movie.posterURL)
                        .placeholder {
                            Rectangle()
                                .fill(Color.surfaceSecondary)
                                .shimmer(isActive: true)
                        }
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipped()

                    // Rating badge
                    if movie.voteAverage > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.ratingStar)
                            Text(movie.formattedRating)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(6)
                    }
                }
                .aspectRatio(2/3, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.glassBorder, lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)

                // Title
                Text(movie.title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Year
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
            }
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(AppTheme.Animation.quick, value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct HomeView: View {

    // MARK: - Properties

    @StateObject private var viewModel: HomeViewModel
    @ObservedObject private var userPreferences = UserPreferences.shared
    @State private var showingFilters = false
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedCategory: MovieCategory?
    @State private var showingCategoryView = false

    let onMovieTap: (Movie) -> Void
    let onPlayTrailer: (Movie) -> Void

    // Dynamic years - current year and 4 previous years
    private var years: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (0..<5).map { String(currentYear - $0) }
    }

    // MARK: - Initialization

    init(
        viewModel: HomeViewModel,
        onMovieTap: @escaping (Movie) -> Void,
        onPlayTrailer: @escaping (Movie) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMovieTap = onMovieTap
        self.onPlayTrailer = onPlayTrailer
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.xxl) {
                    // Cinematic Hero Carousel
                    if !viewModel.filteredFeaturedMovies.isEmpty {
                        CinematicHeroCarousel(
                            movies: viewModel.filteredFeaturedMovies,
                            onPlay: onPlayTrailer,
                            onAddToList: { movie in
                                viewModel.toggleWatchlist(for: movie)
                            },
                            onTap: onMovieTap,
                            watchlistChecker: { movie in
                                viewModel.isInWatchlist(movie)
                            }
                        )
                    }

                    // Quick filter pills
                    quickFilterSection

                    if hasPersonalization {
                        personalizationSection
                    }

                    // Offline banner (if using cached data)
                    if viewModel.isUsingCachedData {
                        OfflineBanner {
                            Task { await viewModel.loadContent() }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Error banner (if any)
                    if viewModel.showErrorBanner, let message = viewModel.errorMessage, !viewModel.isUsingCachedData {
                        ErrorBanner(
                            message: message,
                            onRetry: {
                                Task { await viewModel.loadContent() }
                            },
                            onDismiss: {
                                viewModel.dismissError()
                            }
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Active filter indicator
                    if viewModel.hasActiveFilters {
                        activeFilterBanner
                    }

                    // Continue Watching (if any in watchlist)
                    if !viewModel.watchlistMovies.isEmpty && !viewModel.hasActiveFilters {
                        LargePosterRow(
                            title: "Continue Watching",
                            subtitle: "Pick up where you left off",
                            movies: viewModel.watchlistMovies,
                            onMovieTap: onMovieTap
                        )
                    }

                    // Top 10 Movies
                    if !viewModel.filteredTopRatedMovies.isEmpty {
                        Top10Row(
                            title: viewModel.hasActiveFilters ? "Top Matches" : "Top 10 Movies Today",
                            movies: Array(viewModel.filteredTopRatedMovies.prefix(10)),
                            onMovieTap: onMovieTap,
                            onSeeAll: { showCategory(.topRated) }
                        )
                    }

                    // Trending Now with Featured Cards
                    if !viewModel.filteredTrendingMovies.isEmpty {
                        FeaturedRow(
                            title: viewModel.hasActiveFilters ? "Trending Matches" : "Trending Now",
                            subtitle: viewModel.hasActiveFilters ? "Based on your filters" : "What everyone's watching",
                            movies: Array(viewModel.filteredTrendingMovies.prefix(10)),
                            onMovieTap: onMovieTap,
                            onTrailerTap: onPlayTrailer,
                            onSeeAll: { showCategory(.trending) }
                        )
                    }

                    // In Theaters Now
                    if !viewModel.filteredNowPlayingMovies.isEmpty && !viewModel.hasActiveFilters {
                        theaterSection
                    }

                    // Popular Movies
                    if !viewModel.filteredPopularMovies.isEmpty {
                        ContentRow(
                            title: viewModel.hasActiveFilters ? "Popular Matches" : "Popular Movies",
                            subtitle: viewModel.hasActiveFilters ? "Matching your preferences" : "Fan favorites",
                            movies: viewModel.filteredPopularMovies,
                            onMovieTap: onMovieTap,
                            onSeeAll: { showCategory(.popular) }
                        )
                    }

                    // New Releases
                    if !viewModel.filteredNewReleases.isEmpty && !viewModel.hasActiveFilters {
                        ContentRow(
                            title: "New Releases",
                            subtitle: "Fresh arrivals",
                            movies: viewModel.filteredNewReleases,
                            onMovieTap: onMovieTap,
                            onSeeAll: { showCategory(.newReleases) }
                        )
                    }

                    // Genre Sections (hide when filtering)
                    if !viewModel.hasActiveFilters {
                        genreSections
                    }

                    // Bottom padding for tab bar
                    Spacer()
                        .frame(height: 120)
                }
            }
            .coordinateSpace(name: "scroll")
        }
        .preferredColorScheme(.dark)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadContent()
        }
        .overlay {
            if viewModel.isLoading && viewModel.trendingMovies.isEmpty {
                loadingOverlay
            } else if let error = viewModel.error, viewModel.trendingMovies.isEmpty {
                ErrorView(error: error) {
                    Task {
                        await viewModel.loadContent()
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            filterSheet
        }
        .sheet(isPresented: $showingCategoryView) {
            if let category = selectedCategory {
                NavigationStack {
                    CategoryMoviesView(
                        category: category,
                        movies: moviesForCategory(category),
                        onMovieTap: { movie in
                            showingCategoryView = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onMovieTap(movie)
                            }
                        }
                    )
                }
            }
        }
    }

    // MARK: - Category Navigation

    private func showCategory(_ category: MovieCategory) {
        Haptics.shared.buttonTapped()
        selectedCategory = category
        showingCategoryView = true
    }

    private func moviesForCategory(_ category: MovieCategory) -> [Movie] {
        switch category {
        case .trending: return viewModel.trendingMovies
        case .popular: return viewModel.popularMovies
        case .topRated: return viewModel.topRatedMovies
        case .nowPlaying: return viewModel.nowPlayingMovies
        case .newReleases: return viewModel.newReleases
        case .action: return viewModel.actionMovies
        case .comedy: return viewModel.comedyMovies
        case .drama: return viewModel.dramaMovies
        case .horror: return viewModel.horrorMovies
        case .sciFi: return viewModel.sciFiMovies
        case .all: return viewModel.popularMovies
        case .animation: return viewModel.popularMovies.filter { $0.genreIds.contains(16) }
        case .romance: return viewModel.popularMovies.filter { $0.genreIds.contains(10749) }
        case .thriller: return viewModel.popularMovies.filter { $0.genreIds.contains(53) }
        case .documentary: return viewModel.popularMovies.filter { $0.genreIds.contains(99) }
        }
    }

    // MARK: - Quick Filter Section

    private var quickFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // Filter button
                Button {
                    Haptics.shared.buttonTapped()
                    showingFilters = true
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14, weight: .medium))
                        Text("Filters")
                            .font(.labelMedium)
                        if viewModel.selectedGenre != nil || viewModel.selectedYear != nil || viewModel.minRating > 0 {
                            Circle()
                                .fill(Color.cyan)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.glassLight)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.glassBorder, lineWidth: 0.5)
                    )
                }
                .buttonStyle(ScaleButtonStyle())

                // Quick filter presets
                QuickFilterPill(
                    title: "Tonight",
                    icon: "moon.stars.fill",
                    isSelected: viewModel.selectedQuickFilter == .tonight,
                    isLoading: viewModel.isLoadingQuickFilter
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.setQuickFilter(.tonight)
                    }
                }

                QuickFilterPill(
                    title: "Date Night",
                    icon: "heart.fill",
                    isSelected: viewModel.selectedQuickFilter == .dateNight,
                    isLoading: viewModel.isLoadingQuickFilter
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.setQuickFilter(.dateNight)
                    }
                }

                QuickFilterPill(
                    title: "Family",
                    icon: "figure.2.and.child.holdinghands",
                    isSelected: viewModel.selectedQuickFilter == .family,
                    isLoading: viewModel.isLoadingQuickFilter
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.setQuickFilter(.family)
                    }
                }

                QuickFilterPill(
                    title: "New",
                    icon: "star.fill",
                    isSelected: viewModel.selectedQuickFilter == .newReleases,
                    isLoading: viewModel.isLoadingQuickFilter
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.setQuickFilter(.newReleases)
                    }
                }

                // Clear all button (when filters active)
                if viewModel.hasActiveFilters {
                    Button {
                        Haptics.shared.lightImpact()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.clearAllFilters()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                            Text("Clear")
                                .font(.labelMedium)
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                    }
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }

    // MARK: - Personalization

    private var hasPersonalization: Bool {
        !userPreferences.selectedGenreIds.isEmpty || !userPreferences.selectedStreamingServices.isEmpty
    }

    private var personalizationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            if !userPreferences.selectedGenreIds.isEmpty {
                Text("Your Genres")
                    .font(.headline3)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Spacing.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(userPreferences.selectedGenres) { genre in
                            PreferenceChip(
                                title: genre.name,
                                icon: GenreHelper.icon(for: genre.id),
                                color: Color.genre(genre.id),
                                isSelected: viewModel.selectedGenre?.id == genre.id
                            ) {
                                Haptics.shared.selectionChanged()
                                if viewModel.selectedGenre?.id == genre.id {
                                    viewModel.selectedGenre = nil
                                } else {
                                    viewModel.selectedGenre = genre
                                    viewModel.selectedQuickFilter = .none
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.horizontal)
                }
            }

            if !userPreferences.selectedStreamingServices.isEmpty {
                Text("Your Services")
                    .font(.headline3)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Spacing.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(Array(userPreferences.selectedStreamingServices), id: \.self) { service in
                            StreamingBadge(service: service, style: .compact)
                        }
                    }
                    .padding(.horizontal, Spacing.horizontal)
                }
            }
        }
    }

    // MARK: - Active Filter Banner

    private var activeFilterBanner: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(.cyan)

            Text(viewModel.activeFilterDescription)
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()

            Text("\(viewModel.totalFilteredCount) movies")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.cyan.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, Spacing.horizontal)
    }

    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            List {
                // Genre Section
                Section("Genre") {
                    ForEach(Genre.all.prefix(12)) { genre in
                        Button {
                            Haptics.shared.selectionChanged()
                            if viewModel.selectedGenre?.id == genre.id {
                                viewModel.selectedGenre = nil
                            } else {
                                viewModel.selectedGenre = genre
                            }
                        } label: {
                            HStack {
                                Text(genre.name)
                                    .foregroundColor(.white)
                                Spacer()
                                if viewModel.selectedGenre?.id == genre.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.cyan)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }

                // Year Section
                Section("Release Year") {
                    ForEach(years, id: \.self) { year in
                        Button {
                            Haptics.shared.selectionChanged()
                            if viewModel.selectedYear == year {
                                viewModel.selectedYear = nil
                            } else {
                                viewModel.selectedYear = year
                            }
                        } label: {
                            HStack {
                                Text(year)
                                    .foregroundColor(.white)
                                Spacer()
                                if viewModel.selectedYear == year {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.cyan)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }

                // Rating Section
                Section("Minimum Rating") {
                    ForEach([0.0, 5.0, 6.0, 7.0, 8.0], id: \.self) { rating in
                        Button {
                            Haptics.shared.selectionChanged()
                            viewModel.minRating = rating
                        } label: {
                            HStack {
                                if rating == 0 {
                                    Text("Any Rating")
                                        .foregroundColor(.white)
                                } else {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.system(size: 14))
                                        Text("\(Int(rating))+ Stars")
                                            .foregroundColor(.white)
                                    }
                                }
                                Spacer()
                                if viewModel.minRating == rating {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.cyan)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }

                // Clear All Section
                Section {
                    Button("Clear All Filters") {
                        Haptics.shared.lightImpact()
                        viewModel.clearAllFilters()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showingFilters = false
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.cyan)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    // MARK: - Theater Section

    private var theaterSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header with theater icon - CLICKABLE
            Button {
                showCategory(.nowPlaying)
            } label: {
                HStack(spacing: Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)

                        Image(systemName: "popcorn.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.orange)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("In Theaters Now")
                            .font(.headline1)
                            .foregroundColor(.textPrimary)

                        Text("Now showing near you")
                            .font(.labelMedium)
                            .foregroundColor(.textTertiary)
                    }

                    Spacer()

                    // See All text
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.labelMedium)
                            .foregroundColor(.accentPrimary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.accentPrimary)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.horizontal)

            // Theater movie cards - HORIZONTAL SCROLL
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(viewModel.nowPlayingMovies.prefix(15)) { movie in
                        TheaterMovieCard(
                            movie: movie,
                            onTap: { onMovieTap(movie) },
                            onTrailerTap: { onPlayTrailer(movie) }
                        )
                        .frame(width: 220)
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
                .padding(.vertical, 8)
            }
            .frame(height: 360)
        }
    }

    // MARK: - Genre Sections

    @ViewBuilder
    private var genreSections: some View {
        // Action Movies
        if !viewModel.actionMovies.isEmpty {
            CompactMovieRow(
                title: "Action & Adventure",
                icon: "bolt.fill",
                movies: viewModel.actionMovies,
                onMovieTap: onMovieTap,
                onSeeAll: { showCategory(.action) }
            )
        }

        // Comedy Movies
        if !viewModel.comedyMovies.isEmpty {
            CompactMovieRow(
                title: "Comedy",
                icon: "face.smiling.fill",
                movies: viewModel.comedyMovies,
                onMovieTap: onMovieTap,
                onSeeAll: { showCategory(.comedy) }
            )
        }

        // Drama Movies
        if !viewModel.dramaMovies.isEmpty {
            CompactMovieRow(
                title: "Drama",
                icon: "theatermasks.fill",
                movies: viewModel.dramaMovies,
                onMovieTap: onMovieTap,
                onSeeAll: { showCategory(.drama) }
            )
        }

        // Sci-Fi Movies
        if !viewModel.sciFiMovies.isEmpty {
            CompactMovieRow(
                title: "Sci-Fi & Fantasy",
                icon: "sparkles",
                movies: viewModel.sciFiMovies,
                onMovieTap: onMovieTap,
                onSeeAll: { showCategory(.sciFi) }
            )
        }

        // Horror Movies
        if !viewModel.horrorMovies.isEmpty {
            CompactMovieRow(
                title: "Horror & Thriller",
                icon: "moon.fill",
                movies: viewModel.horrorMovies,
                onMovieTap: onMovieTap,
                onSeeAll: { showCategory(.horror) }
            )
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ScrollView {
            VStack(spacing: Spacing.section) {
                SkeletonHero()

                SkeletonMovieRow(title: "Trending Now", cardCount: 6, cardWidth: 140, cardHeight: 200)
                SkeletonMovieRow(title: "Top Rated", cardCount: 6, cardWidth: 140, cardHeight: 200)
                SkeletonMovieRow(title: "Popular Picks", cardCount: 6, cardWidth: 140, cardHeight: 200)
            }
            .padding(.bottom, Spacing.floatingBottom)
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// MARK: - Offline Banner

struct OfflineBanner: View {
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "wifi.slash")
                .foregroundColor(.orange)

            Text("You're offline. Showing cached content.")
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()

            Button("Retry") {
                onRetry()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.cyan)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.orange.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal, Spacing.horizontal)
    }
}

// MARK: - Spinner Modifier

private struct SpinnerModifier: ViewModifier {
    @State private var isRotating = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1.0).repeatForever(autoreverses: false),
                value: isRotating
            )
            .onAppear {
                isRotating = true
            }
    }
}

// MARK: - Quick Filter Pill

struct PreferenceChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(title)
                    .font(.labelMedium)
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .textInverted : .textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? color : Color.glassThin)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.glassBorder, lineWidth: 0.5)
            )
        }
        .shadow(color: isSelected ? color.opacity(0.35) : .clear, radius: 10, x: 0, y: 6)
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Quick Filter Pill

struct QuickFilterPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.shared.selectionChanged()
            action()
        }) {
            HStack(spacing: Spacing.xs) {
                if isLoading && isSelected {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.textInverted)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(.labelMedium)
            }
            .foregroundColor(isSelected ? .textInverted : .textSecondary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [Color.accentPrimary, Color.accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.glassThin
                    }
                }
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: isSelected ? Color.accentPrimary.opacity(0.35) : .clear, radius: 10, x: 0, y: 6)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isLoading)
    }
}

// MARK: - Theater Movie Card

struct TheaterMovieCard: View {

    let movie: Movie
    let onTap: () -> Void
    let onTrailerTap: () -> Void

    @State private var isPressed = false

    private let cardWidth: CGFloat = 220
    private let cardHeight: CGFloat = 320

    var body: some View {
        Button(action: {
            Haptics.shared.cardTapped()
            onTap()
        }) {
            ZStack(alignment: .bottom) {
                // Poster
                KFImage(movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                            .shimmer(isActive: true)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: cardHeight)

                // Gradient overlay
                LinearGradient(
                    colors: [
                        .clear,
                        .clear,
                        .black.opacity(0.6),
                        .black.opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Content
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Spacer()

                    // Now showing badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("NOW SHOWING")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                    }

                    Text(movie.title)
                        .font(.headline2)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)

                    // Metadata
                    HStack(spacing: Spacing.sm) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.ratingStar)
                            Text(movie.formattedRating)
                                .font(.labelMedium)
                                .foregroundColor(.textPrimary)
                        }

                        if let year = movie.releaseYear {
                            Text("•")
                                .foregroundColor(.textTertiary)
                            Text(year)
                                .font(.labelMedium)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    // Action buttons
                    HStack(spacing: Spacing.sm) {
                        // Trailer button
                        Button {
                            Haptics.shared.buttonTapped()
                            onTrailerTap()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12))
                                Text("Trailer")
                                    .font(.buttonSmall)
                            }
                            .foregroundColor(.textInverted)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.white)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(ScaleButtonStyle())

                        // Showtimes button - opens Fandango search
                        Button {
                            Haptics.shared.buttonTapped()
                            openShowtimes(for: movie)
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "ticket.fill")
                                    .font(.system(size: 12))
                                Text("Showtimes")
                                    .font(.buttonSmall)
                            }
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(Spacing.md)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 10)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(AppTheme.Animation.quick, value: isPressed)
        }
        .buttonStyle(TheaterCardButtonStyle(isPressed: $isPressed))
    }

    // Open showtimes search for this movie
    private func openShowtimes(for movie: Movie) {
        // URL encode the movie title for search
        let encodedTitle = movie.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? movie.title
        // Open Fandango search for showtimes
        if let url = URL(string: "https://www.fandango.com/search?q=\(encodedTitle)&mode=movies") {
            UIApplication.shared.open(url)
        }
    }
}

// Custom button style that doesn't block scrolling
struct TheaterCardButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - KFImage Import

import Kingfisher

// MARK: - View State

enum ViewState: Equatable {
    case idle
    case loading
    case success
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}

// MARK: - Home View Model

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var featuredMovies: [Movie] = []
    @Published var trendingMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    @Published var topRatedMovies: [Movie] = []
    @Published var newReleases: [Movie] = []
    @Published var nowPlayingMovies: [Movie] = []
    @Published var watchlistMovies: [Movie] = []

    // Genre-specific
    @Published var actionMovies: [Movie] = []
    @Published var comedyMovies: [Movie] = []
    @Published var dramaMovies: [Movie] = []
    @Published var horrorMovies: [Movie] = []
    @Published var sciFiMovies: [Movie] = []

    // View state for proper error handling
    @Published var viewState: ViewState = .idle
    @Published var showErrorBanner = false
    @Published var errorMessage: String?

    // Filtering state (moved from View)
    @Published var selectedQuickFilter: QuickFilter = .none
    @Published var selectedGenre: Genre?
    @Published var selectedYear: String?
    @Published var minRating: Double = 0
    @Published var quickFilteredMovies: [Movie] = []
    @Published var isLoadingQuickFilter = false

    // Legacy compatibility
    var isLoading: Bool { viewState.isLoading }
    var error: NetworkError? {
        if case .error = viewState { return .unknown }
        return nil
    }

    // MARK: - Dependencies

    private let tmdbService: TMDBService
    private let watchlistManager: WatchlistManager
    private let imagePrefetcher = ImagePrefetcher()
    private let offlineCache: OfflineMovieCache
    private let networkMonitor: NetworkMonitor

    // Offline state
    @Published var isOffline = false
    @Published var isUsingCachedData = false

    // MARK: - Computed Properties - Filtering

    var hasActiveFilters: Bool {
        selectedQuickFilter != .none || selectedGenre != nil || selectedYear != nil || minRating > 0
    }

    var filteredFeaturedMovies: [Movie] {
        // When quick filter is active, use fetched movies
        if selectedQuickFilter != .none && !quickFilteredMovies.isEmpty {
            return Array(quickFilteredMovies.prefix(5))
        }
        let filtered = filterMovies(featuredMovies)
        return filtered.isEmpty && hasActiveFilters ? filterMovies(trendingMovies).prefix(5).map { $0 } : filtered
    }

    var filteredTopRatedMovies: [Movie] {
        // When quick filter is active, show top rated from fetched movies
        if selectedQuickFilter != .none && !quickFilteredMovies.isEmpty {
            return quickFilteredMovies.sorted { $0.voteAverage > $1.voteAverage }.prefix(10).map { $0 }
        }
        return filterMovies(topRatedMovies)
    }

    var filteredTrendingMovies: [Movie] {
        // When quick filter is active, use fetched movies
        if selectedQuickFilter != .none && !quickFilteredMovies.isEmpty {
            return quickFilteredMovies
        }
        return filterMovies(trendingMovies)
    }

    var filteredNowPlayingMovies: [Movie] {
        // When quick filter is active, filter from fetched movies
        if selectedQuickFilter != .none && !quickFilteredMovies.isEmpty {
            return quickFilteredMovies.filter { movie in
                guard let dateString = movie.releaseDate else { return false }
                let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return dateString >= formatter.string(from: threeMonthsAgo)
            }
        }
        return filterMovies(nowPlayingMovies)
    }

    var filteredPopularMovies: [Movie] {
        // When quick filter is active, use fetched movies sorted by popularity
        if selectedQuickFilter != .none && !quickFilteredMovies.isEmpty {
            return quickFilteredMovies.sorted { $0.popularity > $1.popularity }
        }
        return filterMovies(popularMovies)
    }

    var filteredNewReleases: [Movie] {
        // When quick filter is active, filter recent from fetched movies
        if selectedQuickFilter != .none && !quickFilteredMovies.isEmpty {
            let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let cutoffDate = formatter.string(from: threeMonthsAgo)
            return quickFilteredMovies.filter { ($0.releaseDate ?? "") >= cutoffDate }
        }
        return filterMovies(newReleases)
    }

    var activeFilterDescription: String {
        var parts: [String] = []
        if selectedQuickFilter != .none { parts.append(selectedQuickFilter.rawValue) }
        if let genre = selectedGenre { parts.append(genre.name) }
        if let year = selectedYear { parts.append(year) }
        if minRating > 0 { parts.append("★\(Int(minRating))+") }
        return parts.isEmpty ? "Filtered" : parts.joined(separator: " • ")
    }

    var totalFilteredCount: Int {
        filteredTrendingMovies.count + filteredPopularMovies.count
    }

    // MARK: - Initialization

    init(
        tmdbService: TMDBService,
        watchlistManager: WatchlistManager,
        offlineCache: OfflineMovieCache = .shared,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
        self.offlineCache = offlineCache
        self.networkMonitor = networkMonitor

        // Observe network status
        observeNetworkStatus()
    }

    private func observeNetworkStatus() {
        // Check initial state
        isOffline = !networkMonitor.isConnected
    }

    // MARK: - Public Methods

    func loadContent() async {
        guard viewState != .loading else { return }
        viewState = .loading
        showErrorBanner = false
        isUsingCachedData = false

        // Check network status
        isOffline = !networkMonitor.isConnected

        // Load watchlist
        loadWatchlist()

        var hasError = false
        var errorMessages: [String] = []

        // Load all content in parallel
        await withTaskGroup(of: (String, Error?).self) { group in
            group.addTask { ("trending", await self.loadTrendingWithError()) }
            group.addTask { ("popular", await self.loadPopularWithError()) }
            group.addTask { ("topRated", await self.loadTopRatedWithError()) }
            group.addTask { ("nowPlaying", await self.loadNowPlayingWithError()) }

            for await (source, error) in group {
                if let error = error {
                    hasError = true
                    errorMessages.append("\(source): \(error.localizedDescription)")
                }
            }
        }

        // If all failed, try loading from cache
        if hasError && trendingMovies.isEmpty && popularMovies.isEmpty {
            await loadFromCacheIfAvailable()
        }

        // Cache successful results for offline use
        if !trendingMovies.isEmpty {
            await offlineCache.cacheMovies(trendingMovies, category: .trending)
        }
        if !popularMovies.isEmpty {
            await offlineCache.cacheMovies(popularMovies, category: .popular)
        }
        if !topRatedMovies.isEmpty {
            await offlineCache.cacheMovies(topRatedMovies, category: .topRated)
        }
        if !nowPlayingMovies.isEmpty {
            await offlineCache.cacheMovies(nowPlayingMovies, category: .nowPlaying)
        }

        // Filter by genres (initial from existing data)
        filterByGenres()

        // Load genre-specific movies from TMDB discover API
        await loadGenreMovies()

        // Prefetch images for featured movies
        prefetchImages()

        // Update state
        if hasError && trendingMovies.isEmpty && popularMovies.isEmpty {
            viewState = .error("Failed to load movies. Check your connection.")
            showErrorBanner = true
            errorMessage = "Network error. Tap to retry."
        } else if hasError {
            // Partial success - show banner but still display content
            viewState = .success
            showErrorBanner = true
            errorMessage = isUsingCachedData ? "Showing cached content" : "Some content failed to load"
        } else {
            viewState = .success
        }
    }

    /// Load content from offline cache
    private func loadFromCacheIfAvailable() async {
        let cachedTrending = await offlineCache.getMovies(for: .trending)
        let cachedPopular = await offlineCache.getMovies(for: .popular)
        let cachedTopRated = await offlineCache.getMovies(for: .topRated)
        let cachedNowPlaying = await offlineCache.getMovies(for: .nowPlaying)

        if !cachedTrending.isEmpty {
            trendingMovies = cachedTrending
            featuredMovies = Array(cachedTrending.prefix(5))
            isUsingCachedData = true
        }
        if !cachedPopular.isEmpty {
            popularMovies = cachedPopular
            isUsingCachedData = true
        }
        if !cachedTopRated.isEmpty {
            topRatedMovies = cachedTopRated
            isUsingCachedData = true
        }
        if !cachedNowPlaying.isEmpty {
            nowPlayingMovies = cachedNowPlaying
            newReleases = cachedNowPlaying
            isUsingCachedData = true
        }
    }

    func refresh() async {
        await loadContent()
    }

    func toggleWatchlist(for movie: Movie) {
        watchlistManager.toggle(movie)
        loadWatchlist()
        Haptics.shared.addedToWatchlist()
    }

    func isInWatchlist(_ movie: Movie) -> Bool {
        watchlistManager.contains(movie)
    }

    func dismissError() {
        showErrorBanner = false
        errorMessage = nil
    }

    func clearAllFilters() {
        selectedQuickFilter = .none
        selectedGenre = nil
        selectedYear = nil
        minRating = 0
        quickFilteredMovies = []
    }

    func setQuickFilter(_ filter: QuickFilter) {
        if selectedQuickFilter == filter {
            selectedQuickFilter = .none
            quickFilteredMovies = []
        } else {
            selectedQuickFilter = filter
            // Fetch movies matching the filter from TMDB
            Task {
                await loadQuickFilterMovies(for: filter)
            }
        }
    }

    /// Fetch movies from TMDB that match the quick filter
    private func loadQuickFilterMovies(for filter: QuickFilter) async {
        guard filter != .none else {
            quickFilteredMovies = []
            return
        }

        isLoadingQuickFilter = true

        do {
            var allMovies: [Movie] = []

            if filter == .newReleases {
                // Fetch recent releases
                let response = try await tmdbService.fetchRecentMovies(page: 1)
                allMovies = response.results
            } else {
                // Fetch movies for each genre in the filter
                let genreIds = filter.genreIds
                for genreId in genreIds.prefix(2) { // Limit to 2 genres to avoid too many requests
                    let response = try await tmdbService.fetchMoviesByGenre(genreId, page: 1)
                    allMovies.append(contentsOf: response.results)
                }
                // Remove duplicates and sort by popularity
                let uniqueMovies = Array(Set(allMovies))
                allMovies = uniqueMovies.sorted { $0.popularity > $1.popularity }
            }

            quickFilteredMovies = Array(allMovies.prefix(30))
            isLoadingQuickFilter = false
        } catch {
            #if DEBUG
            print("⚠️ Failed to load quick filter movies: \(error)")
            #endif
            isLoadingQuickFilter = false
        }
    }

    // MARK: - Filtering Logic (moved from View)

    func filterMovies(_ movies: [Movie]) -> [Movie] {
        var filtered = movies

        // Apply quick filter
        if selectedQuickFilter != .none {
            if selectedQuickFilter == .newReleases {
                // Dynamic: filter movies released in the last 3 months
                let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let cutoffDate = dateFormatter.string(from: threeMonthsAgo)

                filtered = filtered.filter { movie in
                    guard let dateString = movie.releaseDate else { return false }
                    return dateString >= cutoffDate
                }
            } else {
                let genreIds = selectedQuickFilter.genreIds
                filtered = filtered.filter { movie in
                    movie.genreIds.contains { genreIds.contains($0) }
                }
            }
        }

        // Apply genre filter
        if let genre = selectedGenre {
            filtered = filtered.filter { $0.genreIds.contains(genre.id) }
        }

        // Apply year filter
        if let year = selectedYear {
            filtered = filtered.filter { $0.releaseDate?.hasPrefix(year) == true }
        }

        // Apply rating filter
        if minRating > 0 {
            filtered = filtered.filter { $0.voteAverage >= minRating }
        }

        return filtered
    }

    // MARK: - Private Methods

    private func loadWatchlist() {
        watchlistMovies = watchlistManager.items.prefix(10).map { $0.toMovie() }
    }

    private func loadTrendingWithError() async -> Error? {
        do {
            let response = try await tmdbService.fetchTrending(page: 1)
            trendingMovies = response.results
            featuredMovies = Array(response.results.prefix(5))
            return nil
        } catch {
            return error
        }
    }

    private func loadPopularWithError() async -> Error? {
        do {
            let response = try await tmdbService.fetchRecentMovies(page: 1)
            popularMovies = response.results
            return nil
        } catch {
            do {
                let response = try await tmdbService.fetchPopular(page: 1)
                popularMovies = response.results
                return nil
            } catch {
                return error
            }
        }
    }

    private func loadTopRatedWithError() async -> Error? {
        do {
            // Use recent top rated (last 2 years) for fresh content
            let response = try await tmdbService.fetchRecentTopRated(page: 1)
            topRatedMovies = Array(response.results.prefix(10))
            return nil
        } catch {
            do {
                // Fallback to trending sorted by rating if recent top-rated fails
                let response = try await tmdbService.fetchTrending(page: 1)
                topRatedMovies = Array(response.results.sorted { $0.voteAverage > $1.voteAverage }.prefix(10))
                return nil
            } catch {
                return error
            }
        }
    }

    private func loadNowPlayingWithError() async -> Error? {
        do {
            let response = try await tmdbService.fetchNowPlaying(page: 1)
            nowPlayingMovies = response.results
            newReleases = response.results
            return nil
        } catch {
            return error
        }
    }

    private func filterByGenres() {
        // Use already-fetched movies as initial source, but also fetch genre-specific content
        let allMovies = trendingMovies + nowPlayingMovies + popularMovies

        let recentMovies = allMovies.filter { movie in
            guard let dateString = movie.releaseDate, dateString.count >= 4 else { return true }
            let year = String(dateString.prefix(4))
            return (Int(year) ?? 0) >= 2023
        }

        let uniqueMovies = Array(Set(recentMovies))

        // Initial population from existing data
        actionMovies = uniqueMovies.filter { $0.genreIds.contains(28) }
        comedyMovies = uniqueMovies.filter { $0.genreIds.contains(35) }
        dramaMovies = uniqueMovies.filter { $0.genreIds.contains(18) }
        horrorMovies = uniqueMovies.filter { $0.genreIds.contains(27) || $0.genreIds.contains(53) }
        sciFiMovies = uniqueMovies.filter { $0.genreIds.contains(878) || $0.genreIds.contains(14) }
    }

    /// Fetch genre-specific movies from TMDB discover API
    private func loadGenreMovies() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadGenre(id: 28, into: \.actionMovies) }
            group.addTask { await self.loadGenre(id: 35, into: \.comedyMovies) }
            group.addTask { await self.loadGenre(id: 18, into: \.dramaMovies) }
            group.addTask { await self.loadGenre(id: 27, into: \.horrorMovies) }
            group.addTask { await self.loadGenre(id: 878, into: \.sciFiMovies) }
        }
    }

    private func loadGenre(id: Int, into keyPath: ReferenceWritableKeyPath<HomeViewModel, [Movie]>) async {
        do {
            let response = try await tmdbService.fetchMoviesByGenre(id, page: 1)
            self[keyPath: keyPath] = Array(response.results.prefix(15))
        } catch {
            // Keep existing filtered data on error
            #if DEBUG
            print("⚠️ HomeViewModel: Failed to load genre \(id): \(error)")
            #endif
        }
    }

    // MARK: - Image Prefetching

    private func prefetchImages() {
        // Prefetch featured movie images
        let urls = featuredMovies.compactMap { $0.backdropURL ?? $0.posterURL }
        imagePrefetcher.prefetch(urls: urls)

        // Prefetch next carousel images
        let nextUrls = trendingMovies.prefix(10).compactMap { $0.posterURL }
        imagePrefetcher.prefetch(urls: nextUrls)
    }
}

// MARK: - Image Prefetcher

final class ImagePrefetcher {
    private var currentPrefetcher: Kingfisher.ImagePrefetcher?

    func prefetch(urls: [URL]) {
        guard !urls.isEmpty else { return }
        currentPrefetcher?.stop()
        currentPrefetcher = Kingfisher.ImagePrefetcher(urls: urls)
        currentPrefetcher?.start()
    }

    func stop() {
        currentPrefetcher?.stop()
        currentPrefetcher = nil
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension HomeViewModel {
    static func mock() -> HomeViewModel {
        let viewModel = HomeViewModel(
            tmdbService: .shared,
            watchlistManager: .mock()
        )
        viewModel.featuredMovies = Movie.samples
        viewModel.trendingMovies = Movie.samples
        viewModel.popularMovies = Movie.samples
        viewModel.topRatedMovies = Movie.samples
        viewModel.nowPlayingMovies = Movie.samples
        viewModel.actionMovies = Movie.samples
        viewModel.comedyMovies = Movie.samples
        viewModel.dramaMovies = Movie.samples
        return viewModel
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            viewModel: .mock(),
            onMovieTap: { _ in },
            onPlayTrailer: { _ in }
        )
    }
}
#endif
