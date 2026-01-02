//
//  AccessibilityModifiers.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Comprehensive accessibility modifiers for all UI components
//

import SwiftUI
import UIKit

// MARK: - Movie Card Accessibility

struct MovieCardAccessibilityModifier: ViewModifier {
    let movie: Movie
    let isInWatchlist: Bool
    let additionalInfo: String?

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(accessibilityHint)
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(accessibilityValue)
    }

    private var accessibilityLabel: String {
        var label = movie.title

        // Add rating
        label += ", rated \(movie.formattedRating) out of 10"

        // Add year
        if let year = movie.releaseYear {
            label += ", released \(year)"
        }

        // Add genres
        if let genres = movie.genreNames, !genres.isEmpty {
            label += ", genres: \(genres.prefix(3).joined(separator: ", "))"
        }

        return label
    }

    private var accessibilityHint: String {
        var hint = "Double tap to view details"

        if isInWatchlist {
            hint += ". Currently in your watchlist"
        }

        if let info = additionalInfo {
            hint += ". \(info)"
        }

        return hint
    }

    private var accessibilityValue: String {
        if isInWatchlist {
            return "In watchlist"
        }
        return ""
    }
}

extension View {
    func movieCardAccessibility(
        movie: Movie,
        isInWatchlist: Bool = false,
        additionalInfo: String? = nil
    ) -> some View {
        modifier(MovieCardAccessibilityModifier(
            movie: movie,
            isInWatchlist: isInWatchlist,
            additionalInfo: additionalInfo
        ))
    }
}

// MARK: - Swipe Card Accessibility

struct SwipeCardAccessibilityModifier: ViewModifier {
    let movie: Movie
    let currentIndex: Int
    let totalCount: Int

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(accessibilityHint)
            .accessibilityValue("Card \(currentIndex + 1) of \(totalCount)")
            .accessibilityActions {
                Button("Like") {
                    // Trigger like action
                    NotificationCenter.default.post(
                        name: .accessibilitySwipeAction,
                        object: nil,
                        userInfo: ["action": "like", "movieId": movie.id]
                    )
                }

                Button("Skip") {
                    NotificationCenter.default.post(
                        name: .accessibilitySwipeAction,
                        object: nil,
                        userInfo: ["action": "skip", "movieId": movie.id]
                    )
                }

                Button("Add to Watch Later") {
                    NotificationCenter.default.post(
                        name: .accessibilitySwipeAction,
                        object: nil,
                        userInfo: ["action": "watchLater", "movieId": movie.id]
                    )
                }
            }
    }

    private var accessibilityLabel: String {
        var label = movie.title

        label += ", \(movie.formattedRating) stars"

        if let year = movie.releaseYear {
            label += ", \(year)"
        }

        if let genres = movie.genreNames, !genres.isEmpty {
            label += ", \(genres.prefix(2).joined(separator: " and "))"
        }

        if !movie.overview.isEmpty {
            let shortOverview = String(movie.overview.prefix(150))
            label += ". \(shortOverview)"
        }

        return label
    }

    private var accessibilityHint: String {
        "Swipe right to like, left to skip, up to save for later. Or use actions rotor."
    }
}

extension View {
    func swipeCardAccessibility(
        movie: Movie,
        currentIndex: Int,
        totalCount: Int
    ) -> some View {
        modifier(SwipeCardAccessibilityModifier(
            movie: movie,
            currentIndex: currentIndex,
            totalCount: totalCount
        ))
    }
}

// MARK: - Rating Accessibility

struct RatingAccessibilityModifier: ViewModifier {
    let rating: Double
    let maxRating: Double
    let voteCount: Int?

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue("\(String(format: "%.1f", rating)) out of \(Int(maxRating))")
    }

    private var accessibilityLabel: String {
        var label = "Rating: \(String(format: "%.1f", rating)) out of \(Int(maxRating))"

        if let count = voteCount, count > 0 {
            label += ", based on \(formatCount(count)) reviews"
        }

        return label
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1f million", Double(count) / 1000000)
        } else if count >= 1000 {
            return String(format: "%.1f thousand", Double(count) / 1000)
        }
        return "\(count)"
    }
}

extension View {
    func ratingAccessibility(
        rating: Double,
        maxRating: Double = 10,
        voteCount: Int? = nil
    ) -> some View {
        modifier(RatingAccessibilityModifier(
            rating: rating,
            maxRating: maxRating,
            voteCount: voteCount
        ))
    }
}

