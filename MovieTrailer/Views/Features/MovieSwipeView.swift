//
//  MovieSwipeView.swift
//  MovieTrailer
//
//  Apple 2025 Ultimate Swipe Experience
//  Premium Tinder-style movie discovery with filters
//

import SwiftUI

struct MovieSwipeView: View {

    // MARK: - Properties

    @StateObject private var viewModel: MovieSwipeViewModel
    @State private var showingFilters = false
    @State private var showingMovieDetail = false
    @State private var selectedMovie: Movie?
    @State private var showTutorial = false

    let onMovieTap: (Movie) -> Void
    let onPlayTrailer: ((Movie) -> Void)?

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
            // Premium background
            premiumBackground

            VStack(spacing: 0) {
                // Premium header
                premiumHeader

                Spacer()

                // Card stack area
                if viewModel.isLoading && viewModel.movieQueue.isEmpty {
                    loadingView
                } else if let error = viewModel.error, viewModel.movieQueue.isEmpty {
                    errorView(error)
                } else if viewModel.currentMovie == nil {
                    emptyStateView
                } else {
                    cardStackArea
                }

                Spacer()

                // Premium action buttons
                if viewModel.currentMovie != nil {
                    premiumActionButtons
                }
            }
            .padding(.bottom, Spacing.xxxl + 80) // Space for tab bar

            // Match animation overlay
            if let matchMovie = viewModel.matchAnimation {
                MatchAnimationOverlay(
                    movie: matchMovie,
                    onDismiss: { viewModel.dismissMatch() },
                    onPlayTrailer: {
                        onPlayTrailer?(matchMovie)
                        viewModel.dismissMatch()
                    }
                )
            }

            // Tutorial overlay for first-time users
            if showTutorial {
                swipeTutorialOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Discover")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)
            }

            ToolbarItem(placement: .topBarLeading) {
                filterButton
            }

