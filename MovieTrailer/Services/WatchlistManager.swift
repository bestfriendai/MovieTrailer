//
//  WatchlistManager.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//  Enhanced: Background I/O, debounce, and Smart Collections
//

import Foundation
import SwiftUI
import Combine

// MARK: - Smart Collection

struct SmartCollection: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
    var genreIds: [Int]
    var minRating: Double?
    var isAutomatic: Bool

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: String = "cyan",
        genreIds: [Int] = [],
        minRating: Double? = nil,
        isAutomatic: Bool = true
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.genreIds = genreIds
        self.minRating = minRating
        self.isAutomatic = isAutomatic
    }

    // Built-in collections
    static let dateNight = SmartCollection(
        name: "Date Night",
        icon: "heart.fill",
        color: "pink",
        genreIds: [10749, 35, 18], // Romance, Comedy, Drama
        minRating: 6.5
    )

    static let familyFun = SmartCollection(
        name: "Family Fun",
        icon: "figure.2.and.child.holdinghands",
        color: "green",
        genreIds: [10751, 16, 12, 14] // Family, Animation, Adventure, Fantasy
    )

    static let actionPacked = SmartCollection(
        name: "Action Packed",
        icon: "bolt.fill",
        color: "orange",
        genreIds: [28, 53, 878] // Action, Thriller, Sci-Fi
    )

    static let scaryNight = SmartCollection(
        name: "Scary Night",
        icon: "moon.fill",
        color: "purple",
        genreIds: [27, 53, 9648] // Horror, Thriller, Mystery
    )

    static let allBuiltIn: [SmartCollection] = [
        .dateNight, .familyFun, .actionPacked, .scaryNight
    ]
}

// MARK: - Background IO Actor

actor WatchlistIO {
    private let fileManager = FileManager.default
    private let fileName = "watchlist.json"
    private let collectionsFileName = "collections.json"

    private var fileURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }

    private var collectionsURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(collectionsFileName)
    }

    func loadItems() async throws -> [WatchlistItem] {
        guard let fileURL = fileURL else { return [] }

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode([WatchlistItem].self, from: data)
    }

    func saveItems(_ items: [WatchlistItem]) async throws {
        guard let fileURL = fileURL else { return }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(items)
        try data.write(to: fileURL, options: .atomic)
    }

    func loadCollections() async throws -> [SmartCollection] {
        guard let url = collectionsURL else { return [] }

        guard fileManager.fileExists(atPath: url.path) else {
            return SmartCollection.allBuiltIn
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([SmartCollection].self, from: data)
    }

    func saveCollections(_ collections: [SmartCollection]) async throws {
        guard let url = collectionsURL else { return }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(collections)
        try data.write(to: url, options: .atomic)
    }
}

