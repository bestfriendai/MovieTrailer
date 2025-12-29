//
//  ParallaxMovieCard.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Premium parallax movie card with 3D transformations
//

import SwiftUI
import Kingfisher

// MARK: - Parallax Movie Card

struct ParallaxMovieCard: View {
    let movie: Movie
    let onTap: () -> Void
    let isInWatchlist: Bool
    let onWatchlistToggle: (() -> Void)?

    @State private var isPressed = false
    @State private var dragOffset: CGSize = .zero
    @GestureState private var isDragging = false

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(
        movie: Movie,
        onTap: @escaping () -> Void,
        isInWatchlist: Bool = false,
        onWatchlistToggle: (() -> Void)? = nil
    ) {
        self.movie = movie
        self.onTap = onTap
        self.isInWatchlist = isInWatchlist
        self.onWatchlistToggle = onWatchlistToggle
    }

    var body: some View {
        GeometryReader { geometry in
            let midX = geometry.frame(in: .global).midX
            let midY = geometry.frame(in: .global).midY
            let screenMidX = UIScreen.main.bounds.width / 2
            let screenMidY = UIScreen.main.bounds.height / 2

            // Calculate rotation based on position in viewport
            let rotationX = reduceMotion ? 0 : (midY - screenMidY) / 30
            let rotationY = reduceMotion ? 0 : (midX - screenMidX) / -30

            // Additional rotation from drag
            let dragRotationX = reduceMotion ? 0 : dragOffset.height / 10
            let dragRotationY = reduceMotion ? 0 : -dragOffset.width / 10

            ZStack {
                // Shadow layer (offset for depth)
                if !reduceMotion {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                        .blur(radius: 20)
                        .offset(
                            x: -rotationY * 1.5 - dragRotationY,
                            y: rotationX * 1.5 + dragRotationX + 15
                        )
                        .scaleEffect(0.95)
                }

                // Main card
                cardContent(geometry: geometry)
                    .rotation3DEffect(
                        .degrees(isPressed ? (rotationX + dragRotationX) * 0.3 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: 0.5
                    )
                    .rotation3DEffect(
                        .degrees(isPressed ? (rotationY + dragRotationY) * 0.3 : 0),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
            }
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(
                reduceMotion ? .linear(duration: 0.1) : .spring(response: 0.3, dampingFraction: 0.6),
                value: isPressed
            )
        }
        .aspectRatio(2/3, contentMode: .fit)
        .onTapGesture {
            Haptics.shared.mediumImpact()
            onTap()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { value in
                    if !reduceMotion {
                        dragOffset = CGSize(
                            width: value.translation.width.clamped(to: -20...20),
                            height: value.translation.height.clamped(to: -20...20)
                        )
                    }
                    if !isPressed {
                        withAnimation(.spring(response: 0.2)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        isPressed = false
                        dragOffset = .zero
                    }
                }
        )
        // Accessibility handled at call site
    }

    // MARK: - Card Content

    private func cardContent(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottom) {
            // Poster image
            KFImage(movie.posterURL)
                .placeholder {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                .frame(width: geometry.size.width, height: geometry.size.height)

            // Gradient overlay
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.5),
                    .init(color: .black.opacity(0.3), location: 0.7),
                    .init(color: .black.opacity(0.8), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Info overlay
            VStack(alignment: .leading, spacing: 6) {
                // Rating badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.ratingStar)

                    Text(movie.formattedRating)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())

                Spacer()

                // Title
                Text(movie.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .shadow(color: .black.opacity(0.5), radius: 2, y: 1)

                // Year
                if let year = movie.releaseYear {
                    Text(year)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Watchlist indicator
            if isInWatchlist {
                VStack {
                    HStack {
                        Spacer()

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 28, height: 28)
                            )
                            .padding(8)
                    }
                    Spacer()
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(isPressed ? 0.4 : 0.2),
                            .white.opacity(0.05),
                            .clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(
            color: .black.opacity(isPressed ? 0.2 : 0.4),
            radius: isPressed ? 5 : 15,
            x: 0,
            y: isPressed ? 3 : 10
        )
    }
}

// MARK: - Staggered Appear Modifier

struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    let animation: Animation

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 30)
            .scaleEffect(isVisible ? 1 : 0.9)
            .onAppear {
                let delay = Double(index) * 0.05
                withAnimation(animation.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggeredAppear(
        index: Int,
        animation: Animation = .spring(response: 0.5, dampingFraction: 0.7)
    ) -> some View {
        modifier(StaggeredAppearModifier(index: index, animation: animation))
    }
}

// MARK: - Bounce Animation Modifier

struct BounceAnimationModifier: ViewModifier {
    let trigger: Bool

    @State private var animating = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(animating ? 1.2 : 1.0)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                        animating = true
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
                        animating = false
                    }
                }
            }
    }
}

extension View {
    func bounceOnChange(_ trigger: Bool) -> some View {
        modifier(BounceAnimationModifier(trigger: trigger))
    }
}

// MARK: - Floating Animation

struct FloatingModifier: ViewModifier {
    let enabled: Bool
    let amount: CGFloat
    let duration: Double

    @State private var floating = false

    func body(content: Content) -> some View {
        content
            .offset(y: floating ? -amount : amount)
            .onAppear {
                guard enabled else { return }
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    floating = true
                }
            }
    }
}

extension View {
    func floating(
        enabled: Bool = true,
        amount: CGFloat = 5,
        duration: Double = 2
    ) -> some View {
        modifier(FloatingModifier(enabled: enabled, amount: amount, duration: duration))
    }
}

// MARK: - Glow Effect

struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let animated: Bool

    @State private var glowing = false

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(glowing ? 0.8 : 0.4), radius: radius)
            .onAppear {
                guard animated else { return }
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    glowing = true
                }
            }
    }
}

extension View {
    func glow(
        color: Color = .white,
        radius: CGFloat = 10,
        animated: Bool = false
    ) -> some View {
        modifier(GlowModifier(color: color, radius: radius, animated: animated))
    }
}

// MARK: - Preview

#if DEBUG
struct ParallaxMovieCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 16
                ) {
                    ForEach(Array(Movie.samples.enumerated()), id: \.element.id) { index, movie in
                        ParallaxMovieCard(
                            movie: movie,
                            onTap: {},
                            isInWatchlist: index % 2 == 0
                        )
                        .staggeredAppear(index: index)
                    }
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }
}
#endif
