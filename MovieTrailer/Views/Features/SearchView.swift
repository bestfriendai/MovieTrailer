//
//  SearchView.swift
//  MovieTrailer
//
//  Apple 2025 Premium Search Experience
//  Voice search, filters, and browse sections
//

import SwiftUI

struct SearchView: View {

    @StateObject private var viewModel: SearchViewModel
    @FocusState private var isSearchFocused: Bool
    @State private var animateResults = false
    @State private var selectedBrowseCategory: BrowseCategory?

    let onMovieTap: (Movie) -> Void

    init(viewModel: SearchViewModel, onMovieTap: @escaping (Movie) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMovieTap = onMovieTap
    }

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Premium search bar
                premiumSearchBar

                // Content
                if viewModel.isSearching {
                    searchLoadingView
                } else if let error = viewModel.error, viewModel.searchResults.isEmpty {
                    searchErrorView(error)
                } else if viewModel.searchQuery.isEmpty {
                    browseView
                } else if viewModel.searchResults.isEmpty && !viewModel.isSearching {
                    noResultsView
                } else {
                    searchResultsView
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .onTapGesture {
            dismissKeyboard()
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    dismissKeyboard()
                }
        )
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Keyboard Dismissal

    private func dismissKeyboard() {
        isSearchFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Premium Search Bar

    private var premiumSearchBar: some View {
        VStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                // Search field with glass effect
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.textTertiary)

                    TextField("Search movies, TV shows...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                        .font(.bodyLarge)
                        .foregroundColor(.textPrimary)
                        .focused($isSearchFocused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.search)
                        .onSubmit {
                            Haptics.shared.buttonTapped()
                            viewModel.search()
                        }
                        .onChange(of: viewModel.searchQuery) { _ in
                            viewModel.search()
                        }

                    if !viewModel.searchQuery.isEmpty {
                        Button {
                            Haptics.shared.lightImpact()
                            viewModel.clearSearch()
                            isSearchFocused = true
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.textTertiary)
                        }
                    }

                    // Voice search button
                    Button {
                        Haptics.shared.buttonTapped()
                        // Voice search would be triggered here
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.accentPrimary)
                    }
                }
                .padding(Spacing.md)
                .background(Color.glassLight)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
                        .stroke(Color.glassBorder, lineWidth: 0.5)
                )

                // Filter button
                Button {
                    Haptics.shared.buttonTapped()
                    // TODO: Implement filters
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .frame(width: 48, height: 48)
                        .background(Color.glassLight)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                }
                .buttonStyle(ScaleButtonStyle())

                // Cancel button when searching
                if isSearchFocused {
                    Button("Cancel") {
                        Haptics.shared.lightImpact()
                        dismissKeyboard()
                        viewModel.clearSearch()
                    }
                    .font(.buttonMedium)
                    .foregroundColor(.accentPrimary)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, Spacing.horizontal)
            .animation(AppTheme.Animation.smooth, value: isSearchFocused)

        }
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Browse View

    private var browseView: some View {
        ScrollView {
            VStack(spacing: Spacing.xxl) {
                // Browse by Category
                browseCategoriesSection

                // Trending Searches
                trendingSearchesSection

                // Browse by Genre
                browseByGenreSection

                // Browse by Streaming
                browseByStreamingSection

                // Bottom padding
                Spacer()
                    .frame(height: 120)
            }
            .padding(.top, Spacing.md)
        }
    }

    private var browseCategoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Browse")
                .font(.headline1)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.horizontal)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: Spacing.md
            ) {
                ForEach(BrowseCategory.allCases) { category in
                    BrowseCategoryCard(category: category) {
                        Haptics.shared.cardTapped()
                        viewModel.searchQuery = category.searchQuery
                        viewModel.search()
                    }
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }

    private var trendingSearchesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.accentPrimary)
                Text("Trending Searches")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)
            }
            .padding(.horizontal, Spacing.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(trendingSearches, id: \.self) { term in
                        TrendingSearchPill(text: term) {
                            Haptics.shared.selectionChanged()
                            viewModel.searchQuery = term
                            viewModel.search()
                        }
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }

    private var browseByGenreSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Browse by Genre")
                .font(.headline2)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Genre.all) { genre in
                        GenreCardView(genre: genre) {
                            Haptics.shared.selectionChanged()
                            viewModel.searchQuery = genre.name
                            viewModel.search()
                        }
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }

    private var browseByStreamingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Browse by Streaming")
                .font(.headline2)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.horizontal)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: Spacing.md
            ) {
                ForEach(StreamingService.allCases) { service in
                    StreamingServiceCardView(service: service) {
                        Haptics.shared.selectionChanged()
                        viewModel.searchQuery = service.displayName
                        viewModel.search()
                    }
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }

    private var trendingSearches: [String] {
        ["Dune", "Oppenheimer", "Barbie", "Spider-Man", "Avatar", "Top Gun", "Marvel", "Star Wars"]
    }

    // MARK: - Search Results

    private var searchResultsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Results header
                HStack {
                    Text("\(viewModel.searchResults.count) results")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)

                    Spacer()

                    // Sort button
                    Menu {
                        Button("Most Popular", action: {})
                        Button("Highest Rated", action: {})
                        Button("Newest First", action: {})
                        Button("Title A-Z", action: {})
                    } label: {
                        HStack(spacing: 4) {
                            Text("Sort")
                                .font(.labelMedium)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
                .padding(.top, Spacing.sm)

                // Results grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: Spacing.md),
                        GridItem(.flexible(), spacing: Spacing.md)
                    ],
                    spacing: Spacing.lg
                ) {
                    ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, movie in
                        SearchResultCard(
                            movie: movie,
                            isInWatchlist: viewModel.isInWatchlist(movie),
                            onTap: {
                                dismissKeyboard()
                                Haptics.shared.cardTapped()
                                onMovieTap(movie)
                            },
                            onWatchlistToggle: {
                                viewModel.toggleWatchlist(for: movie)
                            }
                        )
                        .opacity(animateResults ? 1 : 0)
                        .offset(y: animateResults ? 0 : 20)
                        .animation(
                            AppTheme.Animation.smooth.delay(Double(index) * 0.03),
                            value: animateResults
                        )
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
                .padding(.bottom, 120)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            withAnimation {
                animateResults = true
            }
        }
        .onChange(of: viewModel.searchResults) { _ in
            animateResults = false
            withAnimation(AppTheme.Animation.smooth.delay(0.1)) {
                animateResults = true
            }
        }
    }

    // MARK: - Loading View

    private var searchLoadingView: some View {
        VStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .stroke(Color.glassLight, lineWidth: 3)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Color.accentPrimary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .modifier(SearchSpinnerModifier())
            }

            Text("Searching...")
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View

    private func searchErrorView(_ error: NetworkError) -> some View {
        VStack(spacing: Spacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.glassLight)
                    .frame(width: 100, height: 100)

                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.orange)
            }

            VStack(spacing: Spacing.sm) {
                Text("Search Failed")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                Text(error.errorDescription ?? "Please try again")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Haptics.shared.buttonTapped()
                viewModel.search()
            } label: {
                Text("Try Again")
                    .font(.buttonMedium)
                    .foregroundColor(.textInverted)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.horizontal)
    }

    // MARK: - No Results

    private var noResultsView: some View {
        VStack(spacing: Spacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.glassLight)
                    .frame(width: 100, height: 100)

                Image(systemName: "film.stack")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.textTertiary)
            }

            VStack(spacing: Spacing.sm) {
                Text("No Results")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                Text("No movies found for \"\(viewModel.searchQuery)\"")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Haptics.shared.buttonTapped()
                viewModel.clearSearch()
                isSearchFocused = true
            } label: {
                Text("Clear Search")
                    .font(.buttonMedium)
                    .foregroundColor(.textInverted)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.md)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.horizontal)
    }
}

