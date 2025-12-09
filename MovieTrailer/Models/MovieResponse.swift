//
//  MovieResponse.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 09/12/2025.
//

import Foundation

/// Wrapper for paginated TMDB API responses
struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
    // MARK: - Computed Properties
    
    /// Whether there are more pages to load
    var hasMorePages: Bool {
        page < totalPages
    }
    
    /// Next page number to load
    var nextPage: Int {
        page + 1
    }
    
    /// Whether this is the first page
    var isFirstPage: Bool {
        page == 1
    }
    
    /// Whether this is the last page
    var isLastPage: Bool {
        page >= totalPages
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension MovieResponse {
    /// Sample response for SwiftUI previews
    static let sample = MovieResponse(
        page: 1,
        results: Movie.samples,
        totalPages: 500,
        totalResults: 10000
    )
    
    /// Sample last page response
    static let lastPageSample = MovieResponse(
        page: 500,
        results: Movie.samples,
        totalPages: 500,
        totalResults: 10000
    )
    
    /// Empty response
    static let empty = MovieResponse(
        page: 1,
        results: [],
        totalPages: 0,
        totalResults: 0
    )
}
#endif
