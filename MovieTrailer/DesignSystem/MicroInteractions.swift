//
//  MicroInteractions.swift
//  MovieTrailer
//
//  Apple 2025 Premium Micro-Interactions Library
//  Subtle animations that make the app feel premium
//

import SwiftUI

// MARK: - Liquid Shimmer Effect

struct LiquidShimmerModifier: ViewModifier {

    var isActive: Bool
    var duration: Double = 1.5

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isActive {
                        shimmerGradient
                            .frame(width: geometry.size.width * 2.5)
                            .offset(x: -geometry.size.width + (phase * geometry.size.width * 2.5))
                    }
                }
                .mask(content)
            )
            .onAppear {
                guard isActive else { return }
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }

    private var shimmerGradient: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .white.opacity(0.3), location: 0.3),
                .init(color: .white.opacity(0.6), location: 0.5),
                .init(color: .white.opacity(0.3), location: 0.7),
                .init(color: .clear, location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

extension View {
    /// Apply liquid shimmer loading effect
    func liquidShimmer(isActive: Bool = true, duration: Double = 1.5) -> some View {
        modifier(LiquidShimmerModifier(isActive: isActive, duration: duration))
    }
}

// MARK: - Shake Effect (Error Feedback)

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: Int = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

struct ShakeModifier: ViewModifier {
    var trigger: Bool
    var amount: CGFloat = 8
    var shakesPerUnit: Int = 3

    @State private var shakeAmount: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(amount: amount, shakesPerUnit: shakesPerUnit, animatableData: shakeAmount))
            .onChange(of: trigger) { _, newValue in
                guard newValue else { return }
                withAnimation(.linear(duration: 0.4)) {
                    shakeAmount = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    shakeAmount = 0
                }
            }
    }
}

extension View {
    /// Apply shake animation on error
    func shake(trigger: Bool, amount: CGFloat = 8) -> some View {
        modifier(ShakeModifier(trigger: trigger, amount: amount))
    }
}

// MARK: - Glow Pulse Effect

struct GlowPulseModifier: ViewModifier {
    var color: Color
    var minRadius: CGFloat = 8
    var maxRadius: CGFloat = 20
    var minOpacity: Double = 0.3
    var maxOpacity: Double = 0.8

    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(isGlowing ? maxOpacity : minOpacity),
                radius: isGlowing ? maxRadius : minRadius
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    isGlowing = true
                }
            }
    }
}

extension View {
    /// Apply pulsing glow effect
    func glowPulse(color: Color = .accentPrimary, intensity: Double = 0.8) -> some View {
        modifier(GlowPulseModifier(color: color, maxOpacity: intensity))
    }
}

// MARK: - Slide In Effect

struct SlideInModifier: ViewModifier {
    var delay: Double = 0
    var direction: SlideDirection = .leading
    var distance: CGFloat = 30

    @State private var show = false

    enum SlideDirection {
        case leading, trailing, top, bottom

        var offset: (x: CGFloat, y: CGFloat) {
            switch self {
            case .leading: return (-1, 0)
            case .trailing: return (1, 0)
            case .top: return (0, -1)
            case .bottom: return (0, 1)
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(
                x: show ? 0 : direction.offset.x * distance,
                y: show ? 0 : direction.offset.y * distance
            )
            .opacity(show ? 1 : 0)
            .onAppear {
                withAnimation(
                    .spring(response: 0.45, dampingFraction: 0.8)
                    .delay(delay)
                ) {
                    show = true
                }
            }
    }
}

extension View {
    /// Apply slide-in entrance animation
    func slideIn(delay: Double = 0, from direction: SlideInModifier.SlideDirection = .leading) -> some View {
        modifier(SlideInModifier(delay: delay, direction: direction))
    }

