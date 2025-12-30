//
//  UserSyncData.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Models for syncing user data with Firestore
//

import Foundation

// MARK: - User Sync Data

/// Complete user data structure for Firestore sync
struct UserSyncData: Codable {

    // MARK: - Properties

    /// User's watchlist items
    var watchlist: [SyncWatchlistItem]

    /// User's swipe preferences (likes/dislikes)
    var swipePreferences: SyncSwipePreferences

    /// Selected streaming services
    var streamingServices: [String]

    /// App preferences
    var preferences: SyncUserPreferences

    /// Last sync timestamp
    var lastUpdated: Date

    /// App version when last synced
    var appVersion: String

    // MARK: - Initialization

    init(
        watchlist: [SyncWatchlistItem] = [],
        swipePreferences: SyncSwipePreferences = .empty,
        streamingServices: [String] = [],
        preferences: SyncUserPreferences = .default,
        lastUpdated: Date = Date(),
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    ) {
        self.watchlist = watchlist
        self.swipePreferences = swipePreferences
        self.streamingServices = streamingServices
        self.preferences = preferences
        self.lastUpdated = lastUpdated
        self.appVersion = appVersion
    }

    // MARK: - Empty State

    static let empty = UserSyncData()
}

// MARK: - Sync Watchlist Item

/// Watchlist item for Firestore sync
struct SyncWatchlistItem: Codable, Identifiable, Equatable {

    /// Movie ID from TMDB
    let id: Int

    /// Movie title (cached for offline display)
    let title: String

    /// Poster path for image
    let posterPath: String?

    /// Release date string
    let releaseDate: String?

    /// Vote average
    let voteAverage: Double

    /// When added to watchlist
    let addedAt: Date

    /// Whether user has watched this movie
    var watched: Bool

    /// When user marked as watched
    var watchedAt: Date?

    /// User's personal rating (1-10)
    var userRating: Int?

    /// User's notes
    var notes: String?

    // MARK: - Initialization from Movie

    init(from movie: Movie, watched: Bool = false) {
        self.id = movie.id
        self.title = movie.title
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.addedAt = Date()
        self.watched = watched
        self.watchedAt = nil
        self.userRating = nil
        self.notes = nil
    }

    init(
        id: Int,
        title: String,
        posterPath: String?,
        releaseDate: String?,
        voteAverage: Double,
        addedAt: Date,
        watched: Bool,
        watchedAt: Date? = nil,
        userRating: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.addedAt = addedAt
        self.watched = watched
        self.watchedAt = watchedAt
        self.userRating = userRating
        self.notes = notes
    }
}

// MARK: - Sync Swipe Preferences

/// User's swipe history for recommendations
struct SyncSwipePreferences: Codable, Equatable {

    /// Movie IDs the user liked (swiped right)
    var likedMovieIds: [Int]

    /// Movie IDs the user disliked (swiped left)
    var dislikedMovieIds: [Int]

    /// Movie IDs the user super-liked (swiped up)
    var superLikedMovieIds: [Int]

    /// Movie IDs the user wants to watch later
    var watchLaterIds: [Int]

    /// Genre preferences learned from swipes (genre ID -> weight)
    var genreWeights: [String: Double]

    // MARK: - Empty State

    static let empty = SyncSwipePreferences(
        likedMovieIds: [],
        dislikedMovieIds: [],
        superLikedMovieIds: [],
        watchLaterIds: [],
        genreWeights: [:]
    )

    // MARK: - Computed Properties

    /// All movie IDs that have been swiped
    var allSwipedIds: Set<Int> {
        Set(likedMovieIds + dislikedMovieIds + superLikedMovieIds)
    }

    /// Total number of swipes
    var totalSwipes: Int {
        likedMovieIds.count + dislikedMovieIds.count + superLikedMovieIds.count
    }
}

// MARK: - Sync User Preferences

/// User's app preferences for sync
struct SyncUserPreferences: Codable, Equatable {

    /// Preferred content language
    var preferredLanguage: String

