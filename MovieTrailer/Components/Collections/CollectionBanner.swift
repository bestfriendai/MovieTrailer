//
//  CollectionBanner.swift
//  MovieTrailer
//
//  Apple 2025 Premium Collection Banner
//  Franchise display with movie count
//

import SwiftUI
import Kingfisher

// MARK: - Collection Banner

/// Banner showing movie belongs to a collection/franchise
struct CollectionBanner: View {

    let collection: CollectionInfo
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .leading) {
                // Background
                background

                // Content
                content
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.snappy, value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Part of \(collection.name)")
        .accessibilityHint("Double tap to view collection")
    }

    private var background: some View {
        ZStack {
            // Collection backdrop
            if let url = collection.backdropURL ?? collection.posterURL {
                KFImage(url)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.accentPrimary.opacity(0.3), .accentSecondary.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            // Gradient overlay
            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.4)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    private var content: some View {
        HStack(spacing: Spacing.md) {
            // Collection icon
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 28))
                .foregroundColor(.accentPrimary)
                .frame(width: 50, height: 50)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Text content
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("PART OF A COLLECTION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.textTertiary)
                    .tracking(1.2)

                Text(collection.name)
                    .font(.headline2)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textTertiary)
        }
        .padding(Spacing.md)
    }
}

// MARK: - Full Collection Card

/// Larger collection card showing poster and details
struct CollectionCard: View {

    let collection: MovieCollection
    let onTap: () -> Void
    let onMovieTap: ((CollectionPart) -> Void)?

    init(
        collection: MovieCollection,
        onTap: @escaping () -> Void,
        onMovieTap: ((CollectionPart) -> Void)? = nil
    ) {
        self.collection = collection
        self.onTap = onTap
        self.onMovieTap = onMovieTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            Button(action: onTap) {
                collectionHeader
            }
            .buttonStyle(CardButtonStyle())

            // Movies preview
            if !collection.parts.isEmpty {
                moviesRow
            }
        }
    }

    private var collectionHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Background
            Group {
                if let url = collection.backdropURL {
                    KFImage(url)
                        .placeholder {
                            Rectangle().fill(Color.surfaceSecondary)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color.surfaceSecondary)
                }
            }
            .frame(height: 180)

            // Gradient
            LinearGradient.heroOverlay

            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(collection.name)
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                HStack(spacing: Spacing.sm) {
                    // Movie count
                    HStack(spacing: 4) {
                        Image(systemName: "film.stack")
                            .font(.system(size: 12))
                        Text("\(collection.movieCount) movies")
                    }
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)

                    // Year range
                    if let range = collection.yearRange {
                        Text("•")
                            .foregroundColor(.textTertiary)
                        Text(range)
                            .font(.labelSmall)
                            .foregroundColor(.textSecondary)
                    }

                    // Average rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.ratingStar)
                        Text(String(format: "%.1f", collection.averageRating))
                    }
                    .font(.labelSmall)
                    .foregroundColor(.textSecondary)
                }
            }
            .padding(Spacing.md)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))
    }

    private var moviesRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(collection.moviesByReleaseDate) { movie in
                    collectionMovieCard(movie)
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }

    private func collectionMovieCard(_ movie: CollectionPart) -> some View {
        Button {
            Haptics.shared.cardTapped()
            onMovieTap?(movie)
        } label: {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Poster
                KFImage(movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                    }
                    .resizable()
                    .aspectRatio(AspectRatio.poster, contentMode: .fill)
                    .frame(width: 100, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))

                // Title
                Text(movie.title)
                    .font(.labelSmall)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)

                // Year
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.captionSmall)
                        .foregroundColor(.textTertiary)
                }
            }
            .frame(width: 100)
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Mini Collection Badge

/// Small badge indicating movie is part of collection
struct CollectionBadge: View {

    let collectionName: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 10))

            Text(collectionName)
                .font(.system(size: 10, weight: .medium))
                .lineLimit(1)
        }
        .foregroundColor(.textSecondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#if DEBUG
struct CollectionBanner_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Banner
                CollectionBanner(
                    collection: CollectionInfo.sample,
                    onTap: {}
                )
                .padding(.horizontal)

                // Full Card
                CollectionCard(
                    collection: MovieCollection.sample,
                    onTap: {},
                    onMovieTap: { _ in }
                )

                // Badge
                CollectionBadge(collectionName: "Star Wars Collection")
            }
            .padding(.vertical)
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
