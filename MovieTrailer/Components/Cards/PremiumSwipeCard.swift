//
//  PremiumSwipeCard.swift
//  MovieTrailer
//
//  Apple 2025 Premium Swipe Card
//  Tinder-style with enhanced physics and visual feedback
//

import SwiftUI
import Kingfisher

// MARK: - Swipe Direction

enum SwipeDirection: String, CaseIterable {
    case left   // Skip
    case right  // Love/Like
    case up     // Watch Later

    var color: Color {
        switch self {
        case .left: return .swipeSkip
        case .right: return .swipeLove
        case .up: return .swipeWatchLater
        }
    }

    var icon: String {
        switch self {
        case .left: return "xmark"
        case .right: return "heart.fill"
        case .up: return "bookmark.fill"
        }
    }

    var label: String {
        switch self {
        case .left: return "SKIP"
        case .right: return "LOVE"
        case .up: return "WATCH LATER"
        }
    }
}

// MARK: - Premium Swipe Card

struct PremiumSwipeCard: View {

    // MARK: - Properties

    let movie: Movie
    let onSwipe: (SwipeDirection) -> Void
    let onTap: () -> Void
    let onTrailerTap: (() -> Void)?

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @GestureState private var isDragging = false

    // Configuration
    private let swipeThreshold: CGFloat = 120
    private let rotationFactor: Double = 25
    private let cardWidth: CGFloat = Size.swipeCardMaxWidth
    private let cardAspectRatio: CGFloat = 0.62

    // MARK: - Computed Properties

    private var currentDirection: SwipeDirection? {
        if offset.width > swipeThreshold {
            return .right
        } else if offset.width < -swipeThreshold {
            return .left
        } else if offset.height < -swipeThreshold {
            return .up
        }
        return nil
    }

    private var indicatorProgress: CGFloat {
        let maxOffset = swipeThreshold * 1.5
        switch currentDirection {
        case .left:
            return min(1, abs(offset.width) / maxOffset)
        case .right:
            return min(1, abs(offset.width) / maxOffset)
        case .up:
            return min(1, abs(offset.height) / maxOffset)
        case .none:
            let maxProgress = max(
                abs(offset.width) / maxOffset,
                abs(offset.height) / maxOffset
            )
            return min(0.5, maxProgress)
        }
    }

