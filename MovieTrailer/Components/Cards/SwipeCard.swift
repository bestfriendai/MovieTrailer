//
//  SwipeCard.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Tinder-style swipeable movie card
//

import SwiftUI
import Kingfisher

struct SwipeCard: View {

    // MARK: - Properties

    let movie: Movie
    let onSwipe: (SwipeDirection) -> Void
    let onTap: () -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @GestureState private var isDragging = false

    private let swipeThreshold: CGFloat = 100

    enum SwipeDirection {
        case left   // Skip
        case right  // Like
        case up     // Super Like / Watch Later
    }

    // MARK: - Computed Properties

    private var swipeIndicator: SwipeDirection? {
        if offset.width > swipeThreshold {
            return .right
        } else if offset.width < -swipeThreshold {
            return .left
        } else if offset.height < -swipeThreshold {
            return .up
        }
        return nil
    }

    private var indicatorOpacity: Double {
        let maxOffset = swipeThreshold * 1.5
        switch swipeIndicator {
        case .left:
            return min(1, Double(abs(offset.width)) / maxOffset)
        case .right:
            return min(1, Double(abs(offset.width)) / maxOffset)
        case .up:
            return min(1, Double(abs(offset.height)) / maxOffset)
        case .none:
            return 0
        }
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                posterImage(size: geometry.size)

                // Gradient overlay
                gradientOverlay

                // Content
                cardContent

                // Swipe indicators
                swipeIndicators
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .offset(offset)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(isDragging ? 1.02 : 1.0)
            .animation(AppTheme.Animation.stiff, value: isDragging)
            .gesture(dragGesture)
            .onTapGesture {
                Haptics.shared.cardTapped()
                onTap()
            }
        }
        .aspectRatio(0.65, contentMode: .fit)
    }

    // MARK: - Poster Image

    private func posterImage(size: CGSize) -> some View {
        KFImage(movie.posterURL)
            .placeholder {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.gray.opacity(0.4), .gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Image(systemName: "film")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                    }
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
    }

    // MARK: - Gradient Overlay

    private var gradientOverlay: some View {
        VStack(spacing: 0) {
            // Top gradient for rating
            LinearGradient(
                colors: [.black.opacity(0.6), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)

            Spacer()

            // Bottom gradient for info
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
        }
    }

    // MARK: - Card Content

    private var cardContent: some View {
        VStack {
            // Top - Rating
            HStack {
                ratingBadge
                Spacer()
            }
            .padding(Spacing.lg)

            Spacer()

            // Bottom - Movie info
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Title
                Text(movie.title)
                    .font(.displaySmall)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(radius: 4)

                // Metadata
                HStack(spacing: Spacing.md) {
                    // Year
                    if let year = movie.releaseDate?.prefix(4) {
                        metadataItem(icon: "calendar", text: String(year))
                    }

                    // Vote count
                    metadataItem(icon: "person.2.fill", text: "\(movie.voteCount) votes")
                }

                // Genres
                if let genres = movie.genreNames {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.xs) {
                            ForEach(genres.prefix(4), id: \.self) { genre in
                                Text(genre)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, Spacing.sm)
                                    .padding(.vertical, Spacing.xxs)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // Overview
                if !movie.overview.isEmpty {
                    Text(movie.overview)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(3)
                        .padding(.top, Spacing.xs)
                }
            }
            .padding(Spacing.lg)
        }
    }

    // MARK: - Rating Badge

    private var ratingBadge: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)

            Text(String(format: "%.1f", movie.voteAverage))
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    // MARK: - Metadata Item

    private func metadataItem(icon: String, text: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.subheadline)
        }
        .foregroundColor(.white.opacity(0.8))
    }

    // MARK: - Swipe Indicators

    private var swipeIndicators: some View {
        ZStack {
            // Like indicator (right)
            likeIndicator
                .opacity(swipeIndicator == .right ? indicatorOpacity : 0)

            // Skip indicator (left)
            skipIndicator
                .opacity(swipeIndicator == .left ? indicatorOpacity : 0)

            // Super like indicator (up)
            superLikeIndicator
                .opacity(swipeIndicator == .up ? indicatorOpacity : 0)
        }
    }

    private var likeIndicator: some View {
        VStack {
            HStack {
                Text("LIKE")
                    .font(.system(size: 40, weight: .black))
                    .foregroundColor(.swipeLike)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.swipeLike, lineWidth: 4)
                    )
                    .rotationEffect(.degrees(-20))
                Spacer()
            }
            Spacer()
        }
        .padding(Spacing.xl)
    }

    private var skipIndicator: some View {
        VStack {
            HStack {
                Spacer()
                Text("SKIP")
                    .font(.system(size: 40, weight: .black))
                    .foregroundColor(.swipeSkip)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.swipeSkip, lineWidth: 4)
                    )
                    .rotationEffect(.degrees(20))
            }
            Spacer()
        }
        .padding(Spacing.xl)
    }

    private var superLikeIndicator: some View {
        VStack {
            Spacer()
            Text("WATCH LATER")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.swipeSuperLike)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.swipeSuperLike, lineWidth: 4)
                )
            Spacer()
        }
        .padding(Spacing.xl)
    }

    // MARK: - Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { gesture in
                offset = gesture.translation
                rotation = Double(gesture.translation.width / 20)
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
                    // Animate card off screen
                    withAnimation(AppTheme.Animation.smooth) {
                        switch direction {
                        case .left:
                            offset = CGSize(width: -500, height: 0)
                        case .right:
                            offset = CGSize(width: 500, height: 0)
                        case .up:
                            offset = CGSize(width: 0, height: -800)
                        }
                        rotation = direction == .left ? -30 : (direction == .right ? 30 : 0)
                    }

                    // Notify parent after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSwipe(direction)
                    }
                } else {
                    // Reset position
                    withAnimation(AppTheme.Animation.bouncy) {
                        offset = .zero
                        rotation = 0
                    }
                }
            }
    }
}

// MARK: - Swipe Action Button

struct SwipeActionButton: View {

    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.shared.mediumImpact()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 2)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG
struct SwipeCard_Previews: PreviewProvider {
    static var previews: some View {
        SwipeCard(
            movie: .sample,
            onSwipe: { _ in },
            onTap: {}
        )
        .padding()
    }
}
#endif
