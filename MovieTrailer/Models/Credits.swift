//
//  Credits.swift
//  MovieTrailer
//
//  TMDB Cast & Crew Models
//  Full cast with photos, director, writer information
//

import Foundation

// MARK: - Credits Response

/// Full credits response from TMDB
struct Credits: Codable {
    let id: Int?
    let cast: [CastMember]
    let crew: [CrewMember]

    // MARK: - Convenience Accessors

    /// Get the director(s)
    var directors: [CrewMember] {
        crew.filter { $0.job.lowercased() == "director" }
    }

    /// Get the primary director
    var director: CrewMember? {
        directors.first
    }

    /// Get writers (including screenplay)
    var writers: [CrewMember] {
        crew.filter {
            $0.department.lowercased() == "writing" ||
            $0.job.lowercased().contains("writer") ||
            $0.job.lowercased().contains("screenplay")
        }
    }

    /// Get producers
    var producers: [CrewMember] {
        crew.filter { $0.job.lowercased().contains("producer") }
    }

    /// Get top-billed cast (first 10)
    var topBilledCast: [CastMember] {
        Array(cast.sorted { $0.order < $1.order }.prefix(10))
    }

    /// Get featured cast (first 5)
    var featuredCast: [CastMember] {
        Array(cast.sorted { $0.order < $1.order }.prefix(5))
    }

    /// Check if credits are empty
    var isEmpty: Bool {
        cast.isEmpty && crew.isEmpty
    }

    // MARK: - Empty Credits

    static let empty = Credits(id: nil, cast: [], crew: [])
}

// MARK: - Cast Member

/// Actor/actress in a movie
struct CastMember: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let order: Int
    let adult: Bool?
    let gender: Int?
    let knownForDepartment: String?
    let originalName: String?
    let popularity: Double?
    let castId: Int?
    let creditId: String?

    enum CodingKeys: String, CodingKey {
        case id, name, character, order, adult, gender, popularity
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
        case originalName = "original_name"
        case castId = "cast_id"
        case creditId = "credit_id"
    }

    // MARK: - Computed Properties

    /// Full URL for profile image (w185 size)
    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }

    /// Full URL for high-res profile image
    var profileURLLarge: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    /// Gender display string
    var genderString: String? {
        guard let gender = gender else { return nil }
        switch gender {
        case 1: return "Female"
        case 2: return "Male"
        case 3: return "Non-binary"
        default: return nil
        }
    }

    /// Whether this person has a profile image
    var hasProfileImage: Bool {
        profilePath != nil
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(character)
    }

    static func == (lhs: CastMember, rhs: CastMember) -> Bool {
        lhs.id == rhs.id && lhs.character == rhs.character
    }
}

// MARK: - Crew Member

/// Behind-the-scenes crew member
struct CrewMember: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let job: String
    let department: String
    let profilePath: String?
    let adult: Bool?
    let gender: Int?
    let knownForDepartment: String?
    let originalName: String?
    let popularity: Double?
    let creditId: String?

    enum CodingKeys: String, CodingKey {
        case id, name, job, department, adult, gender, popularity
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
        case originalName = "original_name"
        case creditId = "credit_id"
    }

    // MARK: - Computed Properties

    /// Full URL for profile image
    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }

    /// Whether this is a director
    var isDirector: Bool {
        job.lowercased() == "director"
    }

    /// Whether this is a writer
    var isWriter: Bool {
        department.lowercased() == "writing"
    }

    /// Whether this is a producer
    var isProducer: Bool {
        job.lowercased().contains("producer")
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(job)
    }

    static func == (lhs: CrewMember, rhs: CrewMember) -> Bool {
        lhs.id == rhs.id && lhs.job == rhs.job
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension CastMember {
    static let sample = CastMember(
        id: 287,
        name: "Brad Pitt",
        character: "Tyler Durden",
        profilePath: "/kU3B75TyRiCgE270EyZnHjfivoq.jpg",
        order: 0,
        adult: false,
        gender: 2,
        knownForDepartment: "Acting",
        originalName: "Brad Pitt",
        popularity: 35.123,
        castId: 4,
        creditId: "52fe4250c3a36847f80149f3"
    )

    static let samples: [CastMember] = [
        sample,
        CastMember(
            id: 819,
            name: "Edward Norton",
            character: "The Narrator",
            profilePath: "/8nytsqL59SFJTVYVrN72k6qkGgJ.jpg",
            order: 1,
            adult: false,
            gender: 2,
            knownForDepartment: "Acting",
            originalName: "Edward Norton",
            popularity: 28.456,
            castId: 5,
            creditId: "52fe4250c3a36847f80149f7"
        ),
        CastMember(
            id: 1283,
            name: "Helena Bonham Carter",
            character: "Marla Singer",
            profilePath: "/mX1jEMBOzEpzLQyIxd6k8P0uqNz.jpg",
            order: 2,
            adult: false,
            gender: 1,
            knownForDepartment: "Acting",
            originalName: "Helena Bonham Carter",
            popularity: 22.789,
            castId: 6,
            creditId: "52fe4250c3a36847f80149fb"
        )
    ]
}

extension CrewMember {
    static let sample = CrewMember(
        id: 7467,
        name: "David Fincher",
        job: "Director",
        department: "Directing",
        profilePath: "/tpEczFclQZeKAiCeKZZ0adRvtfz.jpg",
        adult: false,
        gender: 2,
        knownForDepartment: "Directing",
        originalName: "David Fincher",
        popularity: 18.234,
        creditId: "52fe4250c3a36847f8014a05"
    )

    static let samples: [CrewMember] = [
        sample,
        CrewMember(
            id: 7468,
            name: "Jim Uhls",
            job: "Screenplay",
            department: "Writing",
            profilePath: nil,
            adult: false,
            gender: 2,
            knownForDepartment: "Writing",
            originalName: "Jim Uhls",
            popularity: 2.456,
            creditId: "52fe4250c3a36847f8014a0b"
        )
    ]
}

extension Credits {
    static let sample = Credits(
        id: 550,
        cast: CastMember.samples,
        crew: CrewMember.samples
    )
}
#endif
