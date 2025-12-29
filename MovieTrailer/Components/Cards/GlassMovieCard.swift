//
//  GlassMovieCard.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Modern glass-effect movie card component
//

import SwiftUI
import Kingfisher

struct GlassMovieCard: View {

    // MARK: - Properties

    let movie: Movie
    let isInWatchlist: Bool
    let size: CardSize
    let onTap: () -> Void
    let onWatchlistToggle: () -> Void

    @State private var isPressed = false

    enum CardSize {
        case compact   // 120pt width
        case standard  // 150pt width
        case large     // 180pt width

        var width: CGFloat {
            switch self {
            case .compact: return Size.movieCardCompact
            case .standard: return Size.movieCardStandard
            case .large: return Size.movieCardLarge
            }
        }
    }

    // MARK: - Initialization

    init(
        movie: Movie,
        isInWatchlist: Bool = false,
        size: CardSize = .standard,
        onTap: @escaping () -> Void,
        onWatchlistToggle: @escaping () -> Void = {}
    ) {
        self.movie = movie
        self.isInWatchlist = isInWatchlist
        self.size = size
        self.onTap = onTap
        self.onWatchlistToggle = onWatchlistToggle
    }

    // MARK: - Body

    var body: some View {
        Button(action: {
            Haptics.shared.cardTapped()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Poster with overlays
                posterSection

                // Info section
                infoSection
            }
            .frame(width: size.width)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Poster Section

    private var posterSection: some View {
        ZStack(alignment: .topTrailing) {
            // Poster image
            KFImage(movie.posterURL)
                .placeholder {
                    posterPlaceholder
                }
                .resizable()
                .aspectRatio(AspectRatio.poster, contentMode: .fill)
                .frame(width: size.width)
                .clipped()

            // Gradient overlay at bottom
            VStack {
                Spacer()
                LinearGradient.cardOverlay
                    .frame(height: 80)
            }

            // Rating badge
            ratingBadge
                .padding(Spacing.xs)

            // Watchlist button
            watchlistButton
                .padding(Spacing.xs)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(movie.title)
                .font(.cardTitle)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: Spacing.xxs) {
                if let year = movie.releaseDate?.prefix(4) {
                    Text(String(year))
                        .font(.movieYear)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top, Spacing.sm)
        .padding(.horizontal, Spacing.xxs)
    }

    // MARK: - Rating Badge

    private var ratingBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundColor(.yellow)

            Text(String(format: "%.1f", movie.voteAverage))
                .font(.badge)
                .foregroundColor(.white)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    // MARK: - Watchlist Button

    private var watchlistButton: some View {
        Button(action: {
            Haptics.shared.addedToWatchlist()
            onWatchlistToggle()
        }) {
            Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                .font(.body.weight(.semibold))
                .foregroundColor(isInWatchlist ? .accentStart : .white)
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }

    // MARK: - Placeholder

    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
            .fill(
                LinearGradient(
                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "film")
                    .font(.largeTitle)
                    .foregroundColor(.gray.opacity(0.5))
            }
    }
}

// MARK: - Preview

#if DEBUG
struct GlassMovieCard_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
            GlassMovieCard(
                movie: .sample,
                isInWatchlist: false,
                size: .standard,
                onTap: {},
                onWatchlistToggle: {}
            )

            GlassMovieCard(
                movie: .sample,
                isInWatchlist: true,
                size: .standard,
                onTap: {},
                onWatchlistToggle: {}
            )
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
#endif
