//
//  Theme.swift
//  MovieTrailer
//
//  Apple 2025 Premium Theme System
//  Animations, Shadows, Corner Radius, Materials
//

import SwiftUI

// MARK: - App Theme

/// Central theme configuration for the app
enum AppTheme {

    // MARK: - Animation Presets

    enum Animation {
        // MARK: - Spring Presets (Apple 2025 Style)

        /// Snappy - Quick response for buttons, toggles (feels instant)
        static let snappy = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.75)

        /// Standard spring for UI elements - 0.35s response
        static let standard = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.75)

        /// Smooth - Standard UI transitions
        static let smooth = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.82)

        /// Bouncy spring for playful elements - 0.4s response
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)

        /// Cinematic - Hero reveals, modal presentations
        static let cinematic = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.78)

        /// Stiff spring for quick responses - 0.25s response
        static let stiff = SwiftUI.Animation.spring(response: 0.25, dampingFraction: 0.85)

        /// Quick snap animation - 0.2s response
        static let snap = SwiftUI.Animation.spring(response: 0.2, dampingFraction: 0.9)

        /// Gentle spring for cards - 0.5s response
        static let gentle = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7)

        /// Slow spring for hero elements - 0.6s response
        static let slow = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.75)

        /// Interactive spring for gestures - 0.3s response
        static let interactive = SwiftUI.Animation.interactiveSpring(
            response: 0.3,
            dampingFraction: 0.8,
            blendDuration: 0.1
        )

        /// Micro animation for tiny elements - 0.15s
        static let micro = SwiftUI.Animation.spring(response: 0.15, dampingFraction: 0.8)

        /// Quick animation for press effects - 0.2s
        static let quick = SwiftUI.Animation.spring(response: 0.2, dampingFraction: 0.75)

        // MARK: - Easing Presets

        /// Page transition - 0.4s ease
        static let pageTransition = SwiftUI.Animation.easeInOut(duration: 0.4)

        /// Smooth ease for subtle transitions - 0.3s
        static let smoothEase = SwiftUI.Animation.easeInOut(duration: 0.3)

        // MARK: - Component-Specific

        /// Tab change animation
        static let tabChange = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.8)

        /// Card press animation
        static let cardPress = SwiftUI.Animation.spring(response: 0.2, dampingFraction: 0.7)

        /// Swipe card physics
        static let swipeCard = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.65)

        /// Swipe release
        static let swipeRelease = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7)

        /// Button press
        static let buttonPress = SwiftUI.Animation.spring(response: 0.15, dampingFraction: 0.6)

        /// Sheet presentation
        static let sheetPresent = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)

        /// List item appearance
        static let listItem = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.8)

        /// Carousel rotation
        static let carousel = SwiftUI.Animation.easeInOut(duration: 0.5)

        // MARK: - Repeating Animations

        /// Shimmer animation
        static let shimmer = SwiftUI.Animation.linear(duration: 1.2).repeatForever(autoreverses: false)

        /// Pulse animation
        static let pulse = SwiftUI.Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)

        /// Glow pulse animation
        static let glowPulse = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)

        // MARK: - Helper Functions

        /// Delayed animation helper
        static func delayed(_ delay: Double) -> SwiftUI.Animation {
            standard.delay(delay)
        }

        /// Staggered animation for lists
        static func staggered(index: Int, baseDelay: Double = 0.05) -> SwiftUI.Animation {
            listItem.delay(Double(index) * baseDelay)
        }

        /// Custom spring with parameters
        static func customSpring(response: Double, damping: Double) -> SwiftUI.Animation {
            SwiftUI.Animation.spring(response: response, dampingFraction: damping)
        }
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        /// Extra small - 4pt (chips, tiny elements)
        static let xs: CGFloat = 4

        /// Small - 8pt (buttons, tags)
        static let small: CGFloat = 8

        /// Medium - 12pt (cards, inputs)
        static let medium: CGFloat = 12

        /// Large - 16pt (posters)
        static let large: CGFloat = 16

        /// Extra large - 20pt (feature cards)
        static let extraLarge: CGFloat = 20

        /// XL - 24pt (larger cards)
        static let xl: CGFloat = 24

        /// XXL - 28pt (prominent elements)
        static let xxl: CGFloat = 28

        /// Card - 24pt
        static let card: CGFloat = 24

        /// Sheet - 32pt (modal sheets)
        static let sheet: CGFloat = 32

        /// Full - 999pt (circular/pill shapes)
        static let full: CGFloat = 999
    }

    // MARK: - Shadows

    enum Shadow {
        /// Subtle shadow for minimal elevation
        static let subtle = ShadowStyle(color: .black.opacity(0.15), radius: 4, y: 2)

        /// Small shadow for slight elevation
        static let small = ShadowStyle(color: .black.opacity(0.20), radius: 8, y: 4)

        /// Medium shadow for cards
        static let medium = ShadowStyle(color: .black.opacity(0.25), radius: 12, y: 6)

        /// Large shadow for prominent elements
        static let large = ShadowStyle(color: .black.opacity(0.30), radius: 20, y: 10)

        /// Hero shadow for featured content
        static let hero = ShadowStyle(color: .black.opacity(0.40), radius: 32, y: 16)

        /// Card shadow (legacy)
        static let card = ShadowStyle(color: .black.opacity(0.25), radius: 20, y: 10)

        /// Button shadow
        static let button = ShadowStyle(color: .black.opacity(0.20), radius: 8, y: 4)

        /// Floating shadow for FABs
        static let floating = ShadowStyle(color: .black.opacity(0.35), radius: 16, y: 8)

        /// Glow shadow (colored)
        static func glow(_ color: Color, intensity: Double = 0.4) -> ShadowStyle {
            ShadowStyle(color: color.opacity(intensity), radius: 20, y: 0)
        }

        /// Inner shadow simulation (for inset effects)
        static let inner = ShadowStyle(color: .black.opacity(0.15), radius: 4, y: -2)
    }

    // MARK: - Blur

    enum Blur {
        /// Ultra light blur - 5pt
        static let ultraLight: CGFloat = 5

        /// Light blur - 10pt
        static let light: CGFloat = 10

        /// Medium blur - 20pt
        static let medium: CGFloat = 20

        /// Heavy blur - 30pt
        static let heavy: CGFloat = 30

        /// Ultra heavy blur - 50pt
        static let ultraHeavy: CGFloat = 50

        /// Background blur - 40pt
        static let background: CGFloat = 40
    }

    // MARK: - Opacity

    enum Opacity {
        static let disabled: Double = 0.4
        static let secondary: Double = 0.7
        static let tertiary: Double = 0.5
        static let overlay: Double = 0.6
        static let dimmed: Double = 0.3
        static let ghost: Double = 0.15
        static let subtle: Double = 0.08
    }

    // MARK: - Scale

    enum Scale {
        static let pressed: CGFloat = 0.96
        static let cardPressed: CGFloat = 0.98
        static let buttonPressed: CGFloat = 0.94
        static let hovered: CGFloat = 1.03
        static let selected: CGFloat = 1.05
        static let highlighted: CGFloat = 1.08
    }

    // MARK: - Durations

    enum Duration {
        static let instant: Double = 0.1
        static let fast: Double = 0.2
        static let normal: Double = 0.3
        static let slow: Double = 0.5
        static let verySlow: Double = 0.8
        static let carousel: Double = 6.0  // Auto-advance interval
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let y: CGFloat

    var x: CGFloat { 0 }
}

