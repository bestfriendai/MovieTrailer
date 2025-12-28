//
//  GlassBackgroundView.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Implemented by Claude Code Audit on 28/12/2025.
//

import SwiftUI

/// Glassmorphism background component with customizable blur and tint
struct GlassBackgroundView: View {

    // MARK: - Properties

    let style: GlassStyle
    let cornerRadius: CGFloat

    // MARK: - Initialization

    init(style: GlassStyle = .regular, cornerRadius: CGFloat = 20) {
        self.style = style
        self.cornerRadius = cornerRadius
    }

    // MARK: - Glass Styles

    enum GlassStyle {
        case ultraThin    // Very subtle blur
        case thin         // Light blur
        case regular      // Standard glassmorphism
        case thick        // Heavy blur
        case chrome       // Metallic appearance

        var material: Material {
            switch self {
            case .ultraThin: return .ultraThinMaterial
            case .thin: return .thinMaterial
            case .regular: return .regularMaterial
            case .thick: return .thickMaterial
            case .chrome: return .ultraThickMaterial
            }
        }

        var borderOpacity: Double {
            switch self {
            case .ultraThin: return 0.1
            case .thin: return 0.15
            case .regular: return 0.2
            case .thick: return 0.25
            case .chrome: return 0.4
            }
        }

        var shadowOpacity: Double {
            switch self {
            case .ultraThin: return 0.05
            case .thin: return 0.1
            case .regular: return 0.15
            case .thick: return 0.2
            case .chrome: return 0.3
            }
        }
    }

    // MARK: - Body

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(style.material)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(style.borderOpacity),
                                Color.white.opacity(style.borderOpacity * 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(style.shadowOpacity),
                radius: 10,
                x: 0,
                y: 5
            )
    }
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    let style: GlassBackgroundView.GlassStyle
    let cornerRadius: CGFloat
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                GlassBackgroundView(style: style, cornerRadius: cornerRadius)
            )
    }
}

extension View {
    /// Apply glassmorphism card styling to any view
    func glassCard(
        style: GlassBackgroundView.GlassStyle = .regular,
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 16
    ) -> some View {
        modifier(GlassCardModifier(style: style, cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - Glass Button Style

struct GlassButtonStyle: ButtonStyle {
    let style: GlassBackgroundView.GlassStyle

    init(style: GlassBackgroundView.GlassStyle = .thin) {
        self.style = style
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                GlassBackgroundView(style: style, cornerRadius: 12)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Frosted Glass Background

struct FrostedGlassBackground: View {
    let colors: [Color]
    let opacity: Double

    init(
        colors: [Color] = [.blue, .purple, .pink],
        opacity: Double = 0.3
    ) {
        self.colors = colors
        self.opacity = opacity
    }

    var body: some View {
        ZStack {
            // Gradient blobs
            GeometryReader { geometry in
                ForEach(0..<colors.count, id: \.self) { index in
                    Circle()
                        .fill(colors[index].opacity(opacity))
                        .frame(
                            width: geometry.size.width * 0.6,
                            height: geometry.size.width * 0.6
                        )
                        .offset(
                            x: CGFloat.random(in: -50...geometry.size.width * 0.5),
                            y: CGFloat.random(in: -50...geometry.size.height * 0.5)
                        )
                        .blur(radius: 60)
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Preview

#if DEBUG
struct GlassBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue, .purple, .pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Glass styles showcase
                Group {
                    Text("Ultra Thin")
                        .glassCard(style: .ultraThin)

                    Text("Thin")
                        .glassCard(style: .thin)

                    Text("Regular")
                        .glassCard(style: .regular)

                    Text("Thick")
                        .glassCard(style: .thick)

                    Text("Chrome")
                        .glassCard(style: .chrome)
                }
                .font(.headline)
                .foregroundColor(.white)

                // Glass button
                Button("Glass Button") {}
                    .buttonStyle(GlassButtonStyle())
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}
#endif