/// Manages watchlist persistence using FileManager and AppStorage
/// Enhanced with background I/O, debounce, and Smart Collections
@MainActor
class WatchlistManager: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var items: [WatchlistItem] = []
    @Published private(set) var collections: [SmartCollection] = SmartCollection.allBuiltIn
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    // MARK: - Storage

    private let io = WatchlistIO()
    private var saveTask: Task<Void, Never>?
    private var debounceDelay: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds

    /// AppStorage for quick ID lookup
    @AppStorage("watchlist_ids") private var watchlistIDsData: Data = Data()

    // MARK: - Computed Properties

    /// Set of movie IDs in watchlist for quick lookup
    var movieIDs: Set<Int> {
        Set(items.map { $0.id })
    }

    /// Number of items in watchlist
    var count: Int {
        items.count
    }

    /// Whether watchlist is empty
    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Initialization

    init() {
        Task {
            await loadWatchlist()
        }
    }

    // MARK: - Public Methods

    /// Check if a movie is in the watchlist
    func contains(_ movieID: Int) -> Bool {
        movieIDs.contains(movieID)
    }

    /// Check if a movie is in the watchlist
    func contains(_ movie: Movie) -> Bool {
        contains(movie.id)
    }

    /// Add a movie to the watchlist
    func add(_ movie: Movie) {
        guard !contains(movie.id) else { return }

        let item = WatchlistItem(from: movie)
        items.insert(item, at: 0) // Add to beginning
        debouncedSave()
    }

    /// Remove a movie from the watchlist
    func remove(_ movieID: Int) {
        items.removeAll { $0.id == movieID }
        debouncedSave()
    }

    /// Remove a movie from the watchlist
    func remove(_ movie: Movie) {
        remove(movie.id)
    }

    /// Toggle a movie in/out of the watchlist
    func toggle(_ movie: Movie) {
        if contains(movie.id) {
            remove(movie.id)
        } else {
            add(movie)
        }
    }

    /// Remove all items from watchlist
    func clearAll() {
        items.removeAll()
        debouncedSave()
    }

    /// Get sorted watchlist
    func sorted(by option: WatchlistItem.SortOption) -> [WatchlistItem] {
        items.sorted(by: option.comparator)
    }

    /// Get watchlist items for specific genre
    func items(for genreID: Int) -> [WatchlistItem] {
        items.filter { $0.genreIds.contains(genreID) }
    }

    /// Get genre frequency (for recommendation engine)
    func genreFrequency() -> [Int: Int] {
        var frequency: [Int: Int] = [:]
        for item in items {
            for genreID in item.genreIds {
                frequency[genreID, default: 0] += 1
            }
        }
        return frequency
    }

    /// Get most common genres
    func topGenres(limit: Int = 3) -> [Int] {
        let frequency = genreFrequency()
        return frequency
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { $0.key }
    }

    // MARK: - Smart Collections

    /// Get items matching a smart collection
    func items(for collection: SmartCollection) -> [WatchlistItem] {
        items.filter { item in
            // Check genre match
            let genreMatch = collection.genreIds.isEmpty ||
                !Set(item.genreIds).isDisjoint(with: Set(collection.genreIds))

            // Check rating match
            let ratingMatch = collection.minRating == nil ||
                item.voteAverage >= (collection.minRating ?? 0)

            return genreMatch && ratingMatch
        }
    }

    /// Add a custom collection
    func addCollection(_ collection: SmartCollection) {
        collections.append(collection)
        Task {
            try? await io.saveCollections(collections)
        }
    }

    /// Remove a collection
    func removeCollection(_ collection: SmartCollection) {
        collections.removeAll { $0.id == collection.id }
        Task {
            try? await io.saveCollections(collections)
        }
    }

    /// Update a collection
    func updateCollection(_ collection: SmartCollection) {
        if let index = collections.firstIndex(where: { $0.id == collection.id }) {
            collections[index] = collection
            Task {
                try? await io.saveCollections(collections)
            }
        }
    }

    // MARK: - Background Persistence

    /// Load watchlist from disk (background)
    private func loadWatchlist() async {
        isLoading = true
        error = nil

        do {
            let loadedItems = try await io.loadItems()
            items = loadedItems
            updateStoredIDs()

            let loadedCollections = try await io.loadCollections()
            collections = loadedCollections
        } catch {
            self.error = error
            items = []
            print("❌ Failed to load watchlist: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Debounced save to prevent disk thrashing
    private func debouncedSave() {
        // Cancel any pending save
        saveTask?.cancel()

        // Update AppStorage immediately for quick access
        updateStoredIDs()

        // Schedule debounced background save
        saveTask = Task {
            do {
                try await Task.sleep(nanoseconds: debounceDelay)

                // Check if cancelled
                guard !Task.isCancelled else { return }

                // Save to disk in background
                try await io.saveItems(items)
            } catch {
                if !Task.isCancelled {
                    print("❌ Failed to save watchlist: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Force immediate save (for app termination)
    func forceSave() async {
        saveTask?.cancel()
        do {
            try await io.saveItems(items)
            try await io.saveCollections(collections)
        } catch {
            print("❌ Force save failed: \(error.localizedDescription)")
        }
    }

    /// Update stored IDs in AppStorage for quick access
    private func updateStoredIDs() {
        let ids = items.map { $0.id }
        if let data = try? JSONEncoder().encode(ids) {
            watchlistIDsData = data
        }
    }

    // MARK: - Export/Import

    /// Export watchlist as JSON data
    func exportData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(items)
    }

    /// Import watchlist from JSON data
    func importData(_ data: Data, merge: Bool = false) throws {
        let decoder = JSONDecoder()
        let importedItems = try decoder.decode([WatchlistItem].self, from: data)

        if merge {
            // Merge with existing items (avoid duplicates)
            let existingIDs = Set(items.map { $0.id })
            let newItems = importedItems.filter { !existingIDs.contains($0.id) }
            items.append(contentsOf: newItems)
        } else {
            // Replace all items
            items = importedItems
        }

        debouncedSave()
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension WatchlistManager {
    /// Create a mock manager with sample data
    static func mock() -> WatchlistManager {
        let manager = WatchlistManager()
        manager.items = WatchlistItem.samples
        return manager
    }
    
    /// Create an empty mock manager
    static func mockEmpty() -> WatchlistManager {
        WatchlistManager()
    }
}
#endif
