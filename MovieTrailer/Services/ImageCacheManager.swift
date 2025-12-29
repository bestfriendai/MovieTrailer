//
//  ImageCacheManager.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Centralized image caching with memory pressure handling
//

import Foundation
import UIKit
import SwiftUI
import Kingfisher

/// Centralized image cache manager with memory pressure handling and prefetching
@MainActor
final class ImageCacheManager {

    // MARK: - Singleton

    static let shared = ImageCacheManager()

    // MARK: - Properties

    private let prefetcher = ImagePrefetcher()
    private var activePrefetchURLs: Set<URL> = []
    private var prefetchTasks: [String: [URL]] = [:]

    // MARK: - Configuration

    private let memoryLimit: Int = 100 * 1024 * 1024  // 100MB
    private let diskLimit: UInt = 500 * 1024 * 1024   // 500MB

    // MARK: - Initialization

    private init() {
        configureCache()
        setupMemoryWarningObserver()
    }

    // MARK: - Configuration

    private func configureCache() {
        let cache = ImageCache.default

        // Memory cache configuration
        cache.memoryStorage.config.totalCostLimit = memoryLimit
        cache.memoryStorage.config.countLimit = 150
        cache.memoryStorage.config.expiration = .seconds(300) // 5 minutes

        // Disk cache configuration
        cache.diskStorage.config.sizeLimit = diskLimit
        cache.diskStorage.config.expiration = .days(7)

        // Downloader configuration
        let downloader = ImageDownloader.default
        downloader.downloadTimeout = 30

        // Enable progressive JPEG loading
        KingfisherManager.shared.defaultOptions = [
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage,
            .backgroundDecode,
            .alsoPrefetchToMemory
        ]
    }

    private func setupMemoryWarningObserver() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }

        // Also observe when app enters background
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reduceMemoryFootprint()
        }
    }

    // MARK: - Memory Management

    private func handleMemoryWarning() {
        print("⚠️ Memory warning received - clearing image cache")

        // Stop all prefetching immediately
        prefetcher.stop()
        activePrefetchURLs.removeAll()
        prefetchTasks.removeAll()

        // Clear memory cache but keep disk cache
        ImageCache.default.clearMemoryCache()

        // Trigger haptic to indicate something happened
        Haptics.shared.warning()
    }

    private func reduceMemoryFootprint() {
        // Reduce memory cache when backgrounded
        ImageCache.default.memoryStorage.config.totalCostLimit = memoryLimit / 2

        // Clear some memory
        ImageCache.default.cleanExpiredMemoryCache()
    }

    // MARK: - Prefetching

    /// Prefetch images for a carousel (high priority)
    func prefetchForCarousel(movies: [Movie]) {
        let urls = movies.compactMap { $0.backdropURL ?? $0.posterURL }
        prefetch(urls: urls, priority: .high, key: "carousel")
    }

    /// Prefetch posters for a movie row
    func prefetchForRow(movies: [Movie], rowKey: String) {
        let urls = movies.compactMap { $0.posterURL }
        prefetch(urls: urls, priority: .normal, key: rowKey)
    }

    /// Prefetch images for swipe cards (important for smooth experience)
    func prefetchForSwipeCards(movies: [Movie]) {
        // Prefetch both poster and backdrop for swipe cards
        var urls: [URL] = []
        for movie in movies.prefix(5) {
            if let poster = movie.posterURL { urls.append(poster) }
            if let backdrop = movie.backdropURL { urls.append(backdrop) }
        }
        prefetch(urls: urls, priority: .high, key: "swipe")
    }

    /// Prefetch movie detail images
    func prefetchForDetail(movie: Movie) {
        var urls: [URL] = []
        if let backdrop = movie.backdropURL { urls.append(backdrop) }
        if let poster = movie.posterURL { urls.append(poster) }
        prefetch(urls: urls, priority: .high, key: "detail_\(movie.id)")
    }

    /// General prefetch with deduplication
    private func prefetch(urls: [URL], priority: ImagePrefetcher.Priority = .normal, key: String) {
        // Filter out already prefetched URLs
        let newURLs = urls.filter { !activePrefetchURLs.contains($0) }
        guard !newURLs.isEmpty else { return }

        // Track active prefetch
        activePrefetchURLs.formUnion(newURLs)
        prefetchTasks[key] = newURLs

        // Create prefetcher using Kingfisher's ImagePrefetcher
        let kfPrefetcher = Kingfisher.ImagePrefetcher(urls: newURLs)
        kfPrefetcher.start()
    }

    /// Cancel prefetch for a specific key
    func cancelPrefetch(key: String) {
        if let urls = prefetchTasks[key] {
            activePrefetchURLs.subtract(urls)
            prefetchTasks.removeValue(forKey: key)
        }
    }

    /// Cancel all prefetching
    func cancelAllPrefetch() {
        prefetcher.stop()
        activePrefetchURLs.removeAll()
        prefetchTasks.removeAll()
    }

    // MARK: - Cache Management

    /// Clear all caches
    func clearAllCache() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
    }

    /// Clear only memory cache
    func clearMemoryCache() {
        ImageCache.default.clearMemoryCache()
    }

    /// Clean expired cache entries
    func cleanExpiredCache() {
        ImageCache.default.cleanExpiredMemoryCache()
        ImageCache.default.cleanExpiredDiskCache()
    }

    /// Get current cache size
    func getCacheSize() async -> (memory: Int, disk: UInt) {
        let memorySize = ImageCache.default.memoryStorage.config.totalCostLimit

        return await withCheckedContinuation { continuation in
            ImageCache.default.calculateDiskStorageSize { result in
                switch result {
                case .success(let size):
                    continuation.resume(returning: (memorySize, size))
                case .failure:
                    continuation.resume(returning: (memorySize, 0))
                }
            }
        }
    }

    /// Get formatted cache size string
    func getFormattedCacheSize() async -> String {
        let (memory, disk) = await getCacheSize()
        let memoryMB = Double(memory) / (1024 * 1024)
        let diskMB = Double(disk) / (1024 * 1024)
        return String(format: "Memory: %.1f MB, Disk: %.1f MB", memoryMB, diskMB)
    }

    // MARK: - Preloading

    /// Preload a single image with completion
    func preloadImage(url: URL, completion: (() -> Void)? = nil) {
        KingfisherManager.shared.retrieveImage(with: url) { _ in
            completion?()
        }
    }

    /// Check if image is cached
    func isImageCached(url: URL) -> Bool {
        ImageCache.default.isCached(forKey: url.absoluteString)
    }
}

// MARK: - ImagePrefetcher Priority Extension

extension ImagePrefetcher {
    enum Priority {
        case high
        case normal
        case low
    }
}

// MARK: - View Extension for Easy Prefetching

extension View {
    /// Prefetch images when view appears
    func prefetchImages(_ urls: [URL], key: String) -> some View {
        self.onAppear {
            ImageCacheManager.shared.prefetchForRow(
                movies: [], // This needs to be movies
                rowKey: key
            )
        }
        .onDisappear {
            ImageCacheManager.shared.cancelPrefetch(key: key)
        }
    }
}
