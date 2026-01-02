//
//  PreferenceLearningEngine.swift
//  MovieTrailer
//

import Foundation

actor PreferenceLearningEngine {
    
    // MARK: - Properties
    
    private var genreScores: [Int: Double] = [:]
    private var actorScores: [Int: Double] = [:]
    private var directorScores: [Int: Double] = [:]
    private var avgPreferredRating: Double = 7.0
    private var avgPreferredRuntime: Int = 120
    private var interactionCount: Int = 0
    
    private let storageKey = "preference_learning_data"
    
    // MARK: - Initialization
    
    init() {
        Task {
            await loadPreferences()
        }
    }
    
    // MARK: - Record Interactions
    
    func recordInteraction(_ movie: Movie, action: UserAction) {
        let weight = action.weight
        
        for genreId in movie.genreIds {
            genreScores[genreId, default: 0] += weight
        }
        
        if action == .liked || action == .superLiked {
            avgPreferredRating = (avgPreferredRating * 0.9) + (movie.voteAverage * 0.1)
        }
        
        interactionCount += 1
        
        if interactionCount % 10 == 0 {
            Task { await savePreferences() }
        }
    }
    
    func recordCastInteraction(actorId: Int, liked: Bool) {
        let weight = liked ? 1.0 : -0.3
        actorScores[actorId, default: 0] += weight
    }
    
    func recordDirectorInteraction(directorId: Int, liked: Bool) {
        let weight = liked ? 1.5 : -0.5
        directorScores[directorId, default: 0] += weight
    }
    
    // MARK: - Score Movies
    
    func score(_ movie: Movie) -> Double {
        var score: Double = 0
        
        let genreScore = movie.genreIds.reduce(0.0) { sum, id in
            sum + (genreScores[id] ?? 0)
        } / max(Double(movie.genreIds.count), 1)
        score += genreScore * 0.4
        
        let ratingDiff = abs(movie.voteAverage - avgPreferredRating)
        let ratingScore = max(0, 10 - ratingDiff) / 10
        score += ratingScore * 0.3
        
        if let year = movie.releaseYear, let yearInt = Int(year) {
            let currentYear = Calendar.current.component(.year, from: Date())
            let agePenalty = max(0, 1 - Double(currentYear - yearInt) / 20)
            score += agePenalty * 0.2
        }
        
        let popularityScore = min(movie.popularity / 100, 1.0)
        score += popularityScore * 0.1
        
        return score
    }
    
    func getRecommendations(from movies: [Movie], limit: Int = 20) -> [Movie] {
        var scoredMovies: [(Movie, Double)] = []
        
        for movie in movies {
            let movieScore = score(movie)
            scoredMovies.append((movie, movieScore))
        }
        
        return scoredMovies
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }
    
    // MARK: - Top Preferences
    
    func topGenres(limit: Int = 5) -> [Int] {
        genreScores
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { $0.key }
    }
    
    func topActors(limit: Int = 10) -> [Int] {
        actorScores
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { $0.key }
    }
    
    func preferredRatingRange() -> ClosedRange<Double> {
        let lower = max(0, avgPreferredRating - 2)
        let upper = min(10, avgPreferredRating + 1)
        return lower...upper
    }
    
    // MARK: - Persistence
    
    private func savePreferences() {
        let data = PreferenceData(
            genreScores: genreScores,
            actorScores: actorScores,
            directorScores: directorScores,
            avgPreferredRating: avgPreferredRating,
            avgPreferredRuntime: avgPreferredRuntime,
            interactionCount: interactionCount
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadPreferences() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(PreferenceData.self, from: data) else {
            return
        }
        
        genreScores = decoded.genreScores
        actorScores = decoded.actorScores
        directorScores = decoded.directorScores
        avgPreferredRating = decoded.avgPreferredRating
        avgPreferredRuntime = decoded.avgPreferredRuntime
        interactionCount = decoded.interactionCount
    }
    
    func reset() {
        genreScores = [:]
        actorScores = [:]
        directorScores = [:]
        avgPreferredRating = 7.0
        avgPreferredRuntime = 120
        interactionCount = 0
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    // MARK: - Types
    
    enum UserAction {
        case viewed
        case liked
        case superLiked
        case skipped
        case watchLater
        
        var weight: Double {
            switch self {
            case .superLiked: return 2.0
            case .liked: return 1.0
            case .watchLater: return 0.5
            case .viewed: return 0.2
            case .skipped: return -0.3
            }
        }
    }
    
    private struct PreferenceData: Codable {
        let genreScores: [Int: Double]
        let actorScores: [Int: Double]
        let directorScores: [Int: Double]
        let avgPreferredRating: Double
        let avgPreferredRuntime: Int
        let interactionCount: Int
    }
}
