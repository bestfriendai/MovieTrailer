//
//  Video.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 14/12/2025.
//

import Foundation

/// Represents a video (trailer, teaser, clip) from TMDB
struct Video: Codable, Identifiable {
    let id: String
    let key: String // YouTube video key
    let name: String
    let site: String // "YouTube", "Vimeo", etc.
    let type: String // "Trailer", "Teaser", "Clip", etc.
    let official: Bool
    let publishedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case key
        case name
        case site
        case type
        case official
        case publishedAt = "published_at"
    }
    
    // MARK: - Computed Properties
    
    /// Check if this is a YouTube video
    var isYouTube: Bool {
        site.lowercased() == "youtube"
    }
    
    /// Check if this is an official trailer
    var isOfficialTrailer: Bool {
        official && type.lowercased() == "trailer"
    }
    
    /// YouTube watch URL
    var youtubeURL: URL? {
        guard isYouTube else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }
    
    /// YouTube embed URL for iframe player
    var youtubeEmbedURL: URL? {
        guard isYouTube else { return nil }
        return URL(string: "https://www.youtube.com/embed/\(key)?playsinline=1&autoplay=1&rel=0&modestbranding=1")
    }
    
    /// YouTube thumbnail URL (high quality)
    var youtubeThumbnailURL: URL? {
        guard isYouTube else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(key)/hqdefault.jpg")
    }
    
    /// YouTube thumbnail URL (max quality)
    var youtubeMaxResThumbnailURL: URL? {
        guard isYouTube else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(key)/maxresdefault.jpg")
    }
}

// MARK: - Video Response

/// Response from TMDB /movie/{id}/videos endpoint
struct VideoResponse: Codable {
    let id: Int
    let results: [Video]
    
    /// Filter for official trailers only
    var officialTrailers: [Video] {
        results.filter { $0.isOfficialTrailer && $0.isYouTube }
    }
    
    /// Get the primary (first official) trailer
    var primaryTrailer: Video? {
        officialTrailers.first ?? results.first(where: { $0.isYouTube && $0.type.lowercased() == "trailer" })
    }
    
    /// All YouTube trailers (official and unofficial)
    var allTrailers: [Video] {
        results.filter { $0.isYouTube && $0.type.lowercased() == "trailer" }
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Video {
    /// Sample video for previews
    static let sample = Video(
        id: "1",
        key: "dQw4w9WgXcQ",
        name: "Official Trailer",
        site: "YouTube",
        type: "Trailer",
        official: true,
        publishedAt: "2024-01-15T12:00:00.000Z"
    )
    
    /// Sample teaser
    static let sampleTeaser = Video(
        id: "2",
        key: "dQw4w9WgXcQ",
        name: "Teaser Trailer",
        site: "YouTube",
        type: "Teaser",
        official: true,
        publishedAt: "2023-12-01T12:00:00.000Z"
    )
}

extension VideoResponse {
    /// Sample video response
    static let sample = VideoResponse(
        id: 550,
        results: [.sample, .sampleTeaser]
    )
}
#endif