// MARK: - Search Spinner Modifier

private struct SearchSpinnerModifier: ViewModifier {
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

// MARK: - Browse Category

enum BrowseCategory: String, CaseIterable, Identifiable {
    case trending = "Trending"
    case newReleases = "New Releases"
    case topRated = "Top Rated"
    case comingSoon = "Coming Soon"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .trending: return "flame.fill"
        case .newReleases: return "sparkles"
        case .topRated: return "star.fill"
        case .comingSoon: return "calendar"
        }
    }

    var color: Color {
        switch self {
        case .trending: return .orange
        case .newReleases: return .purple
        case .topRated: return .yellow
        case .comingSoon: return .blue
        }
    }

    var searchQuery: String {
        switch self {
        case .trending: return "trending"
        case .newReleases: return "2024"
        case .topRated: return "top rated"
        case .comingSoon: return "upcoming"
        }
    }
}

// MARK: - Browse Category Card

struct BrowseCategoryCard: View {
    let category: BrowseCategory
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: category.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(category.color)
                }

                Text(category.rawValue)
                    .font(.headline3)
                    .foregroundColor(.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textTertiary)
            }
            .padding(Spacing.md)
            .background(Color.glassLight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
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

// MARK: - Trending Search Pill

struct TrendingSearchPill: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12))
                Text(text)
                    .font(.labelMedium)
            }
            .foregroundColor(.textSecondary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.glassThin)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Genre Card View

