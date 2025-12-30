//
//  FirestoreService.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Handles Firestore database operations for user data sync
//

import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

// MARK: - Firestore Service

@MainActor
final class FirestoreService: ObservableObject {

    // MARK: - Singleton

    static let shared = FirestoreService()

    // MARK: - Published Properties

    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncDate: Date?
    @Published var syncError: Error?

    // MARK: - Private Properties

    #if canImport(FirebaseFirestore)
    private let db = Firestore.firestore()
    #endif

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Full User Data Sync

    /// Fetch all user data from Firestore
    func fetchUserData(for userId: String) async throws -> UserSyncData {
        #if canImport(FirebaseFirestore)
        let document = try await db.collection(UserSyncData.collectionName).document(userId).getDocument()

        guard let data = document.data() else {
            return UserSyncData.empty
        }

        return try decodeUserData(from: data)
        #else
        // Return cached data for development
        if let cachedData = loadCachedUserData(for: userId) {
            return cachedData
        }
        return UserSyncData.empty
        #endif
    }

    /// Save all user data to Firestore
    func saveUserData(_ userData: UserSyncData, for userId: String) async throws {
        isSyncing = true
        defer { isSyncing = false }

        #if canImport(FirebaseFirestore)
        let data = try encodeUserData(userData)
        try await db.collection(UserSyncData.collectionName).document(userId).setData(data, merge: true)
        #else
        // Cache locally for development
        cacheUserData(userData, for: userId)
        #endif

        lastSyncDate = Date()
    }

    /// Sync local data with remote (merge strategy)
    func syncUserData(local: UserSyncData, for userId: String) async throws -> UserSyncData {
        isSyncing = true
        defer { isSyncing = false }

        do {
            let remote = try await fetchUserData(for: userId)
            let merged = local.merging(with: remote)
            try await saveUserData(merged, for: userId)
            lastSyncDate = Date()
            return merged
        } catch {
            syncError = error
            throw error
        }
    }

    // MARK: - Watchlist Operations

    /// Save watchlist to Firestore
    func saveWatchlist(_ items: [SyncWatchlistItem], for userId: String) async throws {
        #if canImport(FirebaseFirestore)
        let data = try items.map { try encodeItem($0) }
        try await db.collection(UserSyncData.collectionName)
            .document(userId)
            .setData([UserSyncData.FieldKeys.watchlist.rawValue: data], merge: true)
        #else
        var userData = loadCachedUserData(for: userId) ?? UserSyncData.empty
        userData.watchlist = items
        cacheUserData(userData, for: userId)
        #endif
    }

    /// Fetch watchlist from Firestore
    func fetchWatchlist(for userId: String) async throws -> [SyncWatchlistItem] {
        let userData = try await fetchUserData(for: userId)
        return userData.watchlist
    }

    /// Add single item to watchlist
    func addToWatchlist(_ item: SyncWatchlistItem, for userId: String) async throws {
        #if canImport(FirebaseFirestore)
        let data = try encodeItem(item)
        try await db.collection(UserSyncData.collectionName)
            .document(userId)
            .updateData([
                UserSyncData.FieldKeys.watchlist.rawValue: FieldValue.arrayUnion([data])
            ])
        #else
        var userData = loadCachedUserData(for: userId) ?? UserSyncData.empty
        if !userData.watchlist.contains(where: { $0.id == item.id }) {
            userData.watchlist.append(item)
            cacheUserData(userData, for: userId)
        }
        #endif
    }

    /// Remove item from watchlist
    func removeFromWatchlist(movieId: Int, for userId: String) async throws {
        #if canImport(FirebaseFirestore)
        // First fetch current watchlist
        var userData = try await fetchUserData(for: userId)
        userData.watchlist.removeAll { $0.id == movieId }
        try await saveWatchlist(userData.watchlist, for: userId)
        #else
        var userData = loadCachedUserData(for: userId) ?? UserSyncData.empty
        userData.watchlist.removeAll { $0.id == movieId }
        cacheUserData(userData, for: userId)
        #endif
    }

    // MARK: - Swipe Preferences Operations

