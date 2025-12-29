//
//  RecommendationEngine.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Personalized movie recommendation engine based on user preferences
//

import Foundation

// MARK: - Swipe Preference

struct SwipePreference: Codable, Identifiable {
    let id: UUID
    let movieId: Int
    let action: SwipeAction
    let genres: [Int]
    let rating: Double
    let releaseYear: String?
    let timestamp: Date

    init(
        movieId: Int,
        action: SwipeAction,
        genres: [Int],
        rating: Double,
        releaseYear: String? = nil
    ) {
        self.id = UUID()
        self.movieId = movieId
        self.action = action
        self.genres = genres
        self.rating = rating
        self.releaseYear = releaseYear
        self.timestamp = Date()
    }
}

// MARK: - Swipe Action

enum SwipeAction: String, Codable {
    case liked
    case superLiked
    case skipped
    case watchLater

    var weight: Double {
        switch self {
        case .superLiked: return 2.5
        case .liked: return 1.5
        case .watchLater: return 1.0
        case .skipped: return -0.5
        }
    }

    var displayName: String {
        switch self {
        case .superLiked: return "Loved"
        case .liked: return "Liked"
        case .watchLater: return "Watch Later"
        case .skipped: return "Skipped"
        }
    }
}

// MARK: - Recommendation Engine

