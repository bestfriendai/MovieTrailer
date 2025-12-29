//
//  Colors.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Apple TV-inspired dark cinematic color system
//

import SwiftUI

// MARK: - App Colors

extension Color {

    // MARK: - Background Colors (Dark Theme)

    /// Pure black background like Apple TV
    static let appBackground = Color.black

    /// Slightly elevated surface
    static let surfaceElevated = Color(white: 0.08)

    /// Card background
    static let cardBackground = Color(white: 0.12)

    /// Subtle separator
    static let separator = Color(white: 0.2)

    // MARK: - Text Colors

    /// Primary text - pure white
    static let textPrimary = Color.white

    /// Secondary text - muted white
    static let textSecondary = Color(white: 0.7)

    /// Tertiary text - very muted
    static let textTertiary = Color(white: 0.5)

    // MARK: - Accent Colors

    /// Primary accent - Apple TV blue
    static let accentPrimary = Color(red: 0.0, green: 0.48, blue: 1.0)

    /// Gradient start
    static let accentStart = Color(red: 0.4, green: 0.2, blue: 1.0)

    /// Gradient end
    static let accentEnd = Color(red: 1.0, green: 0.4, blue: 0.6)

    // MARK: - Action Colors

    /// Play button background
    static let playButton = Color.white

    /// Add to list button
    static let addButton = Color(white: 0.25)

    // MARK: - Badge Colors

    /// "New" badge background
    static let badgeNew = Color(white: 0.2)

    /// Rating star
    static let ratingStar = Color.yellow

    // MARK: - Swipe Colors

    static let swipeLike = Color(red: 0.13, green: 0.77, blue: 0.37)
    static let swipeSkip = Color(red: 0.94, green: 0.27, blue: 0.27)
    static let swipeSuperLike = Color(red: 0.0, green: 0.66, blue: 1.0)
    static let swipeSeen = Color(red: 0.23, green: 0.51, blue: 0.96)

    // MARK: - Category Colors

    static let categoryNew = Color(hex: "FF6B6B")
    static let categoryClassics = Color(hex: "A78BFA")
    static let categoryTV = Color(hex: "60A5FA")
    static let categoryAnimation = Color(hex: "34D399")
    static let categoryAction = Color(hex: "F59E0B")
    static let categoryComedy = Color(hex: "EC4899")
    static let categoryDrama = Color(hex: "6366F1")
    static let categoryHorror = Color(hex: "EF4444")
    static let categorySciFi = Color(hex: "06B6D4")
    static let categoryRomance = Color(hex: "F472B6")
    static let categoryThriller = Color(hex: "8B5CF6")
    static let categoryDocumentary = Color(hex: "10B981")

    // MARK: - Semantic Colors

    static let success = Color(hex: "22C55E")
    static let warning = Color(hex: "F59E0B")
    static let error = Color(hex: "EF4444")
    static let info = Color(hex: "3B82F6")

    // MARK: - Rating Colors

    static let ratingExcellent = Color(hex: "22C55E")
    static let ratingGood = Color(hex: "F59E0B")
    static let ratingAverage = Color(hex: "F97316")
    static let ratingPoor = Color(hex: "EF4444")

    static func rating(for score: Double) -> Color {
        switch score {
        case 8...10: return .ratingExcellent
        case 6..<8: return .ratingGood
        case 4..<6: return .ratingAverage
        default: return .ratingPoor
        }
    }

    // MARK: - Streaming Provider Colors

    static let netflix = Color(hex: "E50914")
    static let disneyPlus = Color(hex: "113CCF")
    static let amazonPrime = Color(hex: "00A8E1")
    static let hboMax = Color(hex: "5822B4")
    static let appleTVPlus = Color(white: 0.15)
    static let hulu = Color(hex: "1CE783")
    static let peacock = Color(white: 0.15)
    static let paramount = Color(hex: "0064FF")

    // MARK: - Top 10 Ranking Colors

    static let ranking1 = Color(hex: "FFD700")  // Gold
    static let ranking2 = Color(hex: "C0C0C0")  // Silver
    static let ranking3 = Color(hex: "CD7F32")  // Bronze
}

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Presets

extension LinearGradient {

    /// Hero overlay gradient - heavy at bottom for text
    static let heroOverlay = LinearGradient(
        colors: [
            .black,
            .black.opacity(0.9),
            .black.opacity(0.5),
            .clear
        ],
        startPoint: .bottom,
        endPoint: .top
    )

    /// Card overlay gradient
    static let cardOverlay = LinearGradient(
        colors: [.black.opacity(0.8), .black.opacity(0.3), .clear],
        startPoint: .bottom,
        endPoint: .center
    )

    /// Top safe area overlay
    static let topOverlay = LinearGradient(
        colors: [.black.opacity(0.5), .clear],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Accent gradient
    static let accent = LinearGradient(
        colors: [.accentStart, .accentEnd],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Full overlay gradient
    static let fullOverlay = LinearGradient(
        colors: [.black.opacity(0.3), .black.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Glass shimmer gradient
    static let glassShimmer = LinearGradient(
        colors: [.white.opacity(0.1), .white.opacity(0.2), .white.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
