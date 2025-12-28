//
//  WatchlistManagerTests.swift
//  MovieTrailerTests
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Enhanced by Claude Code Audit on 28/12/2025.
//

import XCTest
@testable import MovieTrailer

/// Unit tests for WatchlistManager
@MainActor
final class WatchlistManagerTests: XCTestCase {

    var sut: WatchlistManager!

    override func setUp() async throws {
        try await super.setUp()
        sut = WatchlistManager()
        sut.clearAll()
    }

    override func tearDown() async throws {
        sut.clearAll()
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Add/Remove Tests

    func testAddMovieToWatchlist() {
        let movie = Movie.sample

        sut.add(movie)

        XCTAssertTrue(sut.contains(movie))
        XCTAssertEqual(sut.count, 1)
    }

    func testAddDuplicateMovieDoesNothing() {
        let movie = Movie.sample

        sut.add(movie)
        sut.add(movie)

        XCTAssertEqual(sut.count, 1)
    }

    func testAddMultipleMovies() {
        let movie1 = Movie.sample
        let movie2 = Movie(
            id: 999, title: "Test Movie", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 7.0, voteCount: 0, popularity: 0,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "Test", video: false
        )

        sut.add(movie1)
        sut.add(movie2)

        XCTAssertEqual(sut.count, 2)
        XCTAssertTrue(sut.contains(movie1))
        XCTAssertTrue(sut.contains(movie2))
    }

    func testRemoveMovieFromWatchlist() {
        let movie = Movie.sample
        sut.add(movie)

        sut.remove(movie)

        XCTAssertFalse(sut.contains(movie))
        XCTAssertEqual(sut.count, 0)
    }

    func testRemoveMovieById() {
        let movie = Movie.sample
        sut.add(movie)

        sut.remove(movie.id)

        XCTAssertFalse(sut.contains(movie.id))
    }

    func testRemoveNonExistentMovieDoesNothing() {
        sut.remove(999)

        XCTAssertEqual(sut.count, 0)
    }

    func testToggleAddsIfNotInWatchlist() {
        let movie = Movie.sample

        sut.toggle(movie)

        XCTAssertTrue(sut.contains(movie))
    }

    func testToggleRemovesIfInWatchlist() {
        let movie = Movie.sample
        sut.add(movie)

        sut.toggle(movie)

        XCTAssertFalse(sut.contains(movie))
    }

    func testToggleTwiceResultsInEmpty() {
        let movie = Movie.sample

        sut.toggle(movie)
        sut.toggle(movie)

        XCTAssertFalse(sut.contains(movie))
    }

    // MARK: - Contains Tests

    func testContainsReturnsTrueForAddedMovie() {
        let movie = Movie.sample
        sut.add(movie)

        XCTAssertTrue(sut.contains(movie.id))
        XCTAssertTrue(sut.contains(movie))
    }

    func testContainsReturnsFalseForNotAddedMovie() {
        XCTAssertFalse(sut.contains(999))
    }

    // MARK: - Clear All Tests

    func testClearAllRemovesEverything() {
        sut.add(Movie.sample)

        sut.clearAll()

        XCTAssertTrue(sut.isEmpty)
        XCTAssertEqual(sut.count, 0)
    }

    func testClearAllOnEmptyListDoesNothing() {
        sut.clearAll()

        XCTAssertTrue(sut.isEmpty)
    }

    // MARK: - Sorting Tests

    func testSortByRating() {
        let movie1 = Movie(
            id: 1, title: "Low", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 5.0, voteCount: 0, popularity: 0,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "Low", video: false
        )
        let movie2 = Movie(
            id: 2, title: "High", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 9.0, voteCount: 0, popularity: 0,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "High", video: false
        )

        sut.add(movie1)
        sut.add(movie2)

        let sorted = sut.sorted(by: .rating)

        XCTAssertEqual(sorted.first?.id, 2) // High rating first
        XCTAssertEqual(sorted.last?.id, 1)
    }

    func testSortByTitle() {
        let movieA = Movie(
            id: 1, title: "Alpha", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 5.0, voteCount: 0, popularity: 0,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "Alpha", video: false
        )
        let movieZ = Movie(
            id: 2, title: "Zebra", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 9.0, voteCount: 0, popularity: 0,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "Zebra", video: false
        )

        sut.add(movieZ)
        sut.add(movieA)

        let sorted = sut.sorted(by: .title)

        XCTAssertEqual(sorted.first?.title, "Alpha") // Alphabetical
        XCTAssertEqual(sorted.last?.title, "Zebra")
    }

    func testSortByReleaseDate() {
        let oldMovie = Movie(
            id: 1, title: "Old", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: "1990-01-01", voteAverage: 5.0, voteCount: 0, popularity: 0,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "Old", video: false
        )
        let newMovie = Movie(
            id: 2, title: "New", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: "2024-01-01", voteAverage: 9.0, voteCount: 0, popularity: 0,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "New", video: false
        )

        sut.add(oldMovie)
        sut.add(newMovie)

        let sorted = sut.sorted(by: .releaseDate)

        XCTAssertEqual(sorted.first?.id, 2) // Newest first
    }

    // MARK: - Genre Frequency Tests

    func testGenreFrequency() {
        let movie1 = Movie(
            id: 1, title: "Action1", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 5.0, voteCount: 0, popularity: 0,
            genreIds: [28, 12], adult: false, originalLanguage: "en", originalTitle: "Action1", video: false
        )
        let movie2 = Movie(
            id: 2, title: "Action2", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 9.0, voteCount: 0, popularity: 0,
            genreIds: [28, 35], adult: false, originalLanguage: "en", originalTitle: "Action2", video: false
        )

        sut.add(movie1)
        sut.add(movie2)

        let frequency = sut.genreFrequency()

        XCTAssertEqual(frequency[28], 2) // Action appears twice
        XCTAssertEqual(frequency[12], 1) // Adventure once
        XCTAssertEqual(frequency[35], 1) // Comedy once
    }

    func testGenreFrequencyEmptyWatchlist() {
        let frequency = sut.genreFrequency()

        XCTAssertTrue(frequency.isEmpty)
    }

    func testTopGenres() {
        let movie1 = Movie(
            id: 1, title: "M1", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 5.0, voteCount: 0, popularity: 0,
            genreIds: [28, 12], adult: false, originalLanguage: "en", originalTitle: "M1", video: false
        )
        let movie2 = Movie(
            id: 2, title: "M2", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 9.0, voteCount: 0, popularity: 0,
            genreIds: [28], adult: false, originalLanguage: "en", originalTitle: "M2", video: false
        )

        sut.add(movie1)
        sut.add(movie2)

        let topGenres = sut.topGenres(limit: 1)

        XCTAssertEqual(topGenres.first, 28) // Action is most common
    }

    func testTopGenresEmptyWatchlist() {
        let topGenres = sut.topGenres(limit: 3)

        XCTAssertTrue(topGenres.isEmpty)
    }

    // MARK: - Items for Genre Tests

    func testItemsForGenre() {
        let actionMovie = Movie(
            id: 1, title: "Action", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 5.0, voteCount: 0, popularity: 0,
            genreIds: [28], adult: false, originalLanguage: "en", originalTitle: "Action", video: false
        )
        let comedyMovie = Movie(
            id: 2, title: "Comedy", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 9.0, voteCount: 0, popularity: 0,
            genreIds: [35], adult: false, originalLanguage: "en", originalTitle: "Comedy", video: false
        )

        sut.add(actionMovie)
        sut.add(comedyMovie)

        let actionItems = sut.items(for: 28)
        let comedyItems = sut.items(for: 35)
        let dramaItems = sut.items(for: 18)

        XCTAssertEqual(actionItems.count, 1)
        XCTAssertEqual(comedyItems.count, 1)
        XCTAssertTrue(dramaItems.isEmpty)
    }

    // MARK: - Empty State Tests

    func testIsEmptyReturnsTrueWhenEmpty() {
        XCTAssertTrue(sut.isEmpty)
    }

    func testIsEmptyReturnsFalseWhenNotEmpty() {
        sut.add(Movie.sample)
        XCTAssertFalse(sut.isEmpty)
    }

    // MARK: - Movie IDs Tests

    func testMovieIDsReturnsCorrectSet() {
        let movie1 = Movie.sample
        let movie2 = Movie(
            id: 999, title: "Test", overview: "", posterPath: nil, backdropPath: nil,
            releaseDate: nil, voteAverage: 7.0, voteCount: 0, popularity: 0,
            genreIds: [], adult: false, originalLanguage: "en", originalTitle: "Test", video: false
        )

        sut.add(movie1)
        sut.add(movie2)

        let ids = sut.movieIDs

        XCTAssertEqual(ids.count, 2)
        XCTAssertTrue(ids.contains(movie1.id))
        XCTAssertTrue(ids.contains(999))
    }
}
