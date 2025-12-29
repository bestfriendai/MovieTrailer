//
//  PremiumRefreshable.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Premium pull-to-refresh with custom animations
//

import SwiftUI

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Premium Refreshable Modifier

struct PremiumRefreshableModifier: ViewModifier {
    let action: () async -> Void
    let tintColor: Color
    let threshold: CGFloat

    @State private var pullOffset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var rotationAngle: Double = 0

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    init(
        tintColor: Color = .white,
        threshold: CGFloat = 80,
        action: @escaping () async -> Void
    ) {
        self.tintColor = tintColor
        self.threshold = threshold
        self.action = action
    }

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Refresh indicator
                refreshIndicator
                    .offset(y: indicatorOffset)
                    .opacity(indicatorOpacity)

                // Content with offset tracking
                content
                    .offset(y: isRefreshing ? 60 : 0)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: proxy.frame(in: .named("refreshScroll")).minY
                            )
                        }
                    )
            }
            .coordinateSpace(name: "refreshScroll")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                guard !isRefreshing else { return }
                pullOffset = max(0, value)

                // Update rotation based on pull
                if !reduceMotion {
                    rotationAngle = Double(pullOffset) * 3
                }

                // Trigger refresh at threshold
                if pullOffset > threshold {
                    triggerRefresh()
                }
            }
        }
    }

    // MARK: - Refresh Indicator

    private var refreshIndicator: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(tintColor.opacity(0.2), lineWidth: 3)
                    .frame(width: 36, height: 36)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progressAmount)
                    .stroke(
                        AngularGradient(
                            colors: [tintColor, tintColor.opacity(0.5), tintColor],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(-90))
                    .rotationEffect(.degrees(isRefreshing ? 360 : rotationAngle))
                    .animation(
                        isRefreshing
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .none,
                        value: isRefreshing
                    )

                // Center icon
                if isRefreshing {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(tintColor)
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(
                            .linear(duration: 1).repeatForever(autoreverses: false),
                            value: isRefreshing
                        )
                } else if pullOffset > threshold * 0.5 {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(tintColor)
                        .rotationEffect(.degrees(pullOffset > threshold ? 180 : 0))
                        .animation(.spring(response: 0.3), value: pullOffset > threshold)
                }
            }

            // Status text
            if pullOffset > threshold * 0.3 {
                Text(statusText)
                    .font(.caption.weight(.medium))
                    .foregroundColor(tintColor.opacity(0.8))
                    .transition(.opacity)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .opacity(pullOffset > 20 ? 1 : 0)
        )
    }

    // MARK: - Computed Properties

    private var indicatorOffset: CGFloat {
        if isRefreshing {
            return 20
        }
        return min(pullOffset - 60, 40)
    }

    private var indicatorOpacity: Double {
        if isRefreshing {
            return 1
        }
        return min(1, Double(pullOffset) / 60)
    }

    private var progressAmount: CGFloat {
        if isRefreshing {
            return 0.8
        }
        return min(1, pullOffset / threshold)
    }

    private var statusText: String {
        if isRefreshing {
            return "Updating..."
        }
        if pullOffset > threshold {
            return "Release to refresh"
        }
        return "Pull to refresh"
    }

    // MARK: - Actions

    private func triggerRefresh() {
        guard !isRefreshing else { return }

        Haptics.shared.mediumImpact()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isRefreshing = true
        }

        Task {
            await action()

            await MainActor.run {
                Haptics.shared.success()

                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isRefreshing = false
                    pullOffset = 0
                }
            }
        }
    }
}

extension View {
    func premiumRefreshable(
        tintColor: Color = .white,
        threshold: CGFloat = 80,
        action: @escaping () async -> Void
    ) -> some View {
        modifier(PremiumRefreshableModifier(
            tintColor: tintColor,
            threshold: threshold,
            action: action
        ))
    }
}

// MARK: - Liquid Pull Indicator

struct LiquidPullIndicator: View {
    let progress: CGFloat
    let isRefreshing: Bool
    let color: Color

    @State private var wavePhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Liquid blob
            WaveShape(phase: wavePhase, amplitude: 10 * progress)
                .fill(color.opacity(0.3))
                .frame(height: 60 * progress)
                .blur(radius: 2)

            // Icon
            Image(systemName: isRefreshing ? "arrow.triangle.2.circlepath" : "arrow.down")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(color)
                .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                .animation(
                    isRefreshing
                        ? .linear(duration: 1).repeatForever(autoreverses: false)
                        : .spring(),
                    value: isRefreshing
                )
                .offset(y: -20 * progress)
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
}

// MARK: - Wave Shape

struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(phase, amplitude) }
        set {
            phase = newValue.first
            amplitude = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let wavelength = rect.width / 2
        let midHeight = rect.height / 2

        path.move(to: CGPoint(x: 0, y: rect.height))

        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / wavelength
            let y = midHeight + amplitude * sin(relativeX * .pi * 2 + phase)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Minimal Refresh Indicator

struct MinimalRefreshIndicator: View {
    let isRefreshing: Bool
    let progress: CGFloat

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isRefreshing ? 1 : progress * 0.5)
                    .opacity(isRefreshing ? 1 : Double(progress))
                    .animation(
                        isRefreshing
                            ? .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.15)
                            : .spring(),
                        value: isRefreshing
                    )
            }
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Preview

#if DEBUG
struct PremiumRefreshable_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10) { index in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.surfaceSecondary)
                        .frame(height: 100)
                        .overlay(
                            Text("Item \(index + 1)")
                                .foregroundColor(.textSecondary)
                        )
                }
            }
            .padding()
        }
        .premiumRefreshable {
            try? await Task.sleep(for: .seconds(2))
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
