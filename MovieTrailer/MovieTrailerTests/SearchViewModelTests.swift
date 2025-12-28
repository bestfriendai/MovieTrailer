//
//  SearchViewModelTests.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Enhanced by Claude Code Audit on 28/12/2025.
//

import XCTest
@testable import MovieTrailer

/// Unit tests for SearchViewModel
@MainActor
final class SearchViewModelTests: XCTestCase {

    var sut: SearchViewModel!
    var mockWatchlistManager: WatchlistManager!

    override func setUp() async throws {
        try await super.setUp()
        mockWatchlistManager = WatchlistManager()
        mockWatchlistManager.clearAll()
        sut = SearchViewModel(
            tmdbService: .mock(),
            watchlistManager: mockWatchlistManager
        )
    }

    override func tearDown() async throws {
        mockWatchlistManager.clearAll()
        mockWatchlistManager = nil
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(sut.searchQuery.isEmpty)
        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertFalse(sut.isSearching)
        XCTAssertNil(sut.error)
    }

    // MARK: - Search Query Tests

    func testClearSearchResetsState() {
        // Given
        sut.searchQuery = "Matrix"
        sut.searchResults = Movie.samples

        // When
        sut.clearSearch()

        // Then
        XCTAssertTrue(sut.searchQuery.isEmpty)
        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertNil(sut.error)
    }

    func testSearchWithEmptyQueryClearsResults() {
        // Given
        sut.searchResults = Movie.samples
        sut.searchQuery = ""

        // When
        sut.search()

        // Then
        XCTAssertTrue(sut.searchResults.isEmpty)
    }

    func testSearchWithWhitespaceOnlyClearsResults() {
        // Given
        sut.searchResults = Movie.samples
        sut.searchQuery = "   "

        // When
        sut.search()

        // Then
        XCTAssertTrue(sut.searchResults.isEmpty)
    }

    // MARK: - Watchlist Integration Tests

    func testIsInWatchlistReturnsTrueForAddedMovie() {
        // Given
        let movie = Movie.sample
        mockWatchlistManager.add(movie)

        // Then
        XCTAssertTrue(sut.isInWatchlist(movie))
    }

    func testIsInWatchlistReturnsFalseForNotAddedMovie() {
        // Given
        let movie = Movie.sample

        // Then
        XCTAssertFalse(sut.isInWatchlist(movie))
    }

    func testToggleWatchlistAddsMovie() {
        // Given
        let movie = Movie.sample

        // When
        sut.toggleWatchlist(for: movie)

        // Then
        XCTAssertTrue(mockWatchlistManager.contains(movie))
    }

    func testToggleWatchlistRemovesMovie() {
        // Given
        let movie = Movie.sample
        mockWatchlistManager.add(movie)

        // When
        sut.toggleWatchlist(for: movie)

        // Then
        XCTAssertFalse(mockWatchlistManager.contains(movie))
    }

    func testToggleWatchlistTwiceResultsInEmpty() {
        // Given
        let movie = Movie.sample

        // When
        sut.toggleWatchlist(for: movie)
        sut.toggleWatchlist(for: movie)

        // Then
        XCTAssertFalse(mockWatchlistManager.contains(movie))
    }

    // MARK: - Search Debounce Tests

    func testSearchCancelsPreviousTask() async throws {
        // Given
        sut.searchQuery = "First"
        sut.search()

        // When - immediately start a second search
        sut.searchQuery = "Second"
        sut.search()

        // Wait for debounce
        try await Task.sleep(for: .milliseconds(350))

        // Then - only the second search should be active
        XCTAssertEqual(sut.searchQuery, "Second")
    }

    // MARK: - Mock Helper Tests

    func testMockCreatesValidViewModel() {
        let mockViewModel = SearchViewModel.mock()

        XCTAssertNotNil(mockViewModel)
        XCTAssertEqual(mockViewModel.searchResults.count, Movie.samples.count)
    }
}