actor RecommendationEngine {

    // MARK: - Singleton

    static let shared = RecommendationEngine()

    // MARK: - Properties

    private var swipeHistory: [SwipePreference] = []
    private var genreWeights: [Int: Double] = [:]
    private var preferredRatingRange: ClosedRange<Double> = 6.0...10.0
    private var preferredDecades: [String: Double] = [:]

    private let maxHistorySize = 500
    private let historyRetentionDays = 90

    // MARK: - File URL

    private var preferencesURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("recommendation_preferences.json")
    }

    // MARK: - Initialization

    init() {
        Task {
            await loadPreferences()
        }
    }

    // MARK: - Public Methods

    /// Record a swipe action
    func recordSwipe(
        movieId: Int,
        action: SwipeAction,
        genres: [Int],
        rating: Double,
        releaseYear: String? = nil
    ) async {
        let preference = SwipePreference(
            movieId: movieId,
            action: action,
            genres: genres,
            rating: rating,
            releaseYear: releaseYear
        )

        swipeHistory.append(preference)
        await updateWeights(from: preference)
        await trimHistory()
        await savePreferences()
    }

    /// Record from a Movie object
    func recordSwipe(movie: Movie, action: SwipeAction) async {
        await recordSwipe(
            movieId: movie.id,
            action: action,
            genres: movie.genreIds,
            rating: movie.voteAverage,
            releaseYear: movie.releaseYear
        )
    }

    /// Score a movie based on user preferences
    func score(movie: Movie) async -> Double {
        var score: Double = 50 // Base score

        // Genre matching (up to +30)
        let genreScore = movie.genreIds.reduce(0.0) { sum, genreId in
            sum + (genreWeights[genreId] ?? 0)
        }
        score += min(30, max(-20, genreScore * 5))

        // Rating preference (up to +15)
        if preferredRatingRange.contains(movie.voteAverage) {
            score += 15
        } else {
            let distance = min(
                abs(movie.voteAverage - preferredRatingRange.lowerBound),
                abs(movie.voteAverage - preferredRatingRange.upperBound)
            )
            score -= distance * 2
        }

        // High-rated bonus (up to +10)
        if movie.voteAverage >= 7.5 {
            score += (movie.voteAverage - 7.5) * 4
        }

        // Popularity factor (up to +5)
        if movie.voteCount > 1000 {
            score += min(5, Double(movie.voteCount) / 2000)
        }

        // Recency bonus (up to +10)
        if let year = movie.releaseYear, let yearInt = Int(year) {
            let currentYear = Calendar.current.component(.year, from: Date())
            if yearInt >= currentYear - 1 {
                score += 10
            } else if yearInt >= currentYear - 3 {
                score += 5
            }

            // Decade preference
            let decade = "\(yearInt / 10 * 10)s"
            if let decadeWeight = preferredDecades[decade] {
                score += decadeWeight * 5
            }
        }

        // Already swiped penalty
        if swipeHistory.contains(where: { $0.movieId == movie.id }) {
            score -= 50 // Heavily penalize already seen movies
        }

        return max(0, min(100, score))
    }

    /// Sort movies by recommendation score
    func sortByRecommendation(_ movies: [Movie]) async -> [Movie] {
        var scored: [(movie: Movie, score: Double)] = []

        for movie in movies {
            let movieScore = await score(movie: movie)
            scored.append((movie, movieScore))
        }

        return scored
            .sorted { $0.score > $1.score }
            .map(\.movie)
    }

    /// Filter out already-swiped movies
    func filterSwipedMovies(_ movies: [Movie]) async -> [Movie] {
        let swipedIds = Set(swipeHistory.map(\.movieId))
        return movies.filter { !swipedIds.contains($0.id) }
    }

    /// Get top preferred genres
    func getTopGenres(limit: Int = 5) async -> [Int] {
        genreWeights
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map(\.key)
    }

    /// Get disliked genres
    func getDislikedGenres() async -> [Int] {
        genreWeights
            .filter { $0.value < -1 }
            .sorted { $0.value < $1.value }
            .prefix(3)
            .map(\.key)
    }

    /// Generate personalized quick filters
    func generateQuickFilters() async -> [PersonalizedFilter] {
        var filters: [PersonalizedFilter] = []

        let topGenres = await getTopGenres(limit: 3)

        // Genre-based filters
        for genreId in topGenres {
            if let genreName = GenreHelper.name(for: genreId) {
                filters.append(PersonalizedFilter(
                    id: "genre_\(genreId)",
                    name: genreName,
                    icon: GenreHelper.icon(for: genreId),
                    filterCriteria: .genre(genreId)
                ))
            }
        }

        // Rating-based filter
        let avgRating = calculateAveragePreferredRating()
        if avgRating >= 7.5 {
            filters.append(PersonalizedFilter(
                id: "high_rated",
                name: "Critically Acclaimed",
                icon: "star.fill",
                filterCriteria: .minRating(7.5)
            ))
        }

        // Time-based
        filters.append(PersonalizedFilter(
            id: "new_releases",
            name: "New Releases",
            icon: "sparkles",
            filterCriteria: .yearRange(2024, 2025)
        ))

        return filters
    }

    /// Get user taste profile
    func getTasteProfile() async -> TasteProfile {
        let topGenres = await getTopGenres(limit: 5)
        let avgRating = calculateAveragePreferredRating()
        let totalSwipes = swipeHistory.count
        let likeRate = Double(swipeHistory.filter { $0.action == .liked || $0.action == .superLiked }.count) / max(1, Double(totalSwipes))

        return TasteProfile(
            topGenres: topGenres,
            averagePreferredRating: avgRating,
            totalMoviesRated: totalSwipes,
            likeRate: likeRate,
            preferredDecades: Array(preferredDecades.filter { $0.value > 0.5 }.keys)
        )
    }

    /// Clear all preferences
    func clearAllPreferences() async {
        swipeHistory.removeAll()
        genreWeights.removeAll()
        preferredDecades.removeAll()
        preferredRatingRange = 6.0...10.0

        if let url = preferencesURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Private Methods

    private func updateWeights(from preference: SwipePreference) async {
        let weight = preference.action.weight

        // Update genre weights
        for genreId in preference.genres {
            genreWeights[genreId, default: 0] += weight
        }

        // Update rating preference
        if preference.action == .liked || preference.action == .superLiked {
            // Expand preferred range towards this rating
            let lower = min(preferredRatingRange.lowerBound, preference.rating - 0.5)
            let upper = max(preferredRatingRange.upperBound, preference.rating + 0.5)
            preferredRatingRange = max(0, lower)...min(10, upper)
        }

        // Update decade preference
        if let year = preference.releaseYear, let yearInt = Int(year) {
            let decade = "\(yearInt / 10 * 10)s"
            preferredDecades[decade, default: 0] += weight * 0.3
        }
    }

    private func trimHistory() async {
        // Remove entries older than retention period
        let cutoff = Date().addingTimeInterval(-Double(historyRetentionDays * 24 * 60 * 60))
        swipeHistory = swipeHistory.filter { $0.timestamp > cutoff }

        // Limit total size
        if swipeHistory.count > maxHistorySize {
            swipeHistory = Array(swipeHistory.suffix(maxHistorySize))
        }
    }

    private func calculateAveragePreferredRating() -> Double {
        let likedRatings = swipeHistory
            .filter { $0.action == .liked || $0.action == .superLiked }
            .map(\.rating)

        guard !likedRatings.isEmpty else { return 7.0 }
        return likedRatings.reduce(0, +) / Double(likedRatings.count)
    }

    private func loadPreferences() async {
        guard let url = preferencesURL,
              FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let saved = try decoder.decode(SavedPreferences.self, from: data)
            self.swipeHistory = saved.swipeHistory
            self.genreWeights = saved.genreWeights
            self.preferredDecades = saved.preferredDecades

            if let lower = saved.preferredRatingLower,
               let upper = saved.preferredRatingUpper {
                self.preferredRatingRange = lower...upper
            }

            print("✅ Loaded recommendation preferences (\(swipeHistory.count) swipes)")
        } catch {
            print("❌ Failed to load preferences: \(error)")
        }
    }

    private func savePreferences() async {
        guard let url = preferencesURL else { return }

        let saved = SavedPreferences(
            swipeHistory: swipeHistory,
            genreWeights: genreWeights,
            preferredDecades: preferredDecades,
            preferredRatingLower: preferredRatingRange.lowerBound,
            preferredRatingUpper: preferredRatingRange.upperBound
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(saved)
            try data.write(to: url, options: .atomic)
        } catch {
            print("❌ Failed to save preferences: \(error)")
        }
    }
}

