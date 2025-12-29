//
//  CinematicHero.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Apple TV-style cinematic hero banner
//

import SwiftUI
import Kingfisher

// MARK: - Cinematic Hero

struct CinematicHero: View {

    let movie: Movie
    let onPlay: () -> Void
    let onAddToList: () -> Void
    let onTap: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background image
                heroImage(size: geometry.size)

                // Gradient overlay
                LinearGradient.heroOverlay
                    .frame(height: geometry.size.height * 0.7)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                // Content
                heroContent
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(0.7, contentMode: .fit)
        .onTapGesture {
            onTap()
        }
    }

    // MARK: - Hero Image

    private func heroImage(size: CGSize) -> some View {
        KFImage(movie.backdropURL ?? movie.posterURL)
            .placeholder {
                Rectangle()
                    .fill(Color.surfaceElevated)
            }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    // MARK: - Hero Content

    private var heroContent: some View {
        VStack(alignment: .center, spacing: 16) {
            // "New" badge
            Text("New")
                .font(.caption.weight(.semibold))
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.badgeNew)
                .clipShape(Capsule())

            // Movie logo or title
            Text(movie.title)
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

            // Genre tags
            if let genres = movie.genreNames, !genres.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "film")
                        .font(.caption)
                    Text(genres.prefix(3).joined(separator: " · "))
                        .font(.subheadline)
                }
                .foregroundColor(.textSecondary)
            }

            // Action buttons
            HStack(spacing: 16) {
                // Play button
                Button(action: {
                    Haptics.shared.mediumImpact()
                    onPlay()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.body.weight(.semibold))
                        Text("Play")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color.playButton)
                    .clipShape(Capsule())
                }

                // Add to list button
                Button(action: {
                    Haptics.shared.lightImpact()
                    onAddToList()
                }) {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                        .foregroundColor(.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(Color.addButton)
                        .clipShape(Circle())
                }
            }
        }
    }
}

// MARK: - Hero Carousel (Apple TV Style)

struct CinematicHeroCarousel: View {

    let movies: [Movie]
    let onPlay: (Movie) -> Void
    let onAddToList: (Movie) -> Void
    let onTap: (Movie) -> Void

    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 12) {
            // Carousel
            TabView(selection: $currentIndex) {
                ForEach(Array(movies.prefix(5).enumerated()), id: \.element.id) { index, movie in
                    CinematicHero(
                        movie: movie,
                        onPlay: { onPlay(movie) },
                        onAddToList: { onAddToList(movie) },
                        onTap: { onTap(movie) }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<min(movies.count, 5), id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? Color.textPrimary : Color.textTertiary)
                        .frame(width: 8, height: 8)
                        .scaleEffect(currentIndex == index ? 1.0 : 0.7)
                        .animation(.easeInOut(duration: 0.2), value: currentIndex)
                }
            }
            .padding(.bottom, 8)
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % min(movies.count, 5)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CinematicHero_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            CinematicHero(
                movie: .sample,
                onPlay: {},
                onAddToList: {},
                onTap: {}
            )
        }
        .preferredColorScheme(.dark)
    }
}
#endif
