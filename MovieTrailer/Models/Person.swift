//
//  Person.swift
//  MovieTrailer
//
//  TMDB Person Models
//  Full actor/crew member profile and filmography
//

import Foundation

// MARK: - Person Details

/// Full person profile from TMDB
struct PersonDetails: Codable, Identifiable {
    let id: Int
    let name: String
    let biography: String?
    let birthday: String?
    let deathday: String?
    let placeOfBirth: String?
    let profilePath: String?
    let knownForDepartment: String?
    let alsoKnownAs: [String]?
    let gender: Int?
    let popularity: Double?
    let adult: Bool?
    let imdbId: String?
    let homepage: String?

    // MARK: - Appended Responses

    let movieCredits: PersonMovieCredits?
    let images: PersonImages?
    let externalIds: ExternalIds?

    enum CodingKeys: String, CodingKey {
        case id, name, biography, birthday, deathday, gender, popularity, adult, homepage
        case placeOfBirth = "place_of_birth"
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
        case alsoKnownAs = "also_known_as"
        case imdbId = "imdb_id"
        case movieCredits = "movie_credits"
        case images
        case externalIds = "external_ids"
    }

    // MARK: - Computed Properties

    /// Full URL for profile image
    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    /// High resolution profile URL
    var profileURLHD: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(path)")
    }

    /// Formatted birthday
    var formattedBirthday: String? {
        guard let birthday = birthday else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: birthday) else { return nil }
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    /// Age calculation
    var age: Int? {
        guard let birthday = birthday else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let birthDate = formatter.date(from: birthday) else { return nil }

        let endDate = deathday.flatMap { formatter.date(from: $0) } ?? Date()
        let components = Calendar.current.dateComponents([.year], from: birthDate, to: endDate)
        return components.year
    }

    /// Whether the person is deceased
    var isDeceased: Bool {
        deathday != nil
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

    /// IMDB URL
    var imdbURL: URL? {
        guard let imdbId = imdbId else { return nil }
        return URL(string: "https://www.imdb.com/name/\(imdbId)")
    }

    /// Known for movies (most popular)
    var knownForMovies: [PersonCastCredit]? {
        movieCredits?.cast.sorted { $0.popularity > $1.popularity }.prefix(8).map { $0 }
    }

    /// All movies sorted by release date
    var filmographyByDate: [PersonCastCredit]? {
        movieCredits?.cast.sorted {
            ($0.releaseDate ?? "") > ($1.releaseDate ?? "")
        }
    }

    /// Total movie count
    var movieCount: Int {
        (movieCredits?.cast.count ?? 0) + (movieCredits?.crew.count ?? 0)
    }
}

// MARK: - Person Movie Credits

struct PersonMovieCredits: Codable {
    let cast: [PersonCastCredit]
    let crew: [PersonCrewCredit]
}

// MARK: - Person Cast Credit (Acting roles)

struct PersonCastCredit: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let character: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let adult: Bool?
    let overview: String?
    let genreIds: [Int]?
    let originalLanguage: String?
    let originalTitle: String?
    let video: Bool?
    let creditId: String?
    let order: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, character, adult, overview, popularity, video, order
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case creditId = "credit_id"
    }

    // MARK: - Computed Properties

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(path)")
    }

    var releaseYear: String? {
        releaseDate?.prefix(4).description
    }

    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }

    // MARK: - Convert to Movie

    func toMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            overview: overview ?? "",
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: popularity,
            genreIds: genreIds ?? [],
            adult: adult ?? false,
            originalLanguage: originalLanguage ?? "",
            originalTitle: originalTitle ?? title,
            video: video ?? false
        )
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PersonCastCredit, rhs: PersonCastCredit) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Person Crew Credit (Behind the scenes)

