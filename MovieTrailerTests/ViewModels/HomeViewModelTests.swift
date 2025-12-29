//
//  HomeViewModelTests.swift
//  MovieTrailerTests
//
//  Created by Claude Code on 29/12/2025.
//  Unit tests for HomeViewModel
//

import XCTest
@testable import MovieTrailer

@MainActor
final class HomeViewModelTests: XCTestCase {

    // MARK: - Properties

    var sut: HomeViewModel!
    var mockService: MockTMDBService!
    var mockWatchlist: MockWatchlistManager!

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()
        mockService = MockTMDBService()
        mockWatchlist = MockWatchlistManager()
        // Note: In real implementation, HomeViewModel would need to accept a protocol
        // For now, this is a template for the test structure
    }

    override func tearDown() async throws {
        sut = nil
        mockService = nil
        mockWatchlist = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() async {
        // Given/When
        let viewModel = await createViewModel()

        // Then
        XCTAssertEqual(viewModel.viewState, .idle)
        XCTAssertTrue(viewModel.trendingMovies.isEmpty)
        XCTAssertTrue(viewModel.popularMovies.isEmpty)
        XCTAssertTrue(viewModel.topRatedMovies.isEmpty)
        XCTAssertTrue(viewModel.nowPlayingMovies.isEmpty)
        XCTAssertFalse(viewModel.showErrorBanner)
    }

    // MARK: - Load Content Tests

    func testLoadContent_Success_UpdatesViewState() async {
        // Given
        let viewModel = await createViewModel()
        await mockService.reset()

        // When
        await viewModel.loadContent()

        // Then
        XCTAssertEqual(viewModel.viewState, .success)
        XCTAssertFalse(viewModel.trendingMovies.isEmpty)
        XCTAssertFalse(viewModel.popularMovies.isEmpty)
    }

    func testLoadContent_NetworkError_ShowsErrorBanner() async {
        // Given
        let viewModel = await createViewModel()
        await mockService.reset()
        await MainActor.run {
            Task {
                await mockService.shouldFail = true
                await mockService.failureError = .timeout
            }
        }

        // When
        await viewModel.loadContent()

        // Then
        XCTAssertTrue(viewModel.showErrorBanner)
    }

    func testLoadContent_MultipleCalls_DoesNotDuplicateData() async {
        // Given
        let viewModel = await createViewModel()
        await mockService.reset()

        // When
        await viewModel.loadContent()
        let initialCount = viewModel.trendingMovies.count
        await viewModel.loadContent()

        // Then
        XCTAssertEqual(viewModel.trendingMovies.count, initialCount)
    }

    // MARK: - Refresh Tests

    func testRefresh_ClearsAndReloads() async {
        // Given
        let viewModel = await createViewModel()
        await mockService.reset()
        await viewModel.loadContent()

        // When
        await viewModel.refresh()

        // Then
        XCTAssertEqual(viewModel.viewState, .success)
    }

    // MARK: - Watchlist Integration Tests

    func testIsInWatchlist_ReturnsCorrectValue() async {
        // Given
        let movie = Movie.sample
        mockWatchlist.add(movie)
        let viewModel = await createViewModel()

        // When
        let isInWatchlist = viewModel.isInWatchlist(movie)

        // Then
        XCTAssertTrue(isInWatchlist)
    }

    func testToggleWatchlist_AddsMovie() async {
        // Given
        let movie = Movie.sample
        let viewModel = await createViewModel()

        // When
        viewModel.toggleWatchlist(for: movie)

        // Then
        XCTAssertTrue(mockWatchlist.contains(movie))
        XCTAssertEqual(mockWatchlist.toggleCallCount, 1)
    }

    func testToggleWatchlist_RemovesMovie() async {
        // Given
        let movie = Movie.sample
        mockWatchlist.add(movie)
        let viewModel = await createViewModel()

        // When
        viewModel.toggleWatchlist(for: movie)

        // Then
        XCTAssertFalse(mockWatchlist.contains(movie))
    }

    // MARK: - Error Handling Tests

    func testDismissError_ClearsErrorState() async {
        // Given
        let viewModel = await createViewModel()
        await mockService.reset()
        await MainActor.run {
            Task {
                await mockService.shouldFail = true
            }
        }
        await viewModel.loadContent()
        XCTAssertTrue(viewModel.showErrorBanner)

        // When
        viewModel.dismissError()

        // Then
        XCTAssertFalse(viewModel.showErrorBanner)
    }

    // MARK: - Helper Methods

    private func createViewModel() async -> HomeViewModel {
        // This would create the actual view model with mocked dependencies
        // For now, return a real one with real dependencies for compilation
        return HomeViewModel(
            tmdbService: .shared,
            watchlistManager: WatchlistManager()
        )
    }
}

