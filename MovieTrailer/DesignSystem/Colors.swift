//
//  Colors.swift
//  MovieTrailer
//
//  Apple 2025 Premium Design System
//  OLED-optimized cinematic color palette
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - App Colors

extension Color {

    // MARK: - Background Colors (OLED Optimized)

    /// Pure black background - true OLED black
    static let appBackground = Color.black

    /// Primary surface - subtle elevation
    static let surfacePrimary = Color(white: 0.06)

    /// Secondary surface
    static let surfaceSecondary = Color(white: 0.10)

    /// Tertiary surface
    static let surfaceTertiary = Color(white: 0.14)

    /// Elevated surface for cards
    static let surfaceElevated = Color(white: 0.08)

    /// Card background
    static let cardBackground = Color(white: 0.12)

    /// Separator - subtle divider
    static let separator = Color(white: 0.18)

    /// Subtle separator
    static let separatorSubtle = Color(white: 0.12)

    // MARK: - Glass Materials

    /// Ultra thin glass overlay
    static let glassUltraThin = Color.white.opacity(0.03)

    /// Thin glass overlay
    static let glassThin = Color.white.opacity(0.06)

    /// Regular glass overlay
    static let glassRegular = Color.white.opacity(0.10)

    /// Light glass overlay (alias for regular)
    static let glassLight = Color.white.opacity(0.10)

    /// Thick glass overlay
    static let glassThick = Color.white.opacity(0.15)

    /// Glass border
    static let glassBorder = Color.white.opacity(0.12)

    /// Glass border highlight
    static let glassBorderHighlight = Color.white.opacity(0.20)

    // MARK: - Text Colors

    /// Primary text - pure white
    static let textPrimary = Color.white

    /// Secondary text - muted white
    static let textSecondary = Color(white: 0.70)

    /// Tertiary text - very muted
    static let textTertiary = Color(white: 0.45)

    /// Quaternary text - barely visible
    static let textQuaternary = Color(white: 0.30)

    /// Inverted text for light backgrounds
    static let textInverted = Color.black

    // MARK: - Accent Colors (Apple Vibrant)

    /// Primary accent - Apple blue
    static let accentPrimary = Color(red: 0.04, green: 0.52, blue: 1.0) // #0A84FF

    /// Secondary accent - Purple
    static let accentSecondary = Color(red: 0.75, green: 0.35, blue: 0.95) // #BF5AF2

    /// Accent blue
    static let accentBlue = Color(red: 0.04, green: 0.52, blue: 1.0)

    /// Accent purple
    static let accentPurple = Color(red: 0.75, green: 0.35, blue: 0.95)

    /// Accent pink
    static let accentPink = Color(red: 1.0, green: 0.27, blue: 0.53) // #FF4588

    /// Accent orange
    static let accentOrange = Color(red: 1.0, green: 0.62, blue: 0.04) // #FF9F0A

    /// Accent green
    static let accentGreen = Color(red: 0.20, green: 0.84, blue: 0.29) // #34D349

    /// Accent red
    static let accentRed = Color(red: 1.0, green: 0.27, blue: 0.23) // #FF453A

    /// Accent cyan
    static let accentCyan = Color(red: 0.39, green: 0.82, blue: 1.0) // #64D2FF

    /// Accent yellow
    static let accentYellow = Color(red: 1.0, green: 0.84, blue: 0.04) // #FFD60A

    /// Gradient start
    static let accentStart = Color(red: 0.75, green: 0.35, blue: 0.95)

    /// Gradient end
    static let accentEnd = Color(red: 1.0, green: 0.27, blue: 0.53)

    // MARK: - Swipe Action Colors (Vibrant)

    /// Swipe love - Hot Pink
    static let swipeLove = Color(red: 1.0, green: 0.27, blue: 0.53)

    /// Swipe like - Green
    static let swipeLike = Color(red: 0.20, green: 0.84, blue: 0.29)