// MARK: - Hero Carousel Accessibility

struct HeroCarouselAccessibilityModifier: ViewModifier {
    let movies: [Movie]
    let currentIndex: Int

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Featured movies carousel")
            .accessibilityHint("Swipe left or right to browse, double tap to select")
            .accessibilityValue("Showing \(movies[safe: currentIndex]?.title ?? "movie") \(currentIndex + 1) of \(movies.count)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    NotificationCenter.default.post(
                        name: .accessibilityCarouselAction,
                        object: nil,
                        userInfo: ["direction": "next"]
                    )
                case .decrement:
                    NotificationCenter.default.post(
                        name: .accessibilityCarouselAction,
                        object: nil,
                        userInfo: ["direction": "previous"]
                    )
                @unknown default:
                    break
                }
            }
    }
}

extension View {
    func heroCarouselAccessibility(movies: [Movie], currentIndex: Int) -> some View {
        modifier(HeroCarouselAccessibilityModifier(
            movies: movies,
            currentIndex: currentIndex
        ))
    }
}

// MARK: - Watchlist Button Accessibility

struct WatchlistButtonAccessibilityModifier: ViewModifier {
    let isInWatchlist: Bool
    let movieTitle: String

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(isInWatchlist ? "Remove from watchlist" : "Add to watchlist")
            .accessibilityHint(isInWatchlist
                ? "Double tap to remove \(movieTitle) from your watchlist"
                : "Double tap to add \(movieTitle) to your watchlist"
            )
            .accessibilityAddTraits(.isButton)
    }
}

extension View {
    func watchlistButtonAccessibility(isInWatchlist: Bool, movieTitle: String) -> some View {
        modifier(WatchlistButtonAccessibilityModifier(
            isInWatchlist: isInWatchlist,
            movieTitle: movieTitle
        ))
    }
}

// MARK: - Top 10 Rank Accessibility

struct Top10RankAccessibilityModifier: ViewModifier {
    let rank: Int
    let movie: Movie

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Number \(rank): \(movie.title)")
            .accessibilityHint("Double tap to view details")
            .accessibilityAddTraits(.isButton)
    }
}

extension View {
    func top10RankAccessibility(rank: Int, movie: Movie) -> some View {
        modifier(Top10RankAccessibilityModifier(rank: rank, movie: movie))
    }
}

// MARK: - Reduce Motion Support

struct ReduceMotionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    let fullMotionAnimation: Animation
    let reducedMotionAnimation: Animation

    func body(content: Content) -> some View {
        content
            .animation(
                reduceMotion ? reducedMotionAnimation : fullMotionAnimation,
                value: UUID() // Trigger based on view updates
            )
    }
}

extension View {
    func respectsReduceMotion(
        fullMotion: Animation = .spring(),
        reducedMotion: Animation = .linear(duration: 0.1)
    ) -> some View {
        modifier(ReduceMotionModifier(
            fullMotionAnimation: fullMotion,
            reducedMotionAnimation: reducedMotion
        ))
    }
}

// MARK: - Dynamic Type Support

extension View {
    @ViewBuilder
    func scaledFont(_ style: Font.TextStyle, maxSize: CGFloat? = nil) -> some View {
        if let max = maxSize {
            self.font(.custom("System", size: UIFont.preferredFont(forTextStyle: uiKitStyle(for: style)).pointSize, relativeTo: style))
                .minimumScaleFactor(0.5)
                .lineLimit(nil)
        } else {
            self.font(Font.system(style))
                .lineLimit(nil)
        }
    }

    private func uiKitStyle(for style: Font.TextStyle) -> UIFont.TextStyle {
        switch style {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let accessibilitySwipeAction = Notification.Name("accessibilitySwipeAction")
    static let accessibilityCarouselAction = Notification.Name("accessibilityCarouselAction")
}

// MARK: - Array Safe Subscript

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#if DEBUG
struct AccessibilityModifiers_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Movie card with accessibility
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.surfaceSecondary)
                .frame(width: 120, height: 180)
                .movieCardAccessibility(
                    movie: .sample,
                    isInWatchlist: true
                )

            // Rating with accessibility
            HStack {
                Image(systemName: "star.fill")
                Text("8.5")
            }
            .ratingAccessibility(rating: 8.5, voteCount: 15000)

            // Watchlist button
            Button {} label: {
                Image(systemName: "plus")
            }
            .watchlistButtonAccessibility(
                isInWatchlist: false,
                movieTitle: "Inception"
            )
        }
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
