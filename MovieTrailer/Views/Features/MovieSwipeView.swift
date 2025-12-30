//
//  MovieSwipeView.swift
//  MovieTrailer
//
//  Premium Movie Discovery with Swipe Interface
//  Includes working filters, clean design, and haptic feedback
//

import SwiftUI

struct MovieSwipeView: View {

    // MARK: - Properties

    @StateObject private var viewModel: MovieSwipeViewModel
    @State private var showingFilters = false
    @State private var selectedGenre: Genre?
    @State private var selectedYear: String?
    @State private var minRating: Double = 0

    let onMovieTap: (Movie) -> Void
    let onPlayTrailer: ((Movie) -> Void)?

    // Available filter options - dynamic years
    private var years: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (0..<6).map { String(currentYear - $0) }
    }
    private let ratingOptions: [Double] = [0, 5, 6, 7, 8]

    // MARK: - Initialization

    init(
        viewModel: MovieSwipeViewModel,
        onMovieTap: @escaping (Movie) -> Void,
        onPlayTrailer: ((Movie) -> Void)? = nil
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

            VStack(spacing: 0) {
                // Header with title
                headerView

                // Filter chips
                filterChips
                    .padding(.top, 12)

                // Main content
                if viewModel.isLoading && viewModel.movieQueue.isEmpty {
                    loadingView
                } else if let error = viewModel.error, viewModel.movieQueue.isEmpty {
                    errorView(error)
                } else if filteredCurrentMovie == nil {
                    emptyStateView
                } else {
                    // Card stack
                    cardStackView
                        .padding(.top, 16)

                    Spacer(minLength: 16)

                    // Action buttons
                    actionButtonsView
                        .padding(.bottom, 100)
                }
            }

            // Match celebration overlay
            if let matchMovie = viewModel.matchAnimation {
                matchOverlay(movie: matchMovie)
            }
        }
        .sheet(isPresented: $showingFilters) {
            filterSheet
        }
        .sheet(isPresented: $viewModel.showStats) {
            statsSheet
        }
        .task {
            if viewModel.movieQueue.isEmpty {
                await viewModel.loadMovies()
            }
        }
    }

    // MARK: - Filtered Movie

    /// Get current movie if it matches filters, or find next matching one
    private var filteredCurrentMovie: Movie? {
        // If no filters are active, return the current movie
        if selectedGenre == nil && selectedYear == nil && minRating == 0 {
            return viewModel.currentMovie
        }

        // Find the first movie in queue (starting from current index) that matches filters
        for i in viewModel.currentIndex..<viewModel.movieQueue.count {
            let movie = viewModel.movieQueue[i]

            // Check genre filter
            if let genre = selectedGenre {
                guard movie.genreIds.contains(genre.id) else { continue }
            }

            // Check year filter
            if let year = selectedYear {
                guard movie.releaseDate?.hasPrefix(year) == true else { continue }
            }

            // Check rating filter
            if minRating > 0 {
                guard movie.voteAverage >= minRating else { continue }
            }

            return movie
        }

        return nil
    }

    /// Index of the currently filtered movie (for swipe handling)
    private var filteredCurrentIndex: Int? {
        guard let movie = filteredCurrentMovie else { return nil }
        return viewModel.movieQueue.firstIndex(where: { $0.id == movie.id })
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Discover")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)

                Text("\(viewModel.remainingCount) movies to explore")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Stats button with glass effect
            Button {
                Haptics.shared.lightImpact()
                viewModel.showStats = true
            } label: {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, Spacing.horizontal)
        .padding(.top, Spacing.sm)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // All filters button
                FilterChip(
                    title: "Filters",
                    icon: "slider.horizontal.3",
                    isSelected: showingFilters,
                    hasActiveFilter: selectedGenre != nil || selectedYear != nil || minRating > 0
                ) {
                    Haptics.shared.lightImpact()
                    showingFilters = true
                }

                // Genre quick filters
                ForEach([Genre.action, Genre.comedy, Genre.drama, Genre.horror, Genre.scienceFiction], id: \.id) { genre in
                    FilterChip(
                        title: genre.name,
                        isSelected: selectedGenre?.id == genre.id
                    ) {
                        Haptics.shared.selectionChanged()
                        withAnimation(AppTheme.Animation.snappy) {
                            if selectedGenre?.id == genre.id {
                                selectedGenre = nil
                            } else {
                                selectedGenre = genre
                            }
                        }
                    }
                }

                // Clear filters
                if selectedGenre != nil || selectedYear != nil || minRating > 0 {
                    Button {
                        Haptics.shared.lightImpact()
                        withAnimation(AppTheme.Animation.snappy) {
                            selectedGenre = nil
                            selectedYear = nil
                            minRating = 0
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                            Text("Clear")
                                .font(.subheadline.weight(.semibold))
                        }
                        .foregroundColor(.accentPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }

    // MARK: - Card Stack

    private var upcomingMovies: [Movie] {
        // Get the next 3 movies for the stack effect
        let startIndex = viewModel.currentIndex + 1
        let endIndex = min(startIndex + 3, viewModel.movieQueue.count)
        guard startIndex < viewModel.movieQueue.count else { return [] }
        return Array(viewModel.movieQueue[startIndex..<endIndex])
    }

    private var cardStackView: some View {
        ZStack {
            // Background cards for depth effect (show up to 2 behind)
            ForEach(Array(upcomingMovies.prefix(2).reversed().enumerated()), id: \.element.id) { index, movie in
                let depth = upcomingMovies.prefix(2).count - 1 - index
                movieCard(for: movie, isTopCard: false)
                    .scaleEffect(0.88 - (CGFloat(depth) * 0.04))
                    .offset(y: CGFloat(depth + 1) * -12)
                    .opacity(0.4 - (Double(depth) * 0.15))
                    .blur(radius: CGFloat(depth) * 0.5)
                    .allowsHitTesting(false)
            }

            // Current card
            if let movie = filteredCurrentMovie {
                movieCard(for: movie, isTopCard: true)
                    .id(movie.id)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .identity
                    ))
            }
        }
        .padding(.horizontal, 20)
    }

    private func movieCard(for movie: Movie, isTopCard: Bool) -> some View {
        SwipeCard(
            movie: movie,
            onSwipe: { direction in
                handleSwipe(direction, for: movie)
            },
            onTap: {
                onMovieTap(movie)
            },
            isTopCard: isTopCard
        )
    }

    private func handleSwipe(_ direction: SwipeCard.SwipeDirection, for movie: Movie) {
        // If filtered movie is ahead of current index, sync the index first
        if let movieIndex = viewModel.movieQueue.firstIndex(where: { $0.id == movie.id }),
           movieIndex > viewModel.currentIndex {
            viewModel.currentIndex = movieIndex
        }

        switch direction {
        case .right:
            viewModel.like()
        case .left:
            viewModel.skip()
        case .up:
            viewModel.watchLater()
        }
    }

    // MARK: - Action Buttons

    private var actionButtonsView: some View {
        HStack(spacing: 0) {
            // Undo - small secondary button
            SmallActionButton(
                icon: "arrow.uturn.backward",
                isEnabled: viewModel.currentIndex > 0
            ) {
                guard viewModel.currentIndex > 0 else { return }
                Haptics.shared.lightImpact()
                viewModel.undo()
            }

            Spacer()

            // Main action buttons
            HStack(spacing: 16) {
                // Skip (X)
                MainActionButton(
                    icon: "xmark",
                    color: .swipeSkip,
                    size: 60
                ) {
                    Haptics.shared.mediumImpact()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.skip()
                    }
                }

                // Save for later - elevated center
                MainActionButton(
                    icon: "bookmark.fill",
                    color: .swipeWatchLater,
                    size: 52
                ) {
                    Haptics.shared.mediumImpact()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.watchLater()
                    }
                }

                // Love
                MainActionButton(
                    icon: "heart.fill",
                    color: .swipeLove,
                    size: 60
                ) {
                    Haptics.shared.success()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        viewModel.like()
                    }
                }
            }

            Spacer()

            // Play trailer - small secondary button
            SmallActionButton(
                icon: "play.fill",
                isEnabled: filteredCurrentMovie != nil
            ) {
                Haptics.shared.lightImpact()
                if let movie = filteredCurrentMovie {
                    onPlayTrailer?(movie)
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            List {
                // Genre Section
                Section("Genre") {
                    ForEach(Genre.all.prefix(15)) { genre in
                        Button {
                            if selectedGenre?.id == genre.id {
                                selectedGenre = nil
                            } else {
                                selectedGenre = genre
                            }
                        } label: {
                            HStack {
                                Text(genre.name)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedGenre?.id == genre.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.cyan)
                                }
                            }
                        }
                    }
                }

                // Year Section
                Section("Release Year") {
                    ForEach(years, id: \.self) { year in
                        Button {
                            if selectedYear == year {
                                selectedYear = nil
                            } else {
                                selectedYear = year
                            }
                        } label: {
                            HStack {
                                Text(year)
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedYear == year {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.cyan)
                                }
                            }
                        }
                    }
                }

                // Rating Section
                Section("Minimum Rating") {
                    ForEach(ratingOptions, id: \.self) { rating in
                        Button {
                            minRating = rating
                        } label: {
                            HStack {
                                if rating == 0 {
                                    Text("Any")
                                        .foregroundColor(.white)
                                } else {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        Text("\(Int(rating))+")
                                            .foregroundColor(.white)
                                    }
                                }
                                Spacer()
                                if minRating == rating {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.cyan)
                                }
                            }
                        }
                    }
                }

                // Clear all
                Section {
                    Button("Clear All Filters") {
                        selectedGenre = nil
                        selectedYear = nil
                        minRating = 0
                        showingFilters = false
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
                    .foregroundColor(.cyan)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }

    // MARK: - Stats Sheet

    private var statsSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Loved", value: "\(viewModel.likedMovies.count)", icon: "heart.fill", color: .green)
                        StatCard(title: "Skipped", value: "\(viewModel.skippedMovies.count)", icon: "xmark", color: .red)
                        StatCard(title: "Saved", value: "\(viewModel.watchLaterMovies.count)", icon: "bookmark.fill", color: .cyan)
                        StatCard(title: "Match Rate", value: String(format: "%.0f%%", viewModel.likePercentage), icon: "percent", color: .orange)
                    }
                    .padding(.horizontal, 20)

                    // Liked movies
                    if !viewModel.likedMovies.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Movies You Loved")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.likedMovies) { movie in
                                        MoviePosterCard(movie: movie) {
                                            onMovieTap(movie)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    // Saved movies
                    if !viewModel.watchLaterMovies.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Saved for Later")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.watchLaterMovies) { movie in
                                        MoviePosterCard(movie: movie) {
                                            onMovieTap(movie)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color.black)
            .navigationTitle("Your Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.showStats = false
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)

            Text("Finding movies for you...")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error View

    private func errorView(_ error: NetworkError) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Connection Error")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text(error.errorDescription ?? "Please check your connection")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.loadMovies()
                }
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("All Done!")
                .font(.title.bold())
                .foregroundColor(.white)

            Text("You've reviewed all available movies")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 16) {
                Button {
                    viewModel.showStats = true
                } label: {
                    Text("View Stats")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }

                Button {
                    Task {
                        await viewModel.reset()
                    }
                } label: {
                    Text("Start Over")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Match Overlay

    private func matchOverlay(movie: Movie) -> some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color.swipeLove.opacity(0.3),
                    Color.black.opacity(0.95),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Floating particles effect
            GeometryReader { geometry in
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(Color.swipeLove.opacity(Double.random(in: 0.2...0.5)))
                        .frame(width: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .blur(radius: 2)
                }
            }

            VStack(spacing: 28) {
                // Animated heart icon
                ZStack {
                    // Pulsing outer ring
                    Circle()
                        .stroke(Color.swipeLove.opacity(0.3), lineWidth: 4)
                        .frame(width: 100, height: 100)

                    Circle()
                        .fill(Color.swipeLove.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.swipeLove)
                }
                .shadow(color: .swipeLove.opacity(0.6), radius: 30)

                // Title
                VStack(spacing: 8) {
                    Text("IT'S A MATCH!")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .swipeLove],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("You loved")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }

                // Movie poster with glow
                AsyncImage(url: movie.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 140, height: 210)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.swipeLove.opacity(0.5), lineWidth: 2)
                )
                .shadow(color: .swipeLove.opacity(0.6), radius: 30, y: 10)

                // Movie title
                Text(movie.title)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 20)

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        onPlayTrailer?(movie)
                        viewModel.dismissMatch()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .bold))
                            Text("Watch Trailer")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .white.opacity(0.3), radius: 12, y: 4)
                    }
                    .padding(.horizontal, 40)

                    Button {
                        viewModel.dismissMatch()
                    } label: {
                        Text("Keep Swiping")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 12)
                    }
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
        .onTapGesture {
            viewModel.dismissMatch()
        }
        .onAppear {
            // Auto-dismiss after 4 seconds if user doesn't interact
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(AppTheme.Animation.smooth) {
                    viewModel.dismissMatch()
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    var isSelected: Bool = false
    var hasActiveFilter: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold))

                if hasActiveFilter {
                    Circle()
                        .fill(Color.accentPrimary)
                        .frame(width: 6, height: 6)
                }
            }
            .foregroundColor(isSelected ? .black : .textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(Color.accentPrimary)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                    }
                }
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color.glassBorder,
                        lineWidth: 1
                    )
            )
            .shadow(color: isSelected ? Color.accentPrimary.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(AppTheme.Animation.snappy, value: isSelected)
    }
}

