//
//  TMDBEndpoint.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//  Enhanced: Secure API key storage with Keychain
//

import Foundation

/// TMDB API endpoint definitions
enum TMDBEndpoint {
    // MARK: - Movie Lists
    case trending(page: Int)
    case popular(page: Int)
    case topRated(page: Int)
    case nowPlaying(page: Int)
    case upcoming(page: Int)
    case discoverRecent(page: Int)
    case search(query: String, page: Int)
    case searchPerson(query: String, page: Int)

    // MARK: - Movie Details
    case movieDetails(id: Int)
    case movieDetailsFull(id: Int, appendToResponse: [AppendOption])
    case videos(movieId: Int)
    case credits(movieId: Int)
    case reviews(movieId: Int, page: Int)
    case images(movieId: Int)
    case releaseDates(movieId: Int)

    // MARK: - Related Movies
    case similarMovies(movieId: Int, page: Int)
    case recommendations(movieId: Int, page: Int)
    case watchProviders(movieId: Int)

    // MARK: - Collections
    case collection(collectionId: Int)

    // MARK: - Person
    case personDetails(personId: Int)
    case personDetailsFull(personId: Int, appendToResponse: [PersonAppendOption])
    case personMovieCredits(personId: Int)
    case personImages(personId: Int)

    // MARK: - Genres & Configuration
    case genres

    // MARK: - Discover with Advanced Filters
    case discover(filters: DiscoverFilters)

    // MARK: - Append Options for Movie Details
    enum AppendOption: String {
        case videos
        case credits
        case images
        case reviews
        case similar
        case recommendations
        case watchProviders = "watch/providers"
        case releaseDates = "release_dates"
        case externalIds = "external_ids"
        case keywords

        static var all: [AppendOption] {
            [.videos, .credits, .images, .reviews, .similar, .recommendations, .watchProviders, .releaseDates]
        }

        static var essential: [AppendOption] {
            [.videos, .credits, .watchProviders]
        }
    }

    // MARK: - Append Options for Person Details
    enum PersonAppendOption: String {
        case movieCredits = "movie_credits"
        case tvCredits = "tv_credits"
        case combinedCredits = "combined_credits"
        case images
        case externalIds = "external_ids"

        static var all: [PersonAppendOption] {
            [.movieCredits, .images, .externalIds]
        }
    }

    // MARK: - Configuration

    private static let baseURL = "https://api.themoviedb.org/3"

    /// API key - loaded securely from Keychain with Info.plist fallback
    /// Get your API key from: https://www.themoviedb.org/settings/api
    private static var apiKey: String {
        // Use KeychainManager for secure storage
        if let key = KeychainManager.shared.tmdbAPIKey {
            return key
        }

        // Fallback to Info.plist for backwards compatibility
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String,
           !plistKey.isEmpty,
           plistKey != "$(TMDB_API_KEY)" {
            // Migrate to Keychain for future use
            try? KeychainManager.shared.setTMDBAPIKey(plistKey)
            return plistKey
        }

        return ""
    }

    // MARK: - Path

    private var path: String {
        switch self {
        // Movie Lists
        case .trending:
            return "/trending/movie/day"
        case .popular:
            return "/movie/popular"
        case .topRated:
            return "/movie/top_rated"
        case .nowPlaying:
            return "/movie/now_playing"
        case .upcoming:
            return "/movie/upcoming"
        case .discoverRecent, .discover:
            return "/discover/movie"
        case .search:
            return "/search/movie"
        case .searchPerson:
            return "/search/person"

        // Movie Details
        case .movieDetails(let id), .movieDetailsFull(let id, _):
            return "/movie/\(id)"
        case .videos(let movieId):
            return "/movie/\(movieId)/videos"
        case .credits(let movieId):
            return "/movie/\(movieId)/credits"
        case .reviews(let movieId, _):
            return "/movie/\(movieId)/reviews"
        case .images(let movieId):
            return "/movie/\(movieId)/images"
        case .releaseDates(let movieId):
            return "/movie/\(movieId)/release_dates"

        // Related Movies
        case .similarMovies(let movieId, _):
            return "/movie/\(movieId)/similar"
        case .recommendations(let movieId, _):
            return "/movie/\(movieId)/recommendations"
        case .watchProviders(let movieId):
            return "/movie/\(movieId)/watch/providers"

        // Collections
        case .collection(let collectionId):
            return "/collection/\(collectionId)"

        // Person
        case .personDetails(let personId), .personDetailsFull(let personId, _):
            return "/person/\(personId)"
        case .personMovieCredits(let personId):
            return "/person/\(personId)/movie_credits"
        case .personImages(let personId):
            return "/person/\(personId)/images"

        // Genres
        case .genres:
            return "/genre/movie/list"
        }
    }

