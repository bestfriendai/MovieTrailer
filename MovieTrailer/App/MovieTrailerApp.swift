//
//  MovieTrailerApp.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI

#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct MovieTrailerApp: App {

    @StateObject private var appCoordinator = AppCoordinator()
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var userPreferences = UserPreferences.shared

    @State private var showOnboarding = false

    init() {
        configureFirebase()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                appCoordinator.start()
                    .onOpenURL { url in
                        appCoordinator.handleDeepLink(url)
                    }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingContainerView {
                    showOnboarding = false
                }
            }
            .onAppear {
                checkOnboardingStatus()
            }
            .environmentObject(authManager)
            .environmentObject(userPreferences)
        }
    }

    // MARK: - Firebase Configuration

    private func configureFirebase() {
        #if canImport(FirebaseCore)
        // Configure Firebase if GoogleService-Info.plist exists
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            #if DEBUG
            print("Firebase configured successfully")
            #endif
        } else {
            #if DEBUG
            print("GoogleService-Info.plist not found - Firebase features disabled")
            #endif
        }
        #else
        #if DEBUG
        print("Firebase SDK not installed - running in offline mode")
        #endif
        #endif
    }

    // MARK: - Onboarding Check

    private func checkOnboardingStatus() {
        // Show onboarding if user hasn't completed it
        if !userPreferences.hasCompletedOnboarding {
            // Small delay to ensure UI is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showOnboarding = true
            }
        }
    }
}
