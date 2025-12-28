//
//  MovieHeaderView.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Implemented by Claude Code Audit on 28/12/2025.
//

import SwiftUI
import Kingfisher

/// Reusable header component for movie detail views with backdrop, poster, and info
struct MovieHeaderView: View {

    // MARK: - Properties

    let movie: Movie
    let style: HeaderStyle
    var onClose: (() -> Void)?
    var onShare: (() -> Void)?

    // MARK: - Header Styles

    enum HeaderStyle {
        case compact    // Just backdrop with title overlay
        case standard   // Backdrop + floating poster
        case hero       // Full-height hero section
    }

    // MARK: - Body

    var body: some View {
        switch style {
        case .compact:
            compactHeader
        case .standard:
            standardHeader
        case .hero:
            heroHeader
        }
    }

    // MARK: - Compact Header

    private var compactHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Backdrop
            backdropImage
                .frame(height: 200)

            // Gradient
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )

            // Title overlay
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                ratingRow
            }
            .padding()

            // Close button
            if let onClose = onClose {
                closeButton(action: onClose)
            }
        }
    }

    // MARK: - Standard Header

    private var standardHeader: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                // Backdrop section
                ZStack(alignment: .bottomLeading) {
                    backdropImage
                        .frame(height: 250)

                    LinearGradient(
                        colors: [.clear, Color(uiColor: .systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                }

                // Content with poster
                HStack(alignment: .top, spacing: 16) {
                    // Floating poster
                    posterImage
                        .frame(width: 120, height: 180)
                        .offset(y: -60)

                    // Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.title3.bold())
                            .foregroundColor(.primary)
                            .lineLimit(2)

                        ratingRow

                        if let year = movie.releaseYear {
                            Label(year, systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)

                    Spacer()
                }
                .padding(.horizontal)
            }

            // Action buttons
            HStack {
                if let onClose = onClose {
                    closeButton(action: onClose)
                }

                Spacer()

                if let onShare = onShare {
                    shareButton(action: onShare)
                }
            }
            .padding()
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Full backdrop
                backdropImage
                    .frame(width: geometry.size.width, height: geometry.size.height)

                // Gradient overlays
                VStack(spacing: 0) {
                    // Top gradient for buttons
                    LinearGradient(
                        colors: [.black.opacity(0.6), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)

                    Spacer()

                    // Bottom gradient for content
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                }

                // Content
                VStack(alignment: .leading, spacing: 16) {
                    Spacer()

                    // Title
                    Text(movie.title)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)

                    // Rating and info
                    HStack(spacing: 16) {
                        // Rating badge
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(movie.formattedRating)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )

                        // Year
                        if let year = movie.releaseYear {
                            Text(year)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        // Language
                        Text(movie.originalLanguage.uppercased())
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }

                    // Overview teaser
                    Text(movie.overview)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(3)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Top buttons
                VStack {
                    HStack {
                        if let onClose = onClose {
                            closeButton(action: onClose)
                        }

                        Spacer()

                        if let onShare = onShare {
                            shareButton(action: onShare)
                        }
                    }
                    .padding()

                    Spacer()
                }
            }
        }
        .frame(height: 400)
    }

    // MARK: - Shared Components

    private var backdropImage: some View {
        KFImage(movie.backdropURL ?? movie.posterURL)
            .placeholder {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
    }

    private var posterImage: some View {
        KFImage(movie.posterURL)
            .placeholder {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
            .resizable()
            .aspectRatio(2/3, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }

    private var ratingRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.yellow)

            Text(movie.formattedRating)
                .font(.subheadline.bold())
                .foregroundColor(style == .compact ? .white : .primary)

            Text("(\(movie.voteCount))")
                .font(.caption)
                .foregroundColor(style == .compact ? .white.opacity(0.7) : .secondary)
        }
    }

    private func closeButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(10)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
        }
        .accessibilityLabel("Close")
    }

    private func shareButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(10)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
        }
        .accessibilityLabel("Share")
    }
}

// MARK: - Parallax Header

struct ParallaxMovieHeader: View {

    let movie: Movie
    let scrollOffset: CGFloat
    var onClose: (() -> Void)?

    private let headerHeight: CGFloat = 350

    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let isScrollingDown = minY > 0

            ZStack(alignment: .bottom) {
                // Backdrop with parallax
                KFImage(movie.backdropURL ?? movie.posterURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: isScrollingDown ? headerHeight + minY : headerHeight
                    )
                    .offset(y: isScrollingDown ? -minY : 0)
                    .clipped()

                // Gradient
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Title with fade effect
                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.title.bold())
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(movie.formattedRating)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(1 - Double(-scrollOffset / 100).clamped(to: 0...1))

                // Close button
                if let onClose = onClose {
                    VStack {
                        HStack {
                            Button(action: onClose) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Circle().fill(.ultraThinMaterial))
                            }
                            Spacer()
                        }
                        .padding()
                        Spacer()
                    }
                }
            }
        }
        .frame(height: headerHeight)
    }
}

// MARK: - Helpers

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Preview

#if DEBUG
struct MovieHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("Compact Style")
                    .font(.headline)
                MovieHeaderView(
                    movie: .sample,
                    style: .compact,
                    onClose: {}
                )

                Text("Standard Style")
                    .font(.headline)
                MovieHeaderView(
                    movie: .sample,
                    style: .standard,
                    onClose: {},
                    onShare: {}
                )
                .frame(height: 300)

                Text("Hero Style")
                    .font(.headline)
                MovieHeaderView(
                    movie: .sample,
                    style: .hero,
                    onClose: {},
                    onShare: {}
                )
            }
        }
    }
}
#endif
