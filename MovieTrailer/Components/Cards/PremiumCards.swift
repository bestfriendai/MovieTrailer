//
//  PremiumCards.swift
//  MovieTrailer
//
//  Apple 2025 Premium Card Components
//  Beautiful, animated, glassmorphic card designs
//

import SwiftUI
import Kingfisher

// MARK: - Premium Poster Card

/// Standard movie poster card with glass effects
struct PremiumPosterCard: View {

    let movie: Movie
    let size: CardSize
    let showTitle: Bool
    let showRating: Bool
    let showWatchlistButton: Bool
    let isInWatchlist: Bool
    let onTap: () -> Void
    let onWatchlistToggle: (() -> Void)?

    @State private var isPressed = false
    @State private var isHovered = false
    @State private var watchlistAnimating = false

    enum CardSize {
        case compact    // 100pt
        case small      // 120pt
        case standard   // 150pt
        case large      // 180pt
        case featured   // 220pt

        var width: CGFloat {
            switch self {
            case .compact: return Size.movieCardCompact
            case .small: return Size.movieCardSmall
            case .standard: return Size.movieCardStandard
            case .large: return Size.movieCardLarge
            case .featured: return Size.movieCardFeatured
            }
        }

        var height: CGFloat {
            width / AspectRatio.poster
        }

        var cornerRadius: CGFloat {
            switch self {
            case .compact, .small: return AppTheme.CornerRadius.medium
            case .standard: return AppTheme.CornerRadius.large
            case .large, .featured: return AppTheme.CornerRadius.extraLarge
            }
        }

        var titleFont: Font {
            switch self {
            case .compact, .small: return .labelMedium
            case .standard: return .labelLarge
            case .large, .featured: return .titleSmall
            }
        }
    }

    init(
        movie: Movie,
        size: CardSize = .standard,
        showTitle: Bool = true,
        showRating: Bool = true,
        showWatchlistButton: Bool = false,
        isInWatchlist: Bool = false,
        onTap: @escaping () -> Void,
        onWatchlistToggle: (() -> Void)? = nil
    ) {
        self.movie = movie
        self.size = size
        self.showTitle = showTitle
        self.showRating = showRating
        self.showWatchlistButton = showWatchlistButton
        self.isInWatchlist = isInWatchlist
        self.onTap = onTap
        self.onWatchlistToggle = onWatchlistToggle
    }

    var body: some View {
        Button {
            Haptics.shared.cardTapped()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Poster
                posterView

                // Title & metadata
                if showTitle {
                    titleSection
                }
            }
        }
        .buttonStyle(CardButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view details")
    }

    private var posterView: some View {
        ZStack(alignment: .topTrailing) {
            // Image
            KFImage(movie.posterURL)
                .placeholder {
                    posterPlaceholder
                }
                .resizable()
                .aspectRatio(AspectRatio.poster, contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))

            // Overlays
            VStack {
                HStack {
                    // Rating badge
                    if showRating {
                        ratingBadge
                    }

                    Spacer()

                    // Watchlist button
                    if showWatchlistButton {
                        watchlistButton
                    }
                }
                .padding(Spacing.xs)

                Spacer()
            }

            // Glass border
            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .stroke(Color.glassBorder, lineWidth: 0.5)
        }
        .frame(width: size.width, height: size.height)
        .mediumShadow()
    }

    private var posterPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.surfaceSecondary, Color.surfaceTertiary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "film")
                    .font(.system(size: size.width * 0.3))
                    .foregroundColor(.textTertiary)
            }
            .shimmer(isActive: true)
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(movie.title)
                .font(size.titleFont)
                .foregroundColor(.textPrimary)
                .lineLimit(2)

            if let year = movie.releaseYear {
                Text(year)
                    .font(.captionSmall)
                    .foregroundColor(.textTertiary)
            }
        }
        .frame(width: size.width, alignment: .leading)
    }

    private var ratingBadge: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(.ratingStar)

            Text(movie.formattedRating)
                .font(.badge)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var watchlistButton: some View {
        Button {
            handleWatchlistToggle()
        } label: {
            Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isInWatchlist ? .accentYellow : .textPrimary)
                .scaleEffect(watchlistAnimating ? 1.3 : 1.0)
                .frame(width: 28, height: 28)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var accessibilityLabel: String {
        var label = movie.title
        label += ", rated \(movie.formattedRating)"
        if let year = movie.releaseYear {
            label += ", \(year)"
        }
        return label
    }

    private func handleWatchlistToggle() {
        Haptics.shared.addedToWatchlist()
        withAnimation(AppTheme.Animation.bouncy) {
            watchlistAnimating = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(AppTheme.Animation.standard) {
                watchlistAnimating = false
            }
        }
        onWatchlistToggle?()
    }
}