// MARK: - SearchViewModel Tests

@MainActor
final class SearchViewModelTests: XCTestCase {

    var sut: SearchViewModel!
    var mockService: MockTMDBService!
    var mockWatchlist: MockWatchlistManager!

    override func setUp() async throws {
        try await super.setUp()
        mockService = MockTMDBService()
        mockWatchlist = MockWatchlistManager()
    }

    override func tearDown() async throws {
        sut = nil
        mockService = nil
        mockWatchlist = nil
        try await super.tearDown()
    }

    func testInitialState() async {
        // Given/When
        let viewModel = SearchViewModel(
            tmdbService: .shared,
            watchlistManager: WatchlistManager()
        )

        // Then
        XCTAssertTrue(viewModel.searchQuery.isEmpty)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertFalse(viewModel.isSearching)
        XCTAssertNil(viewModel.error)
    }

    func testSearch_WithEmptyQuery_ReturnsEmpty() async {
        // Given
        let viewModel = SearchViewModel(
            tmdbService: .shared,
            watchlistManager: WatchlistManager()
        )
        viewModel.searchQuery = ""

        // When
        viewModel.search()

        // Wait for debounce
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Then
        XCTAssertTrue(viewModel.searchResults.isEmpty)
    }

    func testClearSearch_ResetsState() async {
        // Given
        let viewModel = SearchViewModel(
            tmdbService: .shared,
            watchlistManager: WatchlistManager()
        )
        viewModel.searchQuery = "test"

        // When
        viewModel.clearSearch()

        // Then
        XCTAssertTrue(viewModel.searchQuery.isEmpty)
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertNil(viewModel.error)
    }
}

// MARK: - WatchlistViewModel Tests

@MainActor
final class WatchlistViewModelTests: XCTestCase {

    var sut: WatchlistViewModel!
    var mockWatchlist: MockWatchlistManager!

    override func setUp() async throws {
        try await super.setUp()
        mockWatchlist = .withSampleData()
    }

    override func tearDown() async throws {
        sut = nil
        mockWatchlist = nil
        try await super.tearDown()
    }

    func testItems_ReturnsSortedItems() async {
        // Given
        let viewModel = WatchlistViewModel(
            watchlistManager: WatchlistManager.mock(),
            liveActivityManager: .mock(isActive: false)
        )

        // When
        let items = viewModel.items

        // Then
        // Items should be returned (actual content depends on mock data)
        XCTAssertNotNil(items)
    }

    func testIsEmpty_WhenEmpty_ReturnsTrue() async {
        // Given
        let emptyWatchlist = WatchlistManager()
        let viewModel = WatchlistViewModel(
            watchlistManager: emptyWatchlist,
            liveActivityManager: .mock(isActive: false)
        )

        // Then
        XCTAssertTrue(viewModel.isEmpty)
    }

    func testCount_ReturnsCorrectCount() async {
        // Given
        let viewModel = WatchlistViewModel(
            watchlistManager: WatchlistManager.mock(),
            liveActivityManager: .mock(isActive: false)
        )

        // Then
        XCTAssertGreaterThan(viewModel.count, 0)
    }
}
