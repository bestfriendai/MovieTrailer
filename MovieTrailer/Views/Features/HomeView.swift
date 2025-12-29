//
//  HomeView.swift
//  MovieTrailer
//
//  Apple 2025 Premium Home Experience
//  Apple TV-inspired cinematic home screen
//

import SwiftUI

struct HomeView: View {

    // MARK: - Properties

    @StateObject private var viewModel: HomeViewModel
    @State private var showingFilters = false
    @State private var scrollOffset: CGFloat = 0

    let onMovieTap: (Movie) -> Void
    let onPlayTrailer: (Movie) -> Void

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
                    if !viewModel.featuredMovies.isEmpty {
                        CinematicHeroCarousel(
                            movies: viewModel.featuredMovies,
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

                    // Continue Watching (if any in watchlist)
                    if !viewModel.watchlistMovies.isEmpty {
                        LargePosterRow(
                            title: "Continue Watching",
                            subtitle: "Pick up where you left off",
                            movies: viewModel.watchlistMovies,
                            onMovieTap: onMovieTap
                        )
                    }

                    // Top 10 Movies
                    if !viewModel.topRatedMovies.isEmpty {
                        Top10Row(
                            title: "Top 10 Movies Today",
                            movies: viewModel.topRatedMovies,
                            onMovieTap: onMovieTap
                        )
                    }

                    // Trending Now with Featured Cards
                    if !viewModel.trendingMovies.isEmpty {
                        FeaturedRow(
                            title: "Trending Now",
                            subtitle: "What everyone's watching",
                            movies: Array(viewModel.trendingMovies.prefix(10)),
                            onMovieTap: onMovieTap,
                            onTrailerTap: onPlayTrailer
                        )
                    }

                    // In Theaters Now
                    if !viewModel.nowPlayingMovies.isEmpty {
                        theaterSection
                    }

                    // Popular Movies
                    if !viewModel.popularMovies.isEmpty {
                        ContentRow(
                            title: "Popular Movies",
                            subtitle: "Fan favorites",
                            movies: viewModel.popularMovies,
                            onMovieTap: onMovieTap
                        )
                    }

                    // New Releases
                    if !viewModel.newReleases.isEmpty {
                        ContentRow(
                            title: "New Releases",
                            subtitle: "Fresh arrivals",
                            movies: viewModel.newReleases,
                            onMovieTap: onMovieTap
                        )
                    }

                    // Genre Sections
                    genreSections

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
            }
        }
        // Filter sheet placeholder - to be implemented
        // .sheet(isPresented: $showingFilters) { }
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
                QuickFilterPill(title: "Tonight", icon: "moon.stars.fill", isSelected: false) {}
                QuickFilterPill(title: "Date Night", icon: "heart.fill", isSelected: false) {}
                QuickFilterPill(title: "Family", icon: "figure.2.and.child.holdinghands", isSelected: false) {}
                QuickFilterPill(title: "New", icon: "star.fill", isSelected: false) {}
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }

    // MARK: - Theater Section

    private var theaterSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header with theater icon
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

                // Location badge
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                    Text("Nearby")
                        .font(.pillSmall)
                }
                .foregroundColor(.accentPrimary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(Color.accentPrimary.opacity(0.15))
                .clipShape(Capsule())
            }
            .padding(.horizontal, Spacing.horizontal)

            // Theater movie cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(viewModel.nowPlayingMovies.prefix(10)) { movie in
                        TheaterMovieCard(
                            movie: movie,
                            onTap: { onMovieTap(movie) },
                            onTrailerTap: { onPlayTrailer(movie) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
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
                onMovieTap: onMovieTap
            )
        }

        // Comedy Movies
        if !viewModel.comedyMovies.isEmpty {
            CompactMovieRow(
                title: "Comedy",
                icon: "face.smiling.fill",
                movies: viewModel.comedyMovies,
                onMovieTap: onMovieTap
            )
        }

        // Drama Movies
        if !viewModel.dramaMovies.isEmpty {
            CompactMovieRow(
                title: "Drama",
                icon: "theatermasks.fill",
                movies: viewModel.dramaMovies,
                onMovieTap: onMovieTap
            )
        }

        // Sci-Fi Movies
        if !viewModel.sciFiMovies.isEmpty {
            CompactMovieRow(
                title: "Sci-Fi & Fantasy",
                icon: "sparkles",
                movies: viewModel.sciFiMovies,
                onMovieTap: onMovieTap
            )
        }

        // Horror Movies
        if !viewModel.horrorMovies.isEmpty {
            CompactMovieRow(
                title: "Horror & Thriller",
                icon: "moon.fill",
                movies: viewModel.horrorMovies,
                onMovieTap: onMovieTap
            )
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                // Animated loading indicator
                ZStack {
                    Circle()
                        .stroke(Color.glassThin, lineWidth: 4)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(
                            LinearGradient(
                                colors: [.accentPrimary, .accentSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .modifier(SpinnerModifier())
                }

                VStack(spacing: Spacing.sm) {
                    Text("Loading")
                        .font(.headline2)
                        .foregroundColor(.textPrimary)

                    Text("Fetching the latest movies...")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }
        }
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

struct QuickFilterPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.shared.selectionChanged()
            action()
        }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(title)
                    .font(.labelMedium)
            }
            .foregroundColor(isSelected ? .textInverted : .textSecondary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Color.accentPrimary : Color.glassThin)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.glassBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
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

                        // Showtimes button
                        Button {
                            Haptics.shared.buttonTapped()
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
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - KFImage Import

import Kingfisher

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

    @Published var isLoading = false
    @Published var error: NetworkError?

    // MARK: - Dependencies

    private let tmdbService: TMDBService
    private let watchlistManager: WatchlistManager

    // MARK: - Initialization

    init(tmdbService: TMDBService, watchlistManager: WatchlistManager) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
    }

    // MARK: - Public Methods

    func loadContent() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        // Load watchlist
        loadWatchlist()

        // Load all content in parallel
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTrending() }
            group.addTask { await self.loadPopular() }
            group.addTask { await self.loadTopRated() }
            group.addTask { await self.loadNowPlaying() }
        }

        // Filter by genres
        filterByGenres()

        isLoading = false
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

    // MARK: - Private Methods

    private func loadWatchlist() {
        watchlistMovies = watchlistManager.items.prefix(10).map { $0.toMovie() }
    }

    private func loadTrending() async {
        do {
            let response = try await tmdbService.fetchTrending(page: 1)
            trendingMovies = response.results
            // Use trending for featured
            featuredMovies = Array(response.results.prefix(5))
        } catch {
            // Silent fail
        }
    }

    private func loadPopular() async {
        do {
            let response = try await tmdbService.fetchPopular(page: 1)
            popularMovies = response.results
            // Recent releases
            newReleases = response.results.filter { movie in
                guard let date = movie.releaseDate else { return false }
                let year = String(date.prefix(4))
                return year == "2024" || year == "2025"
            }
        } catch {
            // Silent fail
        }
    }

    private func loadTopRated() async {
        do {
            let response = try await tmdbService.fetchTopRated(page: 1)
            topRatedMovies = response.results
        } catch {
            // Silent fail
        }
    }

    private func loadNowPlaying() async {
        // Use popular movies for now playing section as a fallback
        // since fetchNowPlaying may not be available
        nowPlayingMovies = popularMovies
    }

    private func filterByGenres() {
        let allMovies = trendingMovies + popularMovies + topRatedMovies
        let uniqueMovies = Array(Set(allMovies))

        // Action (28)
        actionMovies = uniqueMovies.filter { $0.genreIds.contains(28) }

        // Comedy (35)
        comedyMovies = uniqueMovies.filter { $0.genreIds.contains(35) }

        // Drama (18)
        dramaMovies = uniqueMovies.filter { $0.genreIds.contains(18) }

        // Horror (27) + Thriller (53)
        horrorMovies = uniqueMovies.filter { $0.genreIds.contains(27) || $0.genreIds.contains(53) }

        // Sci-Fi (878) + Fantasy (14)
        sciFiMovies = uniqueMovies.filter { $0.genreIds.contains(878) || $0.genreIds.contains(14) }
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
