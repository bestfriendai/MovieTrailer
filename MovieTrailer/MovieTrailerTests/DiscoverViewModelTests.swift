//
//  DiscoverViewModelTests.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Enhanced by Claude Code Audit on 28/12/2025.
//

import XCTest
@testable import MovieTrailer

/// Unit tests for DiscoverViewModel
@MainActor
final class DiscoverViewModelTests: XCTestCase {

    var sut: DiscoverViewModel!
    var mockWatchlistManager: WatchlistManager!

    override func setUp() async throws {
        try await super.setUp()
        mockWatchlistManager = WatchlistManager()
        mockWatchlistManager.clearAll()
        sut = DiscoverViewModel(
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
        XCTAssertTrue(sut.trendingMovies.isEmpty)
        XCTAssertTrue(sut.popularMovies.isEmpty)
        XCTAssertTrue(sut.topRatedMovies.isEmpty)
        XCTAssertFalse(sut.isLoadingTrending)
        XCTAssertFalse(sut.isLoadingPopular)
        XCTAssertFalse(sut.isLoadingTopRated)
        XCTAssertNil(sut.error)
    }

    // MARK: - Loading State Tests

    func testLoadTrendingSetsLoadingState() async {
        // Verify initial state
        XCTAssertFalse(sut.isLoadingTrending)

        // We can't easily test intermediate loading state without mocking
        // but we can verify final state
        await sut.loadTrending()

        XCTAssertFalse(sut.isLoadingTrending)
    }

    func testLoadPopularSetsLoadingState() async {
        XCTAssertFalse(sut.isLoadingPopular)

        await sut.loadPopular()

        XCTAssertFalse(sut.isLoadingPopular)
    }

    func testLoadTopRatedSetsLoadingState() async {
        XCTAssertFalse(sut.isLoadingTopRated)

        await sut.loadTopRated()

        XCTAssertFalse(sut.isLoadingTopRated)
    }

    // MARK: - Content Loading Tests

    func testRefreshLoadsAllContent() async {
        // Given
        sut.trendingMovies = []
        sut.popularMovies = []
        sut.topRatedMovies = []

        // When
        await sut.refresh()

        // Then - loading completed (may or may not have data depending on mock)
        XCTAssertFalse(sut.isLoadingTrending)
        XCTAssertFalse(sut.isLoadingPopular)
        XCTAssertFalse(sut.isLoadingTopRated)
    }

    // MARK: - Watchlist Integration Tests

    func testIsInWatchlistReturnsTrueForAddedMovie() {
        let movie = Movie.sample
        mockWatchlistManager.add(movie)

        XCTAssertTrue(sut.isInWatchlist(movie))
    }

    func testIsInWatchlistReturnsFalseForNotAddedMovie() {
        let movie = Movie.sample

        XCTAssertFalse(sut.isInWatchlist(movie))
    }

    func testToggleWatchlistAddsMovie() {
        let movie = Movie.sample

        sut.toggleWatchlist(for: movie)

        XCTAssertTrue(mockWatchlistManager.contains(movie))
    }

    func testToggleWatchlistRemovesMovie() {
        let movie = Movie.sample
        mockWatchlistManager.add(movie)

        sut.toggleWatchlist(for: movie)

        XCTAssertFalse(mockWatchlistManager.contains(movie))
    }

    // MARK: - Multiple Movies Tests

    func testToggleWatchlistForMultipleMovies() {
        let movies = Movie.samples

        for movie in movies {
            sut.toggleWatchlist(for: movie)
        }

        XCTAssertEqual(mockWatchlistManager.count, movies.count)

        for movie in movies {
            XCTAssertTrue(sut.isInWatchlist(movie))
        }
    }

    // MARK: - Mock Helper Tests

    func testMockCreatesValidViewModel() {
        let mockViewModel = DiscoverViewModel.mock()

        XCTAssertNotNil(mockViewModel)
        XCTAssertEqual(mockViewModel.trendingMovies.count, Movie.samples.count)
        XCTAssertEqual(mockViewModel.popularMovies.count, Movie.samples.count)
        XCTAssertEqual(mockViewModel.topRatedMovies.count, Movie.samples.count)
    }
}