    /// Include adult content
    var includeAdult: Bool

    /// Preferred region for content
    var region: String

    /// Notification settings
    var notificationsEnabled: Bool

    /// Dark mode preference
    var prefersDarkMode: Bool

    /// Has completed onboarding
    var hasCompletedOnboarding: Bool

    /// Has seen swipe tutorial
    var hasSeenSwipeTutorial: Bool

    // MARK: - Default

    static let `default` = SyncUserPreferences(
        preferredLanguage: Locale.current.language.languageCode?.identifier ?? "en",
        includeAdult: false,
        region: Locale.current.region?.identifier ?? "US",
        notificationsEnabled: true,
        prefersDarkMode: true,
        hasCompletedOnboarding: false,
        hasSeenSwipeTutorial: false
    )
}

// MARK: - Firestore Document Keys

extension UserSyncData {
    /// Firestore collection name
    static let collectionName = "users"

    /// Document field keys
    enum FieldKeys: String {
        case watchlist
        case swipePreferences
        case streamingServices
        case preferences
        case lastUpdated
        case appVersion
    }
}

// MARK: - Merge Strategy

extension UserSyncData {
    /// Merge local data with remote data (remote wins for conflicts)
    func merging(with remote: UserSyncData) -> UserSyncData {
        // Merge watchlists - keep both, remote wins for duplicates
        var mergedWatchlist = self.watchlist
        for remoteItem in remote.watchlist {
            if let index = mergedWatchlist.firstIndex(where: { $0.id == remoteItem.id }) {
                // Remote wins for duplicates
                mergedWatchlist[index] = remoteItem
            } else {
                mergedWatchlist.append(remoteItem)
            }
        }

        // Merge swipe preferences - combine unique IDs
        let mergedSwipePrefs = SyncSwipePreferences(
            likedMovieIds: Array(Set(self.swipePreferences.likedMovieIds + remote.swipePreferences.likedMovieIds)),
            dislikedMovieIds: Array(Set(self.swipePreferences.dislikedMovieIds + remote.swipePreferences.dislikedMovieIds)),
            superLikedMovieIds: Array(Set(self.swipePreferences.superLikedMovieIds + remote.swipePreferences.superLikedMovieIds)),
            watchLaterIds: Array(Set(self.swipePreferences.watchLaterIds + remote.swipePreferences.watchLaterIds)),
            genreWeights: remote.swipePreferences.genreWeights // Remote wins
        )

        // Merge streaming services - combine unique
        let mergedServices = Array(Set(self.streamingServices + remote.streamingServices))

        return UserSyncData(
            watchlist: mergedWatchlist,
            swipePreferences: mergedSwipePrefs,
            streamingServices: mergedServices,
            preferences: remote.preferences, // Remote wins for preferences
            lastUpdated: Date(),
            appVersion: self.appVersion
        )
    }
}

// MARK: - Preview Data

#if DEBUG
extension UserSyncData {
    static let sample = UserSyncData(
        watchlist: [
            SyncWatchlistItem(
                id: 550,
                title: "Fight Club",
                posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
                releaseDate: "1999-10-15",
                voteAverage: 8.4,
                addedAt: Date(),
                watched: false
            ),
            SyncWatchlistItem(
                id: 680,
                title: "Pulp Fiction",
                posterPath: "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg",
                releaseDate: "1994-09-10",
                voteAverage: 8.5,
                addedAt: Date().addingTimeInterval(-86400),
                watched: true,
                watchedAt: Date()
            )
        ],
        swipePreferences: SyncSwipePreferences(
            likedMovieIds: [550, 680, 278],
            dislikedMovieIds: [299536],
            superLikedMovieIds: [27205],
            watchLaterIds: [],
            genreWeights: ["28": 0.8, "18": 0.7, "53": 0.6]
        ),
        streamingServices: ["netflix", "disney", "hbo"],
        preferences: .default,
        lastUpdated: Date(),
        appVersion: "1.0"
    )
}
#endif
