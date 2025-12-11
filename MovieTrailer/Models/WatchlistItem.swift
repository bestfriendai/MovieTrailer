//
//  WatchlistItem.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//

import Foundation

/// Local persistence model for watchlist items
struct WatchlistItem: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let genreIds: [Int]
    let addedAt: Date
    
    // MARK: - Initialization
    
    /// Create watchlist item from Movie
    init(from movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.genreIds = movie.genreIds
        self.addedAt = Date()
    }
    
    /// Direct initialization (for decoding)
    init(
        id: Int,
        title: String,
        posterPath: String?,
        releaseDate: String?,
        voteAverage: Double,
        genreIds: [Int],
        addedAt: Date
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.genreIds = genreIds
        self.addedAt = addedAt
    }
    
    // MARK: - Computed Properties
    
    /// Full URL for poster image
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    /// Formatted release year
    var releaseYear: String? {
        guard let releaseDate = releaseDate,
              let year = releaseDate.split(separator: "-").first else {
            return nil
        }
        return String(year)
    }
    
    /// Formatted rating
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    /// Genre names
    var genreNames: [String] {
        Genre.names(for: genreIds)
    }
    
    /// Formatted genre string
    var formattedGenres: String {
        Genre.formattedString(for: genreIds)
    }
    
    /// Time since added (e.g., "2 hours ago", "3 days ago")
    var timeSinceAdded: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: addedAt, relativeTo: Date())
    }
    
    /// Convert back to Movie model
    func toMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            overview: "", // Not stored in watchlist
            posterPath: posterPath,
            backdropPath: nil, // Not stored in watchlist
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: 0, // Not stored in watchlist
            popularity: 0, // Not stored in watchlist
            genreIds: genreIds,
            adult: false,
            originalLanguage: "",
            originalTitle: title,
            video: false
        )
    }
}

// MARK: - Sorting

extension WatchlistItem {
    enum SortOption: CaseIterable {
        case dateAdded
        case title
        case rating
        case releaseDate
        
        var displayName: String {
            switch self {
            case .dateAdded:
                return "Date Added"
            case .title:
                return "Title"
            case .rating:
                return "Rating"
            case .releaseDate:
                return "Release Date"
            }
        }
        
        var comparator: (WatchlistItem, WatchlistItem) -> Bool {
            switch self {
            case .dateAdded:
                return { $0.addedAt > $1.addedAt } // Newest first
            case .title:
                return { $0.title < $1.title } // A-Z
            case .rating:
                return { $0.voteAverage > $1.voteAverage } // Highest first
            case .releaseDate:
                return { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") } // Newest first
            }
        }
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension WatchlistItem {
    /// Sample watchlist item for previews
    static let sample = WatchlistItem(
        id: 550,
        title: "Fight Club",
        posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        releaseDate: "1999-10-15",
        voteAverage: 8.433,
        genreIds: [18, 53, 35],
        addedAt: Date().addingTimeInterval(-3600 * 24 * 2) // 2 days ago
    )
    
    /// Array of sample watchlist items
    static let samples = [
        WatchlistItem.sample,
        WatchlistItem(
            id: 238,
            title: "The Godfather",
            posterPath: "/3bhkrj58Vtu7enYsRolD1fZdja1.jpg",
            releaseDate: "1972-03-14",
            voteAverage: 8.7,
            genreIds: [18, 80],
            addedAt: Date().addingTimeInterval(-3600 * 24 * 5) // 5 days ago
        ),
        WatchlistItem(
            id: 278,
            title: "The Shawshank Redemption",
            posterPath: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
            releaseDate: "1994-09-23",
            voteAverage: 8.7,
            genreIds: [18, 80],
            addedAt: Date().addingTimeInterval(-3600 * 24) // 1 day ago
        )
    ]
}
#endif
