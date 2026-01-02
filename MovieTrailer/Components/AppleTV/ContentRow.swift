//
//  ContentRow.swift
//  MovieTrailer
//
//  Apple 2025 Premium Content Rows
//  Apple TV-inspired horizontal scroll sections
//

import SwiftUI
import Kingfisher

// MARK: - Large Poster Row (Continue Watching Style)

struct LargePosterRow: View {

    let title: String
    let subtitle: String?
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onSeeAll: (() -> Void)?

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
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Section header
            PremiumSectionHeader(
                title: title,
                subtitle: subtitle,
                onSeeAll: onSeeAll
            )

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(movies) { movie in
                        LargePosterCard(
                            movie: movie,
                            onTap: { onMovieTap(movie) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }
}

// MARK: - Large Poster Card

struct LargePosterCard: View {

    let movie: Movie
    let onTap: () -> Void

    @State private var isPressed = false

    private let cardWidth: CGFloat = 200
    private let cardHeight: CGFloat = 300

    var body: some View {
        Button(action: {
            Haptics.shared.cardTapped()
            onTap()
        }) {
            ZStack(alignment: .bottomLeading) {
                // Poster image with shimmer placeholder
                posterImage

                // Gradient overlay
                LinearGradient(
                    colors: [
                        .clear,
                        .clear,
                        .black.opacity(0.5),
                        .black.opacity(0.85)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Info overlay
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Spacer()

                    // Progress bar (simulated watch progress)
                    GeometryReader { geometry in
                        Capsule()
                            .fill(Color.accentPrimary)
                            .frame(width: geometry.size.width * 0.6, height: 3)
                    }
                    .frame(height: 3)

                    Text(movie.title)
                        .font(.headline2)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: cardWidth - 24, alignment: .leading)

                    HStack(spacing: Spacing.xs) {
                        if let year = movie.releaseYear {
                            Text(year)
                                .font(.labelSmall)
                                .foregroundColor(.textTertiary)
                        }

                        if movie.voteAverage > 0 {
                            Text("•")
                                .foregroundColor(.textTertiary)

                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.ratingStar)
                                Text(movie.formattedRating)
                                    .font(.labelSmall)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
                .frame(width: cardWidth - 24, alignment: .leading)
                .padding(Spacing.md)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(AppTheme.Animation.quick, value: isPressed)
        }
        .buttonStyle(PressableCardStyle(isPressed: $isPressed))
    }

    private var posterImage: some View {
        KFImage(movie.posterURL)
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
            .frame(width: cardWidth, height: cardHeight)
    }
}

// MARK: - Standard Content Row

struct ContentRow: View {

    let title: String
    let subtitle: String?
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onSeeAll: (() -> Void)?

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
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Section header
            PremiumSectionHeader(
                title: title,
                subtitle: subtitle,
                onSeeAll: onSeeAll
            )

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(movies) { movie in
                        PremiumPosterCard(
                            movie: movie,
                            size: .standard,
                            onTap: { onMovieTap(movie) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }
}

// MARK: - Compact Movie Row

struct CompactMovieRow: View {

    let title: String
    let icon: String
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onSeeAll: (() -> Void)?

    init(
        title: String,
        icon: String,
        movies: [Movie],
        onMovieTap: @escaping (Movie) -> Void,
        onSeeAll: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.movies = movies
        self.onMovieTap = onMovieTap
        self.onSeeAll = onSeeAll
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Section header with icon - CLICKABLE
            Button {
                Haptics.shared.buttonTapped()
                onSeeAll?()
            } label: {
                HStack(spacing: Spacing.sm) {
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.accentPrimary.opacity(0.3), .accentSecondary.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 28, height: 28)

                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.accentPrimary)
                    }

                    Text(title)
                        .font(.headline2)
                        .foregroundColor(.textPrimary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.textTertiary)

                    Spacer()

                    if onSeeAll != nil {
                        Text("See All")
                            .font(.labelMedium)
                            .foregroundColor(.accentPrimary)
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(onSeeAll == nil)
            .padding(.horizontal, Spacing.horizontal)

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(movies) { movie in
                        PremiumPosterCard(
                            movie: movie,
                            size: .small,
                            onTap: { onMovieTap(movie) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }
}

// MARK: - Featured Row (Larger cards with more info)

struct FeaturedRow: View {

    let title: String
    let subtitle: String?
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    let onTrailerTap: ((Movie) -> Void)?
    let onSeeAll: (() -> Void)?

    init(
        title: String,
        subtitle: String? = nil,
        movies: [Movie],
        onMovieTap: @escaping (Movie) -> Void,
        onTrailerTap: ((Movie) -> Void)? = nil,
        onSeeAll: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.movies = movies
        self.onMovieTap = onMovieTap
        self.onTrailerTap = onTrailerTap
        self.onSeeAll = onSeeAll
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Section header
            PremiumSectionHeader(
                title: title,
                subtitle: subtitle,
                onSeeAll: onSeeAll
            )

            // Horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(movies) { movie in
                        FeaturedMovieCard(
                            movie: movie,
                            onTap: { onMovieTap(movie) },
                            onTrailerTap: onTrailerTap.map { callback in { callback(movie) } }
                        )
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }
}

// MARK: - Featured Movie Card

struct FeaturedMovieCard: View {

    let movie: Movie
    let onTap: () -> Void
    let onTrailerTap: (() -> Void)?

    @State private var isPressed = false

    private let cardWidth: CGFloat = 300
    private let cardHeight: CGFloat = 180

    var body: some View {
        Button(action: {
            Haptics.shared.cardTapped()
            onTap()
        }) {
            ZStack(alignment: .bottomLeading) {
                // Backdrop image
                KFImage(movie.backdropURL ?? movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                            .shimmer(isActive: true)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: cardHeight)

                // Gradient overlay
                LinearGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Content
                HStack(alignment: .bottom, spacing: Spacing.sm) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(movie.title)
                            .font(.headline2)
                            .foregroundColor(.textPrimary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: Spacing.sm) {
                            // Rating
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.ratingStar)
                                Text(movie.formattedRating)
                                    .font(.labelMedium)
                                    .foregroundColor(.textPrimary)
                            }

                            if let year = movie.releaseYear {
                                Text("•")
                                    .foregroundColor(.textTertiary)
                                Text(year)
                                    .font(.labelMedium)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 0)

                    // Play trailer button
                    if onTrailerTap != nil {
                        Button {
                            Haptics.shared.buttonTapped()
                            onTrailerTap?()
                        } label: {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.textPrimary)
                                .frame(width: 40, height: 40)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(Spacing.md)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(AppTheme.Animation.quick, value: isPressed)
        }
        .buttonStyle(PressableCardStyle(isPressed: $isPressed))
    }
}

// MARK: - Streaming Row

struct StreamingRow: View {

    let service: StreamingService
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header with streaming service branding
            HStack(spacing: Spacing.sm) {
                // Service badge
                Text(service.displayName)
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                // Service indicator pill
                Text("Now Streaming")
                    .font(.pillSmall)
                    .foregroundColor(service.color)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xxs)
                    .background(service.color.opacity(0.15))
                    .clipShape(Capsule())

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textTertiary)
            }
            .padding(.horizontal, Spacing.horizontal)

            // Movies
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(movies) { movie in
                        StreamingPosterCard(
                            movie: movie,
                            service: service,
                            onTap: { onMovieTap(movie) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }
}

// MARK: - Streaming Poster Card

struct StreamingPosterCard: View {

    let movie: Movie
    let service: StreamingService
    let onTap: () -> Void

    @State private var isPressed = false

    private let cardWidth: CGFloat = 130
    private let cardHeight: CGFloat = 195

    var body: some View {
        Button(action: {
            Haptics.shared.cardTapped()
            onTap()
        }) {
            ZStack(alignment: .topLeading) {
                // Poster
                KFImage(movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                            .shimmer(isActive: true)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: cardHeight)

                // Service badge
                Text(service.shortName)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(service.color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(Spacing.xs)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous)
                    .stroke(service.color.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: service.color.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(AppTheme.Animation.quick, value: isPressed)
        }
        .buttonStyle(PressableCardStyle(isPressed: $isPressed))
    }
}

// MARK: - Premium Section Header

struct PremiumSectionHeader: View {

    let title: String
    let subtitle: String?
    let onSeeAll: (() -> Void)?

    var body: some View {
        Button(action: {
            onSeeAll?()
        }) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline1)
                        .foregroundColor(.textPrimary)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.labelMedium)
                            .foregroundColor(.textTertiary)
                    }
                }

                if onSeeAll != nil {
                    Spacer()

                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.labelMedium)
                            .foregroundColor(.accentPrimary)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.accentPrimary)
                    }
                } else {
                    Spacer()
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
        .buttonStyle(.plain)
        .disabled(onSeeAll == nil)
    }
}

// MARK: - Shimmer Effect

extension View {
    func shimmer(isActive: Bool) -> some View {
        modifier(ShimmerModifier(isActive: isActive))
    }
}

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.1),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 2)
                        .offset(x: -geometry.size.width + phase * geometry.size.width * 3)
                    }
                    .clipped()
                )
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

// MARK: - Pressable Card Button Style

struct PressableCardStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
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
                    subtitle: "Pick up where you left off",
                    movies: Movie.samples,
                    onMovieTap: { _ in }
                )

                ContentRow(
                    title: "Trending Now",
                    subtitle: "What everyone's watching",
                    movies: Movie.samples,
                    onMovieTap: { _ in }
                )

                FeaturedRow(
                    title: "Featured",
                    movies: Movie.samples,
                    onMovieTap: { _ in },
                    onTrailerTap: { _ in }
                )

                CompactMovieRow(
                    title: "Action Movies",
                    icon: "bolt.fill",
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
