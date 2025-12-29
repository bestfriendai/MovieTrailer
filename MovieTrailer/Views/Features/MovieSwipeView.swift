//
//  MovieSwipeView.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Tinder-style movie discovery view
//

import SwiftUI

struct MovieSwipeView: View {

    // MARK: - Properties

    @StateObject private var viewModel: MovieSwipeViewModel
    @State private var showingMovieDetail = false
    @State private var selectedMovie: Movie?

    let onMovieTap: (Movie) -> Void

    // MARK: - Initialization

    init(
        viewModel: MovieSwipeViewModel,
        onMovieTap: @escaping (Movie) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMovieTap = onMovieTap
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            VStack(spacing: 0) {
                // Header
                headerView

                Spacer()

                // Card stack
                if viewModel.isLoading && viewModel.movieQueue.isEmpty {
                    loadingView
                } else if let error = viewModel.error, viewModel.movieQueue.isEmpty {
                    errorView(error)
                } else if viewModel.currentMovie == nil {
                    emptyStateView
                } else {
                    cardStackView
                }

                Spacer()

                // Action buttons
                if viewModel.currentMovie != nil {
                    actionButtons
                }
            }
            .padding(.bottom, Spacing.xxxl + 60) // Space for tab bar

            // Match animation overlay
            if let matchMovie = viewModel.matchAnimation {
                matchOverlay(movie: matchMovie)
            }
        }
        .navigationTitle("Movie Match")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    viewModel.showStats.toggle()
                }) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $viewModel.showStats) {
            SwipeStatsSheet(viewModel: viewModel)
        }
        .task {
            if viewModel.movieQueue.isEmpty {
                await viewModel.loadMovies()
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.appBackground,
                Color.appBackground,
                Color.accentPrimary.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: Spacing.xs) {
            Text("\(viewModel.remainingCount) movies left")
                .font(.caption)
                .foregroundColor(.textSecondary)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.surfaceElevated)
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.accentPrimary)
                        .frame(
                            width: max(0, geometry.size.width * progressPercentage),
                            height: 4
                        )
                }
            }
            .frame(height: 4)
            .padding(.horizontal, Spacing.horizontal)
        }
        .padding(.top, Spacing.sm)
    }

    private var progressPercentage: CGFloat {
        guard !viewModel.movieQueue.isEmpty else { return 0 }
        return CGFloat(viewModel.currentIndex) / CGFloat(viewModel.movieQueue.count)
    }

    // MARK: - Card Stack

    private var cardStackView: some View {
        ZStack {
            // Next card (behind)
            if let nextMovie = viewModel.nextMovie {
                SwipeCard(
                    movie: nextMovie,
                    onSwipe: { _ in },
                    onTap: {}
                )
                .scaleEffect(0.95)
                .opacity(0.7)
                .allowsHitTesting(false)
            }

            // Current card (front)
            if let currentMovie = viewModel.currentMovie {
                SwipeCard(
                    movie: currentMovie,
                    onSwipe: viewModel.handleSwipe,
                    onTap: {
                        onMovieTap(currentMovie)
                    }
                )
                .id(currentMovie.id) // Force refresh when movie changes
            }
        }
        .padding(.horizontal, Spacing.horizontal)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: Spacing.xl) {
            // Undo button
            SwipeActionButton(
                icon: "arrow.uturn.backward",
                color: .orange,
                size: 50
            ) {
                viewModel.undo()
            }
            .opacity(viewModel.currentIndex > 0 ? 1 : 0.3)
            .disabled(viewModel.currentIndex == 0)

            // Skip button
            SwipeActionButton(
                icon: "xmark",
                color: .swipeSkip,
                size: 60
            ) {
                withAnimation(AppTheme.Animation.smooth) {
                    viewModel.skip()
                }
            }

            // Watch Later button
            SwipeActionButton(
                icon: "bookmark.fill",
                color: .swipeSuperLike,
                size: 50
            ) {
                withAnimation(AppTheme.Animation.smooth) {
                    viewModel.watchLater()
                }
            }

            // Like button
            SwipeActionButton(
                icon: "heart.fill",
                color: .swipeLike,
                size: 60
            ) {
                withAnimation(AppTheme.Animation.smooth) {
                    viewModel.like()
                }
            }

            // Info button
            SwipeActionButton(
                icon: "info.circle.fill",
                color: .blue,
                size: 50
            ) {
                if let movie = viewModel.currentMovie {
                    onMovieTap(movie)
                }
            }
        }
        .padding(.vertical, Spacing.lg)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.textSecondary)

            Text("Finding movies for you...")
                .font(.headline)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Error View

    private func errorView(_ error: NetworkError) -> some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Couldn't load movies")
                .font(.headline)
                .foregroundColor(.textPrimary)

            Text(error.errorDescription ?? "Please try again")
                .font(.subheadline)
                .foregroundColor(.textSecondary)

            Button(action: {
                Task {
                    await viewModel.loadMovies()
                }
            }) {
                Text("Try Again")
                    .font(.buttonMedium)
                    .foregroundColor(.black)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.playButton)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.swipeLike)

            Text("You've seen them all!")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)

            Text("You liked \(viewModel.likedMovies.count) movies")
                .font(.subheadline)
                .foregroundColor(.textSecondary)

            HStack(spacing: Spacing.md) {
                Button(action: {
                    viewModel.showStats = true
                }) {
                    Text("View Stats")
                        .font(.buttonMedium)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.surfaceElevated)
                        .clipShape(Capsule())
                }

                Button(action: {
                    Task {
                        await viewModel.reset()
                    }
                }) {
                    Text("Start Over")
                        .font(.buttonMedium)
                        .foregroundColor(.black)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.playButton)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
    }

    // MARK: - Match Overlay

    private func matchOverlay(movie: Movie) -> some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                Text("IT'S A MATCH!")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.swipeLike)

                Text("You and \(movie.title) both like each other")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Movie poster
                AsyncImage(url: movie.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 150, height: 225)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 20)

                Button(action: {
                    viewModel.dismissMatch()
                }) {
                    Text("Keep Swiping")
                        .font(.buttonMedium)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.xxxl)
                        .padding(.vertical, Spacing.md)
                        .background(
                            LinearGradient(
                                colors: [.swipeLike, .swipeLike.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
            }
            .padding()
        }
        .transition(.opacity)
        .onTapGesture {
            viewModel.dismissMatch()
        }
    }
}