            ToolbarItem(placement: .topBarTrailing) {
                statsButton
            }
        }
        .sheet(isPresented: $viewModel.showStats) {
            PremiumSwipeStatsSheet(viewModel: viewModel)
        }
        .task {
            if viewModel.movieQueue.isEmpty {
                await viewModel.loadMovies()
            }
        }
        .onAppear {
            checkFirstTimeUser()
        }
    }

    // MARK: - Premium Background

    private var premiumBackground: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appBackground,
                    Color.surfaceSecondary.opacity(0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow based on current card
            if let movie = viewModel.currentMovie {
                ambientGlow(for: movie)
            }
        }
    }

    private func ambientGlow(for movie: Movie) -> some View {
        GeometryReader { geometry in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.accentPrimary.opacity(0.15),
                            Color.accentPrimary.opacity(0.05),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: geometry.size.width * 0.8
                    )
                )
                .frame(width: geometry.size.width * 1.5, height: geometry.size.width * 1.5)
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.4)
                .blur(radius: 60)
                .animation(AppTheme.Animation.slow, value: movie.id)
        }
        .ignoresSafeArea()
    }

    // MARK: - Premium Header

    private var premiumHeader: some View {
        VStack(spacing: Spacing.sm) {
            // Progress indicator
            HStack(spacing: Spacing.sm) {
                // Remaining count
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "film.stack")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                    Text("\(viewModel.remainingCount) remaining")
                        .font(.labelSmall)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // Session stats
                HStack(spacing: Spacing.md) {
                    miniStat(icon: "heart.fill", count: viewModel.likedMovies.count, color: .swipeLove)
                    miniStat(icon: "bookmark.fill", count: viewModel.watchLaterMovies.count, color: .swipeWatchLater)
                }
            }
            .padding(.horizontal, Spacing.horizontal)

            // Premium progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Color.glassLight)
                        .frame(height: 4)

                    // Progress
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.accentPrimary, .accentSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(0, geometry.size.width * progressPercentage),
                            height: 4
                        )
                        .animation(AppTheme.Animation.smooth, value: progressPercentage)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, Spacing.horizontal)

        }
        .padding(.top, Spacing.sm)
    }

    private func miniStat(icon: String, count: Int, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            Text("\(count)")
                .font(.labelSmall)
                .foregroundColor(.textSecondary)
        }
    }

    private var progressPercentage: CGFloat {
        guard !viewModel.movieQueue.isEmpty else { return 0 }
        return CGFloat(viewModel.currentIndex) / CGFloat(viewModel.movieQueue.count)
    }

    // MARK: - Card Stack Area

    private var cardStackArea: some View {
        ZStack {
            // Background card (next in queue)
            if let nextMovie = viewModel.nextMovie {
                SwipeCard(
                    movie: nextMovie,
                    onSwipe: { _ in },
                    onTap: {}
                )
                .scaleEffect(0.95)
                .offset(y: -8)
                .opacity(0.8)
                .allowsHitTesting(false)
            }

            // Current card (front)
            if let currentMovie = viewModel.currentMovie {
                SwipeCard(
                    movie: currentMovie,
                    onSwipe: { direction in
                        handleSwipe(direction, for: currentMovie)
                    },
                    onTap: {
                        onMovieTap(currentMovie)
                    }
                )
                .id(currentMovie.id)
            }
        }
        .padding(.horizontal, Spacing.lg)
    }

    private func handleSwipe(_ direction: SwipeCard.SwipeDirection, for movie: Movie) {
        switch direction {
        case .right:
            viewModel.like()
        case .left:
            viewModel.skip()
        case .up:
            viewModel.watchLater()
        }
    }

    // MARK: - Premium Action Buttons

    private var premiumActionButtons: some View {
        HStack(spacing: Spacing.lg) {
            // Undo button
            swipeActionButton(
                icon: "arrow.uturn.backward",
                color: .orange,
                size: 44,
                isEnabled: viewModel.currentIndex > 0,
                action: { viewModel.undo() }
            )

            // Skip button
            swipeActionButton(
                icon: "xmark",
                color: .swipeSkip,
                size: 60,
                action: {
                    withAnimation(AppTheme.Animation.swipeCard) {
                        viewModel.skip()
                    }
                }
            )

            // Watch Later button
            swipeActionButton(
                icon: "bookmark.fill",
                color: .swipeWatchLater,
                size: 52,
                action: {
                    withAnimation(AppTheme.Animation.swipeCard) {
                        viewModel.watchLater()
                    }
                }
            )

            // Love button
            swipeActionButton(
                icon: "heart.fill",
                color: .swipeLove,
                size: 60,
                action: {
                    withAnimation(AppTheme.Animation.swipeCard) {
                        viewModel.like()
                    }
                }
            )

            // Trailer button
            swipeActionButton(
                icon: "play.fill",
                color: .accentPrimary,
                size: 44,
                action: {
                    if let movie = viewModel.currentMovie {
                        onPlayTrailer?(movie)
                    }
                }
            )
        }
        .padding(.vertical, Spacing.lg)
        .padding(.horizontal, Spacing.horizontal)
    }

    private func swipeActionButton(
        icon: String,
        color: Color,
        size: CGFloat,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            Haptics.shared.buttonTapped()
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: size, height: size)

                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 2)
                    .frame(width: size, height: size)

                Image(systemName: icon)
                    .font(.system(size: size * 0.35, weight: .semibold))
                    .foregroundColor(isEnabled ? color : color.opacity(0.4))
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!isEnabled)
    }

    // MARK: - Toolbar Buttons

    private var filterButton: some View {
        Button {
            Haptics.shared.buttonTapped()
            // TODO: Implement filter sheet
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.textPrimary)
        }
    }

    private var statsButton: some View {
        Button {
            Haptics.shared.buttonTapped()
            viewModel.showStats = true
        } label: {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.textPrimary)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Spacing.xl) {
            // Animated loading indicator
            ZStack {
                Circle()
                    .stroke(Color.glassLight, lineWidth: 4)
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
                    .modifier(RotatingModifier())
            }

            VStack(spacing: Spacing.sm) {
                Text("Finding movies for you")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                Text("Curating the perfect selection...")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(Spacing.xxxl)
    }

    // MARK: - Error View

    private func errorView(_ error: NetworkError) -> some View {
        VStack(spacing: Spacing.xl) {
            // Error icon with glass background
            ZStack {
                Circle()
                    .fill(Color.glassLight)
                    .frame(width: 100, height: 100)

                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.orange)
            }

            VStack(spacing: Spacing.sm) {
                Text("Connection Issue")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                Text(error.errorDescription ?? "Please check your connection and try again")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await viewModel.loadMovies()
                }
            } label: {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.buttonMedium)
                .foregroundColor(.textInverted)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .background(Color.white)
                .clipShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(Spacing.horizontal)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.xl) {
            // Celebration animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.swipeLove.opacity(0.2), .swipeWatchLater.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.swipeLove, .swipeWatchLater],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: Spacing.sm) {
                Text("All Done!")
                    .font(.displaySmall)
                    .foregroundColor(.textPrimary)

                Text("You've reviewed all \(viewModel.movieQueue.count) movies")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
            }

            // Stats summary
            HStack(spacing: Spacing.xl) {
                statSummary(icon: "heart.fill", count: viewModel.likedMovies.count, label: "Loved", color: .swipeLove)
                statSummary(icon: "bookmark.fill", count: viewModel.watchLaterMovies.count, label: "Saved", color: .swipeWatchLater)
                statSummary(icon: "xmark", count: viewModel.skippedMovies.count, label: "Skipped", color: .swipeSkip)
            }

            // Action buttons
            HStack(spacing: Spacing.md) {
                Button {
                    viewModel.showStats = true
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "chart.bar.fill")
                        Text("View Stats")
                    }
                    .font(.buttonMedium)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .background(Color.glassLight)
                    .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle())

                Button {
                    Task {
                        await viewModel.reset()
                    }
                } label: {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "arrow.clockwise")
                        Text("Start Over")
                    }
                    .font(.buttonMedium)
                    .foregroundColor(.textInverted)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(Spacing.horizontal)
    }

    private func statSummary(icon: String, count: Int, label: String, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text("\(count)")
                .font(.headline1)
                .foregroundColor(.textPrimary)

            Text(label)
                .font(.labelSmall)
                .foregroundColor(.textTertiary)
        }
    }

    // MARK: - Tutorial Overlay

    private var swipeTutorialOverlay: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: Spacing.xxxl) {
                Text("How to Swipe")
                    .font(.displaySmall)
                    .foregroundColor(.textPrimary)

                VStack(spacing: Spacing.xl) {
                    tutorialItem(
                        icon: "arrow.right",
                        color: .swipeLove,
                        title: "Swipe Right",
                        description: "Add to your loved movies"
                    )

                    tutorialItem(
                        icon: "arrow.left",
                        color: .swipeSkip,
                        title: "Swipe Left",
                        description: "Skip this movie"
                    )

                    tutorialItem(
                        icon: "arrow.up",
                        color: .swipeWatchLater,
                        title: "Swipe Up",
                        description: "Save for later"
                    )
                }

                Button {
                    withAnimation(AppTheme.Animation.smooth) {
                        showTutorial = false
                        UserDefaults.standard.set(true, forKey: "hasSeenSwipeTutorial")
                    }
                } label: {
                    Text("Got It")
                        .font(.buttonLarge)
                        .foregroundColor(.textInverted)
                        .padding(.horizontal, Spacing.xxxl)
                        .padding(.vertical, Spacing.md)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(Spacing.horizontal)
        }
        .transition(.opacity)
    }

    private func tutorialItem(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                Text(description)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
    }

    private func checkFirstTimeUser() {
        if !UserDefaults.standard.bool(forKey: "hasSeenSwipeTutorial") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(AppTheme.Animation.smooth) {
                    showTutorial = true
                }
            }
        }
    }
}