// MARK: - Supporting Types

struct SavedPreferences: Codable {
    let swipeHistory: [SwipePreference]
    let genreWeights: [Int: Double]
    let preferredDecades: [String: Double]
    let preferredRatingLower: Double?
    let preferredRatingUpper: Double?
}

struct PersonalizedFilter: Identifiable {
    let id: String
    let name: String
    let icon: String
    let filterCriteria: FilterCriteria

    enum FilterCriteria {
        case genre(Int)
        case minRating(Double)
        case yearRange(Int, Int)
        case popularity(Int)
    }
}

struct TasteProfile {
    let topGenres: [Int]
    let averagePreferredRating: Double
    let totalMoviesRated: Int
    let likeRate: Double
    let preferredDecades: [String]

    var genreNames: [String] {
        topGenres.compactMap { GenreHelper.name(for: $0) }
    }

    var description: String {
        """
        Your Taste Profile:
        - Favorite Genres: \(genreNames.joined(separator: ", "))
        - Preferred Rating: \(String(format: "%.1f", averagePreferredRating))+
        - Movies Rated: \(totalMoviesRated)
        - Like Rate: \(Int(likeRate * 100))%
        - Favorite Eras: \(preferredDecades.joined(separator: ", "))
        """
    }
}

// MARK: - Genre Helper

enum GenreHelper {
    static func name(for id: Int) -> String? {
        genreMap[id]
    }

    static func icon(for id: Int) -> String {
        iconMap[id] ?? "film"
    }

    private static let genreMap: [Int: String] = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Science Fiction",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]

    private static let iconMap: [Int: String] = [
        28: "bolt.fill",
        12: "map.fill",
        16: "sparkles",
        35: "face.smiling.fill",
        80: "exclamationmark.shield.fill",
        99: "doc.text.fill",
        18: "theatermasks.fill",
        10751: "figure.2.and.child.holdinghands",
        14: "wand.and.stars",
        36: "clock.fill",
        27: "moon.fill",
        10402: "music.note",
        9648: "magnifyingglass",
        10749: "heart.fill",
        878: "atom",
        10770: "tv.fill",
        53: "exclamationmark.triangle.fill",
        10752: "airplane",
        37: "sun.dust.fill"
    ]
}
