//
//  HapticManager.swift
//  MovieTrailer
//
//  Created by Claude Code Audit on 28/12/2025.
//  Provides consistent haptic feedback throughout the app
//

import UIKit
import SwiftUI

/// Centralized haptic feedback manager for consistent tactile responses
@MainActor
final class HapticManager {

    // MARK: - Singleton

    static let shared = HapticManager()

    // MARK: - Feedback Generators (lazy initialized for performance)

    private lazy var impactLight = UIImpactFeedbackGenerator(style: .light)
    private lazy var impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private lazy var impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private lazy var impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private lazy var impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private lazy var selectionGenerator = UISelectionFeedbackGenerator()
    private lazy var notificationGenerator = UINotificationFeedbackGenerator()

    // MARK: - Initialization

    private init() {
        // Prepare generators on init for faster response
        prepareGenerators()
    }

    // MARK: - Public Methods

    /// Prepare all generators (call on app launch or before intense UI)
    func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Impact Feedback

    /// Light tap feedback - for small UI elements, toggles
    func lightImpact() {
        impactLight.impactOccurred()
    }

    /// Medium impact - for button presses, card taps
    func mediumImpact() {
        impactMedium.impactOccurred()
    }

    /// Heavy impact - for significant actions, confirmations
    func heavyImpact() {
        impactHeavy.impactOccurred()
    }

    /// Soft impact - for subtle, gentle feedback
    func softImpact() {
        impactSoft.impactOccurred()
    }

    /// Rigid impact - for crisp, definite feedback
    func rigidImpact() {
        impactRigid.impactOccurred()
    }

    /// Custom intensity impact (0.0 to 1.0)
    func impact(intensity: CGFloat) {
        impactMedium.impactOccurred(intensity: intensity)
    }

    // MARK: - Selection Feedback

    /// Selection changed - for pickers, sliders, segment controls
    func selectionChanged() {
        selectionGenerator.selectionChanged()
    }

    // MARK: - Notification Feedback

    /// Success notification - action completed successfully
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    /// Warning notification - something needs attention
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    /// Error notification - something went wrong
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    // MARK: - Contextual Feedback (Semantic)

    /// Feedback for adding to watchlist
    func addedToWatchlist() {
        success()
    }

    /// Feedback for removing from watchlist
    func removedFromWatchlist() {
        rigidImpact()
    }

    /// Feedback for opening movie detail
    func openedDetail() {
        mediumImpact()
    }

    /// Feedback for closing modal/sheet
    func closedModal() {
        lightImpact()
    }

    /// Feedback for pull-to-refresh trigger
    func pulledToRefresh() {
        mediumImpact()
    }

    /// Feedback for tab change
    func changedTab() {
        selectionChanged()
    }

    /// Feedback for button press
    func buttonPressed() {
        lightImpact()
    }

    /// Feedback for long press trigger
    func longPressTriggered() {
        heavyImpact()
    }

    /// Feedback for swipe action
    func swipeAction() {
        rigidImpact()
    }

    /// Feedback for search result tap
    func searchResultTapped() {
        softImpact()
    }

    /// Feedback for trailer play
    func playedTrailer() {
        mediumImpact()
    }
}

// MARK: - SwiftUI View Modifier

/// View modifier for easy haptic feedback on tap
struct HapticFeedbackModifier: ViewModifier {
    let style: HapticStyle

    enum HapticStyle {
        case light
        case medium
        case heavy
        case soft
        case rigid
        case selection
        case success
        case warning
        case error
    }

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        triggerHaptic()
                    }
            )
    }

    private func triggerHaptic() {
        let manager = HapticManager.shared
        switch style {
        case .light: manager.lightImpact()
        case .medium: manager.mediumImpact()
        case .heavy: manager.heavyImpact()
        case .soft: manager.softImpact()
        case .rigid: manager.rigidImpact()
        case .selection: manager.selectionChanged()
        case .success: manager.success()
        case .warning: manager.warning()
        case .error: manager.error()
        }
    }
}

// MARK: - View Extension

extension View {
    /// Add haptic feedback on tap
    func hapticFeedback(_ style: HapticFeedbackModifier.HapticStyle = .light) -> some View {
        modifier(HapticFeedbackModifier(style: style))
    }

    /// Add haptic feedback for button press
    func buttonHaptic() -> some View {
        hapticFeedback(.light)
    }

    /// Add haptic feedback for card tap
    func cardHaptic() -> some View {
        hapticFeedback(.medium)
    }

    /// Add haptic feedback for selection change
    func selectionHaptic() -> some View {
        hapticFeedback(.selection)
    }
}
