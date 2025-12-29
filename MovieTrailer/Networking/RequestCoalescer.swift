//
//  RequestCoalescer.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Request coalescing to prevent duplicate API calls
//

import Foundation

// MARK: - Request Coalescer

/// Actor that coalesces identical concurrent requests into a single network call
actor RequestCoalescer<Key: Hashable & Sendable, Value: Sendable> {

    // MARK: - Properties

    private var pendingRequests: [Key: Task<Value, Error>] = [:]
    private var cache: [Key: CacheEntry] = [:]
    private let defaultCacheDuration: TimeInterval

    // MARK: - Cache Entry

    struct CacheEntry {
        let value: Value
        let timestamp: Date
        let expiration: TimeInterval

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > expiration
        }
    }

    // MARK: - Initialization

    init(defaultCacheDuration: TimeInterval = 60) {
        self.defaultCacheDuration = defaultCacheDuration
    }

    // MARK: - Public Methods

    /// Coalesce requests - if a request with the same key is in flight, wait for it
    func coalesce(
        key: Key,
        cacheDuration: TimeInterval? = nil,
        request: @escaping () async throws -> Value
    ) async throws -> Value {
        // Check cache first
        if let cached = cache[key], !cached.isExpired {
            return cached.value
        }

        // Check if there's already a pending request
        if let existing = pendingRequests[key] {
            return try await existing.value
        }

        // Create new request task
        let task = Task<Value, Error> {
            let result = try await request()

            // Cache the result
            let duration = cacheDuration ?? defaultCacheDuration
            cache[key] = CacheEntry(
                value: result,
                timestamp: Date(),
                expiration: duration
            )

            // Remove from pending
            pendingRequests[key] = nil

            return result
        }

        pendingRequests[key] = task

        do {
            return try await task.value
        } catch {
            pendingRequests[key] = nil
            throw error
        }
    }

    /// Clear cache for a specific key
    func clearCache(for key: Key) {
        cache.removeValue(forKey: key)
    }

    /// Clear all cache
    func clearAllCache() {
        cache.removeAll()
    }

    /// Clear expired cache entries
    func clearExpiredCache() {
        cache = cache.filter { !$0.value.isExpired }
    }

    /// Cancel pending request for a key
    func cancelRequest(for key: Key) {
        pendingRequests[key]?.cancel()
        pendingRequests[key] = nil
    }

    /// Cancel all pending requests
    func cancelAllRequests() {
        pendingRequests.values.forEach { $0.cancel() }
        pendingRequests.removeAll()
    }

    /// Get number of pending requests
    var pendingCount: Int {
        pendingRequests.count
    }

    /// Get number of cached entries
    var cacheCount: Int {
        cache.count
    }
}

// MARK: - Movie Request Coalescer