// MARK: - Premium Landscape Card

/// Wide landscape card for featured content
struct PremiumLandscapeCard: View {

    let movie: Movie
    let height: CGFloat
    let showMetadata: Bool
    let onTap: () -> Void

    init(
        movie: Movie,
        height: CGFloat = Size.landscapeCardHeight,
        showMetadata: Bool = true,
        onTap: @escaping () -> Void
    ) {
        self.movie = movie
        self.height = height
        self.showMetadata = showMetadata
        self.onTap = onTap
    }

    var body: some View {
        Button {
            Haptics.shared.cardTapped()
            onTap()
        } label: {
            ZStack(alignment: .bottomLeading) {
                // Backdrop image
                KFImage(movie.backdropURL ?? movie.posterURL)
                    .placeholder {
                        backdropPlaceholder
                    }
                    .resizable()
                    .aspectRatio(AspectRatio.backdrop, contentMode: .fill)
                    .frame(height: height)

                // Gradient overlay
                LinearGradient.cardOverlay

                // Content
                if showMetadata {
                    contentOverlay
                }

                // Glass border
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            }
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))
            .cardShadow()
        }
        .buttonStyle(CardButtonStyle())
    }

    private var backdropPlaceholder: some View {
        Rectangle()
            .fill(Color.surfaceSecondary)
            .overlay {
                Image(systemName: "film")
                    .font(.system(size: 40))
                    .foregroundColor(.textTertiary)
            }
            .shimmer(isActive: true)
    }

    private var contentOverlay: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Spacer()

            // Title
            Text(movie.title)
                .font(.headline2)
                .foregroundColor(.textPrimary)
                .lineLimit(2)

            // Metadata row
            HStack(spacing: Spacing.sm) {
                // Rating
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.ratingStar)
                    Text(movie.formattedRating)
                        .fontWeight(.semibold)
                }
                .font(.labelMedium)
                .foregroundColor(.textPrimary)

                // Year
                if let year = movie.releaseYear {
                    Text("•")
                        .foregroundColor(.textTertiary)
                    Text(year)
                        .foregroundColor(.textSecondary)
                }

                // Genres
                if let genres = movie.genreNames?.prefix(2) {
                    Text("•")
                        .foregroundColor(.textTertiary)
                    Text(genres.joined(separator: ", "))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
            }
            .font(.labelMedium)
        }
        .padding(Spacing.md)
    }
}

// MARK: - Premium Featured Card

/// Large featured card with full info overlay
struct PremiumFeaturedCard: View {

    let movie: Movie
    let onTap: () -> Void
    let onTrailerTap: (() -> Void)?
    let onWatchlistTap: (() -> Void)?

    init(
        movie: Movie,
        onTap: @escaping () -> Void,
        onTrailerTap: (() -> Void)? = nil,
        onWatchlistTap: (() -> Void)? = nil
    ) {
        self.movie = movie
        self.onTap = onTap
        self.onTrailerTap = onTrailerTap
        self.onWatchlistTap = onWatchlistTap
    }

    var body: some View {
        Button {
            Haptics.shared.cardTapped()
            onTap()
        } label: {
            ZStack(alignment: .bottom) {
                // Background image
                KFImage(movie.backdropURL ?? movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                            .shimmer(isActive: true)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: Size.featuredCardHeight)

                // Gradient overlay
                LinearGradient.heroOverlay

                // Content
                contentOverlay
            }
            .frame(height: Size.featuredCardHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl, style: .continuous))
            .heroShadow()
        }
        .buttonStyle(CardButtonStyle())
    }

    private var contentOverlay: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Spacer()

            // Title
            Text(movie.title)
                .font(.displaySmall)
                .foregroundColor(.textPrimary)
                .lineLimit(2)

            // Metadata
            HStack(spacing: Spacing.sm) {
                // Rating badge
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.ratingStar)
                    Text(movie.formattedRating)
                        .fontWeight(.bold)
                }
                .font(.labelLarge)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

                // Year
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)
                }

                // Genre
                if let genre = movie.genreNames?.first {
                    Text("•")
                        .foregroundColor(.textTertiary)
                    Text(genre)
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)
                }
            }

            // Overview
            if !movie.overview.isEmpty {
                Text(movie.overview)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }

            // Action buttons
            HStack(spacing: Spacing.sm) {
                // Trailer button
                if onTrailerTap != nil {
                    Button {
                        Haptics.shared.buttonTapped()
                        onTrailerTap?()
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

                // Add to list button
                if onWatchlistTap != nil {
                    Button {
                        Haptics.shared.addedToWatchlist()
                        onWatchlistTap?()
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "plus")
                            Text("My List")
                        }
                        .font(.buttonSmall)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
        .padding(Spacing.lg)
    }
}

// MARK: - Premium Compact Card

/// Compact card for search results and grids
struct PremiumCompactCard: View {

    let movie: Movie
    let onTap: () -> Void

    var body: some View {
        Button {
            Haptics.shared.cardTapped()
            onTap()
        } label: {
            HStack(spacing: Spacing.sm) {
                // Poster
                KFImage(movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                            .overlay {
                                Image(systemName: "film")
                                    .foregroundColor(.textTertiary)
                            }
                    }
                    .resizable()
                    .aspectRatio(AspectRatio.poster, contentMode: .fill)
                    .frame(width: 60, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small, style: .continuous))

                // Info
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(movie.title)
                        .font(.labelLarge)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)

                    HStack(spacing: Spacing.xs) {
                        // Rating
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.ratingStar)
                            Text(movie.formattedRating)
                                .font(.captionBold)
                        }
                        .foregroundColor(.textPrimary)

                        // Year
                        if let year = movie.releaseYear {
                            Text("•")
                                .foregroundColor(.textTertiary)
                            Text(year)
                                .foregroundColor(.textTertiary)
                        }
                    }
                    .font(.captionRegular)

                    // Genre
                    if let genre = movie.genreNames?.first {
                        Text(genre)
                            .font(.captionSmall)
                            .foregroundColor(.textTertiary)
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textTertiary)
            }
            .padding(Spacing.sm)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Top 10 Card

