//
//  GlassCard.swift
//  MovieTrailer
//
//  Phase 2: Premium Glass Card Design System Component
//  Standardized depth, translucency, and shadows
//

import SwiftUI

// MARK: - Premium Glass Card Modifier

struct PremiumGlassModifier: ViewModifier {

    let cornerRadius: CGFloat
    let padding: CGFloat
    let shadowRadius: CGFloat
    let borderOpacity: Double

    init(
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 0,
        shadowRadius: CGFloat = 10,
        borderOpacity: Double = 0.15
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shadowRadius = shadowRadius
        self.borderOpacity = borderOpacity
    }

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.3), radius: shadowRadius, x: 0, y: 5)
    }
}

// MARK: - Glass Card View

struct GlassCard<Content: View>: View {

    let cornerRadius: CGFloat
    let padding: CGFloat
    let content: Content

    init(
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .modifier(PremiumGlassModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - Liquid Background

struct LiquidBackground: View {

    let colors: [Color]
    let animationDuration: Double

    @State private var animate = false

    init(
        colors: [Color] = [.cyan.opacity(0.3), .blue.opacity(0.2), .purple.opacity(0.1)],
        animationDuration: Double = 8.0
    ) {
        self.colors = colors
        self.animationDuration = animationDuration
    }

    var body: some View {
        ZStack {
            // Base gradient
            Color.appBackground

            // Animated blobs
            ForEach(0..<3) { index in
                Circle()
                    .fill(colors[index % colors.count])
                    .frame(width: 300, height: 300)
                    .blur(radius: 80)
                    .offset(
                        x: animate ? CGFloat.random(in: -100...100) : CGFloat.random(in: -50...50),
                        y: animate ? CGFloat.random(in: -200...200) : CGFloat.random(in: -100...100)
                    )
                    .animation(
                        Animation.easeInOut(duration: animationDuration)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                        value: animate
                    )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Premium Glass Button Style

struct PremiumGlassButtonStyle: ButtonStyle {

    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = 12) {
        self.cornerRadius = cornerRadius
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Glass Pill

struct GlassPill: View {

    let title: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void

    init(
        title: String,
        icon: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: {
            Haptics.shared.selectionChanged()
            action()
        }) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .medium))
                }
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white : Color.white.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(isSelected ? 0 : 0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {

    let message: String
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?

    init(
        message: String,
        onRetry: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.message = message
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 18))

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .lineLimit(2)

            Spacer()

            if let onRetry = onRetry {
                Button("Retry") {
                    Haptics.shared.lightImpact()
                    onRetry()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.cyan)
            }

            if let onDismiss = onDismiss {
                Button {
                    Haptics.shared.lightImpact()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.orange.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.orange.opacity(0.3), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Toast View

struct ToastView: View {

    let message: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }
}

// MARK: - View Extension

extension View {
    func premiumGlass(
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 0,
        shadowRadius: CGFloat = 10
    ) -> some View {
        modifier(PremiumGlassModifier(
            cornerRadius: cornerRadius,
            padding: padding,
            shadowRadius: shadowRadius
        ))
    }
}

// MARK: - Preview

#if DEBUG
struct GlassCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LiquidBackground()

            VStack(spacing: 20) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Glass Card")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Premium translucent design")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .frame(width: 300)

                HStack(spacing: 10) {
                    GlassPill(title: "Tonight", icon: "moon.stars.fill", isSelected: true) {}
                    GlassPill(title: "Family", icon: "figure.2.and.child.holdinghands", isSelected: false) {}
                }

                ErrorBanner(
                    message: "Failed to load movies",
                    onRetry: {},
                    onDismiss: {}
                )

                ToastView(
                    message: "Added to watchlist",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