// MARK: - Swipe Stats Sheet

struct SwipeStatsSheet: View {

    @ObservedObject var viewModel: MovieSwipeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    // Stats summary
                    statsGrid

                    // Liked movies
                    if !viewModel.likedMovies.isEmpty {
                        movieList(title: "Liked Movies", movies: viewModel.likedMovies, icon: "heart.fill", color: .swipeLike)
                    }

                    // Watch later
                    if !viewModel.watchLaterMovies.isEmpty {
                        movieList(title: "Watch Later", movies: viewModel.watchLaterMovies, icon: "bookmark.fill", color: .swipeSuperLike)
                    }
                }
                .padding(Spacing.horizontal)
            }
            .navigationTitle("Your Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
            statCard(title: "Liked", value: "\(viewModel.likedMovies.count)", icon: "heart.fill", color: .swipeLike)
            statCard(title: "Skipped", value: "\(viewModel.skippedMovies.count)", icon: "xmark", color: .swipeSkip)
            statCard(title: "Watch Later", value: "\(viewModel.watchLaterMovies.count)", icon: "bookmark.fill", color: .swipeSuperLike)
            statCard(title: "Match Rate", value: String(format: "%.0f%%", viewModel.likePercentage), icon: "percent", color: .purple)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)

            Text(value)
                .font(.title.bold())
                .foregroundColor(.textPrimary)

            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }

    private func movieList(title: String, movies: [Movie], icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("\(movies.count)")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(movies) { movie in
                        VStack(alignment: .leading) {
                            AsyncImage(url: movie.posterURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 80, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text(movie.title)
                                .font(.caption)
                                .lineLimit(1)
                                .frame(width: 80)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MovieSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MovieSwipeView(viewModel: .mock(), onMovieTap: { _ in })
        }
    }
}
#endif