    /// Save swipe preferences
    func saveSwipePreferences(_ prefs: SyncSwipePreferences, for userId: String) async throws {
        #if canImport(FirebaseFirestore)
        let data = try encodeItem(prefs)
        try await db.collection(UserSyncData.collectionName)
            .document(userId)
            .setData([UserSyncData.FieldKeys.swipePreferences.rawValue: data], merge: true)
        #else
        var userData = loadCachedUserData(for: userId) ?? UserSyncData.empty
        userData.swipePreferences = prefs
        cacheUserData(userData, for: userId)
        #endif
    }

    /// Fetch swipe preferences
    func fetchSwipePreferences(for userId: String) async throws -> SyncSwipePreferences {
        let userData = try await fetchUserData(for: userId)
        return userData.swipePreferences
    }

    /// Add liked movie
    func addLikedMovie(_ movieId: Int, for userId: String) async throws {
        #if canImport(FirebaseFirestore)
        try await db.collection(UserSyncData.collectionName)
            .document(userId)
            .updateData([
                "\(UserSyncData.FieldKeys.swipePreferences.rawValue).likedMovieIds": FieldValue.arrayUnion([movieId])
            ])
        #else
        var userData = loadCachedUserData(for: userId) ?? UserSyncData.empty
        if !userData.swipePreferences.likedMovieIds.contains(movieId) {
            userData.swipePreferences.likedMovieIds.append(movieId)
            cacheUserData(userData, for: userId)
        }
        #endif
    }

    /// Add disliked movie
    func addDislikedMovie(_ movieId: Int, for userId: String) async throws {
        #if canImport(FirebaseFirestore)
        try await db.collection(UserSyncData.collectionName)
            .document(userId)
            .updateData([
                "\(UserSyncData.FieldKeys.swipePreferences.rawValue).dislikedMovieIds": FieldValue.arrayUnion([movieId])
            ])
        #else
        var userData = loadCachedUserData(for: userId) ?? UserSyncData.empty
        if !userData.swipePreferences.dislikedMovieIds.contains(movieId) {
            userData.swipePreferences.dislikedMovieIds.append(movieId)
            cacheUserData(userData, for: userId)
        }
        #endif
    }

    // MARK: - Streaming Services Operations

    /// Save streaming services
    func saveStreamingServices(_ services: [String], for userId: String) async throws {
        #if canImport(FirebaseFirestore)
        try await db.collection(UserSyncData.collectionName)
            .document(userId)
            .setData([UserSyncData.FieldKeys.streamingServices.rawValue: services], merge: true)
        #else
        var userData = loadCachedUserData(for: userId) ?? UserSyncData.empty
        userData.streamingServices = services
        cacheUserData(userData, for: userId)
        #endif
    }

    /// Fetch streaming services
    func fetchStreamingServices(for userId: String) async throws -> [String] {
        let userData = try await fetchUserData(for: userId)
        return userData.streamingServices
    }

    // MARK: - User Preferences Operations

    /// Save user preferences
    func savePreferences(_ prefs: SyncUserPreferences, for userId: String) async throws {
        #if canImport(FirebaseFirestore)
        let data = try encodeItem(prefs)
        try await db.collection(UserSyncData.collectionName)
            .document(userId)
            .setData([UserSyncData.FieldKeys.preferences.rawValue: data], merge: true)
        #else
        var userData = loadCachedUserData(for: userId) ?? UserSyncData.empty
        userData.preferences = prefs
        cacheUserData(userData, for: userId)
        #endif
    }

    // MARK: - Delete User Data

    /// Delete all user data (for account deletion)
    func deleteUserData(for userId: String) async throws {
        #if canImport(FirebaseFirestore)
        try await db.collection(UserSyncData.collectionName).document(userId).delete()
        #else
        clearCachedUserData(for: userId)
        #endif
    }

    // MARK: - Real-time Listeners