    /// Swipe skip - Neutral Gray
    static let swipeSkip = Color(white: 0.35)

    /// Swipe watch later - Blue
    static let swipeWatchLater = Color(red: 0.04, green: 0.52, blue: 1.0)

    /// Swipe super like - Gold
    static let swipeSuperLike = Color(red: 0.95, green: 0.80, blue: 0.0)

    /// Match celebration
    static let swipeMatch = Color(red: 1.0, green: 0.27, blue: 0.53)

    /// Legacy support
    static let swipeSeen = Color(red: 0.04, green: 0.52, blue: 1.0)

    // MARK: - Action Colors

    /// Play button background
    static let playButton = Color.white

    /// Add to list button
    static let addButton = Color(white: 0.25)

    /// Watch now button
    static let watchNowButton = Color(red: 0.04, green: 0.52, blue: 1.0)

    /// Trailer button
    static let trailerButton = Color(white: 0.20)

    // MARK: - Badge Colors

    /// "New" badge background
    static let badgeNew = Color(red: 1.0, green: 0.27, blue: 0.23)

    /// "HD" badge background
    static let badgeHD = Color(white: 0.25)

    /// "4K" badge background
    static let badge4K = Color(red: 0.75, green: 0.35, blue: 0.95)

    /// Rating star
    static let ratingStar = Color(red: 1.0, green: 0.84, blue: 0.04)

    // MARK: - Category/Genre Colors (Vibrant Palette)

    static let categoryAction = Color(hex: "FF6B35")      // Vibrant Orange
    static let categoryAdventure = Color(hex: "3B82F6")   // Blue
    static let categoryAnimation = Color(hex: "22D3EE")   // Cyan
    static let categoryComedy = Color(hex: "F59E0B")      // Amber
    static let categoryCrime = Color(hex: "6366F1")       // Indigo
    static let categoryDocumentary = Color(hex: "10B981") // Emerald
    static let categoryDrama = Color(hex: "8B5CF6")       // Purple
    static let categoryFamily = Color(hex: "F472B6")      // Pink
    static let categoryFantasy = Color(hex: "A855F7")     // Violet
    static let categoryHistory = Color(hex: "92400E")     // Amber Dark
    static let categoryHorror = Color(hex: "DC2626")      // Red
    static let categoryMusic = Color(hex: "EC4899")       // Pink
    static let categoryMystery = Color(hex: "6B7280")     // Gray
    static let categoryRomance = Color(hex: "FB7185")     // Rose
    static let categorySciFi = Color(hex: "06B6D4")       // Cyan
    static let categoryThriller = Color(hex: "7C3AED")    // Violet
    static let categoryWar = Color(hex: "78716C")         // Stone
    static let categoryWestern = Color(hex: "D97706")     // Amber
    static let categoryTV = Color(hex: "60A5FA")          // Light Blue
    static let categoryNew = Color(hex: "FF6B6B")         // Coral
    static let categoryClassics = Color(hex: "A78BFA")    // Light Purple

    // Genre color mapping
    static func genre(_ id: Int) -> Color {
        switch id {
        case 28: return .categoryAction
        case 12: return .categoryAdventure
        case 16: return .categoryAnimation
        case 35: return .categoryComedy
        case 80: return .categoryCrime
        case 99: return .categoryDocumentary
        case 18: return .categoryDrama
        case 10751: return .categoryFamily
        case 14: return .categoryFantasy
        case 36: return .categoryHistory
        case 27: return .categoryHorror
        case 10402: return .categoryMusic
        case 9648: return .categoryMystery
        case 10749: return .categoryRomance
        case 878: return .categorySciFi
        case 53: return .categoryThriller
        case 10752: return .categoryWar
        case 37: return .categoryWestern
        default: return .accentBlue
        }
    }

    // MARK: - Semantic Colors

