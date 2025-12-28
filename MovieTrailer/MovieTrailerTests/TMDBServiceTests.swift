//
//  TMDBServiceTests.swift
//  MovieTrailerTests
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Enhanced by Claude Code Audit on 28/12/2025.
//

import XCTest
@testable import MovieTrailer

/// Unit tests for TMDBService
final class TMDBServiceTests: XCTestCase {

    var sut: TMDBService!

    override func setUp() async throws {
        try await super.setUp()
        sut = TMDBService.mock()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Endpoint Tests

    func testTrendingEndpointURL() throws {
        let endpoint = TMDBEndpoint.trending(page: 1)
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("trending/movie/day") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("page=1") ?? false)
    }

    func testPopularEndpointURL() throws {
        let endpoint = TMDBEndpoint.popular(page: 2)
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("/movie/popular") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("page=2") ?? false)
    }

    func testTopRatedEndpointURL() throws {
        let endpoint = TMDBEndpoint.topRated(page: 1)
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("/movie/top_rated") ?? false)
    }

    func testSearchEndpointURL() throws {
        let endpoint = TMDBEndpoint.search(query: "Matrix", page: 1)
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("search/movie") ?? false)
        XCTAssertTrue(url?.absoluteString.contains("query=Matrix") ?? false)
    }

    func testSearchEndpointURLEncodesSpecialCharacters() throws {
        let endpoint = TMDBEndpoint.search(query: "The Dark Knight", page: 1)
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("query=The%20Dark%20Knight") ?? false)
    }

    func testMovieDetailsEndpointURL() throws {
        let endpoint = TMDBEndpoint.movieDetails(id: 550)
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("/movie/550") ?? false)
    }

    func testVideosEndpointURL() throws {
        let endpoint = TMDBEndpoint.videos(movieId: 550)
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("/movie/550/videos") ?? false)
    }

    func testGenresEndpointURL() throws {
        let endpoint = TMDBEndpoint.genres
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertTrue(url?.absoluteString.contains("/genre/movie/list") ?? false)
    }

    // MARK: - Network Error Tests

    func testNetworkErrorFromStatusCode401() {
        let error = NetworkError.from(statusCode: 401)
        XCTAssertEqual(error, .unauthorized)
        XCTAssertTrue(error.requiresUserAction)
        XCTAssertFalse(error.isRetryable)
    }

    func testNetworkErrorFromStatusCode429() {
        let error = NetworkError.from(statusCode: 429)
        XCTAssertEqual(error, .rateLimitExceeded)
        XCTAssertTrue(error.isRetryable)
    }

    func testNetworkErrorFromStatusCode500() {
        let error = NetworkError.from(statusCode: 500)
        XCTAssertEqual(error, .serverError)
        XCTAssertTrue(error.isRetryable)
    }

    func testNetworkErrorFromStatusCode503() {
        let error = NetworkError.from(statusCode: 503)
        XCTAssertEqual(error, .serverError)
        XCTAssertTrue(error.isRetryable)
    }

    func testNetworkErrorFromStatusCode404() {
        let error = NetworkError.from(statusCode: 404)
        if case .httpError(let code) = error {
            XCTAssertEqual(code, 404)
        } else {
            XCTFail("Expected httpError")
        }
        XCTAssertFalse(error.isRetryable)
    }

    func testNetworkErrorFromStatusCode200ReturnsUnknown() {
        let error = NetworkError.from(statusCode: 200)
        XCTAssertEqual(error, .unknown)
    }

    // MARK: - Error Message Tests

    func testUnauthorizedErrorMessage() {
        let error = NetworkError.unauthorized
        XCTAssertEqual(error.userMessage, "Invalid API key")
        XCTAssertNotNil(error.recoverySuggestion)
    }

    func testNetworkErrorMessage() {
        let underlyingError = NSError(domain: "test", code: -1009)
        let error = NetworkError.networkError(underlyingError)
        XCTAssertEqual(error.userMessage, "No internet connection")
        XCTAssertTrue(error.isRetryable)
    }

    func testRateLimitErrorMessage() {
        let error = NetworkError.rateLimitExceeded
        XCTAssertEqual(error.userMessage, "Too many requests")
        XCTAssertTrue(error.isRetryable)
    }

    // MARK: - Empty Query Tests

    func testSearchWithEmptyQueryReturnsEmptyResponse() async throws {
        let response = try await sut.searchMovies(query: "")

        XCTAssertEqual(response.page, 1)
        XCTAssertTrue(response.results.isEmpty)
        XCTAssertEqual(response.totalPages, 0)
        XCTAssertEqual(response.totalResults, 0)
    }

    func testSearchWithWhitespaceOnlyQuery() async throws {
        // This should not be empty after trimming in a real implementation
        // For now, test current behavior
        let response = try await sut.searchMovies(query: "   ")

        // Current implementation doesn't trim, so it will make a request
        // This is a potential improvement area
        XCTAssertNotNil(response)
    }

    // MARK: - Cache Tests

    func testGetCacheSizeReturnsValidValues() async {
        let (memory, disk) = await sut.getCacheSize()

        XCTAssertGreaterThanOrEqual(memory, 0)
        XCTAssertGreaterThanOrEqual(disk, 0)
    }

    func testGetFormattedCacheSizeReturnsString() async {
        let formatted = await sut.getFormattedCacheSize()

        XCTAssertTrue(formatted.contains("Memory:"))
        XCTAssertTrue(formatted.contains("Disk:"))
        XCTAssertTrue(formatted.contains("MB"))
    }

    // MARK: - Endpoint Request Creation Tests

    func testEndpointCreatesValidURLRequest() throws {
        let endpoint = TMDBEndpoint.trending(page: 1)
        let request = try endpoint.urlRequest()

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    }

    func testEndpointTimeoutConfiguration() throws {
        let searchEndpoint = TMDBEndpoint.search(query: "test", page: 1)
        let searchRequest = try searchEndpoint.urlRequest()
        XCTAssertEqual(searchRequest.timeoutInterval, 10) // Search has faster timeout

        let trendingEndpoint = TMDBEndpoint.trending(page: 1)
        let trendingRequest = try trendingEndpoint.urlRequest()
        XCTAssertEqual(trendingRequest.timeoutInterval, 30) // Default timeout
    }
}

// MARK: - Network Error Equatable for Testing

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL): return true
        case (.invalidResponse, .invalidResponse): return true
        case (.httpError(let a), .httpError(let b)): return a == b
        case (.noData, .noData): return true
        case (.unauthorized, .unauthorized): return true
        case (.rateLimitExceeded, .rateLimitExceeded): return true
        case (.serverError, .serverError): return true
        case (.unknown, .unknown): return true
        case (.networkError, .networkError): return true
        case (.decodingError, .decodingError): return true
        default: return false
        }
    }
}