    #if canImport(FirebaseFirestore)
    /// Listen to watchlist changes in real-time
    func listenToWatchlist(for userId: String, onChange: @escaping ([SyncWatchlistItem]) -> Void) -> ListenerRegistration {
        return db.collection(UserSyncData.collectionName)
            .document(userId)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(),
                      let watchlistData = data[UserSyncData.FieldKeys.watchlist.rawValue] as? [[String: Any]] else {
                    onChange([])
                    return
                }

                let items = watchlistData.compactMap { dict -> SyncWatchlistItem? in
                    try? self.decodeItem(from: dict)
                }
                onChange(items)
            }
    }
    #endif

    // MARK: - Private Helpers

    #if canImport(FirebaseFirestore)
    private func encodeUserData(_ userData: UserSyncData) throws -> [String: Any] {
        var data: [String: Any] = [:]

        data[UserSyncData.FieldKeys.watchlist.rawValue] = try userData.watchlist.map { try encodeItem($0) }
        data[UserSyncData.FieldKeys.swipePreferences.rawValue] = try encodeItem(userData.swipePreferences)
        data[UserSyncData.FieldKeys.streamingServices.rawValue] = userData.streamingServices
        data[UserSyncData.FieldKeys.preferences.rawValue] = try encodeItem(userData.preferences)
        data[UserSyncData.FieldKeys.lastUpdated.rawValue] = Timestamp(date: userData.lastUpdated)
        data[UserSyncData.FieldKeys.appVersion.rawValue] = userData.appVersion

        return data
    }

    private func decodeUserData(from data: [String: Any]) throws -> UserSyncData {
        let watchlistData = data[UserSyncData.FieldKeys.watchlist.rawValue] as? [[String: Any]] ?? []
        let watchlist = watchlistData.compactMap { try? decodeItem(from: $0) as SyncWatchlistItem }

        let swipePrefsData = data[UserSyncData.FieldKeys.swipePreferences.rawValue] as? [String: Any] ?? [:]
        let swipePreferences = (try? decodeItem(from: swipePrefsData) as SyncSwipePreferences) ?? .empty

        let streamingServices = data[UserSyncData.FieldKeys.streamingServices.rawValue] as? [String] ?? []

        let prefsData = data[UserSyncData.FieldKeys.preferences.rawValue] as? [String: Any] ?? [:]
        let preferences = (try? decodeItem(from: prefsData) as SyncUserPreferences) ?? .default

        let lastUpdated = (data[UserSyncData.FieldKeys.lastUpdated.rawValue] as? Timestamp)?.dateValue() ?? Date()
        let appVersion = data[UserSyncData.FieldKeys.appVersion.rawValue] as? String ?? "1.0"

        return UserSyncData(
            watchlist: watchlist,
            swipePreferences: swipePreferences,
            streamingServices: streamingServices,
            preferences: preferences,
            lastUpdated: lastUpdated,
            appVersion: appVersion
        )
    }

    private func encodeItem<T: Encodable>(_ item: T) throws -> [String: Any] {
        let data = try encoder.encode(item)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "FirestoreService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode item"])
        }
        return dict
    }

    private func decodeItem<T: Decodable>(from dict: [String: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dict)
        return try decoder.decode(T.self, from: data)
    }
    #endif

    // MARK: - Local Cache (for development without Firebase)

    private func cacheUserData(_ userData: UserSyncData, for userId: String) {
        guard let data = try? encoder.encode(userData) else { return }
        UserDefaults.standard.set(data, forKey: "cachedUserData_\(userId)")
    }

    private func loadCachedUserData(for userId: String) -> UserSyncData? {
        guard let data = UserDefaults.standard.data(forKey: "cachedUserData_\(userId)"),
              let userData = try? decoder.decode(UserSyncData.self, from: data) else {
            return nil
        }
        return userData
    }

    private func clearCachedUserData(for userId: String) {
        UserDefaults.standard.removeObject(forKey: "cachedUserData_\(userId)")
    }
}

// MARK: - Convenience Extensions

extension FirestoreService {
    /// Convert Movie to SyncWatchlistItem
    func createWatchlistItem(from movie: Movie) -> SyncWatchlistItem {
        SyncWatchlistItem(from: movie)
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension FirestoreService {
    static func mock() -> FirestoreService {
        return FirestoreService.shared
    }
}
#endif