    private var backgroundTintColor: Color {
        guard let direction = currentDirection else { return .clear }
        return direction.color.opacity(indicatorProgress * 0.3)
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let cardHeight = geometry.size.width * cardAspectRatio / AspectRatio.poster

            ZStack {
                // Background image
                posterImage(width: geometry.size.width * 0.88, height: cardHeight)

                // Gradient overlay
                gradientOverlay

                // Direction tint overlay
                backgroundTintColor
                    .animation(AppTheme.Animation.micro, value: currentDirection)

                // Content
                cardContent

                // Swipe indicators
                swipeIndicatorOverlay

                // Glass border
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            }
            .frame(width: geometry.size.width * 0.88, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card, style: .continuous))
            .heroShadow()
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(isDragging ? 1.02 : scale)
            .animation(AppTheme.Animation.interactive, value: isDragging)
            .gesture(dragGesture)
            .onTapGesture {
                Haptics.shared.cardTapped()
                onTap()
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    // MARK: - Poster Image

    private func posterImage(width: CGFloat, height: CGFloat) -> some View {
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
                    .overlay {
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "film")
                                .font(.system(size: 60))
                                .foregroundColor(.textTertiary)

                            Text("Loading...")
                                .font(.labelMedium)
                                .foregroundColor(.textTertiary)
                        }
                    }
                    .shimmer(isActive: true)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
    }

    // MARK: - Gradient Overlay

    private var gradientOverlay: some View {
        VStack(spacing: 0) {
            // Top gradient for badges
            LinearGradient(
                colors: [.black.opacity(0.7), .black.opacity(0.3), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)

            Spacer()

            // Bottom gradient for content
            LinearGradient(
                colors: [.clear, .black.opacity(0.5), .black.opacity(0.9), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
        }
    }

    // MARK: - Card Content

    private var cardContent: some View {
        VStack {
            // Top section - Rating & badges
            topSection

            Spacer()

            // Bottom section - Movie info
            bottomSection
        }
    }

    private var topSection: some View {
        HStack(alignment: .top) {
            // Rating badge
            ratingBadge

            Spacer()

            // Streaming badges (if available)
            // Placeholder for streaming service logos
        }
        .padding(Spacing.lg)
    }

    private var ratingBadge: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "star.fill")
                .font(.system(size: 14))
                .foregroundColor(.ratingStar)

            Text(movie.formattedRating)
                .font(.ratingLarge)
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.glassBorder, lineWidth: 0.5)
        )
    }

    private var bottomSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Title
            Text(movie.title)
                .font(.displaySmall)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)

            // Metadata row
            HStack(spacing: Spacing.md) {
                // Year
                if let year = movie.releaseDate?.prefix(4) {
                    metadataItem(icon: "calendar", text: String(year))
                }

                // Vote count
                if movie.voteCount > 0 {
                    metadataItem(icon: "person.2.fill", text: formatVoteCount(movie.voteCount))
                }
            }

            // Genres
            if let genres = movie.genreNames, !genres.isEmpty {
                genrePills(genres: Array(genres.prefix(4)))
            }

            // Quick trailer button
            if onTrailerTap != nil {
                quickTrailerButton
                    .padding(.top, Spacing.xs)
            }

            // Overview
            if !movie.overview.isEmpty {
                Text(movie.overview)
                    .font(.bodySmall)
                    .foregroundColor(.textSecondary)
                    .lineLimit(3)
                    .padding(.top, Spacing.xs)
            }
        }
        .padding(Spacing.lg)
    }

    private func metadataItem(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.labelMedium)
        }
        .foregroundColor(.textSecondary)
    }

    private func genrePills(genres: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                ForEach(genres, id: \.self) { genre in
                    Text(genre)
                        .font(.pillSmall)
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, Spacing.xxs)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.glassBorder, lineWidth: 0.5)
                        )
                }
            }
        }
    }

    private var quickTrailerButton: some View {
        Button {
            Haptics.shared.buttonTapped()
            onTrailerTap?()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "play.fill")
                    .font(.system(size: 12))
                Text("Quick Trailer")
                    .font(.buttonSmall)
            }
            .foregroundColor(.textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Swipe Indicators

    private var swipeIndicatorOverlay: some View {
        ZStack {
            // Love indicator (right)
            swipeIndicator(for: .right)
                .opacity(currentDirection == .right ? indicatorProgress : 0)

            // Skip indicator (left)
            swipeIndicator(for: .left)
                .opacity(currentDirection == .left ? indicatorProgress : 0)

            // Watch Later indicator (up)
            swipeIndicator(for: .up)
                .opacity(currentDirection == .up ? indicatorProgress : 0)
        }
        .animation(AppTheme.Animation.micro, value: currentDirection)
    }

    private func swipeIndicator(for direction: SwipeDirection) -> some View {
        VStack {
            if direction == .up {
                Spacer()
            }

            HStack {
                if direction == .right {
                    indicatorContent(for: direction)
                        .rotationEffect(.degrees(-15))
                    Spacer()
                } else if direction == .left {
                    Spacer()
                    indicatorContent(for: direction)
                        .rotationEffect(.degrees(15))
                } else {
                    indicatorContent(for: direction)
                }
            }

            if direction != .up {
                Spacer()
            } else {
                Spacer()
                    .frame(height: 100)
            }
        }
        .padding(Spacing.xl)
    }

    private func indicatorContent(for direction: SwipeDirection) -> some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: direction.icon)
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(direction.color)

            Text(direction.label)
                .font(.system(size: 24, weight: .black))
                .foregroundColor(direction.color)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous)
                .stroke(direction.color, lineWidth: 4)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .shadow(color: direction.color.opacity(0.5), radius: 20, x: 0, y: 0)
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { gesture in
                offset = gesture.translation
                rotation = Double(gesture.translation.width / rotationFactor)

                // Haptic feedback when crossing threshold
                if abs(gesture.translation.width) > swipeThreshold ||
                   gesture.translation.height < -swipeThreshold {
                    if indicatorProgress > 0.95 && indicatorProgress < 1.0 {
                        Haptics.shared.selectionChanged()
                    }
                }
            }
            .onEnded { gesture in
                let direction: SwipeDirection?

                if gesture.translation.width > swipeThreshold {
                    direction = .right
                    Haptics.shared.swipeLike()
                } else if gesture.translation.width < -swipeThreshold {
                    direction = .left
                    Haptics.shared.swipeSkip()
                } else if gesture.translation.height < -swipeThreshold {
                    direction = .up
                    Haptics.shared.swipeSuperLike()
                } else {
                    direction = nil
                }

                if let direction = direction {
                    // Animate card off screen
                    withAnimation(AppTheme.Animation.swipeRelease) {
                        switch direction {
                        case .left:
                            offset = CGSize(width: -600, height: gesture.translation.height)
                            rotation = -30
                        case .right:
                            offset = CGSize(width: 600, height: gesture.translation.height)
                            rotation = 30
                        case .up:
                            offset = CGSize(width: gesture.translation.width, height: -800)
                            scale = 0.8
                        }
                    }

                    // Notify parent after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        onSwipe(direction)
                    }
                } else {
                    // Reset position with bounce
                    withAnimation(AppTheme.Animation.bouncy) {
                        offset = .zero
                        rotation = 0
                        scale = 1.0
                    }
                }
            }
    }

    // MARK: - Helper Methods

    private func formatVoteCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fK", Double(count) / 1000)
        }
        return "\(count)"
    }
}

