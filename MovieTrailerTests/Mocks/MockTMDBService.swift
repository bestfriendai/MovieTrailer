//
//  MockTMDBService.swift
//  MovieTrailerTests
//
//  Created by Claude Code on 29/12/2025.
//  Mock TMDB service for testing
//

import Foundation
@testable import MovieTrailer

// MARK: - Mock TMDB Service

actor MockTMDBService {

    // MARK: - Configuration

    var shouldFail = false
    var failureError: NetworkError = .unknown
    var delay: UInt64 = 0

    // MARK: - Response Data

    var trendingResponse: MovieResponse = .sample
    var popularResponse: MovieResponse = .sample
    var topRatedResponse: MovieResponse = .sample
    var nowPlayingResponse: MovieResponse = .sample
    var upcomingResponse: MovieResponse = .sample
    var recentResponse: MovieResponse = .sample
    var searchResponse: MovieResponse = .sample
    var movieDetailResponse: Movie = .sample
    var videoResponse: VideoResponse = .sample
    var similarResponse: MovieResponse = .sample
    var recommendationsResponse: MovieResponse = .sample

    // MARK: - Call Tracking

    private(set) var fetchTrendingCallCount = 0
    private(set) var fetchPopularCallCount = 0
    private(set) var fetchTopRatedCallCount = 0
    private(set) var fetchNowPlayingCallCount = 0
    private(set) var fetchUpcomingCallCount = 0
    private(set) var searchCallCount = 0
    private(set) var fetchDetailsCallCount = 0
    private(set) var fetchVideosCallCount = 0
    private(set) var lastSearchQuery: String?

    // MARK: - Reset

    func reset() {
        shouldFail = false
        failureError = .unknown
        delay = 0
        fetchTrendingCallCount = 0
        fetchPopularCallCount = 0
        fetchTopRatedCallCount = 0
        fetchNowPlayingCallCount = 0
        fetchUpcomingCallCount = 0
        searchCallCount = 0
        fetchDetailsCallCount = 0
        fetchVideosCallCount = 0
        lastSearchQuery = nil
    }

    // MARK: - Private Helper

    private func performRequest<T>(_ response: T) async throws -> T {
        if delay > 0 {
            try await Task.sleep(nanoseconds: delay * 1_000_000)
        }

        if shouldFail {
            throw failureError
        }

        return response
    }

    // MARK: - Movie Endpoints

    func fetchTrending(page: Int = 1) async throws -> MovieResponse {
        fetchTrendingCallCount += 1
        return try await performRequest(trendingResponse)
    }

    func fetchPopular(page: Int = 1) async throws -> MovieResponse {
        fetchPopularCallCount += 1
        return try await performRequest(popularResponse)
    }

    func fetchTopRated(page: Int = 1) async throws -> MovieResponse {
        fetchTopRatedCallCount += 1
        return try await performRequest(topRatedResponse)
    }

    func fetchNowPlaying(page: Int = 1) async throws -> MovieResponse {
        fetchNowPlayingCallCount += 1
        return try await performRequest(nowPlayingResponse)
    }

    func fetchUpcoming(page: Int = 1) async throws -> MovieResponse {
        fetchUpcomingCallCount += 1
        return try await performRequest(upcomingResponse)
    }

    func fetchRecentMovies(page: Int = 1) async throws -> MovieResponse {
        return try await performRequest(recentResponse)
    }

    func searchMovies(query: String, page: Int = 1) async throws -> MovieResponse {
        searchCallCount += 1
        lastSearchQuery = query

        if query.isEmpty {
            return MovieResponse(page: 1, results: [], totalPages: 0, totalResults: 0)
        }

        return try await performRequest(searchResponse)
    }

    func fetchMovieDetails(id: Int) async throws -> Movie {
        fetchDetailsCallCount += 1
        return try await performRequest(movieDetailResponse)
    }

    func fetchVideos(for movieId: Int) async throws -> VideoResponse {
        fetchVideosCallCount += 1
        return try await performRequest(videoResponse)
    }

    func fetchSimilarMovies(for movieId: Int, page: Int = 1) async throws -> MovieResponse {
        return try await performRequest(similarResponse)
    }

    func fetchRecommendations(for movieId: Int, page: Int = 1) async throws -> MovieResponse {
        return try await performRequest(recommendationsResponse)
    }
}

// MARK: - Sample Data Extensions

extension MovieResponse {
    static let sample = MovieResponse(
        page: 1,
        results: Movie.samples,
        totalPages: 10,
        totalResults: 200
    )

    static let empty = MovieResponse(
        page: 1,
        results: [],
        totalPages: 0,
        totalResults: 0
    )

    static let singlePage = MovieResponse(
        page: 1,
        results: Movie.samples,
        totalPages: 1,
        totalResults: Movie.samples.count
    )
}

extension VideoResponse {
    static let sample = VideoResponse(
        id: 550,
        results: [
            Video(
                id: "video1",
                key: "abc123",
                name: "Official Trailer",
                site: "YouTube",
                type: "Trailer",
                official: true,
                publishedAt: "2024-01-01T00:00:00.000Z"
            ),
            Video(
                id: "video2",
                key: "def456",
                name: "Teaser",
                site: "YouTube",
                type: "Teaser",
                official: true,
                publishedAt: "2024-01-02T00:00:00.000Z"
            )
        ]
    )

    static let empty = VideoResponse(id: 550, results: [])
}
