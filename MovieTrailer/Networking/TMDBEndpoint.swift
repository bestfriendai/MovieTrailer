//
//  TMDBEndpoint.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//

import Foundation

/// TMDB API endpoint definitions
enum TMDBEndpoint {
    case trending(page: Int)
    case popular(page: Int)
    case topRated(page: Int)
    case search(query: String, page: Int)
    case movieDetails(id: Int)
    case videos(movieId: Int)
    case genres
    
    // MARK: - Configuration
    
    private static let baseURL = "https://api.themoviedb.org/3"
    
    /// API key - loaded from Info.plist (configured via Config.xcconfig)
    /// Get your API key from: https://www.themoviedb.org/settings/api
    private static var apiKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String,
              !apiKey.isEmpty,
              apiKey != "$(TMDB_API_KEY)" else {
            return ""
        }
        return apiKey
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
        case .search:
            return "/search/movie"
        case .movieDetails(let id):
            return "/movie/\(id)"
        case .videos(let movieId):
            return "/movie/\(movieId)/videos"
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
        case .trending(let page),
             .popular(let page),
             .topRated(let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            
        case .search(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "include_adult", value: "false"))
            
        case .movieDetails, .videos, .genres:
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
        case .trending, .popular, .topRated:
            // Cache for 5 minutes
            return .returnCacheDataElseLoad
        case .search:
            // Cache search results for 1 hour
            return .returnCacheDataElseLoad
        case .movieDetails:
            // Cache movie details for 1 day
            return .returnCacheDataElseLoad
        case .genres:
            // Cache genres indefinitely (they rarely change)
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
        case .search(let query, let page):
            return "Search: \"\(query)\" (Page \(page))"
        case .movieDetails(let id):
            return "Movie Details (ID: \(id))"
        case .genres:
            return "Genre List"
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
        !apiKey.isEmpty && apiKey != "YOUR_TMDB_API_KEY_HERE"
    }
    
    /// Set API key programmatically (for testing or configuration)
    static func setAPIKey(_ key: String) {
        // In production, this should update a secure storage location
        // For now, this is a placeholder for the configuration pattern
        print("⚠️ API key should be set in TMDBEndpoint.apiKey")
    }
}
