//
//  Haptics.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Comprehensive haptic feedback system
//

import SwiftUI
import UIKit

// MARK: - Haptic Feedback Manager

@MainActor
final class Haptics {

    // MARK: - Shared Instance

    static let shared = Haptics()

    // MARK: - Generators

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    // MARK: - Initialization

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        softGenerator.prepare()
        rigidGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Impact Feedback

    /// Light tap feedback
    func light() {
        lightGenerator.impactOccurred()
    }

    /// Medium tap feedback
    func medium() {
        mediumGenerator.impactOccurred()
    }

    /// Heavy tap feedback
    func heavy() {
        heavyGenerator.impactOccurred()
    }

    /// Soft tap feedback
    func soft() {
        softGenerator.impactOccurred()
    }

    /// Rigid tap feedback
    func rigid() {
        rigidGenerator.impactOccurred()
    }

    // MARK: - Selection Feedback

    /// Selection changed feedback
    func selectionChanged() {
        selectionGenerator.selectionChanged()
    }

    // MARK: - Notification Feedback

    /// Success notification
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    /// Warning notification
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    /// Error notification
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    // MARK: - Contextual Haptics

    /// Tab bar item tapped
    func tabTapped() {
        light()
    }

    /// Card tapped
    func cardTapped() {
        medium()
    }

    /// Button tapped
    func buttonTapped() {
        medium()
    }

    /// Pull to refresh triggered
    func pullRefresh() {
        soft()
    }

    /// Swipe right (like)
    func swipeLike() {
        success()
    }

    /// Swipe left (skip)
    func swipeSkip() {
        light()
    }

    /// Swipe up (super like)
    func swipeSuperLike() {
        heavy()
    }

    /// Swipe down (seen)
    func swipeSeen() {
        medium()
    }

    /// Added to watchlist
    func addedToWatchlist() {
        success()
    }

    /// Removed from watchlist
    func removedFromWatchlist() {
        light()
    }

    /// Long press activated
    func longPress() {
        heavy()
    }

    /// Slider value changed
    func sliderChanged() {
        selectionChanged()
    }

    /// Toggle switched
    func toggleSwitched() {
        medium()
    }

    /// Sheet presented
    func sheetPresented() {
        soft()
    }

    /// Sheet dismissed
    func sheetDismissed() {
        light()
    }

    /// Error occurred
    func errorOccurred() {
        error()
    }

    /// Action completed successfully
    func actionCompleted() {
        success()
    }

    /// Category filter changed
    func filterChanged() {
        selectionChanged()
    }

    /// Trailer started playing
    func trailerStarted() {
        medium()
    }

    /// Undo action triggered
    func undoAction() {
        soft()
    }

    // MARK: - Aliases for convenience

    /// Alias for light impact
    func lightImpact() {
        light()
    }

    /// Alias for medium impact
    func mediumImpact() {
        medium()
    }

    /// Alias for heavy impact
    func heavyImpact() {
        heavy()
    }

    /// Alias for swipe right
    func swipeRight() {
        swipeLike()
    }

    /// Alias for swipe left
    func swipeLeft() {
        swipeSkip()
    }

    /// Alias for super like
    func superLike() {
        swipeSuperLike()
    }

    /// Alias for pulled to refresh
    func pulledToRefresh() {
        pullRefresh()
    }
}

// MARK: - View Extension for Haptic Modifiers

extension View {
    /// Add haptic feedback on tap
    func hapticOnTap(_ type: HapticType = .medium) -> some View {
        self.simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    switch type {
                    case .light: Haptics.shared.light()
                    case .medium: Haptics.shared.medium()
                    case .heavy: Haptics.shared.heavy()
                    case .soft: Haptics.shared.soft()
                    case .rigid: Haptics.shared.rigid()
                    case .success: Haptics.shared.success()
                    case .warning: Haptics.shared.warning()
                    case .error: Haptics.shared.error()
                    case .selection: Haptics.shared.selectionChanged()
                    }
                }
        )
    }
}

enum HapticType {
    case light
    case medium
    case heavy
    case soft
    case rigid
    case success
    case warning
    case error
    case selection
}
