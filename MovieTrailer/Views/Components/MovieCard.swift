//
//  MovieCard.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//  Enhanced: Accessibility, haptic feedback, improved animations
//

import SwiftUI
import Kingfisher

/// Glassmorphism movie card component with accessibility and haptics
struct MovieCard: View {

    let movie: Movie
    let isInWatchlist: Bool
    let onTap: () -> Void
    let onWatchlistToggle: () -> Void

    @State private var isPressed = false
    @State private var watchlistAnimating = false

    var body: some View {
        Button {
            HapticManager.shared.openedDetail()
            onTap()
        } label: {
            ZStack(alignment: .topTrailing) {
                // Main card content
                VStack(alignment: .leading, spacing: 8) {
                    // Poster image
                    posterImage

                    // Movie info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(movie.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)

                        HStack(spacing: 8) {
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)

                                Text(movie.formattedRating)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }

                            // Year
                            if let year = movie.releaseYear {
                                Text("•")
                                    .foregroundColor(.secondary)

                                Text(year)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                // Watchlist button
                watchlistButton
                    .padding(8)
            }
        }
        .buttonStyle(MovieCardButtonStyle())
        // MARK: - Accessibility
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view movie details")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "Toggle Watchlist") {
            handleWatchlistToggle()
        }
    }

    // MARK: - Accessibility Label

    private var accessibilityLabel: String {
        var label = movie.title
        label += ", rated \(movie.formattedRating) out of 10"
        if let year = movie.releaseYear {
            label += ", released in \(year)"
        }
        if isInWatchlist {
            label += ", in your watchlist"
        }
        return label
    }

    // MARK: - Subviews

    private var posterImage: some View {
        KFImage(movie.posterURL)
            .placeholder {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "film")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
            .resizable()
            .aspectRatio(2/3, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .accessibilityHidden(true)
    }

    private var watchlistButton: some View {
        Button {
            handleWatchlistToggle()
        } label: {
            Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                .font(.system(size: 20))
                .foregroundColor(isInWatchlist ? .yellow : .white)
                .scaleEffect(watchlistAnimating ? 1.3 : 1.0)
                .padding(8)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .buttonBorderShape(.circle)
        .accessibilityLabel(isInWatchlist ? "Remove from watchlist" : "Add to watchlist")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Actions

    private func handleWatchlistToggle() {
        // Haptic feedback
        if isInWatchlist {
            HapticManager.shared.removedFromWatchlist()
        } else {
            HapticManager.shared.addedToWatchlist()
        }

        // Animate bookmark icon
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            watchlistAnimating = true
        }

        // Reset animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                watchlistAnimating = false
            }
        }

        onWatchlistToggle()
    }
}

// MARK: - Movie Card Button Style (Spring Animation)

struct MovieCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Scale Button Style (Original - kept for compatibility)

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Bouncy Button Style

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0), value: configuration.isPressed)
    }
}

// MARK: - Preview

#if DEBUG
struct MovieCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MovieCard(
                movie: Movie.sample,
                isInWatchlist: false,
                onTap: {},
                onWatchlistToggle: {}
            )
            .frame(width: 160)

            MovieCard(
                movie: Movie.sample,
                isInWatchlist: true,
                onTap: {},
                onWatchlistToggle: {}
            )
            .frame(width: 160)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
}
#endif
