//
//  LiquidGlass.swift
//  MovieTrailer
//
//  Apple 2025 Liquid Glass Design System
//  Premium glassmorphic components with specular highlights
//

import SwiftUI

// MARK: - Liquid Glass Surface

/// The foundational Liquid Glass material stack
struct LiquidGlassSurface: View {
    var cornerRadius: CGFloat = 20
    var intensity: GlassIntensity = .regular

    enum GlassIntensity {
        case ultraLight
        case light
        case regular
        case thick

        var material: Material {
            switch self {
            case .ultraLight: return .ultraThinMaterial
            case .light: return .thinMaterial
            case .regular: return .regularMaterial
            case .thick: return .thickMaterial
            }
        }

        var highlightOpacity: Double {
            switch self {
            case .ultraLight: return 0.25
            case .light: return 0.30
            case .regular: return 0.35
            case .thick: return 0.40
            }
        }
    }

    var body: some View {
        ZStack {
            // Layer 1: Base blur
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(intensity.material)

            // Layer 2: Specular highlight (top-left light source)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(intensity.highlightOpacity), location: 0),
                            .init(color: .white.opacity(0.1), location: 0.3),
                            .init(color: .clear, location: 0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Layer 3: Inner shadow/border for depth
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.1), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Liquid Glass Button

struct LiquidGlassButton: View {
    let title: String
    var icon: String? = nil
    var style: LiquidButtonStyle = .primary
    let action: () -> Void

    enum LiquidButtonStyle {
        case primary    // Filled white, black text
        case secondary  // Glass with white text
        case ghost      // Text only
        case accent     // Accent color filled

        var foregroundColor: Color {
            switch self {
            case .primary: return .black
            case .secondary: return .white
            case .ghost: return .accentPrimary
            case .accent: return .white
            }
        }
    }

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(buttonBackground)
            .clipShape(Capsule())
            .overlay(buttonBorder)
            .shadow(color: shadowColor, radius: 12, y: 6)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    @ViewBuilder
    private var buttonBackground: some View {
        switch style {
        case .primary:
            Capsule().fill(.white)
        case .secondary:
            ZStack {
                Capsule().fill(.ultraThinMaterial)
                Capsule().fill(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.3), location: 0),
                            .init(color: .white.opacity(0.1), location: 0.3),
                            .init(color: .clear, location: 0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        case .ghost:
            Color.clear
        case .accent:
            Capsule().fill(Color.accentPrimary)
        }
    }

    @ViewBuilder
    private var buttonBorder: some View {
        switch style {
        case .primary, .ghost, .accent:
            EmptyView()
        case .secondary:
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary: return .white.opacity(0.3)
        case .secondary: return .black.opacity(0.2)
        case .ghost: return .clear
        case .accent: return .accentPrimary.opacity(0.4)
        }
    }
}

// MARK: - Liquid Glass Card

struct LiquidGlassCard<Content: View>: View {
    var cornerRadius: CGFloat = 20
    var intensity: LiquidGlassSurface.GlassIntensity = .light
    var showShadow: Bool = true
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(
                LiquidGlassSurface(cornerRadius: cornerRadius, intensity: intensity)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: showShadow ? .black.opacity(0.25) : .clear,
                radius: 20,
                y: 10
            )
    }
}

// MARK: - Liquid Glass Pill

struct LiquidGlassPill: View {
    let text: String
    var icon: String? = nil
    var isSelected: Bool = false
    var color: Color = .accentPrimary

    var body: some View {
        HStack(spacing: 6) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(isSelected ? .white : .textPrimary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Group {
                if isSelected {
                    Capsule().fill(color)
                } else {
                    ZStack {
                        Capsule().fill(.ultraThinMaterial)
                        Capsule().stroke(Color.glassBorder, lineWidth: 0.5)
                    }
                }
            }
        )
        .clipShape(Capsule())
    }
}

// MARK: - Liquid Glass Icon Button

struct LiquidGlassIconButton: View {
    let icon: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 20
    var action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(.textPrimary)
                .frame(width: size, height: size)
                .background(
                    ZStack {
                        Circle().fill(.ultraThinMaterial)
                        Circle().fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .white.opacity(0.25), location: 0),
                                    .init(color: .white.opacity(0.05), location: 0.5),
                                    .init(color: .clear, location: 1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        Circle().stroke(Color.glassBorder, lineWidth: 0.5)
                    }
                )
                .clipShape(Circle())
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Liquid Glass Badge

struct LiquidGlassBadge: View {
    let text: String
    var icon: String? = nil
    var color: Color = .clear

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
            }
            Text(text)
                .font(.system(size: 12, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            ZStack {
                if color != .clear {
                    Capsule().fill(color.opacity(0.8))
                }
                Capsule().fill(.ultraThinMaterial)
                Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            }
        )
        .clipShape(Capsule())
    }
}

// MARK: - Liquid Glass Rating Badge

struct LiquidGlassRatingBadge: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.ratingStar)

            Text(String(format: "%.1f", rating))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Liquid Glass Modifier

struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var intensity: LiquidGlassSurface.GlassIntensity

    func body(content: Content) -> some View {
        content
            .background(
                LiquidGlassSurface(cornerRadius: cornerRadius, intensity: intensity)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    /// Apply liquid glass background
    func liquidGlass(cornerRadius: CGFloat = 20, intensity: LiquidGlassSurface.GlassIntensity = .regular) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, intensity: intensity))
    }
}

// MARK: - Preview

#if DEBUG
struct LiquidGlass_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background image
            Image(systemName: "photo.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            Color.black.opacity(0.3).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Surface
                    Text("Liquid Glass Surface")
                        .foregroundColor(.textSecondary)
                    LiquidGlassSurface()
                        .frame(height: 100)
                        .padding(.horizontal)

                    // Buttons
                    Text("Liquid Glass Buttons")
                        .foregroundColor(.textSecondary)
                    VStack(spacing: 16) {
                        LiquidGlassButton(title: "Primary", icon: "play.fill", style: .primary) {}
                        LiquidGlassButton(title: "Secondary", icon: "plus", style: .secondary) {}
                        LiquidGlassButton(title: "Ghost", style: .ghost) {}
                        LiquidGlassButton(title: "Accent", icon: "star.fill", style: .accent) {}
                    }

                    // Pills
                    Text("Liquid Glass Pills")
                        .foregroundColor(.textSecondary)
                    HStack(spacing: 12) {
                        LiquidGlassPill(text: "Action", isSelected: true)
                        LiquidGlassPill(text: "Comedy")
                        LiquidGlassPill(text: "Drama")
                    }

                    // Icon Buttons
                    Text("Icon Buttons")
                        .foregroundColor(.textSecondary)
                    HStack(spacing: 16) {
                        LiquidGlassIconButton(icon: "heart.fill") {}
                        LiquidGlassIconButton(icon: "bookmark.fill") {}
                        LiquidGlassIconButton(icon: "square.and.arrow.up") {}
                    }

                    // Badges
                    Text("Badges")
                        .foregroundColor(.textSecondary)
                    HStack(spacing: 12) {
                        LiquidGlassRatingBadge(rating: 8.5)
                        LiquidGlassBadge(text: "NEW", color: .red)
                        LiquidGlassBadge(text: "4K", icon: "sparkles")
                    }
                }
                .padding(.vertical, 32)
            }
        }
        .preferredColorScheme(.dark)
    }
}
#endif
