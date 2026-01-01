//
//  UserPreferences.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  User preferences storage for streaming services and app settings
//

import Foundation
import SwiftUI

// MARK: - User Preferences Manager

@MainActor
final class UserPreferences: ObservableObject {

    // MARK: - Shared Instance

    static let shared = UserPreferences()

    // MARK: - Published Properties

    @Published var selectedStreamingServices: Set<StreamingService> {
        didSet { saveStreamingServices() }
    }

    @Published var selectedGenreIds: Set<Int> {
        didSet { savePreferredGenres() }
    }

    @Published var selectedCategory: MovieCategory = .all

    @Published var countryCode: String {
        didSet { UserDefaults.standard.set(countryCode, forKey: Keys.countryCode) }
    }

    @Published var includeAdultContent: Bool {
        didSet { UserDefaults.standard.set(includeAdultContent, forKey: Keys.includeAdult) }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    // MARK: - Keys

    private enum Keys {
        static let streamingServices = "selectedStreamingServices"
        static let preferredGenres = "preferredGenres"
        static let countryCode = "countryCode"
        static let includeAdult = "includeAdultContent"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let swipePreferences = "swipePreferences"
    }

    // MARK: - Initialization

    private init() {
        // Load streaming services
        if let data = UserDefaults.standard.data(forKey: Keys.streamingServices),
           let services = try? JSONDecoder().decode([StreamingService].self, from: data) {
            self.selectedStreamingServices = Set(services)
        } else {
            self.selectedStreamingServices = []
        }

        if let genreIds = UserDefaults.standard.array(forKey: Keys.preferredGenres) as? [Int] {
            self.selectedGenreIds = Set(genreIds)
        } else {
            self.selectedGenreIds = []
        }

        // Load country code (default to US)
        self.countryCode = UserDefaults.standard.string(forKey: Keys.countryCode) ?? "US"

        // Load adult content setting
        self.includeAdultContent = UserDefaults.standard.bool(forKey: Keys.includeAdult)

        // Load onboarding status
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
    }

    // MARK: - Streaming Services

    private func saveStreamingServices() {
        if let data = try? JSONEncoder().encode(Array(selectedStreamingServices)) {
            UserDefaults.standard.set(data, forKey: Keys.streamingServices)
        }
    }

    private func savePreferredGenres() {
        UserDefaults.standard.set(Array(selectedGenreIds), forKey: Keys.preferredGenres)
    }

    func toggleStreamingService(_ service: StreamingService) {
        if selectedStreamingServices.contains(service) {
            selectedStreamingServices.remove(service)
        } else {
            selectedStreamingServices.insert(service)
        }
    }

    func isServiceSelected(_ service: StreamingService) -> Bool {
        selectedStreamingServices.contains(service)
    }

    func clearStreamingServices() {
        selectedStreamingServices.removeAll()
    }

    func toggleGenreId(_ id: Int) {
        if selectedGenreIds.contains(id) {
            selectedGenreIds.remove(id)
        } else {
            selectedGenreIds.insert(id)
        }
    }

    func isGenreSelected(_ id: Int) -> Bool {
        selectedGenreIds.contains(id)
    }

    var selectedGenres: [Genre] {
        selectedGenreIds.compactMap { Genre.genre(for: $0) }
    }

    /// Get provider IDs for selected services
    var selectedProviderIds: [Int] {
        selectedStreamingServices.map { $0.providerId }
    }

    /// Check if a movie's providers match user's selected services
    func matchesUserServices(_ providers: WatchProviderInfo) -> Bool {
        guard !selectedStreamingServices.isEmpty else { return true }

        let allProviderIds = providers.allProviders.map { $0.providerId }
        return !Set(allProviderIds).isDisjoint(with: Set(selectedProviderIds))
    }

    // MARK: - Swipe Preferences

    struct SwipePreference: Codable {
        let movieId: Int
        let action: SwipeAction
        let timestamp: Date
        let genres: [Int]
        let rating: Double
    }

    enum SwipeAction: String, Codable {
        case liked
        case skipped
        case superLiked
        case seen
    }

    func saveSwipePreference(_ preference: SwipePreference) {
        var preferences = loadSwipePreferences()
        preferences.append(preference)

        // Keep only last 500 preferences
        if preferences.count > 500 {
            preferences = Array(preferences.suffix(500))
        }

        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: Keys.swipePreferences)
        }
    }

    func loadSwipePreferences() -> [SwipePreference] {
        guard let data = UserDefaults.standard.data(forKey: Keys.swipePreferences),
              let preferences = try? JSONDecoder().decode([SwipePreference].self, from: data) else {
            return []
        }
        return preferences
    }

    /// Calculate user's preferred genres based on swipe history
    func preferredGenres() -> [Int: Double] {
        let preferences = loadSwipePreferences()
        var genreScores: [Int: Double] = [:]

        for pref in preferences {
            let score: Double
            switch pref.action {
            case .liked: score = 1.0
            case .superLiked: score = 2.0
            case .skipped: score = -0.5
            case .seen: score = 0.5
            }

            for genre in pref.genres {
                genreScores[genre, default: 0] += score
            }
        }

        return genreScores
    }

    /// Get average rating of liked movies
    func averageLikedRating() -> Double {
        let likedPrefs = loadSwipePreferences().filter { $0.action == .liked || $0.action == .superLiked }
        guard !likedPrefs.isEmpty else { return 7.0 }

        let totalRating = likedPrefs.reduce(0.0) { $0 + $1.rating }
        return totalRating / Double(likedPrefs.count)
    }

    // MARK: - Reset

    func resetAllPreferences() {
        selectedStreamingServices.removeAll()
        selectedGenreIds.removeAll()
        countryCode = "US"
        includeAdultContent = false
        UserDefaults.standard.removeObject(forKey: Keys.swipePreferences)
    }
}
