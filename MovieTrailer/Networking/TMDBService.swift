//
//  TMDBService.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//  Enhanced: Retry logic with exponential backoff
//

import Foundation

/// Thread-safe networking service for TMDB API using Swift Actor
/// Enhanced with retry logic and exponential backoff
actor TMDBService {

    // MARK: - Properties

    private let urlSession: URLSession
    private let decoder: JSONDecoder

    // MARK: - Retry Configuration

    private let maxRetries: Int
    private let baseRetryDelay: TimeInterval
    private let maxRetryDelay: TimeInterval

    // MARK: - Initialization

    init(
        urlSession: URLSession = .shared,
        maxRetries: Int = 3,
        baseRetryDelay: TimeInterval = 1.0,
        maxRetryDelay: TimeInterval = 30.0
    ) {
        self.urlSession = urlSession
        self.maxRetries = maxRetries
        self.baseRetryDelay = baseRetryDelay
        self.maxRetryDelay = maxRetryDelay

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

    // MARK: - Generic Request Method with Retry

    /// Perform a network request and decode the response with retry logic
    private func request<T: Decodable>(
        endpoint: TMDBEndpoint,
        responseType: T.Type,
        retryCount: Int = 0
    ) async throws -> T {
        // Create request
        let request = try endpoint.urlRequest()

        // Check if API key is configured
        guard TMDBEndpoint.isAPIKeyConfigured else {
            throw NetworkError.unauthorized
        }

        do {
            // Perform request
            let (data, response) = try await urlSession.data(for: request)

            // Validate response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                let error = NetworkError.from(statusCode: httpResponse.statusCode)

                // Retry for retryable errors
                if error.isRetryable && retryCount < maxRetries {
                    return try await retryRequest(
                        endpoint: endpoint,
                        responseType: responseType,
                        retryCount: retryCount,
                        error: error
                    )
                }

                throw error
            }

            // Decode response
            do {
                let decodedResponse = try decoder.decode(T.self, from: data)
                return decodedResponse
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            // Already a NetworkError, check if retryable
            if error.isRetryable && retryCount < maxRetries {
                return try await retryRequest(
                    endpoint: endpoint,
                    responseType: responseType,
                    retryCount: retryCount,
                    error: error
                )
            }
            throw error
        } catch {
            // Convert to NetworkError and check if retryable
            let networkError = NetworkError.networkError(error)
            if networkError.isRetryable && retryCount < maxRetries {
                return try await retryRequest(
                    endpoint: endpoint,
                    responseType: responseType,
                    retryCount: retryCount,
                    error: networkError
                )
            }
            throw networkError
        }
    }

    /// Retry a request with exponential backoff
    private func retryRequest<T: Decodable>(
        endpoint: TMDBEndpoint,
        responseType: T.Type,
        retryCount: Int,
        error: NetworkError
    ) async throws -> T {
        // Calculate delay with exponential backoff and jitter
        let exponentialDelay = baseRetryDelay * pow(2.0, Double(retryCount))
        let jitter = Double.random(in: 0...0.5) * exponentialDelay
        let delay = min(exponentialDelay + jitter, maxRetryDelay)

        print("⚠️ Retry \(retryCount + 1)/\(maxRetries) for \(endpoint.debugDescription) after \(String(format: "%.1f", delay))s - Error: \(error.localizedDescription)")

        // Wait before retrying
        try await Task.sleep(for: .seconds(delay))

        // Check for cancellation
        try Task.checkCancellation()

        // Retry the request
        return try await request(
            endpoint: endpoint,
            responseType: responseType,
            retryCount: retryCount + 1
        )
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

    // MARK: - Batch Operations with Rate Limiting

    /// Fetch multiple pages of movies concurrently with rate limiting
    func fetchMultiplePages(
        endpoint: TMDBEndpoint,
        pageRange: ClosedRange<Int>,
        maxConcurrent: Int = 3
    ) async throws -> [Movie] {
        var allMovies: [Movie] = []

        // Process in batches to avoid rate limiting
        for batch in stride(from: pageRange.lowerBound, through: pageRange.upperBound, by: maxConcurrent) {
            let batchEnd = min(batch + maxConcurrent - 1, pageRange.upperBound)
            let batchRange = batch...batchEnd

            let batchMovies = try await withThrowingTaskGroup(of: MovieResponse.self) { group in
                for page in batchRange {
                    group.addTask {
                        switch endpoint {
                        case .trending:
                            return try await self.fetchTrending(page: page)
                        case .popular:
                            return try await self.fetchPopular(page: page)
                        case .topRated:
                            return try await self.fetchTopRated(page: page)
                        default:
                            throw NetworkError.invalidURL
                        }
                    }
                }

                var movies: [Movie] = []
                for try await response in group {
                    movies.append(contentsOf: response.results)
                }
                return movies
            }

            allMovies.append(contentsOf: batchMovies)

            // Small delay between batches to avoid rate limiting
            if batchEnd < pageRange.upperBound {
                try await Task.sleep(for: .milliseconds(100))
            }
        }

        return allMovies
    }

    /// Fetch movie details for multiple IDs concurrently with rate limiting
    func fetchMovieDetails(ids: [Int], maxConcurrent: Int = 5) async throws -> [Movie] {
        var allMovies: [Movie] = []

        // Process in batches
        for batch in stride(from: 0, to: ids.count, by: maxConcurrent) {
            let batchEnd = min(batch + maxConcurrent, ids.count)
            let batchIds = Array(ids[batch..<batchEnd])

            let batchMovies = try await withThrowingTaskGroup(of: Movie.self) { group in
                for id in batchIds {
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

            allMovies.append(contentsOf: batchMovies)

            // Small delay between batches
            if batchEnd < ids.count {
                try await Task.sleep(for: .milliseconds(100))
            }
        }

        return allMovies
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

    /// Get cache size as formatted string
    func getFormattedCacheSize() -> String {
        let (memory, disk) = getCacheSize()
        let memoryMB = Double(memory) / (1024 * 1024)
        let diskMB = Double(disk) / (1024 * 1024)
        return String(format: "Memory: %.1f MB, Disk: %.1f MB", memoryMB, diskMB)
    }
}

// MARK: - Singleton (Optional)

extension TMDBService {
    /// Shared instance with custom cached session
    static let shared = TMDBService(urlSession: createCachedSession())
}

// MARK: - TMDBEndpoint Debug Description

#if DEBUG
extension TMDBEndpoint {
    /// Description for debugging (moved here to avoid circular dependency)
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
        case .videos(let movieId):
            return "Videos for Movie (ID: \(movieId))"
        case .genres:
            return "Genre List"
        }
    }
}
#endif

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
