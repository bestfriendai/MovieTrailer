//
//  MovieCollection.swift
//  MovieTrailer
//
//  TMDB Movie Collection Models
//  Franchises like MCU, Harry Potter, Fast & Furious
//

import Foundation

// MARK: - Collection Info (Basic)

/// Basic collection info included in movie details
struct CollectionInfo: Codable, Identifiable {
    let id: Int
    let name: String
    let posterPath: String?
    let backdropPath: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }

    // MARK: - Computed Properties

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(path)")
    }
}

// MARK: - Full Collection Details

/// Full collection details with all movies
struct MovieCollection: Codable, Identifiable {
    let id: Int
    let name: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let parts: [CollectionPart]

    enum CodingKeys: String, CodingKey {
        case id, name, overview, parts
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }

    // MARK: - Computed Properties

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(path)")
    }

    /// Total movies in collection
    var movieCount: Int {
        parts.count
    }

    /// Movies sorted by release date
    var moviesByReleaseDate: [CollectionPart] {
        parts.sorted { ($0.releaseDate ?? "") < ($1.releaseDate ?? "") }
    }

    /// Average rating across all movies
    var averageRating: Double {
        guard !parts.isEmpty else { return 0 }
        let total = parts.reduce(0) { $0 + $1.voteAverage }
        return total / Double(parts.count)
    }

    /// Total revenue (if available)
    var combinedRevenue: Int? {
        let revenues = parts.compactMap { $0.revenue }
        guard !revenues.isEmpty else { return nil }
        return revenues.reduce(0, +)
    }

    /// Year range of collection
    var yearRange: String? {
        let years = parts.compactMap { $0.releaseYear }.sorted()
        guard let first = years.first, let last = years.last else { return nil }
        return first == last ? first : "\(first) - \(last)"
    }
}

// MARK: - Collection Part (Movie in Collection)

struct CollectionPart: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let adult: Bool?
    let genreIds: [Int]?
    let originalLanguage: String?
    let originalTitle: String?
    let video: Bool?
    let mediaType: String?
    let revenue: Int?
    let runtime: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, adult, popularity, video, revenue, runtime
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case mediaType = "media_type"
    }

    // MARK: - Computed Properties

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(path)")
    }

    var releaseYear: String? {
        releaseDate?.prefix(4).description
    }

    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }

    var formattedRuntime: String? {
        guard let runtime = runtime else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    // MARK: - Convert to Movie

    func toMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: popularity,
            genreIds: genreIds ?? [],
            adult: adult ?? false,
            originalLanguage: originalLanguage ?? "",
            originalTitle: originalTitle ?? title,
            video: video ?? false
        )
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CollectionPart, rhs: CollectionPart) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension CollectionInfo {
    static let sample = CollectionInfo(
        id: 10,
        name: "Star Wars Collection",
        posterPath: "/r8Ph5MYXL04Qzu4QBbq2KjqwtkQ.jpg",
        backdropPath: "/d8duYyyC9J5T825Hg7grmaabfxQ.jpg"
    )
}

extension MovieCollection {
    static let sample = MovieCollection(
        id: 10,
        name: "Star Wars Collection",
        overview: "An epic space saga spanning generations, telling the story of the Skywalker family and the eternal battle between good and evil in a galaxy far, far away.",
        posterPath: "/r8Ph5MYXL04Qzu4QBbq2KjqwtkQ.jpg",
        backdropPath: "/d8duYyyC9J5T825Hg7grmaabfxQ.jpg",
        parts: CollectionPart.samples
    )
}

extension CollectionPart {
    static let sample = CollectionPart(
        id: 11,
        title: "Star Wars: A New Hope",
        overview: "Princess Leia is captured and held hostage by the evil Imperial forces in their effort to take over the galactic Empire.",
        posterPath: "/6FfCtAuVAW8XJjZ7eWeLibRLWTw.jpg",
        backdropPath: "/zqkmTXzjkAgXmEWLRsY4UpTWCeo.jpg",
        releaseDate: "1977-05-25",
        voteAverage: 8.2,
        voteCount: 18584,
        popularity: 78.234,
        adult: false,
        genreIds: [12, 28, 878],
        originalLanguage: "en",
        originalTitle: "Star Wars",
        video: false,
        mediaType: "movie",
        revenue: 775398007,
        runtime: 121
    )

    static let samples: [CollectionPart] = [
        sample,
        CollectionPart(
            id: 1891,
            title: "The Empire Strikes Back",
            overview: "The epic saga continues as Luke Skywalker, in hopes of defeating the evil Galactic Empire, learns the ways of the Jedi from aging master Yoda.",
            posterPath: "/nNAeTmF4CtdSgMDplXTDPOpYzsX.jpg",
            backdropPath: "/azIbQpeKKNF9r85lBSRrNnMK0Ax.jpg",
            releaseDate: "1980-05-20",
            voteAverage: 8.4,
            voteCount: 15234,
            popularity: 62.456,
            adult: false,
            genreIds: [12, 28, 878],
            originalLanguage: "en",
            originalTitle: "The Empire Strikes Back",
            video: false,
            mediaType: "movie",
            revenue: 538375067,
            runtime: 124
        ),
        CollectionPart(
            id: 1892,
            title: "Return of the Jedi",
            overview: "Luke Skywalker leads a mission to rescue his friend Han Solo from the clutches of Jabba the Hutt, while the Emperor seeks to destroy the Rebellion.",
            posterPath: "/jQYlydvHm3kUix1f8prMucrplhm.jpg",
            backdropPath: "/mDCBQNhR6R0PVFucJAb3L0aSvJM.jpg",
            releaseDate: "1983-05-25",
            voteAverage: 8.0,
            voteCount: 12456,
            popularity: 55.789,
            adult: false,
            genreIds: [12, 28, 878],
            originalLanguage: "en",
            originalTitle: "Return of the Jedi",
            video: false,
            mediaType: "movie",
            revenue: 475106177,
            runtime: 132
        )
    ]
}
#endif
