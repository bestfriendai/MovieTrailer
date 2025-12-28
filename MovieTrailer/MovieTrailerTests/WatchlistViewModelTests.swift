//
//  WatchlistViewModelTests.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Enhanced by Claude Code Audit on 28/12/2025.
//

import XCTest
@testable import MovieTrailer

/// Unit tests for WatchlistViewModel
@MainActor
final class WatchlistViewModelTests: XCTestCase {

    var sut: WatchlistViewModel!
    var mockWatchlistManager: WatchlistManager!
    var mockLiveActivityManager: LiveActivityManager!

    override func setUp() async throws {
        try await super.setUp()
        mockWatchlistManager = WatchlistManager()
        mockWatchlistManager.clearAll()
        mockLiveActivityManager = LiveActivityManager.mock(isActive: false)
        sut = WatchlistViewModel(
            watchlistManager: mockWatchlistManager,
            liveActivityManager: mockLiveActivityManager
        )
    }

    override func tearDown() async throws {
        mockWatchlistManager.clearAll()
        mockWatchlistManager = nil
        mockLiveActivityManager = nil
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.count, 0)
        XCTAssertEqual(sut.sortOption, .dateAdded)
        XCTAssertFalse(sut.isGeneratingImage)
        XCTAssertNil(sut.shareImage)
    }

    // MARK: - Items Tests

    func testItemsReturnsWatchlistItems() {
        // Given
        let movie = Movie.sample
        mockWatchlistManager.add(movie)

        // Then
        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items.first?.id, movie.id)
    }

    func testIsEmptyReturnsTrueWhenEmpty() {
        XCTAssertTrue(sut.isEmpty)
    }

    func testIsEmptyReturnsFalseWhenNotEmpty() {
        mockWatchlistManager.add(Movie.sample)
        XCTAssertFalse(sut.isEmpty)
    }

    func testCountReturnsCorrectValue() {
        mockWatchlistManager.add(Movie.sample)
        XCTAssertEqual(sut.count, 1)

        mockWatchlistManager.add(Movie.samples[1])
        XCTAssertEqual(sut.count, 2)
    }

    // MARK: - Remove Item Tests

    func testRemoveItemRemovesFromWatchlist() {
        // Given
        let movie = Movie.sample
        mockWatchlistManager.add(movie)
        let item = sut.items.first!

        // When
        sut.removeItem(item)

        // Then
        XCTAssertTrue(sut.isEmpty)
    }

    func testRemoveItemByID() {
        // Given
        let movie = Movie.sample
        mockWatchlistManager.add(movie)
        let item = sut.items.first!

        // When
        sut.removeItem(item)

        // Then
        XCTAssertFalse(mockWatchlistManager.contains(movie.id))
    }

    // MARK: - Clear All Tests

    func testClearAllRemovesEverything() {
        // Given
        for movie in Movie.samples {
            mockWatchlistManager.add(movie)
        }
        XCTAssertEqual(sut.count, Movie.samples.count)

        // When
        sut.clearAll()

        // Then
        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.count, 0)
    }

    func testClearAllOnEmptyListDoesNothing() {
        sut.clearAll()
        XCTAssertTrue(sut.isEmpty)
    }

    // MARK: - Sort Option Tests

    func testSortOptionDefaultsToDateAdded() {
        XCTAssertEqual(sut.sortOption, .dateAdded)
    }

    func testSortOptionCanBeChanged() {
        sut.sortOption = .rating
        XCTAssertEqual(sut.sortOption, .rating)

        sut.sortOption = .title
        XCTAssertEqual(sut.sortOption, .title)
    }

    func testItemsSortedByRating() {
        // Given
        let lowRatedMovie = Movie(
            id: 1, title: "Low", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 5.0, voteCount: 100, popularity: 50,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "Low", video: false
        )
        let highRatedMovie = Movie(
            id: 2, title: "High", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 9.0, voteCount: 100, popularity: 50,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "High", video: false
        )

        mockWatchlistManager.add(lowRatedMovie)
        mockWatchlistManager.add(highRatedMovie)

        // When
        sut.sortOption = .rating
        let sortedItems = mockWatchlistManager.sorted(by: .rating)

        // Then - highest rated first
        XCTAssertEqual(sortedItems.first?.id, 2)
        XCTAssertEqual(sortedItems.last?.id, 1)
    }

    func testItemsSortedByTitle() {
        // Given
        let movieZ = Movie(
            id: 1, title: "Zebra", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 8.0, voteCount: 100, popularity: 50,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "Zebra", video: false
        )
        let movieA = Movie(
            id: 2, title: "Alpha", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 7.0, voteCount: 100, popularity: 50,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "Alpha", video: false
        )

        mockWatchlistManager.add(movieZ)
        mockWatchlistManager.add(movieA)

        // When
        sut.sortOption = .title
        let sortedItems = mockWatchlistManager.sorted(by: .title)

        // Then - alphabetical order
        XCTAssertEqual(sortedItems.first?.title, "Alpha")
        XCTAssertEqual(sortedItems.last?.title, "Zebra")
    }

    // MARK: - Live Activity Tests

    func testIsLiveActivityActiveReturnsFalseInitially() {
        XCTAssertFalse(sut.isLiveActivityActive)
    }

    // MARK: - Share Image Tests

    func testShareImageNilInitially() {
        XCTAssertNil(sut.shareImage)
        XCTAssertFalse(sut.isGeneratingImage)
    }

    // MARK: - Mock Helper Tests

    func testMockCreatesValidViewModel() {
        let mockViewModel = WatchlistViewModel.mock()

        XCTAssertNotNil(mockViewModel)
        XCTAssertTrue(mockViewModel.isLiveActivityActive)
    }
}
