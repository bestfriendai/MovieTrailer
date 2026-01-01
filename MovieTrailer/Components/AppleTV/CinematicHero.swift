//
//  CinematicHero.swift
//  MovieTrailer
//
//  Apple 2025 Premium Cinematic Hero
//  Full-bleed hero banner with auto-rotation
//

import SwiftUI
import Kingfisher

// MARK: - Cinematic Hero

struct CinematicHero: View {

    let movie: Movie
    let onPlay: () -> Void
    let onAddToList: () -> Void
    let onTap: () -> Void
    let isInWatchlist: Bool

    @State private var parallaxOffset: CGFloat = 0
    @State private var addedAnimating = false

    init(
        movie: Movie,
        onPlay: @escaping () -> Void,
        onAddToList: @escaping () -> Void,
        onTap: @escaping () -> Void,
        isInWatchlist: Bool = false
    ) {
        self.movie = movie
        self.onPlay = onPlay
        self.onAddToList = onAddToList
        self.onTap = onTap
        self.isInWatchlist = isInWatchlist
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background image with parallax
                heroImage(size: geometry.size)
                    .offset(y: parallaxOffset * 0.3)

                // Vignette overlay
                RadialGradient(
                    colors: [.clear, .black.opacity(0.2), .black.opacity(0.5)],
                    center: .center,
                    startRadius: 100,
                    endRadius: geometry.size.width
                )

                // Bottom gradient for content
                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.4),
                        .black.opacity(0.8),
                        .black.opacity(0.95),
                        .black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: geometry.size.height * 0.6)
                .frame(maxHeight: .infinity, alignment: .bottom)

                // Content overlay
                heroContent
                    .padding(.horizontal, Spacing.horizontal)
                    .padding(.bottom, 64) // Extra space for page indicators
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(height: Size.heroHeight)
        .onTapGesture {
            Haptics.shared.cardTapped()
            onTap()
        }
    }

    // MARK: - Hero Image

    private func heroImage(size: CGSize) -> some View {
        KFImage(movie.backdropURL ?? movie.posterURL)
            .placeholder {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.surfacePrimary, Color.surfaceSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shimmer(isActive: true)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height * 1.1)
            .clipped()
    }

    // MARK: - Hero Content

    private var heroContent: some View {
        VStack(spacing: Spacing.md) {
            // Title
            Text(movie.title)
                .font(.displayMedium)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .truncationMode(.tail)
                .minimumScaleFactor(0.8)
                .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)

            // Metadata row
            metadataRow

            // Genre tags
            if let genres = movie.genreNames, !genres.isEmpty {
                genreTags(genres: Array(genres.prefix(3)))
            }

            // Action buttons
            actionButtons
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(heroContentBackground)
    }

    private var heroContentBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.6
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 12)
    }

    private var metadataRow: some View {
        HStack(spacing: Spacing.md) {
            // Rating
            HStack(spacing: Spacing.xs) {
                Image(systemName: "star.fill")
                    .foregroundColor(.ratingStar)
                Text(movie.formattedRating)
                    .fontWeight(.bold)
            }
            .font(.labelLarge)
            .foregroundColor(.textPrimary)

            // Separator
            Circle()
                .fill(Color.textTertiary)
                .frame(width: 4, height: 4)

            // Year
            if let year = movie.releaseYear {
                Text(year)
                    .font(.labelLarge)
                    .foregroundColor(.textSecondary)
            }

            // Separator
            if movie.voteCount > 0 {
                Circle()
                    .fill(Color.textTertiary)
                    .frame(width: 4, height: 4)

                // Vote count
                Text(formatVoteCount(movie.voteCount))
                    .font(.labelMedium)
                    .foregroundColor(.textTertiary)
            }
        }
    }

    private func genreTags(genres: [String]) -> some View {
        HStack(spacing: Spacing.xs) {
            ForEach(genres, id: \.self) { genre in
                Text(genre)
                    .font(.pillSmall)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: Spacing.md) {
            // Watch Trailer button
            Button {
                Haptics.shared.buttonTapped()
                onPlay()
            } label: {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Watch Trailer")
                        .font(.buttonMedium)
                }
                .foregroundColor(.textInverted)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.sm)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 0)
            }
            .buttonStyle(ScaleButtonStyle())

            // Add to list button
            Button {
                Haptics.shared.addedToWatchlist()
                withAnimation(AppTheme.Animation.bouncy) {
                    addedAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(AppTheme.Animation.standard) {
                        addedAnimating = false
                    }
                }
                onAddToList()
            } label: {
                Image(systemName: isInWatchlist ? "checkmark" : "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .scaleEffect(addedAnimating ? 1.3 : 1.0)
                    .frame(width: Size.actionButtonMedium, height: Size.actionButtonMedium)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.glassBorder, lineWidth: 0.5)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, Spacing.sm)
    }

    private func formatVoteCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fK reviews", Double(count) / 1000)
        }
        return "\(count) reviews"
    }
}

