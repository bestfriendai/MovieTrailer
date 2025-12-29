//
//  MockWatchlistManager.swift
//  MovieTrailerTests
//
//  Created by Claude Code on 29/12/2025.
//  Mock watchlist manager for testing
//

import Foundation
@testable import MovieTrailer

// MARK: - Mock Watchlist Manager

@MainActor
final class MockWatchlistManager: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var items: [WatchlistItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    // MARK: - Call Tracking

    private(set) var addCallCount = 0
    private(set) var removeCallCount = 0
    private(set) var toggleCallCount = 0
    private(set) var clearAllCallCount = 0

    // MARK: - Computed Properties

    var movieIDs: Set<Int> {
        Set(items.map { $0.id })
    }

    var count: Int {
        items.count
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    // MARK: - Initialization

    init(items: [WatchlistItem] = []) {
        self.items = items
    }

    convenience init(movies: [Movie]) {
        self.init(items: movies.map { WatchlistItem(from: $0) })
    }

    // MARK: - Public Methods

    func contains(_ movieID: Int) -> Bool {
        movieIDs.contains(movieID)
    }

    func contains(_ movie: Movie) -> Bool {
        contains(movie.id)
    }

    func add(_ movie: Movie) {
        addCallCount += 1
        guard !contains(movie.id) else { return }

        let item = WatchlistItem(from: movie)
        items.insert(item, at: 0)
    }

    func remove(_ movieID: Int) {
        removeCallCount += 1
        items.removeAll { $0.id == movieID }
    }

    func remove(_ movie: Movie) {
        remove(movie.id)
    }

    func toggle(_ movie: Movie) {
        toggleCallCount += 1
        if contains(movie.id) {
            remove(movie.id)
        } else {
            add(movie)
        }
    }

    func clearAll() {
        clearAllCallCount += 1
        items.removeAll()
    }

    func sorted(by option: WatchlistItem.SortOption) -> [WatchlistItem] {
        items.sorted(by: option.comparator)
    }

    // MARK: - Reset

    func reset() {
        items.removeAll()
        addCallCount = 0
        removeCallCount = 0
        toggleCallCount = 0
        clearAllCallCount = 0
        error = nil
    }

    // MARK: - Simulation

    func simulateLoading(_ loading: Bool) {
        isLoading = loading
    }

    func simulateError(_ error: Error?) {
        self.error = error
    }

    func setItems(_ newItems: [WatchlistItem]) {
        items = newItems
    }
}

// MARK: - Factory Methods

extension MockWatchlistManager {
    static func empty() -> MockWatchlistManager {
        MockWatchlistManager()
    }

    static func withSampleData() -> MockWatchlistManager {
        MockWatchlistManager(items: WatchlistItem.samples)
    }

    static func withMovies(_ movies: [Movie]) -> MockWatchlistManager {
        MockWatchlistManager(movies: movies)
    }
}