// MARK: - Premium Swipe Action Button

struct PremiumSwipeActionButton: View {

    let direction: SwipeDirection
    let size: Size
    let action: () -> Void

    enum Size {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: return 44
            case .medium: return 56
            case .large: return 64
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 18
            case .medium: return 22
            case .large: return 26
            }
        }
    }

    @State private var isPressed = false

    var body: some View {
        Button {
            Haptics.shared.buttonTapped()
            action()
        } label: {
            ZStack {
                // Background
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size.dimension, height: size.dimension)
                    .overlay(
                        Circle()
                            .stroke(direction.color.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: direction.color.opacity(0.3), radius: 8, x: 0, y: 4)

                // Icon
                Image(systemName: direction.icon)
                    .font(.system(size: size.iconSize, weight: .bold))
                    .foregroundColor(direction.color)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Swipe Stats Overlay

struct SwipeStatsView: View {

    let totalSwiped: Int
    let likedCount: Int
    let skippedCount: Int
    let watchLaterCount: Int

    var matchRate: Double {
        guard totalSwiped > 0 else { return 0 }
        return Double(likedCount) / Double(totalSwiped) * 100
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Text("Your Swipe Stats")
                .font(.headline2)
                .foregroundColor(.textPrimary)

            // Stats grid
            HStack(spacing: Spacing.xl) {
                statItem(value: "\(totalSwiped)", label: "SWIPED", color: .textSecondary)
                statItem(value: "\(likedCount)", label: "LOVED", color: .swipeLove)
                statItem(value: "\(skippedCount)", label: "SKIPPED", color: .swipeSkip)
            }

            // Match rate
            VStack(spacing: Spacing.sm) {
                Text(String(format: "%.1f%%", matchRate))
                    .font(.statsNumber)
                    .foregroundColor(.accentPink)

                Text("Match Rate")
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceSecondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.accentPurple, .accentPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * (matchRate / 100))
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
        }
        .padding(Spacing.lg)
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.statsNumber)
                .foregroundColor(color)

            Text(label)
                .font(.statsLabel)
                .foregroundColor(.textTertiary)
        }
    }
}

// MARK: - Match Animation Overlay

struct MatchAnimationOverlay: View {

    let movie: Movie
    @Binding var isShowing: Bool
    let onAddToList: () -> Void
    let onContinue: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var confettiTrigger = false

    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Content
            VStack(spacing: Spacing.xl) {
                // Title
                Text("IT'S A MATCH!")
                    .font(.displayMedium)
                    .foregroundColor(.textPrimary)
                    .accentGradientText()

                // Poster
                KFImage(movie.posterURL)
                    .resizable()
                    .aspectRatio(AspectRatio.poster, contentMode: .fill)
                    .frame(width: 200, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
                    .shadow(color: .accentPink.opacity(0.5), radius: 30, x: 0, y: 0)

                // Message
                Text("Based on your taste, you'll probably love this one!")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Buttons
                VStack(spacing: Spacing.sm) {
                    Button {
                        Haptics.shared.buttonTapped()
                        onAddToList()
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add to My List")
                        }
                        .font(.buttonMedium)
                        .foregroundColor(.textInverted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(Color.accentPink)
                        .clipShape(Capsule())
                    }

                    Button {
                        Haptics.shared.buttonTapped()
                        dismiss()
                        onContinue()
                    } label: {
                        Text("Keep Swiping")
                            .font(.buttonMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, Spacing.xl)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(AppTheme.Animation.bouncy) {
                scale = 1.0
                opacity = 1.0
            }
            Haptics.shared.success()
        }
    }

    private func dismiss() {
        withAnimation(AppTheme.Animation.smooth) {
            scale = 0.8
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PremiumSwipeCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            PremiumSwipeCard(
                movie: .sample,
                onSwipe: { _ in },
                onTap: {},
                onTrailerTap: {}
            )
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
