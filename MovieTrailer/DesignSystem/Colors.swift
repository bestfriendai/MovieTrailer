//
//  Colors.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Apple 2025 Color System
//

import SwiftUI

// MARK: - App Colors

extension Color {

    // MARK: - Brand Colors

    /// Primary accent gradient start
    static let accentStart = Color(hex: "FF6B6B")

    /// Primary accent gradient end
    static let accentEnd = Color(hex: "FF8E53")

    /// Primary accent gradient
    static let accentGradient = LinearGradient(
        colors: [accentStart, accentEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Category Colors

    static let categoryNew = Color(hex: "FF6B6B")       // Coral Red
    static let categoryClassics = Color(hex: "A78BFA")  // Purple
    static let categoryTV = Color(hex: "60A5FA")        // Blue
    static let categoryAnimation = Color(hex: "34D399") // Green
    static let categoryAction = Color(hex: "F59E0B")    // Amber
    static let categoryComedy = Color(hex: "EC4899")    // Pink
    static let categoryDrama = Color(hex: "6366F1")     // Indigo
    static let categoryHorror = Color(hex: "EF4444")    // Red
    static let categorySciFi = Color(hex: "06B6D4")     // Cyan
    static let categoryRomance = Color(hex: "F472B6")   // Rose
    static let categoryThriller = Color(hex: "8B5CF6")  // Violet
    static let categoryDocumentary = Color(hex: "10B981") // Emerald

    // MARK: - Semantic Colors

    /// Success state color
    static let success = Color(hex: "22C55E")

    /// Warning state color
    static let warning = Color(hex: "F59E0B")

    /// Error state color
    static let error = Color(hex: "EF4444")

    /// Info state color
    static let info = Color(hex: "3B82F6")

    // MARK: - Swipe Colors

    /// Like/Save swipe color
    static let swipeLike = Color(hex: "22C55E")

    /// Skip/Nope swipe color
    static let swipeSkip = Color(hex: "EF4444")

    /// Super like swipe color
    static let swipeSuperLike = Color(hex: "F59E0B")

    /// Already seen swipe color
    static let swipeSeen = Color(hex: "3B82F6")

    // MARK: - Rating Colors

    /// Excellent rating (8+)
    static let ratingExcellent = Color(hex: "22C55E")

    /// Good rating (6-8)
    static let ratingGood = Color(hex: "F59E0B")

    /// Average rating (4-6)
    static let ratingAverage = Color(hex: "F97316")

    /// Poor rating (<4)
    static let ratingPoor = Color(hex: "EF4444")

    /// Get rating color based on score
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
    static let appleTVPlus = Color(hex: "000000")
    static let hulu = Color(hex: "1CE783")
    static let peacock = Color(hex: "000000")
    static let paramount = Color(hex: "0064FF")
}

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradient Presets

extension LinearGradient {
    /// Primary brand gradient
    static let accent = LinearGradient(
        colors: [.accentStart, .accentEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Overlay gradient for cards (bottom fade)
    static let cardOverlay = LinearGradient(
        colors: [.clear, .black.opacity(0.7)],
        startPoint: .center,
        endPoint: .bottom
    )

    /// Full card overlay gradient
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
