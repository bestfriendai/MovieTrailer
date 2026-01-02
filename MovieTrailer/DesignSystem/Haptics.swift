//
//  Haptics.swift
//  MovieTrailer
//

import SwiftUI
import UIKit

// MARK: - Haptic Feedback Manager

@MainActor
final class Haptics {

    // MARK: - Shared Instance

    static let shared = Haptics()

    // MARK: - Generators

    private lazy var lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private lazy var mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private lazy var heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private lazy var softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private lazy var rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private lazy var selectionGenerator = UISelectionFeedbackGenerator()
    private lazy var notificationGenerator = UINotificationFeedbackGenerator()

    // MARK: - Initialization

    private init() {
        prepareGenerators()
    }

    func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        softGenerator.prepare()
        rigidGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Impact Feedback

    func light() {
        lightGenerator.impactOccurred()
    }

    func medium() {
        mediumGenerator.impactOccurred()
    }

    func heavy() {
        heavyGenerator.impactOccurred()
    }

    func soft() {
        softGenerator.impactOccurred()
    }

    func rigid() {
        rigidGenerator.impactOccurred()
    }

    func impact(intensity: CGFloat) {
        mediumGenerator.impactOccurred(intensity: intensity)
    }

    // MARK: - Selection Feedback

    func selectionChanged() {
        selectionGenerator.selectionChanged()
    }

    // MARK: - Notification Feedback

    func success() {
        notificationGenerator.notificationOccurred(.success)
    }

    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }

    func error() {
        notificationGenerator.notificationOccurred(.error)
    }

    // MARK: - Contextual Haptics

    func tabTapped() {
        selectionChanged()
    }

    func changedTab() {
        selectionChanged()
    }

    func cardTapped() {
        medium()
    }

    func buttonTapped() {
        light()
    }

    func buttonPressed() {
        light()
    }

    func pullRefresh() {
        medium()
    }

    func pulledToRefresh() {
        medium()
    }

    func swipeLike() {
        success()
    }

    func swipeSkip() {
        light()
    }

    func swipeSuperLike() {
        heavy()
    }

    func swipeSeen() {
        medium()
    }

    func swipeAction() {
        rigid()
    }

    func addedToWatchlist() {
        success()
    }

    func removedFromWatchlist() {
        rigid()
    }

    func longPress() {
        heavy()
    }

    func longPressTriggered() {
        heavy()
    }

    func sliderChanged() {
        selectionChanged()
    }

    func toggleSwitched() {
        medium()
    }

    func sheetPresented() {
        soft()
    }

    func sheetDismissed() {
        light()
    }

    func closedModal() {
        light()
    }

    func errorOccurred() {
        error()
    }

    func actionCompleted() {
        success()
    }

    func filterChanged() {
        selectionChanged()
    }

    func trailerStarted() {
        medium()
    }

    func playedTrailer() {
        medium()
    }

    func undoAction() {
        soft()
    }

    func openedDetail() {
        medium()
    }

    func searchResultTapped() {
        soft()
    }

    // MARK: - Aliases

    func lightImpact() {
        light()
    }

    func mediumImpact() {
        medium()
    }

    func heavyImpact() {
        heavy()
    }

    func softImpact() {
        soft()
    }

    func rigidImpact() {
        rigid()
    }

    func swipeRight() {
        swipeLike()
    }

    func swipeLeft() {
        swipeSkip()
    }

    func superLike() {
        swipeSuperLike()
    }
}

// MARK: - View Extension for Haptic Modifiers

extension View {
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

    func hapticFeedback(_ style: HapticType = .light) -> some View {
        hapticOnTap(style)
    }

    func buttonHaptic() -> some View {
        hapticFeedback(.light)
    }

    func cardHaptic() -> some View {
        hapticFeedback(.medium)
    }

    func selectionHaptic() -> some View {
        hapticFeedback(.selection)
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

// MARK: - Backwards Compatibility

typealias HapticManager = Haptics