// MARK: - Rotating Modifier

private struct RotatingModifier: ViewModifier {
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

// MARK: - Match Animation Overlay

struct MatchAnimationOverlay: View {
    let movie: Movie
    let onDismiss: () -> Void
    let onPlayTrailer: () -> Void

    @State private var showContent = false
    @State private var particleSystem = false

    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            // Particles
            if particleSystem {
                ParticleEffect()
            }

            // Content
            VStack(spacing: Spacing.xl) {
                // Match text
                Text("IT'S A MATCH!")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.swipeLove, .swipeWatchLater, .accentPrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .swipeLove.opacity(0.5), radius: 20)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                Text("You loved \(movie.title)")
                    .font(.headline2)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)

                // Movie poster with glow
                ZStack {
                    // Glow
                    AsyncImage(url: movie.posterURL) { image in
                        image
                            .resizable()
                            .blur(radius: 40)
                            .opacity(0.6)
                    } placeholder: {
                        Color.clear
                    }
                    .frame(width: 200, height: 300)

                    // Poster
                    AsyncImage(url: movie.posterURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                    }
                    .frame(width: 180, height: 270)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
                    .shadow(color: .swipeLove.opacity(0.5), radius: 30)
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)

                // Action buttons
                HStack(spacing: Spacing.md) {
                    Button {
                        onPlayTrailer()
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "play.fill")
                            Text("Watch Trailer")
                        }
                        .font(.buttonMedium)
                        .foregroundColor(.textInverted)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.md)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())

                    Button {
                        onDismiss()
                    } label: {
                        Text("Keep Swiping")
                            .font(.buttonMedium)
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.md)
                            .background(Color.glassLight)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .opacity(showContent ? 1 : 0)
            }
            .padding(Spacing.horizontal)
        }
        .onAppear {
            Haptics.shared.success()
            withAnimation(AppTheme.Animation.bouncy.delay(0.1)) {
                showContent = true
            }
            withAnimation(.linear(duration: 0.1)) {
                particleSystem = true
            }
        }
        .onTapGesture {
            onDismiss()
        }
    }
}

