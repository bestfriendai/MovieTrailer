//
//  ContentRow.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Apple TV-style content rows
//

import SwiftUI
import Kingfisher

// MARK: - Large Poster Row (Continue Watching Style)

struct LargePosterRow: View {

    let title: String
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void

    private let cardWidth: CGFloat = 200
    private let cardHeight: CGFloat = 300

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            sectionHeader

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(movies) { movie in
                        LargePosterCard(
                            movie: movie,
                            width: cardWidth,
                            height: cardHeight,
                            onTap: { onMovieTap(movie) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var sectionHeader: some View {
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
    }
}

// MARK: - Large Poster Card

struct LargePosterCard: View {

    let movie: Movie
    let width: CGFloat
    let height: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            Haptics.shared.lightImpact()
            onTap()
        }) {
            ZStack(alignment: .bottomLeading) {
                // Poster image
                posterImage

                // Overlay gradient
                LinearGradient.cardOverlay

                // Info overlay
                infoOverlay
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var posterImage: some View {
        KFImage(movie.posterURL)
            .placeholder {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceElevated)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
    }

    private var infoOverlay: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer()

            Text(movie.title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(2)

            if let year = movie.releaseYear {
                Text(year)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(12)
    }
}

// MARK: - Standard Content Row

struct ContentRow: View {

    let title: String
    let subtitle: String?
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onSeeAll: (() -> Void)?

    private let cardWidth: CGFloat = 140
    private let cardHeight: CGFloat = 210

    init(
        title: String,
        subtitle: String? = nil,
        movies: [Movie],
        onMovieTap: @escaping (Movie) -> Void,
        onSeeAll: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.movies = movies
        self.onMovieTap = onMovieTap
        self.onSeeAll = onSeeAll
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            sectionHeader

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(movies) { movie in
                        StandardMovieCard(
                            movie: movie,
                            width: cardWidth,
                            height: cardHeight,
                            onTap: { onMovieTap(movie) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var sectionHeader: some View {
        Button(action: {
            onSeeAll?()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.textTertiary)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
        .disabled(onSeeAll == nil)
    }
}

// MARK: - Standard Movie Card

struct StandardMovieCard: View {

    let movie: Movie
    let width: CGFloat
    let height: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            Haptics.shared.lightImpact()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Poster
                posterImage

                // Title
                Text(movie.title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .frame(width: width, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }

    private var posterImage: some View {
        KFImage(movie.posterURL)
            .placeholder {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.surfaceElevated)
            }
            .resizable()
            .aspectRatio(2/3, contentMode: .fill)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Compact Movie Row

struct CompactMovieRow: View {

    let title: String
    let icon: String
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void

    private let cardSize: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.accentPrimary)

                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(.textPrimary)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.textTertiary)

                Spacer()
            }
            .padding(.horizontal, 20)

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(movies) { movie in
                        CompactMovieCard(
                            movie: movie,
                            size: cardSize,
                            onTap: { onMovieTap(movie) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Compact Movie Card

struct CompactMovieCard: View {

    let movie: Movie
    let size: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            Haptics.shared.lightImpact()
            onTap()
        }) {
            KFImage(movie.posterURL)
                .placeholder {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.surfaceElevated)
                }
                .resizable()
                .aspectRatio(2/3, contentMode: .fill)
                .frame(width: size, height: size * 1.5)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#if DEBUG
struct ContentRow_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                LargePosterRow(
                    title: "Continue Watching",
                    movies: Movie.samples,
                    onMovieTap: { _ in }
                )

                ContentRow(
                    title: "New Releases",
                    subtitle: "Movies added this week",
                    movies: Movie.samples,
                    onMovieTap: { _ in }
                )

                CompactMovieRow(
                    title: "Trending",
                    icon: "flame.fill",
                    movies: Movie.samples,
                    onMovieTap: { _ in }
                )
            }
            .padding(.vertical, 20)
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
