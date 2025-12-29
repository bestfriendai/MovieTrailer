//
//  Theme.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Apple 2025 Design System for iOS 26
//

import SwiftUI

// MARK: - App Theme

/// Central theme configuration for the app
enum AppTheme {

    // MARK: - Animation Presets

    enum Animation {
        /// Standard spring for UI elements
        static let standard = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)

        /// Bouncy spring for playful elements
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)

        /// Stiff spring for quick responses
        static let stiff = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.8)

        /// Smooth ease for subtle transitions
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)

        /// Quick snap animation
        static let snap = SwiftUI.Animation.spring(response: 0.2, dampingFraction: 0.9)
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let xl: CGFloat = 24
        static let card: CGFloat = 24
        static let sheet: CGFloat = 32
    }

    // MARK: - Shadows

    enum Shadow {
        static let small = ShadowStyle(color: .black.opacity(0.08), radius: 4, y: 2)
        static let medium = ShadowStyle(color: .black.opacity(0.1), radius: 8, y: 4)
        static let large = ShadowStyle(color: .black.opacity(0.12), radius: 16, y: 8)
        static let card = ShadowStyle(color: .black.opacity(0.15), radius: 20, y: 10)
    }

    // MARK: - Blur

    enum Blur {
        static let light: CGFloat = 10
        static let medium: CGFloat = 20
        static let heavy: CGFloat = 30
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let y: CGFloat

    var x: CGFloat { 0 }
}

// MARK: - View Extensions

extension View {
    /// Apply standard card shadow
    func cardShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.card.color,
            radius: AppTheme.Shadow.card.radius,
            x: 0,
            y: AppTheme.Shadow.card.y
        )
    }

    /// Apply medium shadow
    func mediumShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.medium.color,
            radius: AppTheme.Shadow.medium.radius,
            x: 0,
            y: AppTheme.Shadow.medium.y
        )
    }

    /// Apply small shadow
    func smallShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.small.color,
            radius: AppTheme.Shadow.small.radius,
            x: 0,
            y: AppTheme.Shadow.small.y
        )
    }

    /// Apply glass background
    func glassBackground(cornerRadius: CGFloat = AppTheme.CornerRadius.large) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    /// Apply glass card style
    func glassCard() -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                    .stroke(.white.opacity(0.2), lineWidth: 0.5)
            )
            .cardShadow()
    }
}