// MARK: - Particle Effect

struct ParticleEffect: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var scale: CGFloat
        var opacity: Double
        var color: Color
        var rotation: Double
    }

    var body: some View {
        GeometryReader { geometry in
            ForEach(particles) { particle in
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(particle.color)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .rotationEffect(.degrees(particle.rotation))
                    .position(x: particle.x, y: particle.y)
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        let colors: [Color] = [.swipeLove, .swipeWatchLater, .accentPrimary, .white]

        for i in 0..<30 {
            let particle = Particle(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 50,
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.5...1.0),
                color: colors.randomElement() ?? .swipeLove,
                rotation: Double.random(in: 0...360)
            )
            particles.append(particle)

            // Animate particle
            withAnimation(
                Animation.easeOut(duration: Double.random(in: 1.5...3.0))
                    .delay(Double(i) * 0.05)
            ) {
                particles[i].y = CGFloat.random(in: -100...size.height * 0.3)
                particles[i].opacity = 0
                particles[i].rotation += Double.random(in: 180...540)
            }
        }
    }
}

// MARK: - Premium Swipe Stats Sheet

struct PremiumSwipeStatsSheet: View {

    @ObservedObject var viewModel: MovieSwipeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    // Hero stats
                    heroStatsSection

                    // Match rate chart
                    matchRateSection

                    // Liked movies
                    if !viewModel.likedMovies.isEmpty {
                        movieSection(
                            title: "Movies You Loved",
                            icon: "heart.fill",
                            color: .swipeLove,
                            movies: viewModel.likedMovies
                        )
                    }

                    // Watch later
                    if !viewModel.watchLaterMovies.isEmpty {
                        movieSection(
                            title: "Watch Later",
                            icon: "bookmark.fill",
                            color: .swipeWatchLater,
                            movies: viewModel.watchLaterMovies
                        )
                    }

