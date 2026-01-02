//
//  SwipeTutorialOverlay.swift
//  MovieTrailer
//

import SwiftUI

struct SwipeTutorialOverlay: View {
    @Binding var hasSeenTutorial: Bool
    @State private var currentStep = 0
    @State private var showingAnimation = false

    private let tutorialSteps: [TutorialStep] = [
        TutorialStep(
            icon: "arrow.left",
            title: "Swipe Left",
            subtitle: "Skip",
            description: "Not interested? Swipe left to skip.",
            color: .red
        ),
        TutorialStep(
            icon: "heart.fill",
            title: "Swipe Right",
            subtitle: "Love",
            description: "Found something great? Swipe right to love it!",
            color: .green
        ),
        TutorialStep(
            icon: "bookmark.fill",
            title: "Swipe Up",
            subtitle: "Save for Later",
            description: "Want to watch it later? Swipe up to save.",
            color: .cyan
        )
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("How to Discover")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                TabView(selection: $currentStep) {
                    ForEach(0..<tutorialSteps.count, id: \.self) { index in
                        TutorialStepView(step: tutorialSteps[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 280)

                HStack(spacing: 8) {
                    ForEach(0..<tutorialSteps.count, id: \.self) { index in
                        Circle()
                            .fill(currentStep == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentStep)
                    }
                }

                VStack(spacing: 16) {
                    if currentStep < tutorialSteps.count - 1 {
                        Button {
                            withAnimation(.spring(response: 0.4)) {
                                currentStep += 1
                            }
                        } label: {
                            Text("Next")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 40)

                        Button {
                            dismissTutorial()
                        } label: {
                            Text("Skip Tutorial")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    } else {
                        Button {
                            dismissTutorial()
                        } label: {
                            Text("Start Swiping!")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 40)
                    }
                }
            }
            .padding(.vertical, 60)
        }
        .transition(.opacity)
    }

    private func dismissTutorial() {
        Haptics.shared.success()
        withAnimation(.spring(response: 0.4)) {
            hasSeenTutorial = true
            UserDefaults.standard.set(true, forKey: "hasSeenSwipeTutorial")
        }
    }
}

// MARK: - Tutorial Step Model

struct TutorialStep {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let color: Color
}

// MARK: - Tutorial Step View

struct TutorialStepView: View {
    let step: TutorialStep
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(step.color.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)

                Circle()
                    .fill(step.color.opacity(0.25))
                    .frame(width: 90, height: 90)

                Image(systemName: step.icon)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(step.color)
                    .offset(x: animationOffset.width, y: animationOffset.height)
            }
            .animation(
                .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                value: isAnimating
            )

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text(step.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("→")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))

                    Text(step.subtitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(step.color)
                }

                Text(step.description)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }

    private var animationOffset: CGSize {
        guard isAnimating else { return .zero }

        switch step.icon {
        case "arrow.left":
            return CGSize(width: -15, height: 0)
        case "heart.fill":
            return CGSize(width: 15, height: 0)
        case "bookmark.fill":
            return CGSize(width: 0, height: -15)
        default:
            return .zero
        }
    }
}

// MARK: - Gesture Demo View

struct TutorialGestureDemo: View {
    let direction: SwipeDirection
    @State private var offset: CGSize = .zero
    @State private var isAnimating = false

    enum SwipeDirection {
        case left, right, up

        var icon: String {
            switch self {
            case .left: return "xmark"
            case .right: return "heart.fill"
            case .up: return "bookmark.fill"
            }
        }

        var color: Color {
            switch self {
            case .left: return .red
            case .right: return .green
            case .up: return .cyan
            }
        }

        var label: String {
            switch self {
            case .left: return "Skip"
            case .right: return "Love"
            case .up: return "Later"
            }
        }

        var animationOffset: CGSize {
            switch self {
            case .left: return CGSize(width: -30, height: 0)
            case .right: return CGSize(width: 30, height: 0)
            case .up: return CGSize(width: 0, height: -30)
            }
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(direction.color.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: direction.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(direction.color)
            }
            .offset(offset)
            .animation(
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                value: isAnimating
            )

            Text(direction.label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
        .onAppear {
            offset = direction.animationOffset
            isAnimating = true
        }
    }
}
