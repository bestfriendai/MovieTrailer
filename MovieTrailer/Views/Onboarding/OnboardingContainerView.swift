//
//  OnboardingContainerView.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Main container for the onboarding flow
//

import SwiftUI

struct OnboardingContainerView: View {

    @StateObject private var coordinator: OnboardingCoordinator
    @Environment(\.dismiss) private var dismiss

    init(onComplete: @escaping () -> Void) {
        let coordinator = OnboardingCoordinator()
        coordinator.onComplete = onComplete
        _coordinator = StateObject(wrappedValue: coordinator)
    }

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            // Animated gradient background
            AnimatedGradientBackground()

            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                    .padding(.top, 16)

                // Content
                TabView(selection: $coordinator.currentStep) {
                    WelcomeStepView(coordinator: coordinator)
                        .tag(OnboardingStep.welcome)

                    FeaturesStepView(coordinator: coordinator)
                        .tag(OnboardingStep.features)

                    StreamingSetupStepView(coordinator: coordinator)
                        .tag(OnboardingStep.streamingServices)

                    AuthenticationStepView(coordinator: coordinator)
                        .tag(OnboardingStep.authentication)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: coordinator.currentStep)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingStep.allCases, id: \.rawValue) { step in
                Capsule()
                    .fill(step.rawValue <= coordinator.currentStep.rawValue ? Color.white : Color.white.opacity(0.3))
                    .frame(width: step == coordinator.currentStep ? 24 : 8, height: 4)
                    .animation(.spring(response: 0.3), value: coordinator.currentStep)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Animated Gradient Background

private struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.05, blue: 0.2),
                Color.black,
                Color(red: 0.05, green: 0.1, blue: 0.15)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // App icon / logo
            VStack(spacing: 24) {
                Image(systemName: "film.stack.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .purple.opacity(0.5), radius: 20)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                VStack(spacing: 12) {
                    Text("MovieTrailer")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Discover movies you'll love")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }

            Spacer()

            // Features preview
            VStack(spacing: 16) {
                FeatureRow(icon: "hand.draw.fill", title: "Swipe to Discover", subtitle: "Find your next favorite movie")
                FeatureRow(icon: "bookmark.fill", title: "Build Your Watchlist", subtitle: "Never forget what to watch")
                FeatureRow(icon: "play.circle.fill", title: "Watch Trailers", subtitle: "Preview before you commit")
            }
            .padding(.horizontal, 32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)

            Spacer()

            // Continue button
            Button {
                coordinator.next()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.cyan)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
    }
}

// MARK: - Features Step

struct FeaturesStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @State private var currentFeature = 0

    private let features = [
        ("hand.draw.fill", "Swipe Right", "Like movies you want to watch", Color.green),
        ("hand.point.left.fill", "Swipe Left", "Skip movies that don't interest you", Color.red),
        ("hand.point.up.fill", "Swipe Up", "Super like your must-watch movies", Color.yellow)
    ]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Swipe demo
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    DemoCard(index: index, currentFeature: currentFeature)
                }
            }
            .frame(height: 300)

            // Feature description
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: features[currentFeature].0)
                        .font(.title)
                        .foregroundColor(features[currentFeature].3)

                    Text(features[currentFeature].1)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }

                Text(features[currentFeature].2)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
            }
            .animation(.easeInOut, value: currentFeature)

            // Feature dots
            HStack(spacing: 8) {
                ForEach(0..<features.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentFeature ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Spacer()

            // Navigation buttons
            HStack(spacing: 16) {
                Button {
                    coordinator.back()
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.vertical, 18)
                        .padding(.horizontal, 32)
                }

                Button {
                    if currentFeature < features.count - 1 {
                        withAnimation {
                            currentFeature += 1
                        }
                    } else {
                        coordinator.next()
                    }
                } label: {
                    Text(currentFeature < features.count - 1 ? "Next" : "Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

private struct DemoCard: View {
    let index: Int
    let currentFeature: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                VStack {
                    Image(systemName: "film")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.3))
                }
            )
            .frame(width: 220, height: 300)
            .rotation3DEffect(
                .degrees(Double(index - 1) * 5),
                axis: (x: 0, y: 1, z: 0)
            )
            .offset(x: CGFloat(index - 1) * 20)
            .scaleEffect(index == 1 ? 1 : 0.9)
            .opacity(index == 1 ? 1 : 0.5)
    }
}

// MARK: - Streaming Setup Step

struct StreamingSetupStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Text("Your Streaming Services")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("Select the platforms you use to personalize your recommendations")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)

            // Services grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(StreamingService.allCases) { service in
                        StreamingServiceButton(
                            service: service,
                            isSelected: coordinator.selectedStreamingServices.contains(service)
                        ) {
                            coordinator.toggleStreamingService(service)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            // Selection info
            if !coordinator.selectedStreamingServices.isEmpty {
                Text("\(coordinator.selectedStreamingServices.count) service\(coordinator.selectedStreamingServices.count == 1 ? "" : "s") selected")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Navigation buttons
            HStack(spacing: 16) {
                Button {
                    coordinator.back()
                } label: {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.vertical, 18)
                        .padding(.horizontal, 32)
                }

                Button {
                    coordinator.next()
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

private struct StreamingServiceButton: View {
    let service: StreamingService
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? service.brandColor : Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)

                    Image(systemName: service.iconName)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                }

                Text(service.displayName)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? service.brandColor : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Authentication Step

struct AuthenticationStepView: View {
    @ObservedObject var coordinator: OnboardingCoordinator
    @ObservedObject private var authManager = AuthenticationManager.shared
    @State private var showEmailSignIn = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Header
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Create an Account")
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text("Sign in to sync your watchlist and preferences across devices")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Sign in options
            VStack(spacing: 12) {
                // Apple Sign In
                Button {
                    Task {
                        await coordinator.signInWithApple()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "apple.logo")
                            .font(.title3)
                        Text("Continue with Apple")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                // Google Sign In
                Button {
                    Task {
                        await coordinator.signInWithGoogle()
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "g.circle.fill")
                            .font(.title3)
                        Text("Continue with Google")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }

                // Email Sign In
                Button {
                    showEmailSignIn = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .font(.title3)
                        Text("Continue with Email")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            .disabled(authManager.isLoading)
            .opacity(authManager.isLoading ? 0.6 : 1)

            // Loading indicator
            if authManager.isLoading {
                ProgressView()
                    .tint(.white)
                    .padding()
            }

            // Error message
            if let error = authManager.error {
                Text(error.errorDescription ?? "An error occurred")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            Spacer()

            // Skip / Continue as guest
            VStack(spacing: 16) {
                Button {
                    coordinator.back()
                } label: {
                    Text("Back")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }

                Button {
                    Task {
                        await coordinator.continueAsGuest()
                    }
                } label: {
                    Text("Continue without an account")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .underline()
                }
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView { success in
                if success {
                    showEmailSignIn = false
                    coordinator.completeOnboarding()
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContainerView {
            print("Onboarding complete")
        }
    }
}
#endif
