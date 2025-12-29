//
//  FeaturedCard.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Hero featured movie card for carousel
//

import SwiftUI
import Kingfisher

struct FeaturedCard: View {

    // MARK: - Properties

    let movie: Movie
    let isInWatchlist: Bool
    let onTap: () -> Void
    let onWatchTrailer: () -> Void
    let onWatchlistToggle: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: {
            Haptics.shared.cardTapped()
            onTap()
        }) {
            ZStack(alignment: .bottom) {
                // Background image
                backdropImage

                // Gradient overlay
                gradientOverlay

                // Content overlay
                contentOverlay
            }
            .frame(height: Size.featuredCardHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
            .cardShadow()
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Backdrop Image

    private var backdropImage: some View {
        KFImage(movie.backdropURL ?? movie.posterURL)
            .placeholder {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: Size.featuredCardHeight)
    }

    // MARK: - Gradient Overlay

    private var gradientOverlay: some View {
        LinearGradient(
            colors: [
                .clear,
                .black.opacity(0.3),
                .black.opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Content Overlay

    private var contentOverlay: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Spacer()

            // Movie info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Title
                Text(movie.title)
                    .font(.displaySmall)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(radius: 4)

                // Metadata row
                HStack(spacing: Spacing.sm) {
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", movie.voteAverage))
                            .fontWeight(.bold)
                    }

                    Text("•")

                    // Year
                    if let year = movie.releaseDate?.prefix(4) {
                        Text(String(year))
                    }

                    Text("•")

                    // Genre
                    if let genre = movie.genreNames?.first {
                        Text(genre)
                    }
                }
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            }

            // Action buttons
            HStack(spacing: Spacing.sm) {
                // Watch trailer button
                Button(action: {
                    Haptics.shared.trailerStarted()
                    onWatchTrailer()
                }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "play.fill")
                        Text("Watch Trailer")
                    }
                    .font(.buttonMedium)
                    .foregroundColor(.black)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.white)
                    .clipShape(Capsule())
                }

                // Watchlist button
                Button(action: {
                    Haptics.shared.addedToWatchlist()
                    onWatchlistToggle()
                }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: isInWatchlist ? "checkmark" : "plus")
                        Text(isInWatchlist ? "Added" : "Watchlist")
                    }
                    .font(.buttonMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(Spacing.lg)
    }
}

// MARK: - Hero Carousel

struct HeroCarousel: View {

    let movies: [Movie]
    let isInWatchlist: (Movie) -> Bool
    let onMovieTap: (Movie) -> Void
    let onWatchTrailer: (Movie) -> Void
    let onWatchlistToggle: (Movie) -> Void

    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Carousel
            TabView(selection: $currentIndex) {
                ForEach(Array(movies.prefix(5).enumerated()), id: \.element.id) { index, movie in
                    FeaturedCard(
                        movie: movie,
                        isInWatchlist: isInWatchlist(movie),
                        onTap: { onMovieTap(movie) },
                        onWatchTrailer: { onWatchTrailer(movie) },
                        onWatchlistToggle: { onWatchlistToggle(movie) }
                    )
                    .padding(.horizontal, Spacing.horizontal)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: Size.featuredCardHeight + Spacing.lg)

            // Page indicators
            HStack(spacing: Spacing.xs) {
                ForEach(0..<min(movies.count, 5), id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: currentIndex == index ? 8 : 6, height: currentIndex == index ? 8 : 6)
                        .animation(AppTheme.Animation.standard, value: currentIndex)
                }
            }
        }
        .onReceive(timer) { _ in
            withAnimation(AppTheme.Animation.smooth) {
                currentIndex = (currentIndex + 1) % min(movies.count, 5)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct FeaturedCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FeaturedCard(
                movie: .sample,
                isInWatchlist: false,
                onTap: {},
                onWatchTrailer: {},
                onWatchlistToggle: {}
            )
            .padding()
        }
        .background(Color(.systemBackground))
    }
}
#endif