struct GenreCardView: View {
    let genre: Genre
    let action: () -> Void

    @State private var isPressed = false

    private var genreColor: Color {
        Color.genre(genre.id)
    }

    private var genreIcon: String {
        switch genre.id {
        case 28: return "bolt.fill"          // Action
        case 12: return "map.fill"           // Adventure
        case 16: return "paintpalette.fill"  // Animation
        case 35: return "face.smiling.fill"  // Comedy
        case 80: return "magnifyingglass"    // Crime
        case 99: return "video.fill"         // Documentary
        case 18: return "theatermasks.fill"  // Drama
        case 10751: return "figure.2.and.child.holdinghands" // Family
        case 14: return "wand.and.stars"     // Fantasy
        case 27: return "moon.fill"          // Horror
        case 10749: return "heart.fill"      // Romance
        case 878: return "sparkles"          // Sci-Fi
        case 53: return "exclamationmark.triangle.fill" // Thriller
        default: return "film"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(genreColor.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: genreIcon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(genreColor)
                }

                Text(genre.name)
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)
            }
            .frame(width: 80)
            .scaleEffect(isPressed ? 0.95 : 1.0)
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

// MARK: - Streaming Service Card View

struct StreamingServiceCardView: View {
    let service: StreamingService
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Text(service.shortName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 36)
                    .background(service.color)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
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

// MARK: - Search Result Card

struct SearchResultCard: View {
    let movie: Movie
    let isInWatchlist: Bool
    let onTap: () -> Void
    let onWatchlistToggle: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
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
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))

                    // Watchlist button
                    Button {
                        Haptics.shared.addedToWatchlist()
                        onWatchlistToggle()
                    } label: {
                        Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isInWatchlist ? .accentPrimary : .white)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(Spacing.xs)
                }

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(movie.title)
                        .font(.labelMedium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)

                    HStack(spacing: Spacing.xs) {
                        if movie.voteAverage > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.ratingStar)
                                Text(movie.formattedRating)
                                    .font(.labelSmall)
                                    .foregroundColor(.textSecondary)
                            }
                        }

                        if let year = movie.releaseYear {
                            if movie.voteAverage > 0 {
                                Text("•")
                                    .foregroundColor(.textTertiary)
                            }
                            Text(year)
                                .font(.labelSmall)
                                .foregroundColor(.textTertiary)
                        }
                    }
                }
            }
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

// MARK: - Preview

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView(viewModel: .mock())
        }
        .preferredColorScheme(.dark)
    }
}
#endif
