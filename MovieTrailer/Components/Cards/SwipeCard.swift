//
//  SwipeCard.swift
//  MovieTrailer
//
//  Premium Apple TV-style swipeable movie card
//  Cinematic design with glassmorphism and rich animations
//

import SwiftUI
import Kingfisher

struct SwipeCard: View {

    // MARK: - Properties

    let movie: Movie
    let onSwipe: (SwipeDirection) -> Void
    let onTap: () -> Void
    var isTopCard: Bool = true

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var cardOpacity: Double = 0
    @State private var cardScale: Double = 0.9
    @GestureState private var isDragging = false

    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15

    enum SwipeDirection {
        case left   // Skip
        case right  // Like
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
            case .left: return "NOPE"
            case .right: return "LOVE"
            case .up: return "LATER"
            }
        }
    }

    // MARK: - Computed Properties

    private var swipeIndicator: SwipeDirection? {
        if offset.width > swipeThreshold * 0.6 {
            return .right
        } else if offset.width < -swipeThreshold * 0.6 {
            return .left
        } else if offset.height < -swipeThreshold * 0.6 {
            return .up
        }
        return nil
    }

    private var swipeProgress: CGFloat {
        let horizontal = abs(offset.width) / swipeThreshold
        let vertical = abs(offset.height) / swipeThreshold
        return min(1, max(horizontal, vertical))
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main card
                cardBody(size: geometry.size)

                // Swipe indicator overlay
                swipeIndicatorOverlay
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.1),
                                .clear,
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            // Dynamic glow based on swipe direction
            .shadow(color: glowColor.opacity(glowOpacity * 0.8), radius: 40, x: 0, y: 0)
            // Depth shadow
            .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 20)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(isDragging ? 1.03 : cardScale)
            .opacity(cardOpacity)
            .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.75), value: isDragging)
            .gesture(isTopCard ? dragGesture : nil)
            .onTapGesture {
                guard isTopCard else { return }
                Haptics.shared.cardTapped()
                onTap()
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    cardOpacity = 1
                    cardScale = 1
                }
            }
        }
        .aspectRatio(0.65, contentMode: .fit)
        // Accessibility support
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Double tap to view details. Swipe right to like, left to skip, up to save for later.")
        .accessibilityAddTraits(.isButton)
        .accessibilityActions {
            Button("Like") {
                onSwipe(.right)
            }
            Button("Skip") {
                onSwipe(.left)
            }
            Button("Save for Later") {
                onSwipe(.up)
            }
            Button("View Details") {
                onTap()
            }
        }
    }

    // MARK: - Accessibility

    private var accessibilityDescription: String {
        var parts: [String] = [movie.title]

        // Add rating
        parts.append("rated \(String(format: "%.1f", movie.voteAverage)) stars")

        // Add year
        if let year = movie.releaseDate?.prefix(4) {
            parts.append("from \(year)")
        }

        // Add genres
        if let genres = movie.genreNames, !genres.isEmpty {
            parts.append(genres.prefix(3).joined(separator: ", "))
        }

        return parts.joined(separator: ", ")
    }

    // MARK: - Card Body

    private func cardBody(size: CGSize) -> some View {
        ZStack {
            // Background image
            posterImage(size: size)

            // Cinematic gradient overlay
            cinematicGradient

            // Content overlay
            VStack(spacing: 0) {
                // Top bar with rating
                topBar

                Spacer()

                // Bottom info panel
                bottomInfoPanel
            }
        }
    }

    // MARK: - Parallax Offset

    private var parallaxOffset: CGSize {
        CGSize(
            width: offset.width * 0.05,
            height: offset.height * 0.05
        )
    }

    // MARK: - Poster Image

    private func posterImage(size: CGSize) -> some View {
        KFImage(movie.posterURL)
            .placeholder {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(white: 0.12),
                            Color(white: 0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    VStack(spacing: 16) {
                        Image(systemName: "film.fill")
                            .font(.system(size: 48, weight: .thin))
                            .foregroundColor(.white.opacity(0.15))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 100, height: 8)
                    }
                }
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width + 20, height: size.height + 20)
            .offset(parallaxOffset)
            .clipped()
            .frame(width: size.width, height: size.height)
    }

    // MARK: - Cinematic Gradient

    private var cinematicGradient: some View {
        ZStack {
            // Top vignette
            VStack {
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.7), location: 0),
                        .init(color: .black.opacity(0.3), location: 0.5),
                        .init(color: .clear, location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 150)

                Spacer()
            }

            // Bottom gradient - rich cinematic
            VStack {
                Spacer()

                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .black.opacity(0.4), location: 0.3),
                        .init(color: .black.opacity(0.85), location: 0.7),
                        .init(color: .black.opacity(0.95), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 320)
            }

            // Side vignettes
            HStack {
                LinearGradient(
                    colors: [.black.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 60)

                Spacer()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 60)
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(alignment: .top) {
            // Premium rating badge
            premiumRatingBadge

            Spacer()

            // Quick actions
            VStack(spacing: 12) {
                quickActionButton(icon: "info.circle", action: onTap)
            }
        }
        .padding(20)
    }

    // MARK: - Premium Rating Badge

    private var premiumRatingBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(String(format: "%.1f", movie.voteAverage))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            ZStack {
                // Glass background
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)

                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    // MARK: - Quick Action Button

    private func quickActionButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                )
        }
    }

    // MARK: - Bottom Info Panel

    private var bottomInfoPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Genre pills - moved to top for better visual hierarchy
            if let genres = movie.genreNames, !genres.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(genres.prefix(3), id: \.self) { genre in
                            genrePill(genre)
                        }
                    }
                }
            }

            // Title with year inline
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(movie.title)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                if let year = movie.releaseDate?.prefix(4) {
                    Text("(\(year))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)

            // Overview
            if !movie.overview.isEmpty {
                Text(movie.overview)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(3)
                    .lineSpacing(3)
            }

            // Modern swipe hint
            modernSwipeHint
                .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 28)
    }

    // MARK: - Modern Swipe Hint

    private var modernSwipeHint: some View {
        HStack(spacing: 0) {
            // Skip hint
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 10, weight: .bold))
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.swipeSkip.opacity(0.7))

            Spacer()

            // Center drag indicator
            VStack(spacing: 4) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.swipeWatchLater.opacity(0.6))

                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 36, height: 4)
            }

            Spacer()

            // Like hint
            HStack(spacing: 6) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundColor(.swipeLove.opacity(0.7))
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Metadata Chip

    private func metadataChip(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text(text)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundColor(.white.opacity(0.75))
    }

    // MARK: - Genre Pill

    private func genrePill(_ genre: String) -> some View {
        Text(genre)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white.opacity(0.95))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(.white.opacity(0.15))
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
    }

    // MARK: - Swipe Indicator Overlay

    private var swipeIndicatorOverlay: some View {
        ZStack {
            // Direction indicators
            if let indicator = swipeIndicator {
                swipeDirectionIndicator(indicator)
                    .transition(.scale.combined(with: .opacity))
            }

            // Edge glow effect
            edgeGlowEffect
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: swipeIndicator)
    }

    private func swipeDirectionIndicator(_ direction: SwipeDirection) -> some View {
        VStack(spacing: 12) {
            // Modern pill indicator with icon
            HStack(spacing: 10) {
                Image(systemName: direction.icon)
                    .font(.system(size: 28, weight: .bold))

                Text(direction.label)
                    .font(.system(size: 22, weight: .black, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 18)
            .background(
                Capsule()
                    .fill(direction.color)
                    .shadow(color: direction.color, radius: 20, x: 0, y: 0)
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
        }
        .scaleEffect(0.7 + (swipeProgress * 0.5))
        .opacity(Double(swipeProgress * 1.2).clamped(to: 0...1))
        .rotation3DEffect(
            .degrees(direction == .left ? -5 : (direction == .right ? 5 : 0)),
            axis: (x: 0, y: 1, z: 0)
        )
    }

    private var edgeGlowEffect: some View {
        GeometryReader { geometry in
            ZStack {
                // Left edge glow (skip)
                if offset.width < 0 {
                    LinearGradient(
                        colors: [SwipeDirection.left.color.opacity(0.4 * swipeProgress), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 100)
                    .position(x: 50, y: geometry.size.height / 2)
                }

                // Right edge glow (like)
                if offset.width > 0 {
                    LinearGradient(
                        colors: [.clear, SwipeDirection.right.color.opacity(0.4 * swipeProgress)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 100)
                    .position(x: geometry.size.width - 50, y: geometry.size.height / 2)
                }

                // Top edge glow (watch later)
                if offset.height < 0 {
                    LinearGradient(
                        colors: [SwipeDirection.up.color.opacity(0.4 * swipeProgress), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .position(x: geometry.size.width / 2, y: 50)
                }
            }
        }
    }

    // MARK: - Glow Color

    private var glowColor: Color {
        switch swipeIndicator {
        case .left: return .swipeSkip
        case .right: return .swipeLove
        case .up: return .swipeWatchLater
        case .none: return .clear
        }
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { gesture in
                offset = gesture.translation
                rotation = Double(gesture.translation.width / 25).clamped(to: -maxRotation...maxRotation)
                glowOpacity = Double(swipeProgress)
            }
            .onEnded { gesture in
                let direction: SwipeDirection?

                if gesture.translation.width > swipeThreshold {
                    direction = .right
                    Haptics.shared.swipeRight()
                } else if gesture.translation.width < -swipeThreshold {
                    direction = .left
                    Haptics.shared.swipeLeft()
                } else if gesture.translation.height < -swipeThreshold {
                    direction = .up
                    Haptics.shared.superLike()
                } else {
                    direction = nil
                }

                if let direction = direction {
                    // Success haptic
                    Haptics.shared.success()

                    // Animate card off screen
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        switch direction {
                        case .left:
                            offset = CGSize(width: -600, height: gesture.translation.height)
                            rotation = -20
                        case .right:
                            offset = CGSize(width: 600, height: gesture.translation.height)
                            rotation = 20
                        case .up:
                            offset = CGSize(width: gesture.translation.width, height: -900)
                            rotation = 0
                        }
                        glowOpacity = 0
                    }

                    // Notify parent
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        onSwipe(direction)
                    }
                } else {
                    // Reset with bounce
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        offset = .zero
                        rotation = 0
                        glowOpacity = 0
                    }
                }
            }
    }
}

// MARK: - Clamped Extension

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Premium Swipe Action Button

struct SwipeActionButton: View {

    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    var isEnabled: Bool = true

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            Haptics.shared.mediumImpact()
            action()
        }) {
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(color.opacity(isEnabled ? 0.3 : 0.1), lineWidth: 2)
                    .frame(width: size, height: size)

                // Inner fill
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(isEnabled ? 0.25 : 0.1),
                                color.opacity(isEnabled ? 0.15 : 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size - 4, height: size - 4)

                // Glass overlay
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: size - 4, height: size - 4)
                    .opacity(0.5)

                // Icon
                Image(systemName: icon)
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundColor(isEnabled ? color : color.opacity(0.4))
            }
            .shadow(color: color.opacity(isEnabled ? 0.4 : 0), radius: 12, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Preview

#if DEBUG
struct SwipeCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            SwipeCard(
                movie: .sample,
                onSwipe: { _ in },
                onTap: {}
            )
            .padding(24)
        }
    }
}
#endif