struct PersonCrewCredit: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let job: String
    let department: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let popularity: Double
    let creditId: String?

    enum CodingKeys: String, CodingKey {
        case id, title, job, department, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case creditId = "credit_id"
    }

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var releaseYear: String? {
        releaseDate?.prefix(4).description
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(job)
    }

    static func == (lhs: PersonCrewCredit, rhs: PersonCrewCredit) -> Bool {
        lhs.id == rhs.id && lhs.job == rhs.job
    }
}

// MARK: - Person Images

struct PersonImages: Codable {
    let profiles: [PersonImage]
}

struct PersonImage: Codable, Identifiable {
    let aspectRatio: Double
    let height: Int
    let width: Int
    let filePath: String
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case height, width
        case aspectRatio = "aspect_ratio"
        case filePath = "file_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    var id: String { filePath }

    var imageURL: URL? {
        URL(string: "https://image.tmdb.org/t/p/w500\(filePath)")
    }

    var imageURLHD: URL? {
        URL(string: "https://image.tmdb.org/t/p/original\(filePath)")
    }
}

// MARK: - External IDs

struct ExternalIds: Codable {
    let imdbId: String?
    let facebookId: String?
    let instagramId: String?
    let twitterId: String?
    let tiktokId: String?
    let youtubeId: String?
    let wikidataId: String?

    enum CodingKeys: String, CodingKey {
        case imdbId = "imdb_id"
        case facebookId = "facebook_id"
        case instagramId = "instagram_id"
        case twitterId = "twitter_id"
        case tiktokId = "tiktok_id"
        case youtubeId = "youtube_id"
        case wikidataId = "wikidata_id"
    }

    var instagramURL: URL? {
        guard let id = instagramId else { return nil }
        return URL(string: "https://instagram.com/\(id)")
    }

    var twitterURL: URL? {
        guard let id = twitterId else { return nil }
        return URL(string: "https://twitter.com/\(id)")
    }

    var facebookURL: URL? {
        guard let id = facebookId else { return nil }
        return URL(string: "https://facebook.com/\(id)")
    }

    var tiktokURL: URL? {
        guard let id = tiktokId else { return nil }
        return URL(string: "https://tiktok.com/@\(id)")
    }

    var imdbURL: URL? {
        guard let id = imdbId else { return nil }
        return URL(string: "https://imdb.com/name/\(id)")
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension PersonDetails {
    static let sample = PersonDetails(
        id: 287,
        name: "Brad Pitt",
        biography: "William Bradley Pitt is an American actor and film producer. He has received multiple awards, including two Golden Globe Awards and an Academy Award for his acting, in addition to another Academy Award, another Golden Globe Award and a Primetime Emmy Award as producer under his production company, Plan B Entertainment.",
        birthday: "1963-12-18",
        deathday: nil,
        placeOfBirth: "Shawnee, Oklahoma, USA",
        profilePath: "/kU3B75TyRiCgE270EyZnHjfivoq.jpg",
        knownForDepartment: "Acting",
        alsoKnownAs: ["William Bradley Pitt", "Brad Pit"],
        gender: 2,
        popularity: 35.123,
        adult: false,
        imdbId: "nm0000093",
        homepage: nil,
        movieCredits: nil,
        images: nil,
        externalIds: ExternalIds(
            imdbId: "nm0000093",
            facebookId: nil,
            instagramId: "bradpittofficial",
            twitterId: nil,
            tiktokId: nil,
            youtubeId: nil,
            wikidataId: "Q35332"
        )
    )
}

extension PersonCastCredit {
    static let sample = PersonCastCredit(
        id: 550,
        title: "Fight Club",
        character: "Tyler Durden",
        posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        backdropPath: "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
        releaseDate: "1999-10-15",
        voteAverage: 8.4,
        voteCount: 28542,
        popularity: 89.234,
        adult: false,
        overview: "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.",
        genreIds: [18, 53],
        originalLanguage: "en",
        originalTitle: "Fight Club",
        video: false,
        creditId: "52fe4250c3a36847f80149f3",
        order: 0
    )
}
#endif
