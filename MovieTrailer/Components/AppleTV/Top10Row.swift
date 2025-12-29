//
//  Top10Row.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Apple TV-style Top 10 ranking row
//

import SwiftUI
import Kingfisher

// MARK: - Top 10 Row

struct Top10Row: View {

    let title: String
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.textPrimary)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.textTertiary)

                Spacer()
            }
            .padding(.horizontal, 20)

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(movies.prefix(10).enumerated()), id: \.element.id) { index, movie in
                        Top10Card(
                            movie: movie,
                            rank: index + 1,
                            onTap: { onMovieTap(movie) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Top 10 Card

struct Top10Card: View {

    let movie: Movie
    let rank: Int
    let onTap: () -> Void

    private let cardWidth: CGFloat = 120
    private let cardHeight: CGFloat = 180

    var body: some View {
        Button(action: {
            Haptics.shared.lightImpact()
            onTap()
        }) {
            HStack(alignment: .bottom, spacing: -20) {
                // Large ranking number
                rankingNumber

                // Movie poster
                posterImage
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Ranking Number

    private var rankingNumber: some View {
        Text("\(rank)")
            .font(.system(size: 100, weight: .heavy, design: .rounded))
            .foregroundStyle(rankGradient)
            .shadow(color: .black.opacity(0.8), radius: 2, x: 0, y: 2)
            .frame(width: 60)
            .offset(y: 10)
    }

    private var rankGradient: LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(colors: [.ranking1, .ranking1.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        case 2:
            return LinearGradient(colors: [.ranking2, .ranking2.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        case 3:
            return LinearGradient(colors: [.ranking3, .ranking3.opacity(0.7)], startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.textSecondary, .textTertiary], startPoint: .top, endPoint: .bottom)
        }
    }

    // MARK: - Poster Image

    private var posterImage: some View {
        KFImage(movie.posterURL)
            .placeholder {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.surfaceElevated)
            }
            .resizable()
            .aspectRatio(2/3, contentMode: .fill)
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Genre Badge

struct GenreBadge: View {
    let genre: String

    var body: some View {
        Text(genre)
            .font(.caption2.weight(.medium))
            .foregroundColor(.textSecondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Preview

#if DEBUG
struct Top10Row_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            Top10Row(
                title: "Top 10 Movies on Apple TV",
                movies: Movie.samples,
                onMovieTap: { _ in }
            )
        }
        .preferredColorScheme(.dark)
    }
}
#endif
