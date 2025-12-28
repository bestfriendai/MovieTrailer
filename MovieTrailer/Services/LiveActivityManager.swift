//
//  LiveActivityManager.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//  Fixed: Proper task cancellation, memory management
//

import Foundation
import ActivityKit
import SwiftUI
import Combine

/// Manages Live Activities for watchlist updates
/// Fixed: Proper task lifecycle management
@MainActor
class LiveActivityManager: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var currentActivity: Activity<WatchlistActivityAttributes>?
    @Published private(set) var isActive = false

    // MARK: - Private Properties

    /// Stored task reference for proper cancellation
    private var autoEndTask: Task<Void, Never>?
    private var monitorTask: Task<Void, Never>?

    // MARK: - Singleton

    static let shared = LiveActivityManager()

    private init() {
        // Check for existing activities on init
        checkExistingActivities()
    }

    deinit {
        // Cancel any pending tasks - called from MainActor context
        autoEndTask?.cancel()
        monitorTask?.cancel()
    }

    // MARK: - Public Methods

    /// Start a Live Activity when a movie is added to watchlist
    func startActivity(for movie: WatchlistItem) async {
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities are not enabled")
            return
        }

        // Cancel any pending auto-end task
        cancelScheduledTasks()

        // End existing activity if any
        await endActivity()

        do {
            // Create attributes (static content)
            let attributes = WatchlistActivityAttributes(
                movieTitle: movie.title,
                posterPath: movie.posterPath,
                rating: movie.voteAverage
            )

            // Create initial content state (dynamic content)
            let initialState = WatchlistActivityAttributes.ContentState(
                addedAt: Date(),
                message: "Added to Watchlist"
            )

            // Start the activity
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )

            currentActivity = activity
            isActive = true

            // Haptic feedback
            HapticManager.shared.addedToWatchlist()

            print("✅ Live Activity started for: \(movie.title)")

            // Schedule automatic end after 2 hours
            scheduleAutoEnd()

            // Start monitoring activity state
            startMonitoring()

        } catch {
            print("❌ Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    /// Update the Live Activity with new content
    func updateActivity(message: String) async {
        guard let activity = currentActivity else {
            print("⚠️ No active Live Activity to update")
            return
        }

        let updatedState = WatchlistActivityAttributes.ContentState(
            addedAt: activity.content.state.addedAt,
            message: message
        )

        await activity.update(
            .init(state: updatedState, staleDate: nil)
        )

        print("✅ Live Activity updated: \(message)")
    }

    /// End the current Live Activity
    func endActivity() async {
        // Cancel scheduled tasks first
        cancelScheduledTasks()

        guard let activity = currentActivity else {
            return
        }

        let finalState = WatchlistActivityAttributes.ContentState(
            addedAt: activity.content.state.addedAt,
            message: "Enjoy watching!"
        )

        await activity.end(
            .init(state: finalState, staleDate: nil),
            dismissalPolicy: .after(.now + 3) // Dismiss after 3 seconds
        )

        currentActivity = nil
        isActive = false

        print("✅ Live Activity ended")
    }

    /// End all activities (cleanup)
    func endAllActivities() async {
        cancelScheduledTasks()

        for activity in Activity<WatchlistActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
        isActive = false
    }

    // MARK: - Private Methods

    /// Cancel all scheduled tasks
    private func cancelScheduledTasks() {
        autoEndTask?.cancel()
        autoEndTask = nil
        monitorTask?.cancel()
        monitorTask = nil
    }

    /// Check for existing activities on app launch
    private func checkExistingActivities() {
        let activities = Activity<WatchlistActivityAttributes>.activities
        if let activity = activities.first {
            currentActivity = activity
            isActive = true
            print("ℹ️ Found existing Live Activity")

            // Resume monitoring for existing activity
            startMonitoring()
        }
    }

    /// Schedule automatic end after 2 hours with proper cancellation support
    private func scheduleAutoEnd() {
        // Cancel any existing task
        autoEndTask?.cancel()

        autoEndTask = Task { [weak self] in
            do {
                // Sleep for 2 hours (with cancellation check)
                try await Task.sleep(for: .hours(2))

                // Check if cancelled before proceeding
                guard !Task.isCancelled else {
                    print("ℹ️ Auto-end task was cancelled")
                    return
                }

                // End the activity
                await self?.endActivity()
            } catch {
                // Task was cancelled or other error
                if Task.isCancelled {
                    print("ℹ️ Auto-end task cancelled")
                } else {
                    print("⚠️ Auto-end task error: \(error)")
                }
            }
        }
    }

    /// Start monitoring activity state changes
    private func startMonitoring() {
        // Cancel existing monitor
        monitorTask?.cancel()

        monitorTask = Task { [weak self] in
            guard let activity = self?.currentActivity else { return }

            for await state in activity.activityStateUpdates {
                // Check for cancellation
                guard !Task.isCancelled else { break }

                await MainActor.run {
                    switch state {
                    case .active:
                        print("ℹ️ Live Activity is active")
                    case .ended:
                        print("ℹ️ Live Activity ended by system")
                        self?.currentActivity = nil
                        self?.isActive = false
                        self?.cancelScheduledTasks()
                    case .dismissed:
                        print("ℹ️ Live Activity dismissed by user")
                        self?.currentActivity = nil
                        self?.isActive = false
                        self?.cancelScheduledTasks()
                    case .stale:
                        print("⚠️ Live Activity is stale")
                    @unknown default:
                        break
                    }
                }
            }
        }
    }

    // MARK: - Activity Monitoring (Public)

    /// Get time elapsed since activity started
    func timeElapsed() -> TimeInterval? {
        guard let activity = currentActivity else { return nil }
        return Date().timeIntervalSince(activity.content.state.addedAt)
    }

    /// Get formatted time elapsed
    func formattedTimeElapsed() -> String? {
        guard let elapsed = timeElapsed() else { return nil }

        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) / 60 % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Convenience Extensions

extension LiveActivityManager {
    /// Quick start activity from Movie model
    func startActivity(for movie: Movie) async {
        let item = WatchlistItem(from: movie)
        await startActivity(for: item)
    }

    /// Update with predefined messages
    func updateWithWatchingMessage() async {
        await updateActivity(message: "Ready to watch tonight?")
    }

    func updateWithReminderMessage() async {
        await updateActivity(message: "Don't forget to watch!")
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension LiveActivityManager {
    /// Create a mock manager for previews
    static func mock(isActive: Bool = true) -> LiveActivityManager {
        let manager = LiveActivityManager()
        manager.isActive = isActive
        return manager
    }
}
#endif