/// Specialized coalescer for movie requests
actor MovieRequestCoalescer {

    // MARK: - Properties

    private let movieResponseCoalescer = RequestCoalescer<String, MovieResponse>(defaultCacheDuration: 120)
    private let movieDetailCoalescer = RequestCoalescer<Int, Movie>(defaultCacheDuration: 300)
    private let videoCoalescer = RequestCoalescer<Int, VideoResponse>(defaultCacheDuration: 600)

    // MARK: - Singleton

    static let shared = MovieRequestCoalescer()

    // MARK: - Movie Lists

    func fetchTrending(
        page: Int,
        using service: TMDBService
    ) async throws -> MovieResponse {
        try await movieResponseCoalescer.coalesce(
            key: "trending_\(page)",
            cacheDuration: 300 // 5 minutes for trending
        ) {
            try await service.fetchTrending(page: page)
        }
    }

    func fetchPopular(
        page: Int,
        using service: TMDBService
    ) async throws -> MovieResponse {
        try await movieResponseCoalescer.coalesce(
            key: "popular_\(page)",
            cacheDuration: 600 // 10 minutes for popular
        ) {
            try await service.fetchPopular(page: page)
        }
    }

    func fetchTopRated(
        page: Int,
        using service: TMDBService
    ) async throws -> MovieResponse {
        try await movieResponseCoalescer.coalesce(
            key: "topRated_\(page)",
            cacheDuration: 3600 // 1 hour for top rated
        ) {
            try await service.fetchTopRated(page: page)
        }
    }

    func fetchNowPlaying(
        page: Int,
        using service: TMDBService
    ) async throws -> MovieResponse {
        try await movieResponseCoalescer.coalesce(
            key: "nowPlaying_\(page)",
            cacheDuration: 600
        ) {
            try await service.fetchNowPlaying(page: page)
        }
    }

    func fetchUpcoming(
        page: Int,
        using service: TMDBService
    ) async throws -> MovieResponse {
        try await movieResponseCoalescer.coalesce(
            key: "upcoming_\(page)",
            cacheDuration: 3600
        ) {
            try await service.fetchUpcoming(page: page)
        }
    }

    func fetchRecent(
        page: Int,
        using service: TMDBService
    ) async throws -> MovieResponse {
        try await movieResponseCoalescer.coalesce(
            key: "recent_\(page)",
            cacheDuration: 1800
        ) {
            try await service.fetchRecentMovies(page: page)
        }
    }

    // MARK: - Movie Details

    func fetchMovieDetails(
        id: Int,
        using service: TMDBService
    ) async throws -> Movie {
        try await movieDetailCoalescer.coalesce(
            key: id,
            cacheDuration: 86400 // 24 hours for movie details
        ) {
            try await service.fetchMovieDetails(id: id)
        }
    }

    // MARK: - Videos

    func fetchVideos(
        movieId: Int,
        using service: TMDBService
    ) async throws -> VideoResponse {
        try await videoCoalescer.coalesce(
            key: movieId,
            cacheDuration: 86400 // 24 hours for videos
        ) {
            try await service.fetchVideos(for: movieId)
        }
    }

    // MARK: - Cache Management

    func clearAllCaches() async {
        await movieResponseCoalescer.clearAllCache()
        await movieDetailCoalescer.clearAllCache()
        await videoCoalescer.clearAllCache()
    }

    func clearExpiredCaches() async {
        await movieResponseCoalescer.clearExpiredCache()
        await movieDetailCoalescer.clearExpiredCache()
        await videoCoalescer.clearExpiredCache()
    }

    func cancelAllRequests() async {
        await movieResponseCoalescer.cancelAllRequests()
        await movieDetailCoalescer.cancelAllRequests()
        await videoCoalescer.cancelAllRequests()
    }
}

// MARK: - Search Debouncer

/// Debounces and coalesces search requests
actor SearchDebouncer {

    // MARK: - Properties

    private var pendingSearch: Task<MovieResponse, Error>?
    private var lastQuery: String = ""
    private var lastResults: MovieResponse?
    private let debounceInterval: UInt64

    // MARK: - Initialization

    init(debounceMilliseconds: UInt64 = 300) {
        self.debounceInterval = debounceMilliseconds * 1_000_000 // Convert to nanoseconds
    }

    // MARK: - Search

    func search(
        query: String,
        page: Int = 1,
        using service: TMDBService
    ) async throws -> MovieResponse {
        // Cancel any pending search
        pendingSearch?.cancel()

        // Return cached results if same query
        if query == lastQuery, let results = lastResults, page == 1 {
            return results
        }

        // Debounce
        let task = Task<MovieResponse, Error> {
            try await Task.sleep(nanoseconds: debounceInterval)

            guard !Task.isCancelled else {
                throw CancellationError()
            }

            let response = try await service.searchMovies(query: query, page: page)

            // Cache results for first page
            if page == 1 {
                lastQuery = query
                lastResults = response
            }

            return response
        }

        pendingSearch = task

        return try await task.value
    }

    func cancel() {
        pendingSearch?.cancel()
        pendingSearch = nil
    }

    func clearCache() {
        lastQuery = ""
        lastResults = nil
    }
}

// MARK: - Batch Request Manager

/// Manages batch requests with rate limiting
actor BatchRequestManager {

    // MARK: - Properties

    private let maxConcurrent: Int
    private let delayBetweenBatches: UInt64
    private var activeTasks: Int = 0

    // MARK: - Initialization

    init(maxConcurrent: Int = 3, delayBetweenBatchesMs: UInt64 = 100) {
        self.maxConcurrent = maxConcurrent
        self.delayBetweenBatches = delayBetweenBatchesMs * 1_000_000
    }

    // MARK: - Batch Fetch

    func fetchBatch<T>(
        items: [Int],
        fetch: @escaping (Int) async throws -> T
    ) async throws -> [T] {
        var results: [T] = []

        for batch in items.chunked(into: maxConcurrent) {
            let batchResults = try await withThrowingTaskGroup(of: T.self) { group in
                for item in batch {
                    group.addTask {
                        try await fetch(item)
                    }
                }

                var collected: [T] = []
                for try await result in group {
                    collected.append(result)
                }
                return collected
            }

            results.append(contentsOf: batchResults)

            // Delay between batches
            if batch != items.chunked(into: maxConcurrent).last {
                try await Task.sleep(nanoseconds: delayBetweenBatches)
            }
        }

        return results
    }
}

// MARK: - Array Extension

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
