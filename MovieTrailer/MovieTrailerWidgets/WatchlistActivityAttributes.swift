//
//  WatchlistActivityAttributes.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import Foundation
import ActivityKit

/// Attributes for Watchlist Live Activity
struct WatchlistActivityAttributes: ActivityAttributes {
    
    // MARK: - Static Content (doesn't change during activity lifetime)
    
    /// Movie title
    let movieTitle: String
    
    /// Poster path for the movie
    let posterPath: String?
    
    /// Movie rating
    let rating: Double
    
    // MARK: - Dynamic Content (can be updated)
    
    struct ContentState: Codable, Hashable {
        /// When the movie was added to watchlist
        let addedAt: Date
        
        /// Current message to display
        var message: String
        
        // MARK: - Computed Properties
        
        /// Time elapsed since added
        var timeElapsed: TimeInterval {
            Date().timeIntervalSince(addedAt)
        }
        
        /// Formatted time elapsed
        var formattedTimeElapsed: String {
            let hours = Int(timeElapsed) / 3600
            let minutes = Int(timeElapsed) / 60 % 60
            
            if hours > 0 {
                return "\(hours)h \(minutes)m ago"
            } else if minutes > 0 {
                return "\(minutes)m ago"
            } else {
                return "Just now"
            }
        }
        
        /// Progress towards "tonight" (assuming 8 PM)
        var progressToTonight: Double {
            let calendar = Calendar.current
            let now = Date()

            // Get today at 8 PM
            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = 20 // 8 PM
            components.minute = 0

            guard let tonight = calendar.date(from: components) else {
                return 0
            }

            // If it's past 8 PM, use tomorrow 8 PM - safe unwrap
            guard let tomorrowNight = calendar.date(byAdding: .day, value: 1, to: tonight) else {
                return 0
            }
            let targetTime = tonight > now ? tonight : tomorrowNight

            // Calculate progress
            let totalTime = targetTime.timeIntervalSince(addedAt)
            guard totalTime > 0 else { return 0 }
            let elapsed = now.timeIntervalSince(addedAt)

            return min(max(elapsed / totalTime, 0), 1)
        }

        /// Time until tonight (8 PM)
        var timeUntilTonight: String {
            let calendar = Calendar.current
            let now = Date()

            var components = calendar.dateComponents([.year, .month, .day], from: now)
            components.hour = 20
            components.minute = 0

            guard let tonight = calendar.date(from: components) else {
                return "Tonight"
            }

            // Safe unwrap for tomorrow calculation
            guard let tomorrowNight = calendar.date(byAdding: .day, value: 1, to: tonight) else {
                return "Tonight"
            }
            let targetTime = tonight > now ? tonight : tomorrowNight
            let timeInterval = targetTime.timeIntervalSince(now)

            guard timeInterval > 0 else { return "Now" }

            let hours = Int(timeInterval) / 3600
            let minutes = Int(timeInterval) / 60 % 60

            if hours > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(minutes)m"
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Formatted rating
    var formattedRating: String {
        String(format: "%.1f", rating)
    }
    
    /// Full poster URL
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)")
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension WatchlistActivityAttributes {
    /// Sample attributes for previews
    static let sample = WatchlistActivityAttributes(
        movieTitle: "Fight Club",
        posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        rating: 8.4
    )
    
    /// Sample content state
    static let sampleState = ContentState(
        addedAt: Date().addingTimeInterval(-3600), // 1 hour ago
        message: "Added to Watchlist"
    )
}
#endif
