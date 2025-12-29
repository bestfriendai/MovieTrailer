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
    case trending(page: Int)
    case popular(page: Int)
    case topRated(page: Int)
    case nowPlaying(page: Int)
    case upcoming(page: Int)
    case discoverRecent(page: Int)
    case search(query: String, page: Int)
    case movieDetails(id: Int)
    case videos(movieId: Int)
    case genres
    case similarMovies(movieId: Int, page: Int)
    case recommendations(movieId: Int, page: Int)
    case watchProviders(movieId: Int)

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
        case .discoverRecent:
            return "/discover/movie"
        case .search:
            return "/search/movie"
        case .movieDetails(let id):
            return "/movie/\(id)"
        case .videos(let movieId):
            return "/movie/\(movieId)/videos"
        case .genres:
            return "/genre/movie/list"
        case .similarMovies(let movieId, _):
            return "/movie/\(movieId)/similar"
        case .recommendations(let movieId, _):
            return "/movie/\(movieId)/recommendations"
        case .watchProviders(let movieId):
            return "/movie/\(movieId)/watch/providers"
        }
    }

    // MARK: - Query Parameters

    private var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "api_key", value: Self.apiKey)
        ]

        switch self {
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

        case .search(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "include_adult", value: "false"))

        case .movieDetails, .videos, .genres, .watchProviders:
            break // No additional parameters

        case .similarMovies(_, let page),
             .recommendations(_, let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
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
        case .trending, .popular, .topRated, .nowPlaying, .upcoming, .discoverRecent:
            // Cache for 5 minutes
            return .returnCacheDataElseLoad
        case .search:
            // Cache search results for 1 hour
            return .returnCacheDataElseLoad
        case .movieDetails:
            // Cache movie details for 1 day
            return .returnCacheDataElseLoad
        case .videos:
            // Cache videos for 1 day (trailers don't change often)
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
        case .search(let query, let page):
            return "Search: \"\(query)\" (Page \(page))"
        case .movieDetails(let id):
            return "Movie Details (ID: \(id))"
        case .videos(let movieId):
            return "Videos for Movie (ID: \(movieId))"
        case .genres:
            return "Genre List"
        case .similarMovies(let movieId, let page):
            return "Similar Movies (ID: \(movieId), Page \(page))"
        case .recommendations(let movieId, let page):
            return "Recommendations (ID: \(movieId), Page \(page))"
        case .watchProviders(let movieId):
            return "Watch Providers (ID: \(movieId))"
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
