//
//  Movie.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//

import Foundation

/// Core movie model representing TMDB API movie data
struct Movie: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let genreIds: [Int]
    let adult: Bool
    let originalLanguage: String
    let originalTitle: String
    let video: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case genreIds = "genre_ids"
        case adult
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case video
        // Note: media_type is ignored (only present in trending endpoint)
    }
    
    // Custom decoder to handle optional fields gracefully
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? ""
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage) ?? 0.0
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? 0
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity) ?? 0.0
        genreIds = try container.decodeIfPresent([Int].self, forKey: .genreIds) ?? []
        adult = try container.decodeIfPresent(Bool.self, forKey: .adult) ?? false
        originalLanguage = try container.decodeIfPresent(String.self, forKey: .originalLanguage) ?? ""
        originalTitle = try container.decodeIfPresent(String.self, forKey: .originalTitle) ?? title
        video = try container.decodeIfPresent(Bool.self, forKey: .video) ?? false
    }
    
    // Memberwise initializer for creating instances manually (e.g., previews)
    init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        releaseDate: String?,
        voteAverage: Double,
        voteCount: Int,
        popularity: Double,
        genreIds: [Int],
        adult: Bool,
        originalLanguage: String,
        originalTitle: String,
        video: Bool
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.genreIds = genreIds
        self.adult = adult
        self.originalLanguage = originalLanguage
        self.originalTitle = originalTitle
        self.video = video
    }

    
    // MARK: - Computed Properties
    
    /// Full URL for poster image (w500 size)
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    /// Full URL for backdrop image (original size)
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
    
    /// Formatted rating (e.g., "8.5")
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    /// Rating percentage (0-100)
    var ratingPercentage: Int {
        Int((voteAverage / 10.0) * 100)
    }

    /// Genre names mapped from genre IDs
    var genreNames: [String]? {
        guard !genreIds.isEmpty else { return nil }
        let genreMap: [Int: String] = [
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
            878: "Sci-Fi",
            10770: "TV Movie",
            53: "Thriller",
            10752: "War",
            37: "Western"
        ]
        return genreIds.compactMap { genreMap[$0] }
    }
    
    // MARK: - Hashable Implementation
    
    /// Custom hash implementation using only ID for uniqueness
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /// Custom equality check using only ID
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Movie {
    /// Sample movie for SwiftUI previews
    static let sample = Movie(
        id: 550,
        title: "Fight Club",
        overview: "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.",
        posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        backdropPath: "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
        releaseDate: "1999-10-15",
        voteAverage: 8.433,
        voteCount: 28542,
        popularity: 89.234,
        genreIds: [18, 53, 35],
        adult: false,
        originalLanguage: "en",
        originalTitle: "Fight Club",
        video: false
    )
    
    /// Array of sample movies for list previews
    static let samples = [
        Movie.sample,
        Movie(
            id: 238,
            title: "The Godfather",
            overview: "Spanning the years 1945 to 1955, a chronicle of the fictional Italian-American Corleone crime family.",
            posterPath: "/3bhkrj58Vtu7enYsRolD1fZdja1.jpg",
            backdropPath: "/tmU7GeKVybMWFButWEGl2M4GeiP.jpg",
            releaseDate: "1972-03-14",
            voteAverage: 8.7,
            voteCount: 19284,
            popularity: 156.789,
            genreIds: [18, 80],
            adult: false,
            originalLanguage: "en",
            originalTitle: "The Godfather",
            video: false
        ),
        Movie(
            id: 278,
            title: "The Shawshank Redemption",
            overview: "Imprisoned in the 1940s for the double murder of his wife and her lover, upstanding banker Andy Dufresne begins a new life at the Shawshank prison.",
            posterPath: "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
            backdropPath: "/kXfqcdQKsToO0OUXHcrrNCHDBzO.jpg",
            releaseDate: "1994-09-23",
            voteAverage: 8.7,
            voteCount: 25847,
            popularity: 134.567,
            genreIds: [18, 80],
            adult: false,
            originalLanguage: "en",
            originalTitle: "The Shawshank Redemption",
            video: false
        )
    ]
}
#endif
