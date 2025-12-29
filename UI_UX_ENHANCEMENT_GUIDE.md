# Ultimate UI/UX Enhancement Guide for MovieTrailer

## Making Your App Indistinguishable from Apple's Own

Based on extensive research of Apple's Liquid Glass design language, Human Interface Guidelines, and premium SwiftUI patterns.

---

## Table of Contents

1. [Apple's Liquid Glass Philosophy](#1-apples-liquid-glass-philosophy)
2. [The 7 Pillars of Premium Feel](#2-the-7-pillars-of-premium-feel)
3. [Typography System](#3-typography-system)
4. [Spacing & Layout System](#4-spacing--layout-system)
5. [Color & Material System](#5-color--material-system)
6. [Micro-Interactions Library](#6-micro-interactions-library)
7. [Animation System](#7-animation-system)
8. [Haptic Feedback System](#8-haptic-feedback-system)
9. [Component Specifications](#9-component-specifications)
10. [Cinematic Patterns for Media Apps](#10-cinematic-patterns-for-media-apps)
11. [Accessibility Excellence](#11-accessibility-excellence)
12. [Performance Optimization](#12-performance-optimization)
13. [Implementation Checklist](#13-implementation-checklist)
14. [Maximizing TMDB API Capabilities](#14-maximizing-tmdb-api-capabilities)

---

## 1. Apple's Liquid Glass Philosophy

> *"A translucent, software-based material that combines the optical qualities of glass with a fluidity only Apple can achieve."* — Apple, June 2025

### Core Characteristics

| Property | Description | Implementation |
|----------|-------------|----------------|
| **Translucency** | UI elements feel like physical glass | `.ultraThinMaterial`, `.thinMaterial` |
| **Refraction** | Content behind affects appearance | Dynamic color sampling |
| **Specular Highlights** | Responds to motion with light reflections | Gradient overlays that shift |
| **Adaptive Color** | Absorbs colors from surroundings | Environment-aware tinting |
| **Depth Layering** | Multiple glass layers create dimension | Z-axis shadows and blur |

### Design Principles

1. **Content First** — UI should enhance, never compete with content
2. **Deference** — Controls give way to what matters (movie posters, artwork)
3. **Depth** — Layered interfaces feel physical and tangible
4. **Clarity** — Every element has purpose and meaning
5. **Consistency** — Predictable behaviors build trust

### Liquid Glass in Practice

```swift
// The Liquid Glass material stack
struct LiquidGlassSurface: View {
    var body: some View {
        ZStack {
            // Layer 1: Base blur
            Rectangle()
                .fill(.ultraThinMaterial)

            // Layer 2: Specular highlight (top-left light source)
            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0.35), location: 0),
                    .init(color: .white.opacity(0.1), location: 0.3),
                    .init(color: .clear, location: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Layer 3: Inner shadow for depth
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.1), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
```

---

## 2. The 7 Pillars of Premium Feel

### Pillar 1: Intentional Motion
Every animation serves a purpose. Nothing moves arbitrarily.

### Pillar 2: Responsive Feedback
The app acknowledges every touch within 100ms via visual change or haptic.

### Pillar 3: Consistent Rhythm
Spacing, timing, and sizing follow a mathematical system.

### Pillar 4: Depth & Dimensionality
Layers communicate hierarchy through shadows, blur, and scale.

### Pillar 5: Contextual Adaptation
UI responds to content, environment (dark/light), and user preferences.

### Pillar 6: Seamless Transitions
State changes feel continuous, not jarring.

### Pillar 7: Invisible Complexity
Advanced features feel simple. Power users discover depth.

---

## 3. Typography System

### Apple's Typography Rules

| Rule | Specification |
|------|---------------|
| Primary Font | San Francisco (SF Pro) |
| Default Body Size | 17pt |
| Line Height | 1.4–1.5× font size |
| Max Line Length | 12–15 words (65–75 characters) |
| Minimum Touch Target | 44×44 points |

### MovieTrailer Type Scale

```swift
extension Font {
    // Display - Hero titles, movie names on detail
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 22, weight: .bold, design: .default)

    // Headlines - Section headers
    static let headline1 = Font.system(size: 20, weight: .semibold)
    static let headline2 = Font.system(size: 17, weight: .semibold)
    static let headline3 = Font.system(size: 15, weight: .semibold)

    // Body - Descriptions, overviews
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)

    // Labels - Metadata, ratings, dates
    static let labelLarge = Font.system(size: 14, weight: .medium)
    static let labelMedium = Font.system(size: 12, weight: .medium)
    static let labelSmall = Font.system(size: 11, weight: .medium)

    // Captions - Tertiary info
    static let caption = Font.system(size: 11, weight: .regular)

    // Special - Ratings, numbers
    static let ratingLarge = Font.system(size: 16, weight: .bold, design: .rounded)
    static let ratingSmall = Font.system(size: 12, weight: .bold, design: .rounded)
}
```

### Dynamic Type Support

```swift
// Always use dynamic type for accessibility
Text(movie.title)
    .font(.headline2)
    .dynamicTypeSize(.large ... .accessibility3)
    .lineLimit(2)
    .truncationMode(.tail)
```

---

## 4. Spacing & Layout System

### The 4-Point Grid

All spacing derives from a base unit of 4 points:

```swift
enum Spacing {
    static let xxxs: CGFloat = 2   // 0.5×
    static let xxs: CGFloat = 4    // 1×
    static let xs: CGFloat = 8     // 2×
    static let sm: CGFloat = 12    // 3×
    static let md: CGFloat = 16    // 4×
    static let lg: CGFloat = 20    // 5×
    static let xl: CGFloat = 24    // 6×
    static let xxl: CGFloat = 32   // 8×
    static let xxxl: CGFloat = 40  // 10×
    static let huge: CGFloat = 48  // 12×

    // Standard horizontal padding
    static let horizontal: CGFloat = 20

    // Card internal padding
    static let cardPadding: CGFloat = 16
}
```

### Touch Target Rules

```swift
// NEVER go below 44pt for interactive elements
enum TouchTarget {
    static let minimum: CGFloat = 44
    static let comfortable: CGFloat = 48
    static let large: CGFloat = 56
}

// Add invisible tap area when visual element is smaller
Button { } label: {
    Image(systemName: "star")
        .frame(width: 24, height: 24)
}
.frame(minWidth: TouchTarget.minimum, minHeight: TouchTarget.minimum)
```

### Card Sizing System

```swift
enum CardSize {
    case small   // Quick browse
    case medium  // Standard
    case large   // Featured
    case hero    // Full-width spotlight

    var width: CGFloat {
        switch self {
        case .small: return 100
        case .medium: return 140
        case .large: return 180
        case .hero: return UIScreen.main.bounds.width - 40
        }
    }

    var height: CGFloat {
        width * 1.5 // 2:3 movie poster ratio
    }

    var cornerRadius: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        case .hero: return 20
        }
    }
}
```

---

## 5. Color & Material System

### Semantic Color Tokens

```swift
extension Color {
    // MARK: - Backgrounds
    static let backgroundPrimary = Color.black
    static let backgroundElevated = Color(white: 0.08)
    static let backgroundCard = Color(white: 0.12)

    // MARK: - Surfaces (Glass)
    static let surfaceGlass = Color.white.opacity(0.08)
    static let surfaceGlassHover = Color.white.opacity(0.12)
    static let surfaceGlassActive = Color.white.opacity(0.16)

    // MARK: - Text
    static let textPrimary = Color.white.opacity(0.95)
    static let textSecondary = Color.white.opacity(0.70)
    static let textTertiary = Color.white.opacity(0.50)
    static let textDisabled = Color.white.opacity(0.30)

    // MARK: - Borders
    static let borderSubtle = Color.white.opacity(0.12)
    static let borderMedium = Color.white.opacity(0.20)
    static let borderStrong = Color.white.opacity(0.30)

    // MARK: - Accent
    static let accentPrimary = Color(red: 0.4, green: 0.7, blue: 1.0)  // Blue
    static let accentSecondary = Color(red: 0.5, green: 0.85, blue: 0.65) // Green

    // MARK: - Semantic
    static let success = Color(red: 0.3, green: 0.85, blue: 0.5)
    static let warning = Color(red: 1.0, green: 0.75, blue: 0.3)
    static let error = Color(red: 0.95, green: 0.35, blue: 0.35)

    // MARK: - Swipe Actions
    static let swipeLike = Color(red: 0.3, green: 0.85, blue: 0.5)
    static let swipeSkip = Color(red: 0.95, green: 0.35, blue: 0.35)
    static let swipeSave = Color.cyan

    // MARK: - Rating
    static let ratingGold = Color(red: 1.0, green: 0.84, blue: 0.0)
}
```

### Material Hierarchy

```swift
// Use materials in this order based on elevation
enum GlassMaterial {
    case ultraLight  // Floating buttons, tooltips
    case light       // Cards, rows
    case medium      // Sheets, modals
    case heavy       // Full-screen overlays

    var material: Material {
        switch self {
        case .ultraLight: return .ultraThinMaterial
        case .light: return .thinMaterial
        case .medium: return .regularMaterial
        case .heavy: return .thickMaterial
        }
    }
}
```

### Gradient Presets

```swift
extension LinearGradient {
    // Hero image overlay
    static let heroOverlay = LinearGradient(
        stops: [
            .init(color: .clear, location: 0),
            .init(color: .black.opacity(0.3), location: 0.5),
            .init(color: .black.opacity(0.85), location: 0.8),
            .init(color: .black, location: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // Card overlay
    static let cardOverlay = LinearGradient(
        colors: [.clear, .black.opacity(0.7)],
        startPoint: .center,
        endPoint: .bottom
    )

    // Specular highlight
    static let specularHighlight = LinearGradient(
        stops: [
            .init(color: .white.opacity(0.4), location: 0),
            .init(color: .white.opacity(0.1), location: 0.3),
            .init(color: .clear, location: 0.5)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Glass border
    static let glassBorder = LinearGradient(
        colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
```

---

## 6. Micro-Interactions Library

> *"Users might not notice good animations, but they definitely notice when they're missing."*

### The 7 Essential Micro-Interactions

#### 1. Tap Pop (The "Apple Button" Feel)

```swift
struct TapPopButton<Label: View>: View {
    let action: () -> Void
    let label: () -> Label

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            label()
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .animation(.snappy(duration: 0.18), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
    }
}
```

#### 2. Hover Lift (Card Elevation)

```swift
struct HoverLiftModifier: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .shadow(
                color: .black.opacity(isHovered ? 0.35 : 0.2),
                radius: isHovered ? 25 : 12,
                y: isHovered ? 12 : 6
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension View {
    func hoverLift() -> some View {
        modifier(HoverLiftModifier())
    }
}
```

#### 3. Ripple Effect

```swift
struct RippleEffect: View {
    @Binding var trigger: Bool
    var color: Color = .white

    @State private var ripple = false

    var body: some View {
        Circle()
            .stroke(color.opacity(ripple ? 0 : 0.4), lineWidth: 3)
            .scaleEffect(ripple ? 3.0 : 0.1)
            .opacity(ripple ? 0 : 1)
            .animation(.smooth(duration: 0.6), value: ripple)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    ripple = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        ripple = false
                        trigger = false
                    }
                }
            }
    }
}
```

#### 4. Icon Pulse (Attract Attention)

```swift
struct PulsingIcon: View {
    let systemName: String
    var color: Color = .accentPrimary

    @State private var pulse = false

    var body: some View {
        Image(systemName: systemName)
            .foregroundColor(color)
            .scaleEffect(pulse ? 1.1 : 1.0)
            .animation(
                .easeInOut(duration: 1.2)
                .repeatForever(autoreverses: true),
                value: pulse
            )
            .onAppear { pulse = true }
    }
}
```

#### 5. Glow Pulse (Premium Ambient Effect)

```swift
struct GlowPulseModifier: ViewModifier {
    var color: Color
    @State private var glow = false

    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(glow ? 0.8 : 0.3),
                radius: glow ? 20 : 8
            )
            .animation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true),
                value: glow
            )
            .onAppear { glow = true }
    }
}
```

#### 6. Slide-In Entrance

```swift
struct SlideInModifier: ViewModifier {
    var delay: Double = 0
    @State private var show = false

    func body(content: Content) -> some View {
        content
            .offset(x: show ? 0 : -30)
            .opacity(show ? 1 : 0)
            .animation(
                .spring(response: 0.45, dampingFraction: 0.8)
                .delay(delay),
                value: show
            )
            .onAppear {
                show = true
            }
    }
}

extension View {
    func slideIn(delay: Double = 0) -> some View {
        modifier(SlideInModifier(delay: delay))
    }
}
```

#### 7. Shake Error

```swift
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

extension View {
    func shake(trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}
```

---

## 7. Animation System

### Spring Presets (The Secret Sauce)

```swift
extension Animation {
    // Quick response - buttons, toggles (feels instant)
    static let snappy = Animation.spring(response: 0.25, dampingFraction: 0.75)

    // Standard UI - most transitions
    static let smooth = Animation.spring(response: 0.35, dampingFraction: 0.82)

    // Bouncy - playful elements, success states
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)

    // Cinematic - hero reveals, modal presentations
    static let cinematic = Animation.spring(response: 0.5, dampingFraction: 0.78)

    // Gentle - background changes, subtle shifts
    static let gentle = Animation.spring(response: 0.6, dampingFraction: 0.9)

    // Interactive - gesture-driven, follows finger
    static let interactive = Animation.interactiveSpring(
        response: 0.3,
        dampingFraction: 0.8,
        blendDuration: 0.1
    )
}
```

### When to Use Each Animation

| Animation | Use Case | Duration Feel |
|-----------|----------|---------------|
| `.snappy` | Button taps, toggles, selections | Instant |
| `.smooth` | Navigation, state changes | Quick |
| `.bouncy` | Success, celebrations, fun | Medium |
| `.cinematic` | Full-screen reveals, heroes | Slow |
| `.gentle` | Background, ambient | Very slow |
| `.interactive` | Drag gestures, swipes | Responsive |

### Matched Geometry Transitions

```swift
struct MovieGridToDetail: View {
    @Namespace private var animation
    @State private var selectedMovie: Movie?

    var body: some View {
        ZStack {
            // Grid State
            if selectedMovie == nil {
                LazyVGrid(columns: columns) {
                    ForEach(movies) { movie in
                        MoviePoster(movie: movie)
                            .matchedGeometryEffect(
                                id: "poster-\(movie.id)",
                                in: animation
                            )
                            .matchedGeometryEffect(
                                id: "background-\(movie.id)",
                                in: animation
                            )
                            .onTapGesture {
                                withAnimation(.cinematic) {
                                    selectedMovie = movie
                                }
                            }
                    }
                }
            }

            // Detail State
            if let movie = selectedMovie {
                MovieDetailView(movie: movie, namespace: animation)
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.cinematic) {
                            selectedMovie = nil
                        }
                    }
            }
        }
    }
}
```

### Staggered List Animations

```swift
struct StaggeredList<Content: View, Item: Identifiable>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                content(item)
                    .slideIn(delay: Double(index) * 0.05)
            }
        }
    }
}
```

---

## 8. Haptic Feedback System

### The Golden Rules of Haptics

1. **Use semantic feedback types** — Don't use `.impact` when `.success` is appropriate
2. **Never overuse** — Haptics lose meaning if everything vibrates
3. **Match intensity to importance** — Subtle for selections, strong for confirmations
4. **Allow user control** — Respect system settings, offer app toggle

### Feedback Type Guide

```swift
extension View {
    // Selection changed (tabs, options, filters)
    func hapticOnSelection<T: Equatable>(_ value: T) -> some View {
        sensoryFeedback(.selection, trigger: value)
    }

    // Action completed successfully
    func hapticOnSuccess<T: Equatable>(_ value: T) -> some View {
        sensoryFeedback(.success, trigger: value)
    }

    // Something went wrong
    func hapticOnError<T: Equatable>(_ value: T) -> some View {
        sensoryFeedback(.error, trigger: value)
    }

    // Value increased (volume, rating)
    func hapticOnIncrease<T: Equatable>(_ value: T) -> some View {
        sensoryFeedback(.increase, trigger: value)
    }

    // Value decreased
    func hapticOnDecrease<T: Equatable>(_ value: T) -> some View {
        sensoryFeedback(.decrease, trigger: value)
    }

    // Physical impact (button press, card snap)
    func hapticOnImpact<T: Equatable>(_ value: T, intensity: Double = 0.5) -> some View {
        sensoryFeedback(.impact(flexibility: .soft, intensity: intensity), trigger: value)
    }
}
```

### MovieTrailer Haptic Strategy

| Action | Feedback Type | Intensity |
|--------|--------------|-----------|
| Tab selection | `.selection` | Light |
| Card tap | `.impact(soft)` | 0.4 |
| Swipe right (like) | `.success` | Medium |
| Swipe left (skip) | `.impact(rigid)` | 0.3 |
| Swipe up (save) | `.success` | Medium |
| Add to watchlist | `.success` | Medium |
| Remove from watchlist | `.impact(soft)` | 0.3 |
| Error/failure | `.error` | Medium |
| Pull to refresh | `.impact(soft)` | 0.5 |
| Scroll snap | `.selection` | Light |

---

## 9. Component Specifications

### Premium Movie Card

```swift
struct PremiumMovieCard: View {
    let movie: Movie
    let size: CardSize
    let onTap: () -> Void

    @State private var isPressed = false
    @State private var isLoaded = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Poster with glass overlay
                ZStack(alignment: .topTrailing) {
                    // Image
                    AsyncImage(url: movie.posterURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .onAppear { isLoaded = true }
                        case .failure:
                            placeholderView
                        case .empty:
                            placeholderView
                                .liquidShimmer()
                        @unknown default:
                            placeholderView
                        }
                    }
                    .frame(width: size.width, height: size.height)

                    // Rating badge
                    if movie.voteAverage > 0 {
                        ratingBadge
                            .padding(8)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                        .stroke(Color.borderSubtle, lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.3), radius: 12, y: 6)

                // Title
                Text(movie.title)
                    .font(.labelMedium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .frame(width: size.width, alignment: .leading)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isLoaded ? 1 : 0.8)
            .animation(.snappy, value: isPressed)
            .animation(.smooth, value: isLoaded)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }

    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: size.cornerRadius)
            .fill(Color.surfaceGlass)
    }

    private var ratingBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.ratingGold)

            Text(String(format: "%.1f", movie.voteAverage))
                .font(.ratingSmall)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.borderSubtle, lineWidth: 0.5)
        )
    }
}
```

### Liquid Glass Button

```swift
struct LiquidGlassButton: View {
    let title: String
    var icon: String? = nil
    var style: ButtonStyle = .primary
    let action: () -> Void

    enum ButtonStyle {
        case primary    // Filled, prominent
        case secondary  // Glass, subtle
        case ghost      // Text only
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
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(background)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: style == .ghost ? 0 : 0.5)
            )
            .shadow(color: shadowColor, radius: 12, y: 6)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.snappy, value: isPressed)
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
    private var background: some View {
        switch style {
        case .primary:
            Capsule().fill(.white)
        case .secondary:
            ZStack {
                Capsule().fill(.ultraThinMaterial)
                Capsule().fill(LinearGradient.specularHighlight)
            }
        case .ghost:
            Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: return .black
        case .secondary: return .white
        case .ghost: return .accentPrimary
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return .clear
        case .secondary: return .borderMedium
        case .ghost: return .clear
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary: return .white.opacity(0.3)
        case .secondary: return .black.opacity(0.2)
        case .ghost: return .clear
        }
    }
}
```

### Floating Tab Bar

```swift
struct FloatingTabBar: View {
    @Binding var selectedTab: Tab

    enum Tab: String, CaseIterable {
        case home = "house.fill"
        case discover = "sparkles"
        case search = "magnifyingglass"
        case library = "bookmark.fill"
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .stroke(Color.borderSubtle, lineWidth: 0.5)
                )
        }
        .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
        .padding(.horizontal, 60)
    }

    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.snappy) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: tab.rawValue)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(selectedTab == tab ? .white : .textTertiary)
                .frame(width: 50, height: 44)
                .background {
                    if selectedTab == tab {
                        Capsule()
                            .fill(Color.accentPrimary)
                            .matchedGeometryEffect(id: "tab", in: tabNamespace)
                    }
                }
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
    }

    @Namespace private var tabNamespace
}
```

---

## 10. Cinematic Patterns for Media Apps

### Hero Carousel (Apple TV Style)

```swift
struct CinematicHeroCarousel: View {
    let movies: [Movie]

    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0

    private let cardWidth: CGFloat = UIScreen.main.bounds.width - 48
    private let cardSpacing: CGFloat = 16

    var body: some View {
        VStack(spacing: 24) {
            // Cards
            GeometryReader { geometry in
                HStack(spacing: cardSpacing) {
                    ForEach(Array(movies.enumerated()), id: \.element.id) { index, movie in
                        HeroCard(movie: movie)
                            .frame(width: cardWidth)
                            .scaleEffect(scale(for: index))
                            .opacity(opacity(for: index))
                            .zIndex(zIndex(for: index))
                    }
                }
                .offset(x: offsetX)
                .gesture(dragGesture)
                .animation(.cinematic, value: currentIndex)
                .animation(.interactive, value: dragOffset)
            }
            .frame(height: 480)

            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<min(movies.count, 5), id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? Color.white : Color.textTertiary)
                        .frame(width: index == currentIndex ? 24 : 8, height: 8)
                        .animation(.snappy, value: currentIndex)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }

    private var offsetX: CGFloat {
        let baseOffset = -CGFloat(currentIndex) * (cardWidth + cardSpacing)
        return baseOffset + dragOffset + 24 // 24 for leading padding
    }

    private func scale(for index: Int) -> CGFloat {
        let distance = abs(index - currentIndex)
        if distance == 0 { return 1.0 }
        if distance == 1 { return 0.9 }
        return 0.85
    }

    private func opacity(for index: Int) -> Double {
        let distance = abs(index - currentIndex)
        if distance == 0 { return 1.0 }
        if distance == 1 { return 0.6 }
        return 0.3
    }

    private func zIndex(for index: Int) -> Double {
        Double(movies.count - abs(index - currentIndex))
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 50
                if value.translation.width > threshold && currentIndex > 0 {
                    currentIndex -= 1
                } else if value.translation.width < -threshold && currentIndex < movies.count - 1 {
                    currentIndex += 1
                }
                dragOffset = 0
            }
    }
}
```

### Parallax Scroll Header

```swift
struct ParallaxHeader<Content: View>: View {
    let height: CGFloat
    let content: Content

    init(height: CGFloat = 400, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            let minY = geometry.frame(in: .global).minY
            let isScrolledUp = minY > 0

            content
                .frame(
                    width: geometry.size.width,
                    height: isScrolledUp ? height + minY : height
                )
                .offset(y: isScrolledUp ? -minY : 0)
                .scaleEffect(isScrolledUp ? 1 + (minY / 500) : 1, anchor: .bottom)
        }
        .frame(height: height)
    }
}
```

### Focus-Aware Row (tvOS Style)

```swift
struct FocusAwareRow<Item: Identifiable, Content: View>: View {
    let title: String
    let items: [Item]
    let content: (Item, Bool) -> Content

    @State private var focusedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(title)
                    .font(.headline1)
                    .foregroundColor(.textPrimary)

                Spacer()

                if items.count > 5 {
                    Text("See All")
                        .font(.labelMedium)
                        .foregroundColor(.accentPrimary)
                }
            }
            .padding(.horizontal, 20)

            // Scrolling content
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        content(item, focusedIndex == index)
                            .onHover { hovering in
                                withAnimation(.snappy) {
                                    focusedIndex = hovering ? index : nil
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8) // Room for scale effect
            }
        }
    }
}
```

---

## 11. Accessibility Excellence

### VoiceOver Support

```swift
struct AccessibleMovieCard: View {
    let movie: Movie

    var body: some View {
        MovieCard(movie: movie)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint("Double tap to view details")
            .accessibilityAddTraits(.isButton)
            .accessibilityActions {
                Button("Add to Watchlist") {
                    // Add action
                }
                Button("Play Trailer") {
                    // Play action
                }
            }
    }

    private var accessibilityLabel: String {
        var parts = [movie.title]

        parts.append("Rated \(String(format: "%.1f", movie.voteAverage)) out of 10")

        if let year = movie.releaseDate?.prefix(4) {
            parts.append("Released in \(year)")
        }

        if let genres = movie.genreNames?.prefix(2) {
            parts.append(genres.joined(separator: " and "))
        }

        return parts.joined(separator: ". ")
    }
}
```

### Reduce Motion Support

```swift
struct MotionAwareAnimation: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    let animation: Animation
    let reducedAnimation: Animation

    func body(content: Content) -> some View {
        content
            .animation(reduceMotion ? reducedAnimation : animation)
    }
}

extension View {
    func motionAwareAnimation(_ animation: Animation = .smooth) -> some View {
        modifier(MotionAwareAnimation(
            animation: animation,
            reducedAnimation: .easeInOut(duration: 0.1)
        ))
    }
}
```

### Reduce Transparency Support

```swift
struct AdaptiveGlassBackground: View {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    var cornerRadius: CGFloat = 16

    var body: some View {
        Group {
            if reduceTransparency {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.95))
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(LinearGradient.specularHighlight)
                    )
            }
        }
    }
}
```

### Dynamic Type Support

```swift
extension View {
    func scaledPadding(_ edges: Edge.Set = .all, _ length: CGFloat) -> some View {
        self.modifier(ScaledPaddingModifier(edges: edges, length: length))
    }
}

struct ScaledPaddingModifier: ViewModifier {
    @ScaledMetric var scaledLength: CGFloat
    let edges: Edge.Set

    init(edges: Edge.Set, length: CGFloat) {
        self.edges = edges
        _scaledLength = ScaledMetric(wrappedValue: length)
    }

    func body(content: Content) -> some View {
        content.padding(edges, scaledLength)
    }
}
```

---

## 12. Performance Optimization

### Image Loading Best Practices

```swift
// Use Kingfisher with proper configuration
let imageModifier = AnyModifier { request in
    var r = request
    r.cachePolicy = .returnCacheDataElseLoad
    return r
}

KFImage(movie.posterURL)
    .requestModifier(imageModifier)
    .loadDiskFileSynchronously() // Faster disk cache reads
    .cacheMemoryOnly() // For thumbnails
    .fade(duration: 0.25) // Smooth appearance
    .placeholder {
        PlaceholderView()
            .liquidShimmer()
    }
    .resizable()
    .aspectRatio(contentMode: .fill)
```

### Lazy Loading Strategy

```swift
struct OptimizedMovieGrid: View {
    let movies: [Movie]

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 16)],
                spacing: 20
            ) {
                ForEach(movies) { movie in
                    MovieCard(movie: movie)
                        .onAppear {
                            prefetchNearbyImages(for: movie)
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    private func prefetchNearbyImages(for movie: Movie) {
        guard let index = movies.firstIndex(where: { $0.id == movie.id }) else { return }

        let prefetchRange = max(0, index - 2)...min(movies.count - 1, index + 10)
        let urls = prefetchRange.compactMap { movies[$0].posterURL }

        ImagePrefetcher(urls: urls).start()
    }
}
```

### Drawing Performance

```swift
// Use drawingGroup() for complex glass effects
struct PerformantGlassCard: View {
    var body: some View {
        ZStack {
            // Complex blur stack
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)

            LinearGradient.specularHighlight

            // Content
            VStack { ... }
        }
        .drawingGroup() // Rasterizes to single layer
    }
}
```

---

## 13. Implementation Checklist

### Phase 1: Foundation (Week 1-2)
- [ ] Create `DesignSystem/` folder structure
- [ ] Implement color tokens and extensions
- [ ] Set up typography scale
- [ ] Define spacing constants
- [ ] Create animation presets

### Phase 2: Core Components (Week 3-4)
- [ ] Build `LiquidGlassButton`
- [ ] Build `PremiumMovieCard`
- [ ] Build `FloatingTabBar`
- [ ] Build `AdaptiveGlassBackground`
- [ ] Add shimmer loading states

### Phase 3: Micro-Interactions (Week 5-6)
- [ ] Implement tap pop effect
- [ ] Add hover lift for cards
- [ ] Create slide-in animations
- [ ] Add staggered list entrance
- [ ] Implement haptic feedback system

### Phase 4: Cinematic Features (Week 7-8)
- [ ] Build hero carousel
- [ ] Implement parallax scroll
- [ ] Add matched geometry transitions
- [ ] Create focus-aware rows
- [ ] Polish swipe card physics

### Phase 5: Polish & QA (Week 9-10)
- [ ] Accessibility audit (VoiceOver, Dynamic Type)
- [ ] Performance profiling with Instruments
- [ ] Reduce Motion / Transparency testing
- [ ] Edge case handling
- [ ] Final visual polish pass

---

## 14. Maximizing TMDB API Capabilities

Your app currently uses only a fraction of what TMDB offers. Here's a comprehensive analysis of what you have vs. what you're missing.

### Current Implementation vs. Full Potential

| Feature | Current Status | Potential |
|---------|---------------|-----------|
| Trending/Popular/Now Playing | ✅ Implemented | — |
| Movie Details | ✅ Basic | 🚀 Can get runtime, budget, revenue, tagline |
| Watch Providers | ✅ Implemented | — |
| Videos/Trailers | ✅ Implemented | — |
| Similar/Recommendations | ✅ Implemented | — |
| **Credits (Cast/Crew)** | ❌ Missing | 🚀 Full cast with photos, director, writer |
| **Person Details** | ❌ Missing | 🚀 Actor bios, filmography, known for |
| **Reviews** | ❌ Missing | 🚀 User reviews from TMDB |
| **Keywords** | ❌ Missing | 🚀 Better discovery, "movies like this" |
| **Collections** | ❌ Missing | 🚀 Movie series (Marvel, Star Wars, etc.) |
| **Images Gallery** | ❌ Missing | 🚀 Posters, backdrops, stills |
| **Release Dates by Country** | ❌ Missing | 🚀 Localized release info |
| **Certifications** | ❌ Missing | 🚀 Age ratings (PG-13, R, etc.) |
| **External IDs** | ❌ Missing | 🚀 Link to IMDb, social media |
| **Multi-Search** | ❌ Missing | 🚀 Search movies, TV, people in one query |
| **Advanced Discover Filters** | ⚠️ Partial | 🚀 30+ filter options available |

### 14.1 The `append_to_response` Superpower

**Current**: Making separate API calls for each piece of data.

**Better**: Get everything in ONE request using `append_to_response`.

```swift
// CURRENT: Multiple requests
let movie = try await fetchMovieDetails(id: movieId)
let videos = try await fetchVideos(for: movieId)
let similar = try await fetchSimilarMovies(for: movieId)
// 3 API calls = 3× latency

// BETTER: Single request with append_to_response
case .movieDetailsFull(let id):
    return "/movie/\(id)"

// With query params:
// append_to_response=credits,videos,similar,recommendations,keywords,reviews,images,release_dates

// 1 API call = 1× latency, same data!
```

#### New Endpoint Definition

```swift
enum TMDBEndpoint {
    // ... existing cases ...

    /// Full movie details with all related data in one request
    case movieDetailsFull(id: Int)

    /// Person (actor/director) details with filmography
    case personDetails(id: Int)

    /// Person filmography (combined movie + TV credits)
    case personCredits(id: Int)

    /// Movie collection (franchise like Marvel, Star Wars)
    case collection(id: Int)

    /// Multi-search (movies, TV, people in one query)
    case multiSearch(query: String, page: Int)

    /// Advanced discover with all filters
    case discoverAdvanced(filters: DiscoverFilters)

    /// Movie images (posters, backdrops, stills)
    case movieImages(id: Int)

    /// Movie reviews
    case movieReviews(id: Int, page: Int)
}

// Query parameters for full movie details
case .movieDetailsFull(let id):
    items.append(URLQueryItem(
        name: "append_to_response",
        value: "credits,videos,similar,recommendations,keywords,reviews,images,release_dates,external_ids"
    ))
```

### 14.2 Cast & Crew Features

**Why it matters**: Users want to see who's in a movie and explore actor filmographies.

```swift
// MARK: - Cast & Crew Models

struct Credits: Codable {
    let cast: [CastMember]
    let crew: [CrewMember]

    var director: CrewMember? {
        crew.first { $0.job == "Director" }
    }

    var writers: [CrewMember] {
        crew.filter { $0.department == "Writing" }
    }

    var topBilledCast: [CastMember] {
        Array(cast.prefix(10))
    }
}

struct CastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int

    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }
}

struct CrewMember: Codable, Identifiable {
    let id: Int
    let name: String
    let job: String
    let department: String
    let profilePath: String?
}
```

#### Cast UI Component

```swift
struct CastRow: View {
    let cast: [CastMember]
    let onPersonTap: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cast")
                .font(.headline1)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(cast) { member in
                        CastCard(member: member) {
                            onPersonTap(member.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct CastCard: View {
    let member: CastMember
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Profile image
                AsyncImage(url: member.profileURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.surfaceGlass)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.textTertiary)
                        )
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.borderSubtle, lineWidth: 1))

                // Name
                Text(member.name)
                    .font(.labelMedium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                // Character
                Text(member.character)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                    .lineLimit(1)
            }
            .frame(width: 90)
        }
        .buttonStyle(.plain)
    }
}
```

### 14.3 Person/Actor Detail Screen

**New Feature**: Tap on any cast member to see their full profile and filmography.

```swift
// MARK: - Person Models

struct Person: Codable, Identifiable {
    let id: Int
    let name: String
    let biography: String?
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let profilePath: String?
    let knownForDepartment: String?
    let popularity: Double

    // From append_to_response=combined_credits
    let combinedCredits: CombinedCredits?

    // From append_to_response=images
    let images: PersonImages?

    // From append_to_response=external_ids
    let externalIds: ExternalIds?

    var age: Int? {
        guard let birthday = birthday else { return nil }
        // Calculate age from birthday
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let birthDate = formatter.date(from: birthday) else { return nil }

        let endDate = deathday.flatMap { formatter.date(from: $0) } ?? Date()
        let components = Calendar.current.dateComponents([.year], from: birthDate, to: endDate)
        return components.year
    }

    var topMovies: [Movie] {
        combinedCredits?.cast
            .filter { $0.mediaType == "movie" }
            .sorted { ($0.popularity ?? 0) > ($1.popularity ?? 0) }
            .prefix(10)
            .compactMap { $0.asMovie } ?? []
    }
}

struct CombinedCredits: Codable {
    let cast: [CreditItem]
    let crew: [CreditItem]
}

struct CreditItem: Codable {
    let id: Int
    let title: String?        // For movies
    let name: String?         // For TV shows
    let mediaType: String     // "movie" or "tv"
    let character: String?
    let job: String?          // For crew
    let posterPath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let voteAverage: Double?
    let popularity: Double?
}

struct ExternalIds: Codable {
    let imdbId: String?
    let instagramId: String?
    let twitterId: String?
    let facebookId: String?
}
```

#### Person Detail View

```swift
struct PersonDetailView: View {
    let personId: Int
    @StateObject private var viewModel: PersonDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero section with photo and basic info
                personHeader

                // Biography
                if let bio = viewModel.person?.biography, !bio.isEmpty {
                    biographySection(bio)
                }

                // Known For / Top Movies
                if !viewModel.topMovies.isEmpty {
                    knownForSection
                }

                // Full Filmography
                if !viewModel.filmography.isEmpty {
                    filmographySection
                }

                // Social Links
                if let externalIds = viewModel.person?.externalIds {
                    socialLinksSection(externalIds)
                }
            }
        }
        .background(Color.backgroundPrimary)
    }

    private var personHeader: some View {
        HStack(alignment: .top, spacing: 20) {
            // Profile photo
            AsyncImage(url: viewModel.person?.profileURL) { ... }
                .frame(width: 120, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.person?.name ?? "")
                    .font(.displayMedium)
                    .foregroundColor(.textPrimary)

                if let department = viewModel.person?.knownForDepartment {
                    Text(department)
                        .font(.labelLarge)
                        .foregroundColor(.textSecondary)
                }

                if let age = viewModel.person?.age {
                    Text("\(age) years old")
                        .font(.labelMedium)
                        .foregroundColor(.textTertiary)
                }

                if let birthplace = viewModel.person?.placeOfBirth {
                    Text(birthplace)
                        .font(.labelSmall)
                        .foregroundColor(.textTertiary)
                }
            }

            Spacer()
        }
        .padding(20)
    }
}
```

### 14.4 Movie Collections (Franchises)

**New Feature**: Show related movies in a franchise (Marvel Cinematic Universe, Harry Potter, etc.)

```swift
struct MovieCollection: Codable, Identifiable {
    let id: Int
    let name: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let parts: [Movie]

    var sortedParts: [Movie] {
        parts.sorted {
            ($0.releaseDate ?? "") < ($1.releaseDate ?? "")
        }
    }
}

// UI Component
struct CollectionBanner: View {
    let collection: MovieCollection
    let onMovieTap: (Movie) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Part of \(collection.name)")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(collection.parts.count) movies")
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 20)

            // Collection movies
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(collection.sortedParts) { movie in
                        CollectionMovieCard(movie: movie) {
                            onMovieTap(movie)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [.clear, Color.accentPrimary.opacity(0.1), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
```

### 14.5 Advanced Discover Filters

**Current**: Basic genre/year/rating filters.

**Better**: Full power of TMDB's 30+ discover filters.

```swift
struct DiscoverFilters {
    // Sorting
    var sortBy: SortOption = .popularityDesc

    // Release dates
    var releaseDateFrom: Date?
    var releaseDateTo: Date?

    // Ratings
    var minRating: Double?
    var maxRating: Double?
    var minVoteCount: Int = 50

    // Genres
    var includeGenres: [Int] = []
    var excludeGenres: [Int] = []

    // People
    var withCast: [Int] = []        // Actor IDs
    var withCrew: [Int] = []        // Director/Writer IDs

    // Other
    var withKeywords: [Int] = []
    var withoutKeywords: [Int] = []
    var withCompanies: [Int] = []   // Production companies
    var withWatchProviders: [Int] = [] // Streaming services
    var watchRegion: String = "US"

    // Content
    var includeAdult: Bool = false
    var includeVideo: Bool = true

    // Language/Region
    var language: String = "en-US"
    var region: String?
    var originalLanguage: String?

    enum SortOption: String {
        case popularityDesc = "popularity.desc"
        case popularityAsc = "popularity.asc"
        case releaseDateDesc = "release_date.desc"
        case releaseDateAsc = "release_date.asc"
        case revenueDesc = "revenue.desc"
        case voteAverageDesc = "vote_average.desc"
        case voteCountDesc = "vote_count.desc"
    }
}
```

#### Smart Discovery Features

```swift
// "Movies like this" using keywords
func fetchMoviesLikeThis(movieId: Int) async throws -> [Movie] {
    // 1. Get keywords for the source movie
    let keywords = try await fetchKeywords(for: movieId)

    // 2. Discover movies with same keywords
    let filters = DiscoverFilters(
        withKeywords: keywords.map(\.id),
        minVoteCount: 100,
        sortBy: .popularityDesc
    )

    return try await discoverMovies(filters: filters)
}

// "Movies by this director"
func fetchMoviesByDirector(personId: Int) async throws -> [Movie] {
    let filters = DiscoverFilters(
        withCrew: [personId],
        sortBy: .releaseDateDesc
    )
    return try await discoverMovies(filters: filters)
}

// "Movies on Netflix"
func fetchMoviesOnNetflix() async throws -> [Movie] {
    let filters = DiscoverFilters(
        withWatchProviders: [8], // Netflix provider ID
        watchRegion: "US",
        sortBy: .popularityDesc
    )
    return try await discoverMovies(filters: filters)
}

// "Hidden gems" (high rated, low popularity)
func fetchHiddenGems() async throws -> [Movie] {
    let filters = DiscoverFilters(
        minRating: 7.5,
        minVoteCount: 100,
        maxVoteCount: 1000, // Not too popular
        sortBy: .voteAverageDesc
    )
    return try await discoverMovies(filters: filters)
}
```

### 14.6 Reviews Integration

```swift
struct Review: Codable, Identifiable {
    let id: String
    let author: String
    let authorDetails: AuthorDetails?
    let content: String
    let createdAt: String
    let updatedAt: String
    let url: String

    struct AuthorDetails: Codable {
        let name: String?
        let username: String
        let avatarPath: String?
        let rating: Double?
    }
}

// UI Component
struct ReviewCard: View {
    let review: Review
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author header
            HStack {
                // Avatar
                AsyncImage(url: review.authorDetails?.avatarURL) { ... }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(review.author)
                        .font(.labelLarge)
                        .foregroundColor(.textPrimary)

                    if let rating = review.authorDetails?.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.ratingGold)
                            Text("\(Int(rating))/10")
                        }
                        .font(.labelSmall)
                        .foregroundColor(.textSecondary)
                    }
                }

                Spacer()

                Text(review.formattedDate)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }

            // Review content
            Text(review.content)
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
                .lineLimit(isExpanded ? nil : 4)

            // Expand button
            if review.content.count > 200 {
                Button {
                    withAnimation(.smooth) {
                        isExpanded.toggle()
                    }
                } label: {
                    Text(isExpanded ? "Show less" : "Read more")
                        .font(.labelMedium)
                        .foregroundColor(.accentPrimary)
                }
            }
        }
        .padding(16)
        .background(Color.surfaceGlass)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
```

### 14.7 External Links & Social

```swift
struct ExternalLinksSection: View {
    let externalIds: ExternalIds
    let homepage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Links")
                .font(.headline2)
                .foregroundColor(.textPrimary)

            HStack(spacing: 16) {
                if let imdb = externalIds.imdbId {
                    ExternalLinkButton(
                        icon: "film",
                        label: "IMDb",
                        url: "https://www.imdb.com/title/\(imdb)"
                    )
                }

                if let homepage = homepage {
                    ExternalLinkButton(
                        icon: "globe",
                        label: "Website",
                        url: homepage
                    )
                }

                if let instagram = externalIds.instagramId {
                    ExternalLinkButton(
                        icon: "camera",
                        label: "Instagram",
                        url: "https://instagram.com/\(instagram)"
                    )
                }

                if let twitter = externalIds.twitterId {
                    ExternalLinkButton(
                        icon: "at",
                        label: "Twitter",
                        url: "https://twitter.com/\(twitter)"
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}
```

### 14.8 New Feature Ideas Using TMDB

| Feature | TMDB Endpoints | User Value |
|---------|---------------|------------|
| **"Because you liked X"** | `/movie/{id}/recommendations` + ML | Personalized suggestions |
| **Actor Filmography** | `/person/{id}?append_to_response=combined_credits` | Explore actor's work |
| **Franchise Collections** | `/collection/{id}` | Watch movies in order |
| **Where to Stream** | `/movie/{id}/watch/providers` | Find streaming options |
| **Behind the Scenes** | `/movie/{id}/images`, `/movie/{id}/videos` | Exclusive content |
| **User Reviews** | `/movie/{id}/reviews` | Community opinions |
| **Related by Theme** | `/movie/{id}/keywords` + `/discover` | "Movies like this" |
| **Coming Soon Alerts** | `/movie/upcoming` + local notifications | Don't miss releases |
| **Award Winners** | `/discover` with vote filters | Quality content |
| **Director's Cut** | `/person/{id}/movie_credits` | Explore filmmakers |

### 14.9 API Call Optimization

```swift
// BEFORE: 5 separate API calls
async func loadMovieDetail(id: Int) {
    movie = try await service.fetchMovieDetails(id: id)      // Call 1
    videos = try await service.fetchVideos(for: id)          // Call 2
    similar = try await service.fetchSimilarMovies(for: id)  // Call 3
    credits = try await service.fetchCredits(for: id)        // Call 4
    providers = try await service.fetchWatchProviders(for: id) // Call 5
}
// Total: 5 round trips, ~500-1500ms

// AFTER: 1 API call with append_to_response
async func loadMovieDetailOptimized(id: Int) {
    let fullMovie = try await service.fetchMovieDetailsFull(id: id)
    // Everything included: credits, videos, similar, keywords, reviews, etc.
}
// Total: 1 round trip, ~100-300ms

// Endpoint with append_to_response
case .movieDetailsFull(let id):
    var items = baseQueryItems
    items.append(URLQueryItem(
        name: "append_to_response",
        value: [
            "credits",
            "videos",
            "similar",
            "recommendations",
            "keywords",
            "reviews",
            "images",
            "release_dates",
            "watch/providers",
            "external_ids"
        ].joined(separator: ",")
    ))
    return items
```

### 14.10 Implementation Priority

#### Phase 1: High Impact, Low Effort
1. ✅ Add `append_to_response` to movie details (saves API calls)
2. ✅ Add credits/cast display to movie detail
3. ✅ Add certifications/age ratings

#### Phase 2: Medium Effort, High Value
4. Add person detail screen with filmography
5. Add movie collections (franchises)
6. Add reviews section

#### Phase 3: Advanced Features
7. Smart discovery ("movies like this")
8. Advanced filter UI
9. External links integration
10. Image galleries

---

## Sources & References

### Apple Design Resources
- [Apple's Liquid Glass Design Announcement](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [Apple Human Interface Guidelines - Typography](https://developer.apple.com/design/human-interface-guidelines/typography)
- [Apple Human Interface Guidelines - Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- [WWDC25: Get to Know the New Design System](https://developer.apple.com/videos/play/wwdc2025/356/)
- [Designing for tvOS - Apple HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-tvos)

### SwiftUI & Animation
- [Micro-Interactions in SwiftUI - DEV Community](https://dev.to/sebastienlato/micro-interactions-in-swiftui-subtle-animations-that-make-apps-feel-premium-2ldn)
- [SwiftUI Animation Masterclass - DEV Community](https://dev.to/sebastienlato/swiftui-animation-masterclass-springs-curves-smooth-motion-3e4o)
- [SwiftUI Sensory Feedback Guide](https://swiftwithmajid.com/2023/10/10/sensory-feedback-in-swiftui/)
- [iOS App Design Guidelines 2025 - Tapptitude](https://tapptitude.com/blog/i-os-app-design-guidelines-for-2025)
- [KaxhyapUI Repository](https://github.com/bestfriendai/KaxhyapUI)

### TMDB API Documentation
- [TMDB API - Getting Started](https://developer.themoviedb.org/reference/intro/getting-started)
- [TMDB Discover Endpoint](https://developer.themoviedb.org/reference/discover-movie)
- [TMDB Append to Response](https://developer.themoviedb.org/docs/append-to-response)
- [TMDB Movie Credits](https://developer.themoviedb.org/reference/movie-credits)
- [TMDB Watch Providers](https://developer.themoviedb.org/reference/movie-watch-providers)
- [TMDB Recommendations](https://developer.themoviedb.org/reference/movie-recommendations)

---

*Document Version 3.0 — December 29, 2025*
*For MovieTrailer iOS App — Premium UI/UX Enhancement & TMDB API Optimization*