                    // Genre breakdown
                    genreBreakdownSection
                }
                .padding(Spacing.horizontal)
                .padding(.bottom, Spacing.xxxl)
            }
            .background(Color.appBackground)
            .navigationTitle("Your Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accentPrimary)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var heroStatsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
            premiumStatCard(
                title: "Loved",
                value: "\(viewModel.likedMovies.count)",
                icon: "heart.fill",
                color: .swipeLove
            )

            premiumStatCard(
                title: "Skipped",
                value: "\(viewModel.skippedMovies.count)",
                icon: "xmark",
                color: .swipeSkip
            )

            premiumStatCard(
                title: "Watch Later",
                value: "\(viewModel.watchLaterMovies.count)",
                icon: "bookmark.fill",
                color: .swipeWatchLater
            )

            premiumStatCard(
                title: "Match Rate",
                value: String(format: "%.0f%%", viewModel.likePercentage),
                icon: "percent",
                color: .accentPrimary
            )
        }
    }

    private func premiumStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(spacing: Spacing.xxs) {
                Text(value)
                    .font(.displaySmall)
                    .foregroundColor(.textPrimary)

                Text(title)
                    .font(.labelMedium)
                    .foregroundColor(.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }

    private var matchRateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Match Analysis")
                .font(.headline2)
                .foregroundColor(.textPrimary)

            // Ring chart
            HStack(spacing: Spacing.xl) {
                // Ring
                ZStack {
                    Circle()
                        .stroke(Color.glassLight, lineWidth: 12)
                        .frame(width: 100, height: 100)

                    Circle()
                        .trim(from: 0, to: viewModel.likePercentage / 100)
                        .stroke(
                            LinearGradient(
                                colors: [.swipeLove, .accentPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))

                    Text(String(format: "%.0f%%", viewModel.likePercentage))
                        .font(.headline1)
                        .foregroundColor(.textPrimary)
                }

                // Legend
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    legendItem(color: .swipeLove, label: "Loved", count: viewModel.likedMovies.count)
                    legendItem(color: .swipeWatchLater, label: "Saved", count: viewModel.watchLaterMovies.count)
                    legendItem(color: .swipeSkip, label: "Skipped", count: viewModel.skippedMovies.count)
                }
            }
            .padding(Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        }
    }

    private func legendItem(color: Color, label: String, count: Int) -> some View {
        HStack(spacing: Spacing.sm) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(label)
                .font(.labelMedium)
                .foregroundColor(.textSecondary)

            Spacer()

            Text("\(count)")
                .font(.labelMedium)
                .foregroundColor(.textPrimary)
        }
    }

    private func movieSection(title: String, icon: String, color: Color, movies: [Movie]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline2)
                    .foregroundColor(.textPrimary)
                Spacer()
                Text("\(movies.count)")
                    .font(.labelMedium)
                    .foregroundColor(.textTertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(movies) { movie in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            AsyncImage(url: movie.posterURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.surfaceSecondary)
                            }
                            .frame(width: 100, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))

                            Text(movie.title)
                                .font(.labelSmall)
                                .foregroundColor(.textPrimary)
                                .lineLimit(2)
                                .frame(width: 100, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    private var genreBreakdownSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Genre Preferences")
                .font(.headline2)
                .foregroundColor(.textPrimary)

            let genreCounts = calculateGenreCounts()
            let sortedGenres = genreCounts.sorted { $0.value > $1.value }.prefix(5)

            VStack(spacing: Spacing.sm) {
                ForEach(Array(sortedGenres), id: \.key) { genre, count in
                    genreBar(genre: genre, count: count, maxCount: sortedGenres.first?.value ?? 1)
                }
            }
            .padding(Spacing.lg)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        }
    }

    private func genreBar(genre: String, count: Int, maxCount: Int) -> some View {
        HStack(spacing: Spacing.md) {
            Text(genre)
                .font(.labelMedium)
                .foregroundColor(.textSecondary)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.glassLight)
                        .frame(height: 8)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.accentPrimary, .accentSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(count) / CGFloat(maxCount), height: 8)
                }
            }
            .frame(height: 8)

            Text("\(count)")
                .font(.labelMedium)
                .foregroundColor(.textPrimary)
                .frame(width: 30, alignment: .trailing)
        }
    }

    private func calculateGenreCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        for movie in viewModel.likedMovies {
            for genreId in movie.genreIds {
                if let genre = Genre.genre(for: genreId) {
                    counts[genre.name, default: 0] += 1
                }
            }
        }
        return counts
    }
}

// MARK: - Preview

#if DEBUG
struct MovieSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MovieSwipeView(viewModel: .mock(), onMovieTap: { _ in })
        }
        .preferredColorScheme(.dark)
    }
}
#endif
