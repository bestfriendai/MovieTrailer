//
//  Genre.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//

import Foundation

/// Movie genre model
struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

// MARK: - Genre Constants

extension Genre {
    /// Common TMDB genre IDs and names
    static let action = Genre(id: 28, name: "Action")
    static let adventure = Genre(id: 12, name: "Adventure")
    static let animation = Genre(id: 16, name: "Animation")
    static let comedy = Genre(id: 35, name: "Comedy")
    static let crime = Genre(id: 80, name: "Crime")
    static let documentary = Genre(id: 99, name: "Documentary")
    static let drama = Genre(id: 18, name: "Drama")
    static let family = Genre(id: 10751, name: "Family")
    static let fantasy = Genre(id: 14, name: "Fantasy")
    static let history = Genre(id: 36, name: "History")
    static let horror = Genre(id: 27, name: "Horror")
    static let music = Genre(id: 10402, name: "Music")
    static let mystery = Genre(id: 9648, name: "Mystery")
    static let romance = Genre(id: 10749, name: "Romance")
    static let scienceFiction = Genre(id: 878, name: "Science Fiction")
    static let tvMovie = Genre(id: 10770, name: "TV Movie")
    static let thriller = Genre(id: 53, name: "Thriller")
    static let war = Genre(id: 10752, name: "War")
    static let western = Genre(id: 37, name: "Western")
    
    /// All available genres
    static let all: [Genre] = [
        .action, .adventure, .animation, .comedy, .crime,
        .documentary, .drama, .family, .fantasy, .history,
        .horror, .music, .mystery, .romance, .scienceFiction,
        .tvMovie, .thriller, .war, .western
    ]
    
    /// Get genre by ID
    static func genre(for id: Int) -> Genre? {
        all.first { $0.id == id }
    }
    
    /// Get genre names for array of IDs
    static func names(for ids: [Int]) -> [String] {
        ids.compactMap { id in
            genre(for: id)?.name
        }
    }
    
    /// Get formatted genre string (e.g., "Action, Drama, Thriller")
    static func formattedString(for ids: [Int]) -> String {
        names(for: ids).joined(separator: ", ")
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Genre {
    /// Sample genres for previews
    static let samples: [Genre] = [.action, .drama, .thriller]
}
#endif