/// Card with large ranking number
struct Top10Card: View {

    let movie: Movie
    let rank: Int
    let onTap: () -> Void

    var body: some View {
        Button {
            Haptics.shared.cardTapped()
            onTap()
        } label: {
            HStack(alignment: .bottom, spacing: -20) {
                // Rank number
                Text("\(rank)")
                    .font(.rankingNumber)
                    .foregroundColor(.ranking(rank))
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 2)
                    .offset(y: 10)

                // Poster
                KFImage(movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                    }
                    .resizable()
                    .aspectRatio(AspectRatio.poster, contentMode: .fill)
                    .frame(width: Size.movieCardStandard, height: Size.top10CardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
                    .mediumShadow()
            }
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Streaming Badge Card

/// Card with streaming service indicator
struct StreamingPosterCard: View {

    let movie: Movie
    let streamingService: String?
    let streamingColor: Color
    let onTap: () -> Void

    var body: some View {
        Button {
            Haptics.shared.cardTapped()
            onTap()
        } label: {
            ZStack(alignment: .topLeading) {
                // Poster
                KFImage(movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                    }
                    .resizable()
                    .aspectRatio(AspectRatio.poster, contentMode: .fill)
                    .frame(width: Size.movieCardStandard)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))

                // Streaming badge
                if let service = streamingService {
                    Text(service)
                        .font(.badge)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, Spacing.xxs)
                        .background(streamingColor)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xs, style: .continuous))
                        .padding(Spacing.xs)
                }
            }
            .mediumShadow()
        }
        .buttonStyle(CardButtonStyle())
    }
}

// MARK: - Card Button Style

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? AppTheme.Scale.cardPressed : 1.0)
            .opacity(configuration.isPressed ? 0.95 : 1.0)
            .animation(AppTheme.Animation.cardPress, value: configuration.isPressed)
    }
}

// MARK: - Preview Provider

#if DEBUG
struct PremiumCards_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Poster cards
                Text("Poster Cards")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        PremiumPosterCard(
                            movie: .sample,
                            size: .standard,
                            onTap: {}
                        )

                        PremiumPosterCard(
                            movie: .sample,
                            size: .large,
                            showWatchlistButton: true,
                            isInWatchlist: true,
                            onTap: {},
                            onWatchlistToggle: {}
                        )
                    }
                    .padding(.horizontal)
                }

                // Landscape card
                Text("Landscape Card")
                    .font(.headline)
                PremiumLandscapeCard(movie: .sample, onTap: {})
                    .padding(.horizontal)

                // Featured card
                Text("Featured Card")
                    .font(.headline)
                PremiumFeaturedCard(
                    movie: .sample,
                    onTap: {},
                    onTrailerTap: {},
                    onWatchlistTap: {}
                )
                .padding(.horizontal)

                // Top 10 card
                Text("Top 10 Card")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(1...5, id: \.self) { rank in
                            Top10Card(movie: .sample, rank: rank, onTap: {})
                        }
                    }
                    .padding(.horizontal)
                }

                // Compact card
                Text("Compact Card")
                    .font(.headline)
                PremiumCompactCard(movie: .sample, onTap: {})
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