// MARK: - Hero Carousel (Apple TV Style)

struct CinematicHeroCarousel: View {

    let movies: [Movie]
    let onPlay: (Movie) -> Void
    let onAddToList: (Movie) -> Void
    let onTap: (Movie) -> Void
    let watchlistChecker: ((Movie) -> Bool)?

    @State private var currentIndex = 0
    @State private var isAutoPlaying = true
    private let timer = Timer.publish(every: AppTheme.Duration.carousel, on: .main, in: .common).autoconnect()

    init(
        movies: [Movie],
        onPlay: @escaping (Movie) -> Void,
        onAddToList: @escaping (Movie) -> Void,
        onTap: @escaping (Movie) -> Void,
        watchlistChecker: ((Movie) -> Bool)? = nil
    ) {
        self.movies = movies
        self.onPlay = onPlay
        self.onAddToList = onAddToList
        self.onTap = onTap
        self.watchlistChecker = watchlistChecker
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Carousel
            TabView(selection: $currentIndex) {
                ForEach(Array(movies.prefix(5).enumerated()), id: \.element.id) { index, movie in
                    CinematicHero(
                        movie: movie,
                        onPlay: { onPlay(movie) },
                        onAddToList: { onAddToList(movie) },
                        onTap: { onTap(movie) },
                        isInWatchlist: watchlistChecker?(movie) ?? false
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: Size.heroHeight)

            // Page indicators - positioned inside the hero area
            pageIndicators
                .padding(.bottom, 16)
        }
        .frame(height: Size.heroHeight)
        .onReceive(timer) { _ in
            guard isAutoPlaying else { return }
            advanceCarousel()
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    isAutoPlaying = false
                }
                .onEnded { _ in
                    // Resume auto-play after 10 seconds of inactivity
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        isAutoPlaying = true
                    }
                }
        )
    }

    private var pageIndicators: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(0..<min(movies.count, 5), id: \.self) { index in
                Button {
                    Haptics.shared.selectionChanged()
                    withAnimation(AppTheme.Animation.carousel) {
                        currentIndex = index
                    }
                    isAutoPlaying = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        isAutoPlaying = true
                    }
                } label: {
                    Capsule()
                        .fill(currentIndex == index ? Color.white : Color.textTertiary)
                        .frame(width: currentIndex == index ? 22 : 6, height: 6)
                        .animation(AppTheme.Animation.smooth, value: currentIndex)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
        )
    }

    private func advanceCarousel() {
        withAnimation(AppTheme.Animation.carousel) {
            currentIndex = (currentIndex + 1) % min(movies.count, 5)
        }
    }
}

// MARK: - Compact Hero (For smaller displays)

struct CompactHero: View {

    let movie: Movie
    let onTap: () -> Void
    let onTrailerTap: () -> Void

    var body: some View {
        Button {
            Haptics.shared.cardTapped()
            onTap()
        } label: {
            ZStack(alignment: .bottomLeading) {
                // Background
                KFImage(movie.backdropURL ?? movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                    }
                    .resizable()
                    .aspectRatio(AspectRatio.backdrop, contentMode: .fill)
                    .frame(height: Size.heroHeightCompact)

                // Gradient
                LinearGradient.heroOverlay

                // Content
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Spacer()

                    Text(movie.title)
                        .font(.headline2)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)

                    HStack(spacing: Spacing.sm) {
                        // Rating
                        HStack(spacing: Spacing.xxs) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.ratingStar)
                            Text(movie.formattedRating)
                        }
                        .font(.labelMedium)

                        if let year = movie.releaseYear {
                            Text("•")
                                .foregroundColor(.textTertiary)
                            Text(year)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .font(.labelMedium)
                    .foregroundColor(.textPrimary)

                    // Trailer button
                    Button {
                        Haptics.shared.buttonTapped()
                        onTrailerTap()
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "play.fill")
                            Text("Trailer")
                        }
                        .font(.buttonSmall)
                        .foregroundColor(.textInverted)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(Spacing.lg)
            }
            .frame(height: Size.heroHeightCompact)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl, style: .continuous))
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG
struct CinematicHero_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                CinematicHeroCarousel(
                    movies: Movie.samples,
                    onPlay: { _ in },
                    onAddToList: { _ in },
                    onTap: { _ in }
                )

                CompactHero(
                    movie: .sample,
                    onTap: {},
                    onTrailerTap: {}
                )
                .padding(.horizontal)
            }
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