// MARK: - Main Action Button (Skip, Save, Love)

struct MainActionButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: size + 16, height: size + 16)
                    .blur(radius: 12)

                // Main circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.25),
                                color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)

                // Glass overlay
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size, height: size)
                    .opacity(0.4)

                // Border with gradient
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.6), color.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: size, height: size)

                // Icon
                Image(systemName: icon)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(color)
            }
            .shadow(color: color.opacity(0.5), radius: 16, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Small Action Button (Undo, Play)

struct SmallActionButton: View {
    let icon: String
    var isEnabled: Bool = true
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)

                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(isEnabled ? 0.9 : 0.3))
            }
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Legacy Action Button (for compatibility)

struct ActionButton: View {
    let icon: String
    let size: CGFloat
    let color: Color
    let iconColor: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: size + 8, height: size + 8)
                    .blur(radius: 8)

                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size, height: size)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [iconColor.opacity(0.2), iconColor.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)

                Circle()
                    .stroke(iconColor.opacity(0.3), lineWidth: 2)
                    .frame(width: size, height: size)

                Image(systemName: icon)
                    .font(.system(size: size * 0.38, weight: .bold))
                    .foregroundColor(iconColor)
            }
            .shadow(color: iconColor.opacity(0.4), radius: 12, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct MoviePosterCard: View {
    let movie: Movie
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: movie.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 100, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(movie.title)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .frame(width: 100, alignment: .leading)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MovieSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        MovieSwipeView(
            viewModel: MovieSwipeViewModel(
                tmdbService: .shared,
                watchlistManager: WatchlistManager()
            ),
            onMovieTap: { _ in }
        )
        .preferredColorScheme(.dark)
    }
}
#endif
