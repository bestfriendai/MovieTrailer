//
//  WatchlistManager.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import Foundation
import SwiftUI

/// Manages watchlist persistence using FileManager and AppStorage
@MainActor
class WatchlistManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var items: [WatchlistItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // MARK: - Storage
    
    private let fileManager = FileManager.default
    private let fileName = "watchlist.json"
    
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
    
    /// File URL for watchlist JSON
    private var fileURL: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }
    
    // MARK: - Initialization
    
    init() {
        loadWatchlist()
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
        saveWatchlist()
    }
    
    /// Remove a movie from the watchlist
    func remove(_ movieID: Int) {
        items.removeAll { $0.id == movieID }
        saveWatchlist()
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
        saveWatchlist()
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
    
    // MARK: - Persistence
    
    /// Load watchlist from disk
    private func loadWatchlist() {
        isLoading = true
        error = nil
        
        guard let fileURL = fileURL else {
            isLoading = false
            return
        }
        
        do {
            // Check if file exists
            guard fileManager.fileExists(atPath: fileURL.path) else {
                items = []
                isLoading = false
                return
            }
            
            // Load and decode
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            items = try decoder.decode([WatchlistItem].self, from: data)
            
            // Update AppStorage IDs
            updateStoredIDs()
            
            isLoading = false
        } catch {
            self.error = error
            items = []
            isLoading = false
            print("❌ Failed to load watchlist: \(error.localizedDescription)")
        }
    }
    
    /// Save watchlist to disk
    private func saveWatchlist() {
        guard let fileURL = fileURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(items)
            try data.write(to: fileURL, options: .atomic)
            
            // Update AppStorage IDs
            updateStoredIDs()
            
        } catch {
            self.error = error
            print("❌ Failed to save watchlist: \(error.localizedDescription)")
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
        
        saveWatchlist()
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
