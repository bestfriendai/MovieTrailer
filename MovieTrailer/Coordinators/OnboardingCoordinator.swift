//
//  OnboardingCoordinator.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Manages the onboarding flow state and navigation
//

import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding Step

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case features = 1
    case streamingServices = 2
    case genres = 3
    case authentication = 4

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .features: return "Discover"
        case .streamingServices: return "Services"
        case .genres: return "Genres"
        case .authentication: return "Account"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome: return "Your personal movie guide"
        case .features: return "Swipe to find movies you'll love"
        case .streamingServices: return "Select your streaming platforms"
        case .genres: return "Tell us what you love"
        case .authentication: return "Save your preferences"
        }
    }

    static var totalSteps: Int {
        allCases.count
    }
}

// MARK: - Onboarding Coordinator

@MainActor
final class OnboardingCoordinator: ObservableObject {

    // MARK: - Published Properties

    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedStreamingServices: Set<StreamingService> = []
    @Published var selectedGenreIds: Set<Int> = []
    @Published var isAnimating = false
    @Published private(set) var isCompleting = false

    // MARK: - Dependencies

    private let authManager: AuthenticationManager
    private let userPreferences: UserPreferences
    private let firestoreService: FirestoreService

    // MARK: - Callbacks

    var onComplete: (() -> Void)?

    // MARK: - Computed Properties

    var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.totalSteps - 1)
    }

    var canGoBack: Bool {
        currentStep.rawValue > 0
    }

    var canSkip: Bool {
        currentStep != .authentication
    }

    var isLastStep: Bool {
        currentStep == .authentication
    }

    // MARK: - Initialization

    init(
        authManager: AuthenticationManager = .shared,
        userPreferences: UserPreferences = .shared,
        firestoreService: FirestoreService = .shared
    ) {
        self.authManager = authManager
        self.userPreferences = userPreferences
        self.firestoreService = firestoreService

        // Load previously selected streaming services if any
        loadExistingPreferences()
    }

    // MARK: - Navigation

    func next() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            completeOnboarding()
            return
        }

        withAnimation(AppTheme.Animation.smooth) {
            currentStep = nextStep
        }
        Haptics.shared.selectionChanged()
    }

    func back() {
        guard let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) else {
            return
        }

        withAnimation(AppTheme.Animation.smooth) {
            currentStep = previousStep
        }
        Haptics.shared.lightImpact()
    }

    func skip() {
        // Skip directly to auth step
        withAnimation(AppTheme.Animation.smooth) {
            currentStep = .authentication
        }
        Haptics.shared.lightImpact()
    }

    func jumpTo(_ step: OnboardingStep) {
        withAnimation(AppTheme.Animation.smooth) {
            currentStep = step
        }
    }

    // MARK: - Streaming Services

    func toggleStreamingService(_ service: StreamingService) {
        if selectedStreamingServices.contains(service) {
            selectedStreamingServices.remove(service)
        } else {
            selectedStreamingServices.insert(service)
        }
        Haptics.shared.lightImpact()
    }

    func selectAllStreamingServices() {
        selectedStreamingServices = Set(StreamingService.allCases)
        Haptics.shared.mediumImpact()
    }

    func clearStreamingServices() {
        selectedStreamingServices.removeAll()
        Haptics.shared.lightImpact()
    }

    // MARK: - Genre Preferences

    func toggleGenre(_ genre: Genre) {
        if selectedGenreIds.contains(genre.id) {
            selectedGenreIds.remove(genre.id)
        } else {
            selectedGenreIds.insert(genre.id)
        }
        Haptics.shared.lightImpact()
    }

    func clearGenres() {
        selectedGenreIds.removeAll()
        Haptics.shared.lightImpact()
    }

    // MARK: - Authentication Actions

    func signInWithGoogle() async {
        do {
            try await authManager.signInWithGoogle()
            await completeOnboardingAsync()
        } catch AuthError.signInCancelled {
            // User cancelled, do nothing
        } catch {
            authManager.error = error as? AuthError ?? .unknown(error)
        }
    }

    func signInWithApple() async {
        do {
            try await authManager.signInWithApple()
            await completeOnboardingAsync()
        } catch AuthError.signInCancelled {
            // User cancelled, do nothing
        } catch {
            authManager.error = error as? AuthError ?? .unknown(error)
        }
    }

    func continueAsGuest() async {
        await authManager.continueAsGuest()
        await completeOnboardingAsync()
    }

    // MARK: - Complete Onboarding

    func completeOnboarding() {
        Task {
            await completeOnboardingAsync()
        }
    }

    private func completeOnboardingAsync() async {
        isCompleting = true

        // Save streaming services preference
        saveStreamingServices()
        savePreferredGenres()

        // Mark onboarding as complete
        userPreferences.hasCompletedOnboarding = true

        // If authenticated, sync to Firestore
        if let user = authManager.authState.currentUser, !user.isGuest {
            do {
                let serviceIds = selectedStreamingServices.map { $0.rawValue }
                try await firestoreService.saveStreamingServices(
                    serviceIds,
                    for: user.id
                )
            } catch {
                // Non-critical error, continue
                #if DEBUG
                print("Failed to sync streaming services: \(error)")
                #endif
            }
        }

        isCompleting = false
        Haptics.shared.success()

        // Notify completion
        onComplete?()
    }

    // MARK: - Private Helpers

    private func loadExistingPreferences() {
        // Load from UserPreferences if available
        selectedStreamingServices = userPreferences.selectedStreamingServices
        selectedGenreIds = userPreferences.selectedGenreIds
    }

    private func saveStreamingServices() {
        userPreferences.selectedStreamingServices = selectedStreamingServices
    }

    private func savePreferredGenres() {
        userPreferences.selectedGenreIds = selectedGenreIds
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension OnboardingCoordinator {
    static func preview() -> OnboardingCoordinator {
        let coordinator = OnboardingCoordinator()
        coordinator.selectedStreamingServices = [.netflix, .disneyPlus, .hboMax]
        return coordinator
    }

    static func previewAtStep(_ step: OnboardingStep) -> OnboardingCoordinator {
        let coordinator = OnboardingCoordinator()
        coordinator.currentStep = step
        return coordinator
    }
}
#endif
