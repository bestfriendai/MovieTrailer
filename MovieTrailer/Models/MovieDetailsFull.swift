//
//  MovieDetailsFull.swift
//  MovieTrailer
//
//  Complete Movie Details with appended data
//  Combines movie info, videos, credits, reviews, etc. in one response
//

import Foundation

// MARK: - Full Movie Details

/// Complete movie details from TMDB using append_to_response
/// This model contains all movie data in a single API response
struct MovieDetailsFull: Codable, Identifiable {
    // MARK: - Core Properties
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let genreIds: [Int]?
    let genres: [Genre]?
    let adult: Bool
    let originalLanguage: String
    let originalTitle: String
    let video: Bool

    // MARK: - Extended Details
    let tagline: String?
    let status: String?
    let runtime: Int?
    let budget: Int?
    let revenue: Int?
    let homepage: String?
    let imdbId: String?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let spokenLanguages: [SpokenLanguage]?
    let belongsToCollection: CollectionInfo?

    // MARK: - Appended Data
    let videos: VideoResponse?
    let credits: Credits?
    let images: MovieImages?
    let reviews: ReviewResponse?
    let similar: MovieResponse?
    let recommendations: MovieResponse?
    let watchProviders: WatchProvidersResponse?
    let releaseDates: ReleaseDatesResponse?
    let externalIds: MovieExternalIds?
    let keywords: KeywordsResponse?

    enum CodingKeys: String, CodingKey {
        case id, title, overview, adult, popularity, video, tagline, status, runtime
        case budget, revenue, homepage, genres
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case imdbId = "imdb_id"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case spokenLanguages = "spoken_languages"
        case belongsToCollection = "belongs_to_collection"
        case videos, credits, images, reviews, similar, recommendations
        case watchProviders = "watch/providers"
        case releaseDates = "release_dates"
        case externalIds = "external_ids"
        case keywords
    }

    // MARK: - Computed Properties

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var posterURLHD: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(path)")
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

    var formattedBudget: String? {
        guard let budget = budget, budget > 0 else { return nil }
        return "$\(budget.formatted())"
    }

    var formattedRevenue: String? {
        guard let revenue = revenue, revenue > 0 else { return nil }
        return "$\(revenue.formatted())"
    }

    var genreNames: [String] {
        genres?.map { $0.name } ?? []
    }

    var primaryTrailer: Video? {
        videos?.primaryTrailer
    }

    var topCast: [CastMember] {
        credits?.topBilledCast ?? []
    }

    var director: CrewMember? {
        credits?.director
    }

    var directors: [CrewMember] {
        credits?.directors ?? []
    }

    var writers: [CrewMember] {
        credits?.writers ?? []
    }

    var imdbURL: URL? {
        guard let imdbId = imdbId else { return nil }
        return URL(string: "https://www.imdb.com/title/\(imdbId)")
    }

    var hasCollection: Bool {
        belongsToCollection != nil
    }

    var usWatchProviders: WatchProviderInfo? {
        guard let results = watchProviders?.results["US"] else { return nil }
        return WatchProviderInfo(
            streaming: results.flatrate ?? [],
            rent: results.rent ?? [],
            buy: results.buy ?? [],
            free: (results.free ?? []) + (results.ads ?? []),
            link: results.link
        )
    }

    var certification: String? {
        // Get US certification
        releaseDates?.results
            .first { $0.iso31661 == "US" }?
            .releaseDates
            .first { !($0.certification?.isEmpty ?? true) }?
            .certification
    }

    // MARK: - Convert to Movie

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
            genreIds: genres?.map { $0.id } ?? genreIds ?? [],
            adult: adult,
            originalLanguage: originalLanguage,
            originalTitle: originalTitle,
            video: video
        )
    }
}

// MARK: - Supporting Types

// Note: Genre is defined in Genre.swift

struct ProductionCompany: Codable, Identifiable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }

    var logoURL: URL? {
        guard let path = logoPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(path)")
    }
}

struct ProductionCountry: Codable {
    let iso31661: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case name
    }
}

struct SpokenLanguage: Codable {
    let iso6391: String
    let name: String
    let englishName: String?

    enum CodingKeys: String, CodingKey {
        case iso6391 = "iso_639_1"
        case name
        case englishName = "english_name"
    }
}

struct MovieImages: Codable {
    let backdrops: [MovieImage]?
    let posters: [MovieImage]?
    let logos: [MovieImage]?
}

struct MovieImage: Codable, Identifiable {
    let aspectRatio: Double
    let height: Int
    let width: Int
    let filePath: String
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case height, width
        case aspectRatio = "aspect_ratio"
        case filePath = "file_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    var id: String { filePath }

    var imageURL: URL? {
        URL(string: "https://image.tmdb.org/t/p/w500\(filePath)")
    }

    var imageURLHD: URL? {
        URL(string: "https://image.tmdb.org/t/p/original\(filePath)")
    }
}

struct ReleaseDatesResponse: Codable {
    let id: Int?
    let results: [ReleaseDateResult]
}

struct ReleaseDateResult: Codable {
    let iso31661: String
    let releaseDates: [ReleaseDate]

    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

struct ReleaseDate: Codable {
    let certification: String?
    let descriptors: [String]?
    let note: String?
    let releaseDate: String?
    let type: Int?

    enum CodingKeys: String, CodingKey {
        case certification, descriptors, note, type
        case releaseDate = "release_date"
    }
}

struct MovieExternalIds: Codable {
    let imdbId: String?
    let facebookId: String?
    let instagramId: String?
    let twitterId: String?
    let wikidataId: String?

    enum CodingKeys: String, CodingKey {
        case imdbId = "imdb_id"
        case facebookId = "facebook_id"
        case instagramId = "instagram_id"
        case twitterId = "twitter_id"
        case wikidataId = "wikidata_id"
    }
}

struct KeywordsResponse: Codable {
    let keywords: [Keyword]?
}

struct Keyword: Codable, Identifiable {
    let id: Int
    let name: String
}

// MARK: - Preview Helpers

#if DEBUG
extension MovieDetailsFull {
    static let sample = MovieDetailsFull(
        id: 550,
        title: "Fight Club",
        overview: "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.",
        posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        backdropPath: "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
        releaseDate: "1999-10-15",
        voteAverage: 8.433,
        voteCount: 28542,
        popularity: 89.234,
        genreIds: nil,
        genres: [Genre(id: 18, name: "Drama"), Genre(id: 53, name: "Thriller")],
        adult: false,
        originalLanguage: "en",
        originalTitle: "Fight Club",
        video: false,
        tagline: "Mischief. Mayhem. Soap.",
        status: "Released",
        runtime: 139,
        budget: 63000000,
        revenue: 100853753,
        homepage: nil,
        imdbId: "tt0137523",
        productionCompanies: [ProductionCompany(id: 508, name: "Regency Enterprises", logoPath: nil, originCountry: "US")],
        productionCountries: [ProductionCountry(iso31661: "US", name: "United States of America")],
        spokenLanguages: [SpokenLanguage(iso6391: "en", name: "English", englishName: "English")],
        belongsToCollection: nil,
        videos: nil,
        credits: Credits.sample,
        images: nil,
        reviews: nil,
        similar: nil,
        recommendations: nil,
        watchProviders: nil,
        releaseDates: nil,
        externalIds: nil,
        keywords: nil
    )
}
#endif
