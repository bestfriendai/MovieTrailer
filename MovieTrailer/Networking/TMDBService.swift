//
//  TMDBService.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//

import Foundation

/// Thread-safe networking service for TMDB API using Swift Actor
actor TMDBService {
    
    // MARK: - Properties
    
    private let urlSession: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
        
        // Configure JSON decoder
        self.decoder = JSONDecoder()
        // Note: NOT using .convertFromSnakeCase because we have custom CodingKeys
    }
    
    // MARK: - Custom URLSession with Caching
    
    /// Create a URLSession with custom cache configuration
    static func createCachedSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        
        // Configure cache (50 MB memory, 200 MB disk)
        let cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,  // 50 MB
            diskCapacity: 200 * 1024 * 1024,   // 200 MB
            diskPath: "tmdb_cache"
        )
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        // Configure timeouts
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        return URLSession(configuration: configuration)
    }
    
    // MARK: - Generic Request Method
    
    /// Perform a network request and decode the response
    private func request<T: Decodable>(
        endpoint: TMDBEndpoint,
        responseType: T.Type
    ) async throws -> T {
        // Create request
        let request = try endpoint.urlRequest()
        
        // Check if API key is configured
        guard TMDBEndpoint.isAPIKeyConfigured else {
            throw NetworkError.unauthorized
        }
        
        // Perform request
        let (data, response) = try await urlSession.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // Check status code
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.from(statusCode: httpResponse.statusCode)
        }
        
        // Decode response
        do {
            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Movie Endpoints
    
    /// Fetch trending movies for the week
    func fetchTrending(page: Int = 1) async throws -> MovieResponse {
        try await request(
            endpoint: .trending(page: page),
            responseType: MovieResponse.self
        )
    }
    
    /// Fetch popular movies
    func fetchPopular(page: Int = 1) async throws -> MovieResponse {
        try await request(
            endpoint: .popular(page: page),
            responseType: MovieResponse.self
        )
    }
    
    /// Fetch top rated movies
    func fetchTopRated(page: Int = 1) async throws -> MovieResponse {
        try await request(
            endpoint: .topRated(page: page),
            responseType: MovieResponse.self
        )
    }
    
    /// Search movies by query
    func searchMovies(query: String, page: Int = 1) async throws -> MovieResponse {
        guard !query.isEmpty else {
            // Return empty response for empty query
            return MovieResponse(page: 1, results: [], totalPages: 0, totalResults: 0)
        }
        
        return try await request(
            endpoint: .search(query: query, page: page),
            responseType: MovieResponse.self
        )
    }
    
    /// Fetch movie details by ID
    func fetchMovieDetails(id: Int) async throws -> Movie {
        try await request(
            endpoint: .movieDetails(id: id),
            responseType: Movie.self
        )
    }
    
    // MARK: - Batch Operations
    
    /// Fetch multiple pages of movies concurrently
    func fetchMultiplePages(
        endpoint: TMDBEndpoint,
        pageRange: ClosedRange<Int>
    ) async throws -> [Movie] {
        // Create tasks for each page
        let tasks = pageRange.map { page in
            Task {
                switch endpoint {
                case .trending:
                    return try await fetchTrending(page: page)
                case .popular:
                    return try await fetchPopular(page: page)
                case .topRated:
                    return try await fetchTopRated(page: page)
                default:
                    throw NetworkError.invalidURL
                }
            }
        }
        
        // Wait for all tasks to complete
        let responses = try await withThrowingTaskGroup(of: MovieResponse.self) { group in
            for task in tasks {
                group.addTask {
                    try await task.value
                }
            }
            
            var allMovies: [Movie] = []
            for try await response in group {
                allMovies.append(contentsOf: response.results)
            }
            return allMovies
        }
        
        return responses
    }
    
    /// Fetch movie details for multiple IDs concurrently
    func fetchMovieDetails(ids: [Int]) async throws -> [Movie] {
        try await withThrowingTaskGroup(of: Movie.self) { group in
            for id in ids {
                group.addTask {
                    try await self.fetchMovieDetails(id: id)
                }
            }
            
            var movies: [Movie] = []
            for try await movie in group {
                movies.append(movie)
            }
            return movies
        }
    }
    
    // MARK: - Videos
    
    /// Fetch videos (trailers, teasers, clips) for a movie
    func fetchVideos(for movieId: Int) async throws -> VideoResponse {
        try await request(
            endpoint: .videos(movieId: movieId),
            responseType: VideoResponse.self
        )
    }
    
    /// Fetch official trailers for a movie
    func fetchOfficialTrailers(for movieId: Int) async throws -> [Video] {
        let response = try await fetchVideos(for: movieId)
        return response.officialTrailers
    }
    
    /// Fetch the primary trailer for a movie
    func fetchPrimaryTrailer(for movieId: Int) async throws -> Video? {
        let response = try await fetchVideos(for: movieId)
        return response.primaryTrailer
    }
    
    // MARK: - Cache Management
    
    /// Clear all cached responses
    func clearCache() {
        urlSession.configuration.urlCache?.removeAllCachedResponses()
    }
    
    /// Clear cached response for specific endpoint
    func clearCache(for endpoint: TMDBEndpoint) {
        guard let url = endpoint.url else { return }
        let request = URLRequest(url: url)
        urlSession.configuration.urlCache?.removeCachedResponse(for: request)
    }
    
    /// Get cache size in bytes
    func getCacheSize() -> (memory: Int, disk: Int) {
        guard let cache = urlSession.configuration.urlCache else {
            return (0, 0)
        }
        return (cache.currentMemoryUsage, cache.currentDiskUsage)
    }
}

// MARK: - Singleton (Optional)

extension TMDBService {
    /// Shared instance with custom cached session
    static let shared = TMDBService(urlSession: createCachedSession())
}

// MARK: - Preview/Testing Helpers

#if DEBUG
extension TMDBService {
    /// Create a mock service for testing
    static func mock() -> TMDBService {
        TMDBService(urlSession: .shared)
    }
    
    /// Test API key configuration
    func testAPIKey() async throws -> Bool {
        do {
            _ = try await fetchTrending(page: 1)
            return true
        } catch NetworkError.unauthorized {
            return false
        } catch {
            throw error
        }
    }
}
#endif
