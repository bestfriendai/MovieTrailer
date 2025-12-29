//
//  OfflineMovieCache.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Offline-capable movie caching with expiration and category indexing
//

import Foundation

// MARK: - Cached Movie

struct CachedMovie: Codable {
    let movie: Movie
    let cachedAt: Date
    let expiresAt: Date

    var isExpired: Bool {
        Date() > expiresAt
    }

    var age: TimeInterval {
        Date().timeIntervalSince(cachedAt)
    }
}

// MARK: - Cache Category

enum CacheCategory: String, CaseIterable, Codable {
    case trending
    case popular
    case topRated
    case nowPlaying
    case upcoming
    case recent
    case search
    case watchlistRelated
    case recommendations

    var ttl: TimeInterval {
        switch self {
        case .trending, .nowPlaying:
            return 3600 // 1 hour
        case .popular, .topRated:
            return 86400 // 24 hours
        case .upcoming:
            return 43200 // 12 hours
        case .recent:
            return 21600 // 6 hours
        case .search:
            return 1800 // 30 minutes
        case .watchlistRelated, .recommendations:
            return 7200 // 2 hours
        }
    }
}

// MARK: - Offline Movie Cache Actor

actor OfflineMovieCache {

    // MARK: - Singleton

    static let shared = OfflineMovieCache()

    // MARK: - Properties

    private let fileManager = FileManager.default
    private var memoryCache: [Int: CachedMovie] = [:]
    private var categoryIndex: [CacheCategory: [Int]] = [:]

    private let maxMemoryCacheSize = 200
    private let maxDiskCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days

    // MARK: - File URLs

    private var cacheDirectory: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("movies", isDirectory: true)
    }

    private var moviesFileURL: URL? {
        cacheDirectory?.appendingPathComponent("movies.json")
    }

    private var indexFileURL: URL? {
        cacheDirectory?.appendingPathComponent("index.json")
    }

    // MARK: - Initialization

    init() {
        Task {
            await loadFromDisk()
        }
    }

    // MARK: - Public Methods

    /// Cache a single movie
    func cache(movie: Movie, category: CacheCategory? = nil) async {
        let cached = CachedMovie(
            movie: movie,
            cachedAt: Date(),
            expiresAt: Date().addingTimeInterval(category?.ttl ?? 86400)
        )

        memoryCache[movie.id] = cached

        // Add to category index
        if let category = category {
            if categoryIndex[category] == nil {
                categoryIndex[category] = []
            }
            if !categoryIndex[category]!.contains(movie.id) {
                categoryIndex[category]!.append(movie.id)
            }
        }

        // Trim memory cache if needed
        await trimMemoryCacheIfNeeded()
    }

    /// Cache multiple movies for a category
    func cacheMovies(_ movies: [Movie], category: CacheCategory) async {
        let ttl = category.ttl

        for movie in movies {
            let cached = CachedMovie(
                movie: movie,
                cachedAt: Date(),
                expiresAt: Date().addingTimeInterval(ttl)
            )
            memoryCache[movie.id] = cached
        }

        // Update category index
        categoryIndex[category] = movies.map(\.id)

        // Trim and persist
        await trimMemoryCacheIfNeeded()
        await persistToDisk()
    }

    /// Get a cached movie by ID
    func get(id: Int) async -> Movie? {
        // Check memory cache first
        if let cached = memoryCache[id], !cached.isExpired {
            return cached.movie
        }

        // Remove if expired
        if memoryCache[id]?.isExpired == true {
            memoryCache.removeValue(forKey: id)
        }

        return nil
    }

    /// Get all cached movies for a category
    func getMovies(for category: CacheCategory) async -> [Movie] {
        guard let ids = categoryIndex[category] else { return [] }

        return ids.compactMap { id in
            guard let cached = memoryCache[id], !cached.isExpired else { return nil }
            return cached.movie
        }
    }

    /// Check if we have valid cached data for a category
    func hasCachedData(for category: CacheCategory) async -> Bool {
        guard let ids = categoryIndex[category], !ids.isEmpty else { return false }

        // Check if at least some movies are still valid
        let validCount = ids.filter { id in
            guard let cached = memoryCache[id] else { return false }
            return !cached.isExpired
        }.count

        return validCount > ids.count / 2 // At least half valid
    }

    /// Get cache statistics
    func getStats() async -> CacheStats {
        let totalMovies = memoryCache.count
        let expiredCount = memoryCache.values.filter(\.isExpired).count
        let validCount = totalMovies - expiredCount

        var categoryCounts: [CacheCategory: Int] = [:]
        for (category, ids) in categoryIndex {
            categoryCounts[category] = ids.count
        }

        return CacheStats(
            totalMovies: totalMovies,
            validMovies: validCount,
            expiredMovies: expiredCount,
            categoryCounts: categoryCounts
        )
    }

    /// Clear all cached data
    func clearAll() async {
        memoryCache.removeAll()
        categoryIndex.removeAll()
        await clearDiskCache()
    }

    /// Clear expired entries only
    func clearExpired() async {
        let expiredIds = memoryCache.filter { $0.value.isExpired }.map(\.key)

        for id in expiredIds {
            memoryCache.removeValue(forKey: id)
        }

        // Update category indexes
        for (category, ids) in categoryIndex {
            categoryIndex[category] = ids.filter { !expiredIds.contains($0) }
        }

        await persistToDisk()
    }

    /// Force save to disk
    func forceSave() async {
        await persistToDisk()
    }

    // MARK: - Private Methods

    private func trimMemoryCacheIfNeeded() async {
        guard memoryCache.count > maxMemoryCacheSize else { return }

        // Remove oldest entries first
        let sorted = memoryCache.sorted { $0.value.cachedAt < $1.value.cachedAt }
        let toRemove = sorted.prefix(memoryCache.count - maxMemoryCacheSize)

        for (id, _) in toRemove {
            memoryCache.removeValue(forKey: id)
        }
    }

    private func loadFromDisk() async {
        guard let moviesURL = moviesFileURL,
              let indexURL = indexFileURL else { return }

        // Load movies
        if fileManager.fileExists(atPath: moviesURL.path) {
            do {
                let data = try Data(contentsOf: moviesURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let cached = try decoder.decode([Int: CachedMovie].self, from: data)

                // Filter out expired entries older than max age
                let cutoff = Date().addingTimeInterval(-maxDiskCacheAge)
                memoryCache = cached.filter { $0.value.cachedAt > cutoff }

                print("✅ Loaded \(memoryCache.count) movies from disk cache")
            } catch {
                print("❌ Failed to load movie cache: \(error)")
            }
        }

        // Load index
        if fileManager.fileExists(atPath: indexURL.path) {
            do {
                let data = try Data(contentsOf: indexURL)
                let decoder = JSONDecoder()
                categoryIndex = try decoder.decode([CacheCategory: [Int]].self, from: data)

                print("✅ Loaded category index from disk")
            } catch {
                print("❌ Failed to load category index: \(error)")
            }
        }
    }

    private func persistToDisk() async {
        guard let cacheDir = cacheDirectory,
              let moviesURL = moviesFileURL,
              let indexURL = indexFileURL else { return }

        do {
            // Create directory if needed
            try fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)

            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted

            // Save movies
            let moviesData = try encoder.encode(memoryCache)
            try moviesData.write(to: moviesURL, options: .atomic)

            // Save index
            let indexData = try encoder.encode(categoryIndex)
            try indexData.write(to: indexURL, options: .atomic)

        } catch {
            print("❌ Failed to persist cache: \(error)")
        }
    }

    private func clearDiskCache() async {
        guard let cacheDir = cacheDirectory else { return }

        try? fileManager.removeItem(at: cacheDir)
    }
}

