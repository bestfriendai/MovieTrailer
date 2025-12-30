//
//  Review.swift
//  MovieTrailer
//
//  TMDB Review Models
//  User reviews and ratings for movies
//

import Foundation

// MARK: - Review Response

struct ReviewResponse: Codable {
    let id: Int
    let page: Int
    let results: [Review]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case id, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }

    // MARK: - Convenience

    var hasMorePages: Bool {
        page < totalPages
    }

    var isEmpty: Bool {
        results.isEmpty
    }

    /// Featured reviews (highest rated or most recent)
    var featuredReviews: [Review] {
        Array(results.prefix(3))
    }
}

// MARK: - Review

struct Review: Codable, Identifiable, Hashable {
    let id: String
    let author: String
    let authorDetails: AuthorDetails?
    let content: String
    let createdAt: String?
    let updatedAt: String?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id, author, content, url
        case authorDetails = "author_details"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // MARK: - Computed Properties

    /// Author's rating (if available)
    var rating: Double? {
        authorDetails?.rating
    }

    /// Author's avatar URL
    var avatarURL: URL? {
        authorDetails?.avatarURL
    }

    /// Formatted creation date
    var formattedDate: String? {
        guard let createdAt = createdAt else { return nil }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else { return nil }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: date)
    }

    /// Relative time ago string
    var timeAgo: String? {
        guard let createdAt = createdAt else { return nil }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else { return nil }

        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: date, to: now)

        if let days = components.day, days > 30 {
            let months = days / 30
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 hour ago" : "\(hours) hours ago"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
        }
        return "Just now"
    }

    /// Truncated content for preview
    var truncatedContent: String {
        if content.count > 200 {
            return String(content.prefix(200)) + "..."
        }
        return content
    }

    /// Is this a long review that should be expandable
    var isLongReview: Bool {
        content.count > 300
    }

    /// External review URL
    var reviewURL: URL? {
        guard let url = url else { return nil }
        return URL(string: url)
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Review, rhs: Review) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Author Details

struct AuthorDetails: Codable {
    let name: String?
    let username: String?
    let avatarPath: String?
    let rating: Double?

    enum CodingKeys: String, CodingKey {
        case name, username, rating
        case avatarPath = "avatar_path"
    }

    // MARK: - Computed Properties

    var displayName: String {
        name ?? username ?? "Anonymous"
    }

    var avatarURL: URL? {
        guard let path = avatarPath else { return nil }
        // TMDB avatar paths can be either:
        // 1. A full URL starting with /https:// (for Gravatar)
        // 2. A TMDB path starting with /
        if path.hasPrefix("/https://") || path.hasPrefix("/http://") {
            return URL(string: String(path.dropFirst()))
        }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }

    /// Get initials for fallback avatar
    var initials: String {
        let name = displayName
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    /// Rating as star count (0-5)
    var starRating: Int? {
        guard let rating = rating else { return nil }
        return Int((rating / 2).rounded())
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension Review {
    static let sample = Review(
        id: "5f9d7e0b3d3e7c0039d8a8c1",
        author: "MovieFan123",
        authorDetails: AuthorDetails(
            name: "John Doe",
            username: "MovieFan123",
            avatarPath: "/path/to/avatar.jpg",
            rating: 8.5
        ),
        content: "An absolute masterpiece of cinema! The direction is flawless, the acting is superb, and the story keeps you on the edge of your seat throughout. David Fincher has outdone himself with this psychological thriller that challenges the viewer's perception of reality and society. The chemistry between Brad Pitt and Edward Norton is electric, and Helena Bonham Carter delivers a haunting performance. This film has only gotten better with age and remains one of the most influential movies of its generation.",
        createdAt: "2024-06-15T10:30:00.000Z",
        updatedAt: "2024-06-15T10:30:00.000Z",
        url: "https://www.themoviedb.org/review/5f9d7e0b3d3e7c0039d8a8c1"
    )

    static let samples: [Review] = [
        sample,
        Review(
            id: "5f9d7e0b3d3e7c0039d8a8c2",
            author: "CinemaLover",
            authorDetails: AuthorDetails(
                name: "Jane Smith",
                username: "CinemaLover",
                avatarPath: nil,
                rating: 9.0
            ),
            content: "One of my all-time favorites. The twist ending is legendary and the social commentary remains relevant today. A must-watch for any film enthusiast.",
            createdAt: "2024-05-20T14:45:00.000Z",
            updatedAt: nil,
            url: nil
        ),
        Review(
            id: "5f9d7e0b3d3e7c0039d8a8c3",
            author: "FilmCritic2024",
            authorDetails: AuthorDetails(
                name: nil,
                username: "FilmCritic2024",
                avatarPath: nil,
                rating: 7.5
            ),
            content: "A thought-provoking film that challenges viewers. While not for everyone, those who appreciate dark psychological thrillers will find much to love here.",
            createdAt: "2024-04-10T08:15:00.000Z",
            updatedAt: nil,
            url: nil
        )
    ]
}

extension ReviewResponse {
    static let sample = ReviewResponse(
        id: 550,
        page: 1,
        results: Review.samples,
        totalPages: 5,
        totalResults: 48
    )
}
#endif