    /// Apply staggered slide-in for list items
    func slideInStaggered(index: Int, baseDelay: Double = 0.05) -> some View {
        modifier(SlideInModifier(delay: Double(index) * baseDelay))
    }
}

// MARK: - Tap Pop Effect (Apple Button Feel)

struct TapPopModifier: ViewModifier {
    var scale: CGFloat = 0.92

    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
    }
}

extension View {
    /// Apply Apple-style tap pop effect
    func tapPop(scale: CGFloat = 0.92) -> some View {
        modifier(TapPopModifier(scale: scale))
    }
}

// MARK: - Hover Lift Effect (iPad/Mac)

struct HoverLiftModifier: ViewModifier {
    var scale: CGFloat = 1.03
    var shadowRadius: CGFloat = 25

    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? scale : 1.0)
            .shadow(
                color: .black.opacity(isHovered ? 0.35 : 0.2),
                radius: isHovered ? shadowRadius : 12,
                y: isHovered ? 12 : 6
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension View {
    /// Apply hover lift effect for cards
    func hoverLift(scale: CGFloat = 1.03) -> some View {
        modifier(HoverLiftModifier(scale: scale))
    }
}

// MARK: - Ripple Effect

struct RippleEffect: View {
    @Binding var trigger: Bool
    var color: Color = .white
    var maxScale: CGFloat = 3.0
    var duration: Double = 0.6

    @State private var ripple = false

    var body: some View {
        Circle()
            .stroke(color.opacity(ripple ? 0 : 0.4), lineWidth: 3)
            .scaleEffect(ripple ? maxScale : 0.1)
            .opacity(ripple ? 0 : 1)
            .animation(.smooth(duration: duration), value: ripple)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    ripple = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        ripple = false
                        trigger = false
                    }
                }
            }
    }
}

// MARK: - Pulsing Icon

struct PulsingIconModifier: ViewModifier {
    var color: Color = .accentPrimary
    var minScale: CGFloat = 1.0
    var maxScale: CGFloat = 1.1
    var duration: Double = 1.2

    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .foregroundColor(color)
            .scaleEffect(isPulsing ? maxScale : minScale)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

extension View {
    /// Apply pulsing animation to icons
    func pulsingIcon(color: Color = .accentPrimary) -> some View {
        modifier(PulsingIconModifier(color: color))
    }
}

// MARK: - Fade In Effect

struct FadeInModifier: ViewModifier {
    var delay: Double = 0
    var duration: Double = 0.3

    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

extension View {
    /// Apply fade-in animation
    func fadeIn(delay: Double = 0, duration: Double = 0.3) -> some View {
        modifier(FadeInModifier(delay: delay, duration: duration))
    }
}

// MARK: - Scale In Effect

struct ScaleInModifier: ViewModifier {
    var delay: Double = 0
    var startScale: CGFloat = 0.8

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                scale = startScale
                withAnimation(
                    .spring(response: 0.4, dampingFraction: 0.7)
                    .delay(delay)
                ) {
                    scale = 1.0
                    opacity = 1
                }
            }
    }
}

extension View {
    /// Apply scale-in animation
    func scaleIn(delay: Double = 0, startScale: CGFloat = 0.8) -> some View {
        modifier(ScaleInModifier(delay: delay, startScale: startScale))
    }
}

// MARK: - Bounce Effect

struct BounceModifier: ViewModifier {
    var trigger: Bool
    var scale: CGFloat = 1.2

    @State private var bouncing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(bouncing ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: bouncing)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    bouncing = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        bouncing = false
                    }
                }
            }
    }
}

extension View {
    /// Apply bounce animation on trigger
    func bounce(trigger: Bool, scale: CGFloat = 1.2) -> some View {
        modifier(BounceModifier(trigger: trigger, scale: scale))
    }
}

// MARK: - Typing Effect

struct TypingEffectModifier: ViewModifier {
    let text: String
    var speed: Double = 0.05

    @State private var displayedText = ""
    @State private var currentIndex = 0

    func body(content: Content) -> some View {
        Text(displayedText)
            .onAppear {
                animateText()
            }
    }

    private func animateText() {
        guard currentIndex < text.count else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + speed) {
            let index = text.index(text.startIndex, offsetBy: currentIndex)
            displayedText += String(text[index])
            currentIndex += 1
            animateText()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct MicroInteractions_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 40) {
                // Shimmer
                Text("Shimmer Effect")
                    .font(.headline)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceSecondary)
                    .frame(height: 100)
                    .liquidShimmer()

                // Glow Pulse
                Text("Glow Pulse")
                    .font(.headline)
                Circle()
                    .fill(Color.accentPrimary)
                    .frame(width: 60, height: 60)
                    .glowPulse()

                // Slide In
                Text("Slide In")
                    .font(.headline)
                HStack(spacing: 16) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentSecondary)
                            .frame(width: 60, height: 60)
                            .slideInStaggered(index: index)
                    }
                }

                // Tap Pop
                Text("Tap Pop (tap me)")
                    .font(.headline)
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentPrimary)
                    .frame(width: 120, height: 50)
                    .tapPop()
            }
            .padding()
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