// MARK: - Cache Stats

struct CacheStats {
    let totalMovies: Int
    let validMovies: Int
    let expiredMovies: Int
    let categoryCounts: [CacheCategory: Int]

    var description: String {
        """
        Cache Stats:
        - Total: \(totalMovies)
        - Valid: \(validMovies)
        - Expired: \(expiredMovies)
        - Categories: \(categoryCounts)
        """
    }
}

// MARK: - Offline-Aware ViewModel Protocol

protocol OfflineAwareViewModel: ObservableObject {
    var isUsingCachedData: Bool { get set }
    var isOffline: Bool { get set }

    func loadFromCache() async
    func refreshFromNetwork() async
}

// MARK: - Cache-First Data Fetcher

actor CacheFirstFetcher<T> {
    private let cache: () async -> T?
    private let network: () async throws -> T
    private let saveToCache: (T) async -> Void

    init(
        cache: @escaping () async -> T?,
        network: @escaping () async throws -> T,
        saveToCache: @escaping (T) async -> Void
    ) {
        self.cache = cache
        self.network = network
        self.saveToCache = saveToCache
    }

    /// Fetch with cache-first strategy
    func fetch(forceRefresh: Bool = false) async throws -> (data: T, fromCache: Bool) {
        // If not forcing refresh, try cache first
        if !forceRefresh, let cached = await cache() {
            // Start background refresh
            Task {
                if let fresh = try? await network() {
                    await saveToCache(fresh)
                }
            }
            return (cached, true)
        }

        // Fetch from network
        do {
            let data = try await network()
            await saveToCache(data)
            return (data, false)
        } catch {
            // If network fails, try cache as fallback
            if let cached = await cache() {
                return (cached, true)
            }
            throw error
        }
    }
}