    static let success = Color(red: 0.20, green: 0.84, blue: 0.29)
    static let warning = Color(red: 1.0, green: 0.62, blue: 0.04)
    static let error = Color(red: 1.0, green: 0.27, blue: 0.23)
    static let info = Color(red: 0.04, green: 0.52, blue: 1.0)

    // MARK: - Rating Colors

    static let ratingExcellent = Color(red: 0.20, green: 0.84, blue: 0.29) // 8+
    static let ratingGood = Color(red: 0.04, green: 0.52, blue: 1.0)       // 7-8
    static let ratingAverage = Color(red: 1.0, green: 0.62, blue: 0.04)    // 5-7
    static let ratingPoor = Color(red: 1.0, green: 0.27, blue: 0.23)       // <5

    static func rating(for score: Double) -> Color {
        switch score {
        case 8...10: return .ratingExcellent
        case 7..<8: return .ratingGood
        case 5..<7: return .ratingAverage
        default: return .ratingPoor
        }
    }

    // MARK: - Streaming Provider Colors (Official Brand Colors)

    static let netflix = Color(red: 0.89, green: 0.07, blue: 0.11)        // #E31111
    static let disneyPlus = Color(red: 0.02, green: 0.27, blue: 0.69)     // #0438B0
    static let amazonPrime = Color(red: 0.0, green: 0.66, blue: 0.88)     // #00A8E1
    static let primeVideo = Color(red: 0.0, green: 0.66, blue: 0.88)      // #00A8E1
    static let hboMax = Color(red: 0.60, green: 0.30, blue: 0.90)         // #9A4DE6
    static let max = Color(red: 0.0, green: 0.18, blue: 0.53)             // #002E87
    static let appleTVPlus = Color(white: 0.90)
    static let hulu = Color(red: 0.12, green: 0.82, blue: 0.42)           // #1ED16A
    static let peacock = Color(red: 0.0, green: 0.0, blue: 0.0)           // Multi-color gradient
    static let paramount = Color(red: 0.0, green: 0.40, blue: 0.90)       // #0066E5
    static let showtime = Color(red: 0.70, green: 0.0, blue: 0.0)         // #B30000
    static let starz = Color(red: 0.0, green: 0.0, blue: 0.0)             // Black with gold
    static let mubi = Color(red: 0.0, green: 0.80, blue: 0.60)            // Teal
    static let criterion = Color(red: 0.93, green: 0.85, blue: 0.68)      // Cream

    // Provider color by ID
    static func streamingProvider(_ providerId: Int) -> Color {
        switch providerId {
        case 8: return .netflix
        case 9: return .primeVideo
        case 15: return .hulu
        case 37: return .showtime
        case 43: return .starz
        case 337: return .disneyPlus
        case 350: return .appleTVPlus
        case 384: return .hboMax
        case 386: return .peacock
        case 531: return .paramount
        case 1899: return .max
        default: return .accentBlue
        }
    }

    // MARK: - Top 10 Ranking Colors

    static let ranking1 = Color(hex: "FFD700")  // Gold
    static let ranking2 = Color(hex: "C0C0C0")  // Silver
    static let ranking3 = Color(hex: "CD7F32")  // Bronze
    static let rankingDefault = Color(white: 0.4)

    static func ranking(_ position: Int) -> Color {
        switch position {
        case 1: return .ranking1
        case 2: return .ranking2
        case 3: return .ranking3
        default: return .rankingDefault
        }
    }

    // MARK: - Theater & Release Colors

    static let inTheaters = Color(red: 1.0, green: 0.27, blue: 0.23)
    static let comingSoon = Color(red: 0.75, green: 0.35, blue: 0.95)
    static let newRelease = Color(red: 0.04, green: 0.52, blue: 1.0)
    static let leavingSoon = Color(red: 1.0, green: 0.62, blue: 0.04)
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

