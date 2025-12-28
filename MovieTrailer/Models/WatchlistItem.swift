//
//  WatchlistItem.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//  Enhanced: Full movie data preservation for detail view display
//

import Foundation

/// Local persistence model for watchlist items
/// Enhanced to preserve all movie data for detail view display
struct WatchlistItem: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let genreIds: [Int]
    let addedAt: Date

    // MARK: - Enhanced Fields (preserve movie data - fixes data loss)

    let overview: String
    let backdropPath: String?
    let voteCount: Int
    let popularity: Double
    let originalLanguage: String
    let originalTitle: String

    // MARK: - Initialization

    /// Create watchlist item from Movie - preserves ALL data
    init(from movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.genreIds = movie.genreIds
        self.addedAt = Date()
        // Enhanced fields - no more data loss!
        self.overview = movie.overview
        self.backdropPath = movie.backdropPath
        self.voteCount = movie.voteCount
        self.popularity = movie.popularity
        self.originalLanguage = movie.originalLanguage
        self.originalTitle = movie.originalTitle
    }

    /// Direct initialization (for decoding and previews)
    init(
        id: Int,
        title: String,
        posterPath: String?,
        releaseDate: String?,
        voteAverage: Double,
        genreIds: [Int],
        addedAt: Date,
        overview: String = "",
        backdropPath: String? = nil,
        voteCount: Int = 0,
        popularity: Double = 0,
        originalLanguage: String = "en",
        originalTitle: String? = nil
    ) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.genreIds = genreIds
        self.addedAt = addedAt
        self.overview = overview
        self.backdropPath = backdropPath
        self.voteCount = voteCount
        self.popularity = popularity
        self.originalLanguage = originalLanguage
        self.originalTitle = originalTitle ?? title
    }

    // MARK: - Codable Migration Support

    /// Custom decoder to handle old items without enhanced fields
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        genreIds = try container.decode([Int].self, forKey: .genreIds)
        addedAt = try container.decode(Date.self, forKey: .addedAt)

        // Gracefully handle missing enhanced fields (migration support)
        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? ""
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? 0
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity) ?? 0
        originalLanguage = try container.decodeIfPresent(String.self, forKey: .originalLanguage) ?? "en"
        originalTitle = try container.decodeIfPresent(String.self, forKey: .originalTitle) ?? title
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, posterPath, releaseDate, voteAverage, genreIds, addedAt
        case overview, backdropPath, voteCount, popularity, originalLanguage, originalTitle
    }

    // MARK: - Computed Properties

    /// Full URL for poster image
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    /// Full URL for backdrop image
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
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

    /// Convert back to Movie model - NOW WITH FULL DATA!
    func toMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: popularity,
            genreIds: genreIds,
            adult: false,
            originalLanguage: originalLanguage,
            originalTitle: originalTitle,
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
                return { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending } // A-Z (locale aware)
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
    /// Sample watchlist item for previews - with full data
    static let sample = WatchlistItem(
        id: 550,
        title: "Fight Club",
        posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        releaseDate: "1999-10-15",
        voteAverage: 8.433,
        genreIds: [18, 53, 35],
        addedAt: Date().addingTimeInterval(-3600 * 24 * 2),
        overview: "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.",
        backdropPath: "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
        voteCount: 28542,
        popularity: 89.234,
        originalLanguage: "en",
        originalTitle: "Fight Club"
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
            addedAt: Date().addingTimeInterval(-3600 * 24 * 5),
            overview: "Spanning the years 1945 to 1955, a chronicle of the fictional Italian-American Corleone crime family.",
            backdropPath: "/tmU7GeKVybMWFButWEGl2M4GeiP.jpg",
            voteCount: 19284,
            popularity: 156.789,
            originalLanguage: "en",
            originalTitle: "The Godfather"
        ),
        WatchlistItem(
            id: 278,
            title: "The Shawshank Redemption",
            posterPath: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
            releaseDate: "1994-09-23",
            voteAverage: 8.7,
            genreIds: [18, 80],
            addedAt: Date().addingTimeInterval(-3600 * 24),
            overview: "Imprisoned in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison.",
            backdropPath: "/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
            voteCount: 25847,
            popularity: 134.567,
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption"
        )
    ]
}
#endif
