//
//  UserPreferences.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  User preferences storage for streaming services and app settings
//  Enhanced with Firebase sync support
//

import Foundation
import SwiftUI
import Combine

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
        didSet {
            UserDefaults.standard.set(countryCode, forKey: Keys.countryCode)
            syncToFirestoreIfNeeded()
        }
    }

    @Published var includeAdultContent: Bool {
        didSet {
            UserDefaults.standard.set(includeAdultContent, forKey: Keys.includeAdult)
            syncToFirestoreIfNeeded()
        }
    }

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    @Published private(set) var isSyncing = false

    // MARK: - Dependencies

    private let firestoreService = FirestoreService.shared
    private var cancellables = Set<AnyCancellable>()
    private var syncTask: Task<Void, Never>?

    // MARK: - Keys

    private enum Keys {
        static let streamingServices = "selectedStreamingServices"
        static let preferredGenres = "preferredGenres"
        static let countryCode = "countryCode"
        static let includeAdult = "includeAdultContent"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let swipePreferences = "swipePreferences"
        static let likedMovieIds = "likedMovieIds"
        static let dislikedMovieIds = "dislikedMovieIds"
        static let superLikedMovieIds = "superLikedMovieIds"
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

        // Observe auth state changes to sync data
        observeAuthState()
    }

    // MARK: - Auth State Observation

    private func observeAuthState() {
        AuthenticationManager.shared.$authState
            .sink { [weak self] state in
                if case .authenticated(let user) = state, !user.isGuest {
                    Task { @MainActor in
                        await self?.syncFromFirestore(userId: user.id)
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Streaming Services

    private func saveStreamingServices() {
        if let data = try? JSONEncoder().encode(Array(selectedStreamingServices)) {
            UserDefaults.standard.set(data, forKey: Keys.streamingServices)
        }
        syncToFirestoreIfNeeded()
    }

    private func savePreferredGenres() {
        UserDefaults.standard.set(Array(selectedGenreIds), forKey: Keys.preferredGenres)
        syncToFirestoreIfNeeded()
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

        // Also save to individual lists for Firestore sync
        saveLikedMovieId(preference)

        // Sync to Firestore
        syncSwipeToFirestore(preference)
    }

    private func saveLikedMovieId(_ preference: SwipePreference) {
        switch preference.action {
        case .liked:
            var liked = UserDefaults.standard.array(forKey: Keys.likedMovieIds) as? [Int] ?? []
            if !liked.contains(preference.movieId) {
                liked.append(preference.movieId)
                UserDefaults.standard.set(liked, forKey: Keys.likedMovieIds)
            }
        case .superLiked:
            var superLiked = UserDefaults.standard.array(forKey: Keys.superLikedMovieIds) as? [Int] ?? []
            if !superLiked.contains(preference.movieId) {
                superLiked.append(preference.movieId)
                UserDefaults.standard.set(superLiked, forKey: Keys.superLikedMovieIds)
            }
        case .skipped:
            var disliked = UserDefaults.standard.array(forKey: Keys.dislikedMovieIds) as? [Int] ?? []
            if !disliked.contains(preference.movieId) {
                disliked.append(preference.movieId)
                UserDefaults.standard.set(disliked, forKey: Keys.dislikedMovieIds)
            }
        case .seen:
            break
        }
    }

    /// Get all liked movie IDs
    func getLikedMovieIds() -> [Int] {
        UserDefaults.standard.array(forKey: Keys.likedMovieIds) as? [Int] ?? []
    }

    /// Get all super liked movie IDs
    func getSuperLikedMovieIds() -> [Int] {
        UserDefaults.standard.array(forKey: Keys.superLikedMovieIds) as? [Int] ?? []
    }

    /// Get all disliked movie IDs
    func getDislikedMovieIds() -> [Int] {
        UserDefaults.standard.array(forKey: Keys.dislikedMovieIds) as? [Int] ?? []
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
        UserDefaults.standard.removeObject(forKey: Keys.likedMovieIds)
        UserDefaults.standard.removeObject(forKey: Keys.dislikedMovieIds)
        UserDefaults.standard.removeObject(forKey: Keys.superLikedMovieIds)
    }

    // MARK: - Firestore Sync

    /// Sync a single swipe action to Firestore immediately
    private func syncSwipeToFirestore(_ preference: SwipePreference) {
        guard case .authenticated(let user) = AuthenticationManager.shared.authState,
              !user.isGuest else { return }

        Task {
            do {
                switch preference.action {
                case .liked:
                    try await firestoreService.addLikedMovie(preference.movieId, for: user.id)
                case .superLiked:
                    try await firestoreService.addLikedMovie(preference.movieId, for: user.id)
                case .skipped:
                    try await firestoreService.addDislikedMovie(preference.movieId, for: user.id)
                case .seen:
                    break
                }
            } catch {
                print("❌ Failed to sync swipe to Firestore: \(error.localizedDescription)")
            }
        }
    }

    /// Debounced sync to Firestore (for preferences that change frequently)
    private func syncToFirestoreIfNeeded() {
        guard case .authenticated(let user) = AuthenticationManager.shared.authState,
              !user.isGuest else { return }

        // Cancel any pending sync
        syncTask?.cancel()

        // Debounce sync by 2 seconds
        syncTask = Task {
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                guard !Task.isCancelled else { return }

                await syncAllToFirestore(userId: user.id)
            } catch {
                // Task was cancelled, ignore
            }
        }
    }

    /// Sync all preferences to Firestore
    func syncAllToFirestore(userId: String) async {
        isSyncing = true
        defer { isSyncing = false }

        do {
            // Build swipe preferences
            let swipePrefs = SyncSwipePreferences(
                likedMovieIds: getLikedMovieIds(),
                dislikedMovieIds: getDislikedMovieIds(),
                superLikedMovieIds: getSuperLikedMovieIds(),
                watchLaterIds: [],
                genreWeights: preferredGenres().mapKeys { String($0) }
            )

            // Build user preferences
            let userPrefs = SyncUserPreferences(
                preferredLanguage: Locale.current.language.languageCode?.identifier ?? "en",
                includeAdult: includeAdultContent,
                region: countryCode,
                notificationsEnabled: true,
                prefersDarkMode: true,
                hasCompletedOnboarding: hasCompletedOnboarding,
                hasSeenSwipeTutorial: true
            )

            // Save to Firestore
            try await firestoreService.saveSwipePreferences(swipePrefs, for: userId)
            try await firestoreService.saveStreamingServices(
                selectedStreamingServices.map { $0.rawValue },
                for: userId
            )
            try await firestoreService.savePreferences(userPrefs, for: userId)

            print("✅ Synced all preferences to Firestore")
        } catch {
            print("❌ Failed to sync preferences to Firestore: \(error.localizedDescription)")
        }
    }

    /// Sync from Firestore (on login)
    func syncFromFirestore(userId: String) async {
        isSyncing = true
        defer { isSyncing = false }

        do {
            let userData = try await firestoreService.fetchUserData(for: userId)

            // Merge liked movies
            let remoteLiked = userData.swipePreferences.likedMovieIds
            let localLiked = getLikedMovieIds()
            let mergedLiked = Array(Set(localLiked + remoteLiked))
            UserDefaults.standard.set(mergedLiked, forKey: Keys.likedMovieIds)

            // Merge disliked movies
            let remoteDisliked = userData.swipePreferences.dislikedMovieIds
            let localDisliked = getDislikedMovieIds()
            let mergedDisliked = Array(Set(localDisliked + remoteDisliked))
            UserDefaults.standard.set(mergedDisliked, forKey: Keys.dislikedMovieIds)

            // Merge super liked movies
            let remoteSuperLiked = userData.swipePreferences.superLikedMovieIds
            let localSuperLiked = getSuperLikedMovieIds()
            let mergedSuperLiked = Array(Set(localSuperLiked + remoteSuperLiked))
            UserDefaults.standard.set(mergedSuperLiked, forKey: Keys.superLikedMovieIds)

            // Merge streaming services
            let remoteServices = userData.streamingServices.compactMap { StreamingService(rawValue: $0) }
            selectedStreamingServices = selectedStreamingServices.union(Set(remoteServices))

            // Sync preferences back to cloud with merged data
            await syncAllToFirestore(userId: userId)

            print("✅ Synced preferences from Firestore")
        } catch {
            print("❌ Failed to sync from Firestore: \(error.localizedDescription)")
        }
    }
}

// MARK: - Dictionary Extension for Key Mapping

extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}
