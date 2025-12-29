//
//  SkeletonLoading.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Premium skeleton loading components with shimmer animations
//

import SwiftUI

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    let angle: Double
    let delay: Double
    let duration: Double

    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    GeometryReader { geo in
                        shimmerGradient
                            .rotationEffect(.degrees(angle))
                            .offset(x: phase * (geo.size.width * 2.5))
                    }
                    .clipped()
                }
            }
            .onAppear {
                guard isActive else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(
                        .linear(duration: duration)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            }
    }

    private var shimmerGradient: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .white.opacity(0.08), location: 0.3),
                .init(color: .white.opacity(0.15), location: 0.5),
                .init(color: .white.opacity(0.08), location: 0.7),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension View {
    func shimmer(
        isActive: Bool = true,
        angle: Double = 70,
        delay: Double = 0,
        duration: Double = 1.5
    ) -> some View {
        modifier(ShimmerModifier(
            isActive: isActive,
            angle: angle,
            delay: delay,
            duration: duration
        ))
    }
}

// MARK: - Skeleton Movie Card

struct SkeletonMovieCard: View {
    let width: CGFloat
    let height: CGFloat
    let showTitle: Bool
    let showRating: Bool
    let delay: Double

    init(
        width: CGFloat = 120,
        height: CGFloat = 180,
        showTitle: Bool = true,
        showRating: Bool = true,
        delay: Double = 0
    ) {
        self.width = width
        self.height = height
        self.showTitle = showTitle
        self.showRating = showRating
        self.delay = delay
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster skeleton
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.surfaceSecondary)
                .frame(width: width, height: height)
                .shimmer(isActive: true, delay: delay)

            if showTitle {
                // Title skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.surfaceSecondary)
                    .frame(width: width * 0.85, height: 14)
                    .shimmer(isActive: true, delay: delay + 0.1)
            }

            if showRating {
                // Rating skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.surfaceSecondary)
                    .frame(width: width * 0.5, height: 12)
                    .shimmer(isActive: true, delay: delay + 0.2)
            }
        }
    }
}

// MARK: - Skeleton Movie Row

struct SkeletonMovieRow: View {
    let title: String
    let cardCount: Int
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    init(
        title: String = "",
        cardCount: Int = 5,
        cardWidth: CGFloat = 120,
        cardHeight: CGFloat = 180
    ) {
        self.title = title
        self.cardCount = cardCount
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            if !title.isEmpty {
                HStack {
                    Text(title)
                        .font(.headline2)
                        .foregroundColor(.textPrimary)

                    Spacer()
                }
                .padding(.horizontal, 20)
            } else {
                // Skeleton title
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.surfaceSecondary)
                    .frame(width: 150, height: 20)
                    .shimmer(isActive: true)
                    .padding(.horizontal, 20)
            }

            // Horizontal scroll of skeleton cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<cardCount, id: \.self) { index in
                        SkeletonMovieCard(
                            width: cardWidth,
                            height: cardHeight,
                            delay: Double(index) * 0.05
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Skeleton Hero

struct SkeletonHero: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Rectangle()
                .fill(Color.surfaceSecondary)
                .shimmer(isActive: true, duration: 2.0)

            // Bottom gradient
            LinearGradient(
                colors: [.clear, .black.opacity(0.8), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)

            // Content
            VStack(spacing: 16) {
                Spacer()

                // Title skeleton
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.surfaceSecondary)
                    .frame(width: 250, height: 32)
                    .shimmer(isActive: true, delay: 0.2)

                // Metadata skeleton
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceSecondary)
                        .frame(width: 60, height: 16)
                        .shimmer(isActive: true, delay: 0.3)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceSecondary)
                        .frame(width: 40, height: 16)
                        .shimmer(isActive: true, delay: 0.35)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceSecondary)
                        .frame(width: 80, height: 16)
                        .shimmer(isActive: true, delay: 0.4)
                }

                // Genre pills skeleton
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(Color.surfaceSecondary)
                            .frame(width: 60, height: 24)
                            .shimmer(isActive: true, delay: 0.5 + Double(index) * 0.05)
                    }
                }

                // Buttons skeleton
                HStack(spacing: 16) {
                    Capsule()
                        .fill(Color.surfaceSecondary)
                        .frame(width: 140, height: 44)
                        .shimmer(isActive: true, delay: 0.6)

                    Circle()
                        .fill(Color.surfaceSecondary)
                        .frame(width: 44, height: 44)
                        .shimmer(isActive: true, delay: 0.65)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 70)
        }
        .frame(height: Size.heroHeight)
    }
}

// MARK: - Skeleton Top 10 Row

struct SkeletonTop10Row: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
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

            // Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<10, id: \.self) { index in
                        HStack(alignment: .bottom, spacing: -20) {
                            // Number skeleton
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.surfaceSecondary)
                                .frame(width: 40, height: 60)
                                .shimmer(isActive: true, delay: Double(index) * 0.05)

                            // Poster skeleton
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.surfaceSecondary)
                                .frame(width: 120, height: 180)
                                .shimmer(isActive: true, delay: Double(index) * 0.05 + 0.1)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Skeleton Grid

struct SkeletonMovieGrid: View {
    let columns: Int
    let rowCount: Int

    init(columns: Int = 3, rowCount: Int = 3) {
        self.columns = columns
        self.rowCount = rowCount
    }

    var body: some View {
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: columns)

        LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(0..<(columns * rowCount), id: \.self) { index in
                SkeletonMovieCard(
                    width: .infinity,
                    height: 180,
                    delay: Double(index) * 0.03
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Skeleton Search Results

struct SkeletonSearchResults: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<6, id: \.self) { index in
                HStack(spacing: 12) {
                    // Poster
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.surfaceSecondary)
                        .frame(width: 80, height: 120)
                        .shimmer(isActive: true, delay: Double(index) * 0.05)

                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceSecondary)
                            .frame(height: 18)
                            .shimmer(isActive: true, delay: Double(index) * 0.05 + 0.1)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceSecondary)
                            .frame(width: 100, height: 14)
                            .shimmer(isActive: true, delay: Double(index) * 0.05 + 0.15)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceSecondary)
                            .frame(height: 12)
                            .shimmer(isActive: true, delay: Double(index) * 0.05 + 0.2)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceSecondary)
                            .frame(width: 150, height: 12)
                            .shimmer(isActive: true, delay: Double(index) * 0.05 + 0.25)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Skeleton Swipe Card

struct SkeletonSwipeCard: View {
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.surfaceSecondary)
                .shimmer(isActive: true, duration: 2.0)

            // Content overlay
            VStack {
                // Top bar
                HStack {
                    // Rating badge skeleton
                    Capsule()
                        .fill(Color.surfaceTertiary)
                        .frame(width: 70, height: 36)
                        .shimmer(isActive: true, delay: 0.2)

                    Spacer()

                    // Info button skeleton
                    Circle()
                        .fill(Color.surfaceTertiary)
                        .frame(width: 36, height: 36)
                        .shimmer(isActive: true, delay: 0.25)
                }
                .padding(20)

                Spacer()

                // Bottom content
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.surfaceTertiary)
                        .frame(height: 28)
                        .shimmer(isActive: true, delay: 0.3)

                    // Metadata
                    HStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceTertiary)
                            .frame(width: 80, height: 16)
                            .shimmer(isActive: true, delay: 0.35)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceTertiary)
                            .frame(width: 100, height: 16)
                            .shimmer(isActive: true, delay: 0.4)
                    }

                    // Genre pills
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Capsule()
                                .fill(Color.surfaceTertiary)
                                .frame(width: 60, height: 28)
                                .shimmer(isActive: true, delay: 0.45 + Double(index) * 0.05)
                        }
                    }

                    // Overview
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceTertiary)
                            .frame(height: 14)
                            .shimmer(isActive: true, delay: 0.6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceTertiary)
                            .frame(height: 14)
                            .shimmer(isActive: true, delay: 0.65)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceTertiary)
                            .frame(width: 200, height: 14)
                            .shimmer(isActive: true, delay: 0.7)
                    }
                    .padding(.top, 4)

                    // Swipe hints
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceTertiary)
                            .frame(width: 40, height: 16)

                        Spacer()

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.surfaceTertiary)
                            .frame(width: 40, height: 4)

                        Spacer()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceTertiary)
                            .frame(width: 40, height: 16)
                    }
                    .shimmer(isActive: true, delay: 0.75)
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
        .aspectRatio(0.67, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
    }
}

// MARK: - Skeleton Movie Detail

struct SkeletonMovieDetail: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero backdrop
                Rectangle()
                    .fill(Color.surfaceSecondary)
                    .frame(height: 300)
                    .shimmer(isActive: true)

                // Content
                VStack(alignment: .leading, spacing: 20) {
                    // Poster and info
                    HStack(alignment: .top, spacing: 16) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.surfaceSecondary)
                            .frame(width: 120, height: 180)
                            .shimmer(isActive: true, delay: 0.2)

                        VStack(alignment: .leading, spacing: 12) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.surfaceSecondary)
                                .frame(height: 24)
                                .shimmer(isActive: true, delay: 0.25)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.surfaceSecondary)
                                .frame(width: 150, height: 16)
                                .shimmer(isActive: true, delay: 0.3)

                            HStack(spacing: 8) {
                                ForEach(0..<3, id: \.self) { index in
                                    Capsule()
                                        .fill(Color.surfaceSecondary)
                                        .frame(width: 50, height: 24)
                                        .shimmer(isActive: true, delay: 0.35 + Double(index) * 0.05)
                                }
                            }
                        }
                    }
                    .padding(.top, -60)

                    // Action buttons
                    HStack(spacing: 12) {
                        Capsule()
                            .fill(Color.surfaceSecondary)
                            .frame(height: 50)
                            .shimmer(isActive: true, delay: 0.5)

                        Capsule()
                            .fill(Color.surfaceSecondary)
                            .frame(height: 50)
                            .shimmer(isActive: true, delay: 0.55)
                    }

                    // Overview
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.surfaceSecondary)
                            .frame(width: 100, height: 20)
                            .shimmer(isActive: true, delay: 0.6)

                        ForEach(0..<4, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.surfaceSecondary)
                                .frame(height: 14)
                                .shimmer(isActive: true, delay: 0.65 + Double(index) * 0.03)
                        }
                    }

                    // Similar movies
                    SkeletonMovieRow(title: "Similar Movies", cardCount: 4)
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.appBackground)
    }
}

// MARK: - Preview

#if DEBUG
struct SkeletonLoading_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                SkeletonHero()

                SkeletonMovieRow(title: "Trending Now")

                SkeletonTop10Row(title: "Top 10 Today")

                SkeletonSwipeCard()
                    .padding(.horizontal, 24)

                SkeletonSearchResults()
            }
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
