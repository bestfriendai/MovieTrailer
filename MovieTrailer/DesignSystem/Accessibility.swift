//
//  Accessibility.swift
//  MovieTrailer
//
//  Apple 2025 Premium Accessibility System
//  Motion-aware animations, Dynamic Type, VoiceOver support
//

import SwiftUI

// MARK: - Motion-Aware Modifier

/// Respects user's Reduce Motion preference
struct MotionAwareModifier<AnimatedContent: View, StaticContent: View>: ViewModifier {

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    let animated: () -> AnimatedContent
    let reduced: () -> StaticContent

    func body(content: Content) -> some View {
        if reduceMotion {
            reduced()
        } else {
            animated()
        }
    }
}

extension View {
    /// Apply motion-aware content
    func motionAware<A: View, S: View>(
        animated: @escaping () -> A,
        reduced: @escaping () -> S
    ) -> some View {
        modifier(MotionAwareModifier(animated: animated, reduced: reduced))
    }

    /// Apply animation only if motion is not reduced
    func animateIfAllowed(_ animation: Animation) -> some View {
        modifier(ReduceMotionAnimationModifier(animation: animation))
    }
}

struct ReduceMotionAnimationModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation

    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? nil : animation, value: UUID())
    }
}

// MARK: - Reduce Motion Safe Transitions

extension AnyTransition {
    /// Motion-safe slide transition
    static var safeSlide: AnyTransition {
        .modifier(
            active: ReduceMotionTransitionModifier(offset: 20, opacity: 0),
            identity: ReduceMotionTransitionModifier(offset: 0, opacity: 1)
        )
    }

    /// Motion-safe scale transition
    static var safeScale: AnyTransition {
        .modifier(
            active: ReduceMotionScaleModifier(scale: 0.9, opacity: 0),
            identity: ReduceMotionScaleModifier(scale: 1, opacity: 1)
        )
    }
}

private struct ReduceMotionTransitionModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let offset: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .offset(y: reduceMotion ? 0 : offset)
            .opacity(opacity)
    }
}

private struct ReduceMotionScaleModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let scale: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1 : scale)
            .opacity(opacity)
    }
}

// MARK: - Adaptive Glass (Transparency Preference)

struct AdaptiveGlassModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var cornerRadius: CGFloat
    var intensity: LiquidGlassSurface.GlassIntensity

    func body(content: Content) -> some View {
        if reduceTransparency {
            content
                .background(Color.surfaceElevated)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            content
                .background(
                    LiquidGlassSurface(cornerRadius: cornerRadius, intensity: intensity)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

extension View {
    /// Apply glass effect that respects Reduce Transparency
    func adaptiveGlass(
        cornerRadius: CGFloat = 20,
        intensity: LiquidGlassSurface.GlassIntensity = .regular
    ) -> some View {
        modifier(AdaptiveGlassModifier(cornerRadius: cornerRadius, intensity: intensity))
    }
}

// MARK: - Semantic Accessibility

extension View {
    /// Add comprehensive accessibility label for movie cards
    func movieAccessibility(_ movie: Movie) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(movieLabel(movie))
            .accessibilityHint("Double tap to view details")
    }

    private func movieLabel(_ movie: Movie) -> String {
        var parts: [String] = [movie.title]

        if let year = movie.releaseYear {
            parts.append("released in \(year)")
        }

        parts.append("rated \(movie.formattedRating) out of 10")

        if let genres = movie.genreNames?.prefix(2).joined(separator: " and ") {
            parts.append(genres)
        }

        return parts.joined(separator: ", ")
    }

    /// Add accessibility for rating displays
    func ratingAccessibility(_ rating: Double, maxRating: Double = 10) -> some View {
        self
            .accessibilityElement()
            .accessibilityLabel("Rating: \(String(format: "%.1f", rating)) out of \(Int(maxRating))")
            .accessibilityValue("\(Int((rating / maxRating) * 100)) percent")
    }

    /// Add accessibility for buttons with custom actions
    func buttonAccessibility(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Dynamic Type Support

extension View {
    /// Apply scalable padding based on Dynamic Type
    func scalablePadding(_ edges: Edge.Set = .all, _ length: CGFloat = 16) -> some View {
        modifier(ScalablePaddingModifier(edges: edges, length: length))
    }
}

private struct ScalablePaddingModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    let edges: Edge.Set
    let length: CGFloat

    func body(content: Content) -> some View {
        content.padding(edges, scaledLength)
    }

    private var scaledLength: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small:
            return length * 0.8
        case .medium, .large:
            return length
        case .xLarge, .xxLarge:
            return length * 1.1
        case .xxxLarge:
            return length * 1.2
        case .accessibility1, .accessibility2:
            return length * 1.3
        case .accessibility3, .accessibility4, .accessibility5:
            return length * 1.5
        @unknown default:
            return length
        }
    }
}

// MARK: - High Contrast Support

struct HighContrastModifier: ViewModifier {
    @Environment(\.colorSchemeContrast) var contrast

    var normalColor: Color
    var highContrastColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(contrast == .increased ? highContrastColor : normalColor)
    }
}

extension View {
    /// Apply color that adapts to high contrast mode
    func adaptiveColor(normal: Color, highContrast: Color) -> some View {
        modifier(HighContrastModifier(normalColor: normal, highContrastColor: highContrast))
    }
}

// MARK: - Focus State for tvOS/iPadOS

struct FocusableCardModifier: ViewModifier {
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .shadow(
                color: isFocused ? .accentPrimary.opacity(0.5) : .clear,
                radius: isFocused ? 20 : 0
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
    }
}

extension View {
    /// Apply focus-aware styling for tvOS/iPadOS
    func focusableCard() -> some View {
        modifier(FocusableCardModifier())
    }
}

// MARK: - VoiceOver Announcement

extension View {
    /// Announce a message via VoiceOver
    func announceChange(_ message: String) {
        let announcement = AttributedString(message)
        AccessibilityNotification.Announcement(announcement).post()
    }
}

// MARK: - Skip Navigation Link

struct SkipNavigationModifier: ViewModifier {
    let destination: String

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityAction(named: "Skip to \(destination)") {
                // This is a semantic action for screen readers
            }
    }
}

extension View {
    /// Add skip navigation for screen readers
    func skipNavigation(to destination: String) -> some View {
        modifier(SkipNavigationModifier(destination: destination))
    }
}

// MARK: - Preview

#if DEBUG
struct Accessibility_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Glass with transparency handling
            Text("Adaptive Glass")
                .padding()
                .adaptiveGlass()

            // Motion-safe button
            Button("Tap Me") {}
                .padding()
                .background(Color.accentPrimary)
                .clipShape(Capsule())
                .buttonAccessibility(label: "Action button", hint: "Double tap to perform action")

            // Rating with accessibility
            HStack {
                Image(systemName: "star.fill")
                Text("8.5")
            }
            .ratingAccessibility(8.5)
        }
        .padding()
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