    var hexString: String {
        #if canImport(UIKit)
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = Int((components.count > 0 ? components[0] : 0) * 255)
        let g = Int((components.count > 1 ? components[1] : 0) * 255)
        let b = Int((components.count > 2 ? components[2] : 0) * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
        #else
        return "#000000"
        #endif
    }
    
    func toHex() -> String? {
        hexString
    }
}

// MARK: - Gradient Presets

extension LinearGradient {

    /// Hero overlay gradient - heavy at bottom for text legibility
    static let heroOverlay = LinearGradient(
        colors: [
            .black,
            .black.opacity(0.95),
            .black.opacity(0.7),
            .black.opacity(0.3),
            .clear
        ],
        startPoint: .bottom,
        endPoint: .top
    )

    /// Card overlay gradient - lighter for cards
    static let cardOverlay = LinearGradient(
        colors: [
            .black.opacity(0.9),
            .black.opacity(0.5),
            .black.opacity(0.2),
            .clear
        ],
        startPoint: .bottom,
        endPoint: .center
    )

    /// Top safe area overlay
    static let topOverlay = LinearGradient(
        colors: [.black.opacity(0.6), .black.opacity(0.3), .clear],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Accent gradient (purple to pink)
    static let accent = LinearGradient(
        colors: [.accentPurple, .accentPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Premium gradient (blue to purple)
    static let premium = LinearGradient(
        colors: [.accentBlue, .accentPurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Warm gradient (orange to pink)
    static let warm = LinearGradient(
        colors: [.accentOrange, .accentPink],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Cool gradient (cyan to blue)
    static let cool = LinearGradient(
        colors: [.accentCyan, .accentBlue],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Gold gradient for premium features
    static let gold = LinearGradient(
        colors: [
            Color(hex: "D4AF37"),
            Color(hex: "FFD700"),
            Color(hex: "D4AF37")
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Full overlay gradient for backgrounds
    static let fullOverlay = LinearGradient(
        colors: [.black.opacity(0.3), .black.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Glass shimmer gradient
    static let glassShimmer = LinearGradient(
        colors: [
            .white.opacity(0.0),
            .white.opacity(0.15),
            .white.opacity(0.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Swipe like gradient
    static let swipeLikeGradient = LinearGradient(
        colors: [.swipeLove.opacity(0.0), .swipeLove.opacity(0.3)],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Swipe skip gradient
    static let swipeSkipGradient = LinearGradient(
        colors: [.swipeSkip.opacity(0.3), .swipeSkip.opacity(0.0)],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Watch later gradient
    static let watchLaterGradient = LinearGradient(
        colors: [.swipeWatchLater.opacity(0.0), .swipeWatchLater.opacity(0.3)],
        startPoint: .bottom,
        endPoint: .top
    )
}

// MARK: - Radial Gradients

extension RadialGradient {

    /// Spotlight effect for hero images
    static let spotlight = RadialGradient(
        colors: [.clear, .black.opacity(0.3), .black.opacity(0.7)],
        center: .center,
        startRadius: 100,
        endRadius: 400
    )

    /// Glow effect for buttons
    static func glow(color: Color) -> RadialGradient {
        RadialGradient(
            colors: [color.opacity(0.4), color.opacity(0.0)],
            center: .center,
            startRadius: 0,
            endRadius: 60
        )
    }
}

// MARK: - Angular Gradients

extension AngularGradient {

    /// Rainbow border for special cards
    static let rainbow = AngularGradient(
        colors: [
            .accentRed,
            .accentOrange,
            .accentYellow,
            .accentGreen,
            .accentCyan,
            .accentBlue,
            .accentPurple,
            .accentPink,
            .accentRed
        ],
        center: .center
    )

    /// Gold shimmer for premium
    static let goldShimmer = AngularGradient(
        colors: [
            Color(hex: "D4AF37"),
            Color(hex: "FFD700"),
            Color(hex: "FFF8DC"),
            Color(hex: "FFD700"),
            Color(hex: "D4AF37")
        ],
        center: .center
    )
}