    // MARK: - Query Parameters

    private var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "api_key", value: Self.apiKey)
        ]

        switch self {
        // Movie Lists with pagination
        case .trending(let page),
             .popular(let page),
             .topRated(let page),
             .nowPlaying(let page),
             .upcoming(let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))

        case .discoverRecent(let page):
            // Get movies from the last 6 months with good ratings
            let calendar = Calendar.current
            let today = Date()
            let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: today) ?? today
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "sort_by", value: "popularity.desc"))
            items.append(URLQueryItem(name: "include_adult", value: "false"))
            items.append(URLQueryItem(name: "include_video", value: "true"))
            items.append(URLQueryItem(name: "primary_release_date.gte", value: dateFormatter.string(from: sixMonthsAgo)))
            items.append(URLQueryItem(name: "primary_release_date.lte", value: dateFormatter.string(from: today)))
            items.append(URLQueryItem(name: "vote_count.gte", value: "50"))

        case .discover(let filters):
            items.append(contentsOf: filters.queryItems)

        case .search(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "include_adult", value: "false"))

        case .searchPerson(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "include_adult", value: "false"))

        // Movie Details with append_to_response
        case .movieDetailsFull(_, let appendOptions):
            let appendValue = appendOptions.map { $0.rawValue }.joined(separator: ",")
            items.append(URLQueryItem(name: "append_to_response", value: appendValue))

        case .movieDetails, .videos, .credits, .images, .releaseDates, .genres, .watchProviders, .collection:
            break // No additional parameters

        // Reviews and Related with pagination
        case .reviews(_, let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))

        case .similarMovies(_, let page),
             .recommendations(_, let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))

        // Person Details with append_to_response
        case .personDetailsFull(_, let appendOptions):
            let appendValue = appendOptions.map { $0.rawValue }.joined(separator: ",")
            items.append(URLQueryItem(name: "append_to_response", value: appendValue))

        case .personDetails, .personMovieCredits, .personImages:
            break // No additional parameters
        }

        return items
    }

    // MARK: - URL Construction

    /// Construct full URL for the endpoint
    var url: URL? {
        var components = URLComponents(string: Self.baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }

    // MARK: - Request Configuration

    /// HTTP method for the endpoint
    var method: String {
        "GET" // All TMDB endpoints use GET
    }

    /// Cache policy for the endpoint
    var cachePolicy: URLRequest.CachePolicy {
        switch self {
        case .trending, .popular, .topRated, .nowPlaying, .upcoming, .discoverRecent, .discover:
            // Cache for 5 minutes
            return .returnCacheDataElseLoad
        case .search:
            // Cache search results for 1 hour
            return .returnCacheDataElseLoad
        case .movieDetails, .movieDetailsFull:
            // Cache movie details for 1 day
            return .returnCacheDataElseLoad
        case .videos, .credits, .images, .releaseDates:
            // Cache media/credits for 1 day
            return .returnCacheDataElseLoad
        case .reviews:
            // Cache reviews for a few hours
            return .returnCacheDataElseLoad
        case .genres:
            // Cache genres indefinitely (they rarely change)
            return .returnCacheDataElseLoad
        case .similarMovies, .recommendations:
            // Cache similar/recommendations for a few hours
            return .returnCacheDataElseLoad
        case .watchProviders:
            // Cache watch providers for 1 day
            return .returnCacheDataElseLoad
        case .collection:
            // Cache collections for 1 day
            return .returnCacheDataElseLoad
        case .personDetails, .personDetailsFull, .personMovieCredits, .personImages:
            // Cache person data for 1 day
            return .returnCacheDataElseLoad
        case .searchPerson:
            // Cache person search results for 1 hour
            return .returnCacheDataElseLoad
        }
    }

    /// Timeout interval for the endpoint
    var timeoutInterval: TimeInterval {
        switch self {
        case .search:
            return 10 // Faster timeout for search
        default:
            return 30
        }
    }

    /// Create URLRequest for the endpoint
    func urlRequest() throws -> URLRequest {
        guard let url = url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.cachePolicy = cachePolicy
        request.timeoutInterval = timeoutInterval

        // Add headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension TMDBEndpoint {
    /// Description for debugging
    var debugDescription: String {
        switch self {
        case .trending(let page):
            return "Trending Movies (Page \(page))"
        case .popular(let page):
            return "Popular Movies (Page \(page))"
        case .topRated(let page):
            return "Top Rated Movies (Page \(page))"
        case .nowPlaying(let page):
            return "Now Playing Movies (Page \(page))"
        case .upcoming(let page):
            return "Upcoming Movies (Page \(page))"
        case .discoverRecent(let page):
            return "Recent Movies (Page \(page))"
        case .discover:
            return "Discover Movies"
        case .search(let query, let page):
            return "Search: \"\(query)\" (Page \(page))"
        case .movieDetails(let id):
            return "Movie Details (ID: \(id))"
        case .movieDetailsFull(let id, let append):
            return "Movie Details Full (ID: \(id), append: \(append.count) options)"
        case .videos(let movieId):
            return "Videos for Movie (ID: \(movieId))"
        case .credits(let movieId):
            return "Credits for Movie (ID: \(movieId))"
        case .reviews(let movieId, let page):
            return "Reviews for Movie (ID: \(movieId), Page \(page))"
        case .images(let movieId):
            return "Images for Movie (ID: \(movieId))"
        case .releaseDates(let movieId):
            return "Release Dates for Movie (ID: \(movieId))"
        case .genres:
            return "Genre List"
        case .similarMovies(let movieId, let page):
            return "Similar Movies (ID: \(movieId), Page \(page))"
        case .recommendations(let movieId, let page):
            return "Recommendations (ID: \(movieId), Page \(page))"
        case .watchProviders(let movieId):
            return "Watch Providers (ID: \(movieId))"
        case .collection(let collectionId):
            return "Collection (ID: \(collectionId))"
        case .personDetails(let personId):
            return "Person Details (ID: \(personId))"
        case .personDetailsFull(let personId, let append):
            return "Person Details Full (ID: \(personId), append: \(append.count) options)"
        case .personMovieCredits(let personId):
            return "Person Movie Credits (ID: \(personId))"
        case .personImages(let personId):
            return "Person Images (ID: \(personId))"
        case .searchPerson(let query, let page):
            return "Search Person: \"\(query)\" (Page \(page))"
        }
    }

    /// Full URL string for debugging
    var urlString: String {
        url?.absoluteString ?? "Invalid URL"
    }
}
#endif

// MARK: - API Key Configuration Helper

extension TMDBEndpoint {
    /// Check if API key is configured
    static var isAPIKeyConfigured: Bool {
        KeychainManager.shared.isTMDBAPIKeyConfigured
    }

    /// Set API key programmatically (stores in Keychain)
    static func setAPIKey(_ key: String) throws {
        try KeychainManager.shared.setTMDBAPIKey(key)
    }

    /// Clear stored API key
    static func clearAPIKey() throws {
        try KeychainManager.shared.delete(key: .tmdbAPIKey)
    }
}

// MARK: - Discover Filters

/// Advanced filtering options for movie discovery
struct DiscoverFilters {
    var page: Int = 1
    var sortBy: SortOption = .popularityDesc
    var genres: [Int]? = nil
    var withoutGenres: [Int]? = nil
    var yearMin: Int? = nil
    var yearMax: Int? = nil
    var releaseDateMin: String? = nil
    var releaseDateMax: String? = nil
    var voteAverageMin: Double? = nil
    var voteAverageMax: Double? = nil
    var voteCountMin: Int? = nil
    var runtimeMin: Int? = nil
    var runtimeMax: Int? = nil
    var withCast: [Int]? = nil
    var withCrew: [Int]? = nil
    var withCompanies: [Int]? = nil
    var withKeywords: [Int]? = nil
    var withOriginalLanguage: String? = nil
    var region: String? = nil
    var watchRegion: String? = nil
    var withWatchProviders: [Int]? = nil
    var watchMonetizationType: WatchType? = nil
    var includeAdult: Bool = false
    var includeVideo: Bool = false

    enum SortOption: String {
        case popularityAsc = "popularity.asc"
        case popularityDesc = "popularity.desc"
        case releaseDateAsc = "release_date.asc"
        case releaseDateDesc = "release_date.desc"
        case revenueAsc = "revenue.asc"
        case revenueDesc = "revenue.desc"
        case primaryReleaseDateAsc = "primary_release_date.asc"
        case primaryReleaseDateDesc = "primary_release_date.desc"
        case originalTitleAsc = "original_title.asc"
        case originalTitleDesc = "original_title.desc"
        case voteAverageAsc = "vote_average.asc"
        case voteAverageDesc = "vote_average.desc"
        case voteCountAsc = "vote_count.asc"
        case voteCountDesc = "vote_count.desc"
    }

    enum WatchType: String {
        case flatrate // Subscription streaming
        case free
        case ads
        case rent
        case buy
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        items.append(URLQueryItem(name: "page", value: "\(page)"))
        items.append(URLQueryItem(name: "sort_by", value: sortBy.rawValue))
        items.append(URLQueryItem(name: "include_adult", value: "\(includeAdult)"))
        items.append(URLQueryItem(name: "include_video", value: "\(includeVideo)"))

        if let genres = genres, !genres.isEmpty {
            items.append(URLQueryItem(name: "with_genres", value: genres.map(String.init).joined(separator: ",")))
        }
        if let withoutGenres = withoutGenres, !withoutGenres.isEmpty {
            items.append(URLQueryItem(name: "without_genres", value: withoutGenres.map(String.init).joined(separator: ",")))
        }
        if let yearMin = yearMin {
            items.append(URLQueryItem(name: "primary_release_date.gte", value: "\(yearMin)-01-01"))
        }
        if let yearMax = yearMax {
            items.append(URLQueryItem(name: "primary_release_date.lte", value: "\(yearMax)-12-31"))
        }
        if let releaseDateMin = releaseDateMin {
            items.append(URLQueryItem(name: "primary_release_date.gte", value: releaseDateMin))
        }
        if let releaseDateMax = releaseDateMax {
            items.append(URLQueryItem(name: "primary_release_date.lte", value: releaseDateMax))
        }
        if let voteAverageMin = voteAverageMin {
            items.append(URLQueryItem(name: "vote_average.gte", value: "\(voteAverageMin)"))
        }
        if let voteAverageMax = voteAverageMax {
            items.append(URLQueryItem(name: "vote_average.lte", value: "\(voteAverageMax)"))
        }
        if let voteCountMin = voteCountMin {
            items.append(URLQueryItem(name: "vote_count.gte", value: "\(voteCountMin)"))
        }
        if let runtimeMin = runtimeMin {
            items.append(URLQueryItem(name: "with_runtime.gte", value: "\(runtimeMin)"))
        }
        if let runtimeMax = runtimeMax {
            items.append(URLQueryItem(name: "with_runtime.lte", value: "\(runtimeMax)"))
        }
        if let withCast = withCast, !withCast.isEmpty {
            items.append(URLQueryItem(name: "with_cast", value: withCast.map(String.init).joined(separator: ",")))
        }
        if let withCrew = withCrew, !withCrew.isEmpty {
            items.append(URLQueryItem(name: "with_crew", value: withCrew.map(String.init).joined(separator: ",")))
        }
        if let withCompanies = withCompanies, !withCompanies.isEmpty {
            items.append(URLQueryItem(name: "with_companies", value: withCompanies.map(String.init).joined(separator: ",")))
        }
        if let withKeywords = withKeywords, !withKeywords.isEmpty {
            items.append(URLQueryItem(name: "with_keywords", value: withKeywords.map(String.init).joined(separator: ",")))
        }
        if let lang = withOriginalLanguage {
            items.append(URLQueryItem(name: "with_original_language", value: lang))
        }
        if let region = region {
            items.append(URLQueryItem(name: "region", value: region))
        }
        if let watchRegion = watchRegion {
            items.append(URLQueryItem(name: "watch_region", value: watchRegion))
        }
        if let providers = withWatchProviders, !providers.isEmpty {
            items.append(URLQueryItem(name: "with_watch_providers", value: providers.map(String.init).joined(separator: "|")))
        }
        if let monetization = watchMonetizationType {
            items.append(URLQueryItem(name: "with_watch_monetization_types", value: monetization.rawValue))
        }

        return items
    }

    // MARK: - Preset Filters

    /// Movies with high ratings (7+)
    static var highlyRated: DiscoverFilters {
        var filters = DiscoverFilters()
        filters.sortBy = .voteAverageDesc
        filters.voteAverageMin = 7.0
        filters.voteCountMin = 1000
        return filters
    }

    /// Recent releases (last 3 months)
    static var recentReleases: DiscoverFilters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date()
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: today) ?? today

        var filters = DiscoverFilters()
        filters.sortBy = .popularityDesc
        filters.releaseDateMin = formatter.string(from: threeMonthsAgo)
        filters.releaseDateMax = formatter.string(from: today)
        return filters
    }

    /// Upcoming movies
    static var upcoming: DiscoverFilters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date()
        let sixMonthsLater = Calendar.current.date(byAdding: .month, value: 6, to: today) ?? today

        var filters = DiscoverFilters()
        filters.sortBy = .popularityDesc
        filters.releaseDateMin = formatter.string(from: today)
        filters.releaseDateMax = formatter.string(from: sixMonthsLater)
        return filters
    }

    /// Hidden gems (good rating, low popularity)
    static var hiddenGems: DiscoverFilters {
        var filters = DiscoverFilters()
        filters.sortBy = .voteAverageDesc
        filters.voteAverageMin = 7.5
        filters.voteCountMin = 100
        filters.voteCountMin = 500
        return filters
    }

    /// Recent top rated (high rating + last 2 years) - for discovering recent gems
    static var recentTopRated: DiscoverFilters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date()
        let twoYearsAgo = Calendar.current.date(byAdding: .year, value: -2, to: today) ?? today

        var filters = DiscoverFilters()
        filters.sortBy = .voteAverageDesc
        filters.voteAverageMin = 7.0
        filters.voteCountMin = 500
        filters.releaseDateMin = formatter.string(from: twoYearsAgo)
        filters.releaseDateMax = formatter.string(from: today)
        return filters
    }

    /// This year's best (high rating + current year)
    static var thisYearsBest: DiscoverFilters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date()
        let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: today)) ?? today

        var filters = DiscoverFilters()
        filters.sortBy = .voteAverageDesc
        filters.voteAverageMin = 6.5
        filters.voteCountMin = 200
        filters.releaseDateMin = formatter.string(from: startOfYear)
        filters.releaseDateMax = formatter.string(from: today)
        return filters
    }
}
