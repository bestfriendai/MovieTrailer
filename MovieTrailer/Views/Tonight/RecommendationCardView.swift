//
//  RecommendationCardView.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Implemented by Claude Code Audit on 28/12/2025.
//

import SwiftUI
import Kingfisher

/// Card view for displaying personalized movie recommendations in Tonight view
struct RecommendationCardView: View {

    // MARK: - Properties

    let movie: Movie
    let rank: Int?
    let matchPercentage: Int?
    let reason: String?
    var isInWatchlist: Bool = false
    var onTap: (() -> Void)?
    var onWatchlistToggle: (() -> Void)?

    // MARK: - Initialization

    init(
        movie: Movie,
        rank: Int? = nil,
        matchPercentage: Int? = nil,
        reason: String? = nil,
        isInWatchlist: Bool = false,
        onTap: (() -> Void)? = nil,
        onWatchlistToggle: (() -> Void)? = nil
    ) {
        self.movie = movie
        self.rank = rank
        self.matchPercentage = matchPercentage
        self.reason = reason
        self.isInWatchlist = isInWatchlist
        self.onTap = onTap
        self.onWatchlistToggle = onWatchlistToggle
    }

    // MARK: - Body

    var body: some View {
        Button {
            HapticManager.shared.openedDetail()
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Poster with overlays
                posterSection

                // Info section
                infoSection
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(RecommendationCardButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Double tap to view details")
    }

    // MARK: - Poster Section

    private var posterSection: some View {
        ZStack(alignment: .topLeading) {
            // Poster image
            KFImage(movie.posterURL)
                .placeholder {
                    posterPlaceholder
                }
                .resizable()
                .aspectRatio(2/3, contentMode: .fill)
                .frame(height: 200)
                .clipped()

            // Gradient overlay for text visibility
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Top badges
            HStack {
                // Rank badge
                if let rank = rank {
                    rankBadge(rank)
                }

                Spacer()

                // Watchlist button
                watchlistButton
            }
            .padding(12)

            // Match percentage badge at bottom
            if let percentage = matchPercentage {
                VStack {
                    Spacer()
                    HStack {
                        matchBadge(percentage)
                        Spacer()
                    }
                    .padding(12)
                }
            }
        }
    }

    private var posterPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.orange.opacity(0.3), .pink.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 200)
            .overlay(
                Image(systemName: "film")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))
            )
    }

    private func rankBadge(_ rank: Int) -> some View {
        Text("#\(rank)")
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
    }

    private func matchBadge(_ percentage: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.caption2)
            Text("\(percentage)% match")
                .font(.caption.bold())
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }

    private var watchlistButton: some View {
        Button {
            HapticManager.shared.addedToWatchlist()
            onWatchlistToggle?()
        } label: {
            Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isInWatchlist ? .yellow : .white)
                .padding(8)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
        }
        .accessibilityLabel(isInWatchlist ? "Remove from watchlist" : "Add to watchlist")
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(movie.title)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
                .lineLimit(2)

            // Rating and year
            HStack(spacing: 12) {
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(movie.formattedRating)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Year
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // Recommendation reason
            if let reason = reason {
                Text(reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .italic()
            }
        }
        .padding(12)
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        var description = movie.title

        if let rank = rank {
            description += ", ranked number \(rank)"
        }

        if let percentage = matchPercentage {
            description += ", \(percentage) percent match"
        }

        description += ", rated \(movie.formattedRating)"

        if let year = movie.releaseYear {
            description += ", released \(year)"
        }

        if isInWatchlist {
            description += ", in watchlist"
        }

        return description
    }
}

// MARK: - Button Style

struct RecommendationCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Large Recommendation Card

struct LargeRecommendationCardView: View {

    let movie: Movie
    let matchPercentage: Int?
    let reason: String?
    var isInWatchlist: Bool = false
    var onTap: (() -> Void)?
    var onWatchlistToggle: (() -> Void)?

    var body: some View {
        Button {
            HapticManager.shared.openedDetail()
            onTap?()
        } label: {
            ZStack(alignment: .bottom) {
                // Background image
                KFImage(movie.backdropURL ?? movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.orange.opacity(0.3), .pink.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .resizable()
                    .aspectRatio(16/9, contentMode: .fill)
                    .frame(height: 220)
                    .clipped()

                // Gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Content
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()

                    // Match badge
                    if let percentage = matchPercentage {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                            Text("\(percentage)% match")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.green, .teal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }

                    // Title
                    Text(movie.title)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .lineLimit(2)

                    // Reason
                    if let reason = reason {
                        Text(reason)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }

                    // Rating and action
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(movie.formattedRating)
                                .fontWeight(.semibold)
                            if let year = movie.releaseYear {
                                Text("• \(year)")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .foregroundColor(.white)

                        Spacer()

                        Button {
                            HapticManager.shared.addedToWatchlist()
                            onWatchlistToggle?()
                        } label: {
                            Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                                .font(.title3)
                                .foregroundColor(isInWatchlist ? .yellow : .white)
                        }
                    }
                }
                .padding(20)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
        }
        .buttonStyle(RecommendationCardButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG
struct RecommendationCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Standard Card")
                    .font(.headline)

                RecommendationCardView(
                    movie: .sample,
                    rank: 1,
                    matchPercentage: 95,
                    reason: "Because you liked The Matrix",
                    isInWatchlist: false
                )
                .frame(width: 180)

                Divider()

                Text("Large Card")
                    .font(.headline)

                LargeRecommendationCardView(
                    movie: .sample,
                    matchPercentage: 92,
                    reason: "Top pick based on your preferences",
                    isInWatchlist: true
                )
                .padding(.horizontal)
            }
            .padding()
        }
    }
}
#endif