// MARK: - View Extensions for Theme

extension View {

    // MARK: - Shadow Modifiers

    /// Apply subtle shadow
    func subtleShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.subtle.color,
            radius: AppTheme.Shadow.subtle.radius,
            x: 0,
            y: AppTheme.Shadow.subtle.y
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

    /// Apply medium shadow
    func mediumShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.medium.color,
            radius: AppTheme.Shadow.medium.radius,
            x: 0,
            y: AppTheme.Shadow.medium.y
        )
    }

    /// Apply large shadow
    func largeShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.large.color,
            radius: AppTheme.Shadow.large.radius,
            x: 0,
            y: AppTheme.Shadow.large.y
        )
    }

    /// Apply hero shadow
    func heroShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.hero.color,
            radius: AppTheme.Shadow.hero.radius,
            x: 0,
            y: AppTheme.Shadow.hero.y
        )
    }

    /// Apply card shadow (legacy)
    func cardShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.card.color,
            radius: AppTheme.Shadow.card.radius,
            x: 0,
            y: AppTheme.Shadow.card.y
        )
    }

    /// Apply button shadow
    func buttonShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.button.color,
            radius: AppTheme.Shadow.button.radius,
            x: 0,
            y: AppTheme.Shadow.button.y
        )
    }

    /// Apply floating shadow
    func floatingShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.floating.color,
            radius: AppTheme.Shadow.floating.radius,
            x: 0,
            y: AppTheme.Shadow.floating.y
        )
    }

    /// Apply colored glow shadow
    func glowShadow(_ color: Color, intensity: Double = 0.4) -> some View {
        let style = AppTheme.Shadow.glow(color, intensity: intensity)
        return self.shadow(
            color: style.color,
            radius: style.radius,
            x: 0,
            y: style.y
        )
    }

    // MARK: - Glass & Material Effects

    /// Apply glass background with material
    func glassBackground(cornerRadius: CGFloat = AppTheme.CornerRadius.large) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// Apply thick glass background
    func thickGlassBackground(cornerRadius: CGFloat = AppTheme.CornerRadius.large) -> some View {
        self
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// Apply glass card style with border
    func glassCard(cornerRadius: CGFloat = AppTheme.CornerRadius.card) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.12), lineWidth: 0.5)
            )
            .cardShadow()
    }

    /// Apply premium glass effect
    func premiumGlass(cornerRadius: CGFloat = AppTheme.CornerRadius.large) -> some View {
        self
            .background(
                ZStack {
                    Color.black.opacity(0.3)
                    Color.white.opacity(0.05)
                }
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }

    /// Apply surface background
    func surfaceBackground(cornerRadius: CGFloat = AppTheme.CornerRadius.medium) -> some View {
        self
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    // MARK: - Card Styles

    /// Standard card style
    func standardCard() -> some View {
        self
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))
            .mediumShadow()
    }

    /// Elevated card style
    func elevatedCard() -> some View {
        self
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card, style: .continuous))
            .largeShadow()
    }

    /// Featured card style
    func featuredCard() -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl, style: .continuous))
            .heroShadow()
    }

    // MARK: - Interactive States

    /// Apply press effect
    func pressEffect(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? AppTheme.Scale.pressed : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(AppTheme.Animation.cardPress, value: isPressed)
    }

    /// Apply button press effect
    func buttonPressEffect(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? AppTheme.Scale.buttonPressed : 1.0)
            .animation(AppTheme.Animation.buttonPress, value: isPressed)
    }

    /// Apply hover effect (iPad/Mac)
    func hoverEffect(isHovered: Bool) -> some View {
        self
            .scaleEffect(isHovered ? AppTheme.Scale.hovered : 1.0)
            .animation(AppTheme.Animation.gentle, value: isHovered)
    }

    // MARK: - Transitions

    /// Standard fade + scale transition
    func standardTransition() -> some View {
        self.transition(
            .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                removal: .opacity
            )
        )
    }

    /// Slide up transition
    func slideUpTransition() -> some View {
        self.transition(
            .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 20)),
                removal: .opacity
            )
        )
    }
}

// MARK: - Button Styles
// Note: ScaleButtonStyle and GlassButtonStyle are defined in their respective component files
// to avoid circular dependencies

struct PremiumButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = .accentBlue) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonMedium)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(AppTheme.Animation.buttonPress, value: configuration.isPressed)
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(AppTheme.Animation.quick, value: configuration.isPressed)
    }
}
