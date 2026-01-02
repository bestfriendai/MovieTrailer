//
//  PersonDetailViewModel.swift
//  MovieTrailer
//
//  ViewModel for Person (Actor/Crew) Detail Screen
//

import Foundation
import SwiftUI

@MainActor
final class PersonDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var person: PersonDetails?
    @Published var isLoading = false
    @Published var error: NetworkError?

    @Published var knownForMovies: [PersonCastCredit] = []
    @Published var filmography: [PersonCastCredit] = []
    @Published var crewFilmography: [PersonCrewCredit] = []

    // MARK: - Private Properties

    private let personId: Int
    private let service: TMDBService

    // MARK: - Initialization

    init(personId: Int, service: TMDBService = .shared) {
        self.personId = personId
        self.service = service
    }

    // MARK: - Data Loading

    func loadPersonDetails() async {
        guard !isLoading else { return }

        isLoading = true
        error = nil

        do {
            let details = try await service.fetchPersonDetailsFull(id: personId)
            self.person = details

            // Process filmography
            if let movieCredits = details.movieCredits {
                // Known for (most popular)
                knownForMovies = movieCredits.cast
                    .sorted { $0.popularity > $1.popularity }
                    .prefix(10)
                    .map { $0 }

                // Full filmography (by release date)
                filmography = movieCredits.cast
                    .sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }

                // Crew work
                crewFilmography = movieCredits.crew
                    .sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
            }

            isLoading = false
        } catch let networkError as NetworkError {
            self.error = networkError
            isLoading = false
        } catch {
            self.error = .networkError(error.localizedDescription)
            isLoading = false
        }
    }

    // MARK: - Computed Properties

    var hasContent: Bool {
        person != nil
    }

    var displayName: String {
        person?.name ?? "Loading..."
    }

    var biography: String? {
        guard let bio = person?.biography, !bio.isEmpty else { return nil }
        return bio
    }

    var profileURL: URL? {
        person?.profileURL
    }

    var birthInfo: String? {
        guard let person = person else { return nil }
        var parts: [String] = []

        if let birthday = person.formattedBirthday {
            parts.append(birthday)
        }
        if let age = person.age {
            parts.append("(Age \(age))")
        }

        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    var placeOfBirth: String? {
        person?.placeOfBirth
    }

    var department: String? {
        person?.knownForDepartment
    }

    var movieCount: Int {
        person?.movieCount ?? 0
    }

    var socialLinks: [SocialLink] {
        guard let externalIds = person?.externalIds else { return [] }
        var links: [SocialLink] = []

        if let url = externalIds.imdbURL {
            links.append(SocialLink(type: .imdb, url: url))
        }
        if let url = externalIds.instagramURL {
            links.append(SocialLink(type: .instagram, url: url))
        }
        if let url = externalIds.twitterURL {
            links.append(SocialLink(type: .twitter, url: url))
        }
        if let url = externalIds.facebookURL {
            links.append(SocialLink(type: .facebook, url: url))
        }

        return links
    }

    // MARK: - Actions

    func retry() async {
        await loadPersonDetails()
    }
}

// MARK: - Social Link

struct SocialLink: Identifiable {
    let id = UUID()
    let type: SocialLinkType
    let url: URL

    enum SocialLinkType {
        case imdb
        case instagram
        case twitter
        case facebook
        case tiktok

        var icon: String {
            switch self {
            case .imdb: return "film"
            case .instagram: return "camera"
            case .twitter: return "at"
            case .facebook: return "person.2"
            case .tiktok: return "music.note"
            }
        }

        var name: String {
            switch self {
            case .imdb: return "IMDb"
            case .instagram: return "Instagram"
            case .twitter: return "X"
            case .facebook: return "Facebook"
            case .tiktok: return "TikTok"
            }
        }
    }
}
