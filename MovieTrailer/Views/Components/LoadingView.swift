//
//  LoadingView.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI

/// Loading state view with glassmorphism
struct LoadingView: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated gradient circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                )
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text("Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Skeleton Views

struct SkeletonHero: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.surfaceSecondary)
            .frame(height: Size.heroHeight)
            .shimmer(isActive: true)
            .padding(.horizontal, Spacing.horizontal)
    }
}

struct SkeletonMovieRow: View {
    let title: String
    let cardCount: Int
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    init(
        title: String,
        cardCount: Int = 6,
        cardWidth: CGFloat = 140,
        cardHeight: CGFloat = 200
    ) {
        self.title = title
        self.cardCount = cardCount
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.headline3)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(0..<cardCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.surfaceSecondary)
                            .frame(width: cardWidth, height: cardHeight)
                            .shimmer(isActive: true)
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }
}

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
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.surfaceSecondary)
                    .frame(height: 180)
                    .shimmer(isActive: true)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct SkeletonSwipeCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.surfaceSecondary)
            .shimmer(isActive: true)
            .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 12)
    }
}

// MARK: - Preview

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
#endif
