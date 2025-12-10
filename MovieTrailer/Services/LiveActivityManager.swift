//
//  LiveActivityManager.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import Foundation
import ActivityKit
import SwiftUI
import Combine

/// Manages Live Activities for watchlist updates
@MainActor
class LiveActivityManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var currentActivity: Activity<WatchlistActivityAttributes>?
    @Published private(set) var isActive = false
    
    // MARK: - Singleton
    
    static let shared = LiveActivityManager()
    
    private init() {
        // Check for existing activities on init
        checkExistingActivities()
    }
    
    // MARK: - Public Methods
    
    /// Start a Live Activity when a movie is added to watchlist
    func startActivity(for movie: WatchlistItem) async {
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ Live Activities are not enabled")
            return
        }
        
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
            
            print("✅ Live Activity started for: \(movie.title)")
            
            // Schedule automatic end after 2 hours
            scheduleAutoEnd()
            
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
        for activity in Activity<WatchlistActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        currentActivity = nil
        isActive = false
    }
    
    // MARK: - Private Methods
    
    /// Check for existing activities on app launch
    private func checkExistingActivities() {
        let activities = Activity<WatchlistActivityAttributes>.activities
        if let activity = activities.first {
            currentActivity = activity
            isActive = true
            print("ℹ️ Found existing Live Activity")
        }
    }
    
    /// Schedule automatic end after 2 hours
    private func scheduleAutoEnd() {
        Task {
            try? await Task.sleep(nanoseconds: 2 * 60 * 60 * 1_000_000_000) // 2 hours
            await endActivity()
        }
    }
    
    // MARK: - Activity Monitoring
    
    /// Monitor activity state changes
    func monitorActivityUpdates() async {
        guard let activity = currentActivity else { return }
        
        for await state in activity.activityStateUpdates {
            switch state {
            case .active:
                print("ℹ️ Live Activity is active")
            case .ended:
                print("ℹ️ Live Activity ended")
                currentActivity = nil
                isActive = false
            case .dismissed:
                print("ℹ️ Live Activity dismissed")
                currentActivity = nil
                isActive = false
            case .stale:
                print("⚠️ Live Activity is stale")
            @unknown default:
                break
            }
        }
    }
    
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
        } else {
            return "\(minutes)m ago"
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
