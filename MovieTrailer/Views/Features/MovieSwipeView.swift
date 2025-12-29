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

    // Available filter options
    private let years = ["2025", "2024", "2023", "2022", "2021", "2020"]
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
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("\(viewModel.remainingCount) movies to explore")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Stats button
            Button {
                Haptics.shared.lightImpact()
                viewModel.showStats = true
            } label: {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
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
                        withAnimation(.easeInOut(duration: 0.2)) {
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
                        withAnimation {
                            selectedGenre = nil
                            selectedYear = nil
                            minRating = 0
                        }
                    } label: {
                        Text("Clear")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Card Stack

    private var cardStackView: some View {
        ZStack {
            // Background card (next)
            if let nextMovie = viewModel.nextMovie {
                movieCard(for: nextMovie, isBackground: true)
                    .scaleEffect(0.92)
                    .offset(y: -10)
                    .opacity(0.6)
                    .allowsHitTesting(false)
            }

            // Current card
            if let movie = filteredCurrentMovie {
                movieCard(for: movie, isBackground: false)
                    .id(movie.id)
            }
        }
        .padding(.horizontal, 24)
    }

    private func movieCard(for movie: Movie, isBackground: Bool) -> some View {
        SwipeCard(
            movie: movie,
            onSwipe: { direction in
                handleSwipe(direction, for: movie)
            },
            onTap: {
                onMovieTap(movie)
            }
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
        HStack(spacing: 20) {
            // Undo
            ActionButton(
                icon: "arrow.uturn.backward",
                size: 50,
                color: .white.opacity(0.2),
                iconColor: .white.opacity(viewModel.currentIndex > 0 ? 1 : 0.3)
            ) {
                guard viewModel.currentIndex > 0 else { return }
                Haptics.shared.lightImpact()
                viewModel.undo()
            }

            Spacer()

            // Skip (X)
            ActionButton(
                icon: "xmark",
                size: 64,
                color: Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.2),
                iconColor: Color(red: 0.9, green: 0.3, blue: 0.3)
            ) {
                Haptics.shared.mediumImpact()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    viewModel.skip()
                }
            }

            // Save for later
            ActionButton(
                icon: "bookmark.fill",
                size: 56,
                color: Color.cyan.opacity(0.2),
                iconColor: .cyan
            ) {
                Haptics.shared.mediumImpact()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    viewModel.watchLater()
                }
            }

            // Love
            ActionButton(
                icon: "heart.fill",
                size: 64,
                color: Color(red: 0.3, green: 0.8, blue: 0.4).opacity(0.2),
                iconColor: Color(red: 0.3, green: 0.8, blue: 0.4)
            ) {
                Haptics.shared.success()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    viewModel.like()
                }
            }

            Spacer()

            // Play trailer
            ActionButton(
                icon: "play.fill",
                size: 50,
                color: .white.opacity(0.2),
                iconColor: .white
            ) {
                Haptics.shared.lightImpact()
                if let movie = filteredCurrentMovie {
                    onPlayTrailer?(movie)
                }
            }
        }
        .padding(.horizontal, 32)
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
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("IT'S A MATCH!")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.green)

                Text("You loved \(movie.title)")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                // Movie poster
                AsyncImage(url: movie.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 160, height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .green.opacity(0.5), radius: 20)

                HStack(spacing: 16) {
                    Button {
                        onPlayTrailer?(movie)
                        viewModel.dismissMatch()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Watch Trailer")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }

                    Button {
                        viewModel.dismissMatch()
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(32)
        }
        .onTapGesture {
            viewModel.dismissMatch()
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
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(.subheadline.weight(.medium))

                if hasActiveFilter {
                    Circle()
                        .fill(Color.cyan)
                        .frame(width: 6, height: 6)
                }
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white : Color.white.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.2), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

struct ActionButton: View {
    let icon: String
    let size: CGFloat
    let color: Color
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.35, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(color)
                )
                .overlay(
                    Circle()
                        .stroke(iconColor.opacity(0.3), lineWidth: 2)
                )
        }
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
