//
//  FilterSystem.swift
//  MovieTrailer
//
//  Apple 2025 Premium Filter System
//  Comprehensive filtering for movies and TV shows
//

import SwiftUI

// MARK: - Content Type

enum ContentType: String, Codable, CaseIterable, Identifiable {
    case movie = "movie"
    case tvShow = "tv"
    case both = "both"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .movie: return "Movies"
        case .tvShow: return "TV Shows"
        case .both: return "All"
        }
    }

    var icon: String {
        switch self {
        case .movie: return "film"
        case .tvShow: return "tv"
        case .both: return "play.rectangle.on.rectangle"
        }
    }
}

// MARK: - Filter Streaming Provider
// Note: This is separate from StreamingService in StreamingBadge.swift
// which is used for UI display. This version uses provider IDs for API filtering.

enum FilterStreamingProvider: String, Codable, CaseIterable, Identifiable {
    case netflix = "8"
    case disneyPlus = "337"
    case primeVideo = "9"
    case hboMax = "384"
    case max = "1899"
    case appleTVPlus = "350"
    case hulu = "15"
    case peacock = "386"
    case paramount = "531"
    case showtime = "37"
    case starz = "43"
    case mubi = "11"

    var id: String { rawValue }

    var providerId: Int { Int(rawValue) ?? 0 }

    var displayName: String {
        switch self {
        case .netflix: return "Netflix"
        case .disneyPlus: return "Disney+"
        case .primeVideo: return "Prime Video"
        case .hboMax: return "HBO Max"
        case .max: return "Max"
        case .appleTVPlus: return "Apple TV+"
        case .hulu: return "Hulu"
        case .peacock: return "Peacock"
        case .paramount: return "Paramount+"
        case .showtime: return "Showtime"
        case .starz: return "Starz"
        case .mubi: return "Mubi"
        }
    }

    var shortName: String {
        switch self {
        case .netflix: return "Netflix"
        case .disneyPlus: return "Disney+"
        case .primeVideo: return "Prime"
        case .hboMax: return "HBO"
        case .max: return "Max"
        case .appleTVPlus: return "Apple"
        case .hulu: return "Hulu"
        case .peacock: return "Peacock"
        case .paramount: return "Para+"
        case .showtime: return "Show"
        case .starz: return "Starz"
        case .mubi: return "Mubi"
        }
    }

    var color: Color {
        Color.streamingProvider(providerId)
    }

    var logoName: String {
        rawValue
    }
}

// MARK: - Filter Genre
// Note: This is separate from Genre struct in Models/Genre.swift
// This enum provides static genre options for filtering.

enum FilterGenre: Int, Codable, CaseIterable, Identifiable {
    case action = 28
    case adventure = 12
    case animation = 16
    case comedy = 35
    case crime = 80
    case documentary = 99
    case drama = 18
    case family = 10751
    case fantasy = 14
    case history = 36
    case horror = 27
    case music = 10402
    case mystery = 9648
    case romance = 10749
    case sciFi = 878
    case thriller = 53
    case war = 10752
    case western = 37

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .action: return "Action"
        case .adventure: return "Adventure"
        case .animation: return "Animation"
        case .comedy: return "Comedy"
        case .crime: return "Crime"
        case .documentary: return "Documentary"
        case .drama: return "Drama"
        case .family: return "Family"
        case .fantasy: return "Fantasy"
        case .history: return "History"
        case .horror: return "Horror"
        case .music: return "Music"
        case .mystery: return "Mystery"
        case .romance: return "Romance"
        case .sciFi: return "Sci-Fi"
        case .thriller: return "Thriller"
        case .war: return "War"
        case .western: return "Western"
        }
    }

    var icon: String {
        switch self {
        case .action: return "bolt.fill"
        case .adventure: return "map.fill"
        case .animation: return "paintpalette.fill"
        case .comedy: return "face.smiling.fill"
        case .crime: return "magnifyingglass"
        case .documentary: return "video.fill"
        case .drama: return "theatermasks.fill"
        case .family: return "figure.2.and.child.holdinghands"
        case .fantasy: return "wand.and.stars"
        case .history: return "clock.fill"
        case .horror: return "moon.fill"
        case .music: return "music.note"
        case .mystery: return "questionmark.circle.fill"
        case .romance: return "heart.fill"
        case .sciFi: return "sparkles"
        case .thriller: return "exclamationmark.triangle.fill"
        case .war: return "shield.fill"
        case .western: return "sun.max.fill"
        }
    }

    var color: Color {
        Color.genre(rawValue)
    }
}

// MARK: - Sort Option

enum SortOption: String, Codable, CaseIterable, Identifiable {
    case popularity = "popularity.desc"
    case rating = "vote_average.desc"
    case releaseDate = "release_date.desc"
    case title = "original_title.asc"
    case voteCount = "vote_count.desc"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .popularity: return "Most Popular"
        case .rating: return "Highest Rated"
        case .releaseDate: return "Newest First"
        case .title: return "Title A-Z"
        case .voteCount: return "Most Reviewed"
        }
    }

    var icon: String {
        switch self {
        case .popularity: return "flame.fill"
        case .rating: return "star.fill"
        case .releaseDate: return "calendar"
        case .title: return "textformat.abc"
        case .voteCount: return "person.2.fill"
        }
    }
}

// MARK: - Runtime Filter

enum RuntimeFilter: String, Codable, CaseIterable, Identifiable {
    case any = "any"
    case under90 = "under90"
    case under120 = "under120"
    case twoToThree = "twoToThree"
    case overThree = "overThree"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .any: return "Any"
        case .under90: return "< 90 min"
        case .under120: return "< 2 hours"
        case .twoToThree: return "2-3 hours"
        case .overThree: return "3+ hours"
        }
    }

    var range: ClosedRange<Int>? {
        switch self {
        case .any: return nil
        case .under90: return 0...90
        case .under120: return 0...120
        case .twoToThree: return 120...180
        case .overThree: return 180...999
        }
    }
}

// MARK: - Filter State

struct FilterState: Codable, Equatable {

    // Content type
    var contentType: ContentType = .both

    // Streaming services
    var selectedServices: Set<FilterStreamingProvider> = []
    var includeTheaters: Bool = true
    var includeRentBuy: Bool = false

    // Genres
    var includedGenres: Set<FilterGenre> = []
    var excludedGenres: Set<FilterGenre> = []

    // Rating
    var minimumRating: Double = 0.0
    var minimumVotes: Int = 0

    // Release
    var releaseYearStart: Int = 1900
    var releaseYearEnd: Int = Calendar.current.component(.year, from: Date())

    // Runtime
    var runtimeFilter: RuntimeFilter = .any

    // Sort
    var sortBy: SortOption = .popularity

    // Adult content
    var includeAdult: Bool = false

    // Computed
    var hasActiveFilters: Bool {
        contentType != .both ||
        !selectedServices.isEmpty ||
        !includedGenres.isEmpty ||
        !excludedGenres.isEmpty ||
        minimumRating > 0 ||
        runtimeFilter != .any ||
        releaseYearStart > 1900 ||
        releaseYearEnd < Calendar.current.component(.year, from: Date())
    }

    var activeFilterCount: Int {
        var count = 0
        if contentType != .both { count += 1 }
        count += selectedServices.count
        count += includedGenres.count
        count += excludedGenres.count
        if minimumRating > 0 { count += 1 }
        if runtimeFilter != .any { count += 1 }
        if releaseYearStart > 1900 || releaseYearEnd < Calendar.current.component(.year, from: Date()) { count += 1 }
        return count
    }

    mutating func reset() {
        self = FilterState()
    }
}

// MARK: - Filter Preset

struct FilterPreset: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var filter: FilterState
    var isBuiltIn: Bool

    static let builtInPresets: [FilterPreset] = [
        FilterPreset(
            id: UUID(),
            name: "Tonight",
            icon: "moon.stars.fill",
            filter: {
                var f = FilterState()
                f.runtimeFilter = .under120
                f.minimumRating = 7.0
                return f
            }(),
            isBuiltIn: true
        ),
        FilterPreset(
            id: UUID(),
            name: "Date Night",
            icon: "heart.fill",
            filter: {
                var f = FilterState()
                f.includedGenres = [.romance, .comedy, .drama]
                f.minimumRating = 7.0
                f.runtimeFilter = .under120
                return f
            }(),
            isBuiltIn: true
        ),
        FilterPreset(
            id: UUID(),
            name: "Family Movie",
            icon: "figure.2.and.child.holdinghands",
            filter: {
                var f = FilterState()
                f.excludedGenres = [.horror, .thriller]
                f.includedGenres = [.family, .animation]
                f.includeAdult = false
                return f
            }(),
            isBuiltIn: true
        ),
        FilterPreset(
            id: UUID(),
            name: "Hidden Gems",
            icon: "sparkles",
            filter: {
                var f = FilterState()
                f.minimumRating = 7.5
                f.sortBy = .voteCount
                return f
            }(),
            isBuiltIn: true
        ),
        FilterPreset(
            id: UUID(),
            name: "New Releases",
            icon: "star.fill",
            filter: {
                var f = FilterState()
                let currentYear = Calendar.current.component(.year, from: Date())
                f.releaseYearStart = currentYear - 1
                f.sortBy = .releaseDate
                return f
            }(),
            isBuiltIn: true
        ),
        FilterPreset(
            id: UUID(),
            name: "Classics",
            icon: "film.fill",
            filter: {
                var f = FilterState()
                f.releaseYearEnd = 1999
                f.minimumRating = 7.5
                return f
            }(),
            isBuiltIn: true
        )
    ]
}

// MARK: - Filter View Model

@MainActor
class FilterViewModel: ObservableObject {
    @Published var filterState: FilterState
    @Published var presets: [FilterPreset]

    private let userDefaults = UserDefaults.standard
    private let filterKey = "savedFilterState"
    private let presetsKey = "savedFilterPresets"

    init() {
        // Load saved filter state
        if let data = userDefaults.data(forKey: filterKey),
           let state = try? JSONDecoder().decode(FilterState.self, from: data) {
            self.filterState = state
        } else {
            self.filterState = FilterState()
        }

        // Load presets (built-in + user)
        if let data = userDefaults.data(forKey: presetsKey),
           let saved = try? JSONDecoder().decode([FilterPreset].self, from: data) {
            self.presets = FilterPreset.builtInPresets + saved.filter { !$0.isBuiltIn }
        } else {
            self.presets = FilterPreset.builtInPresets
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(filterState) {
            userDefaults.set(data, forKey: filterKey)
        }
    }

    func reset() {
        filterState.reset()
        save()
    }

    func applyPreset(_ preset: FilterPreset) {
        filterState = preset.filter
        save()
    }

    func saveAsPreset(name: String, icon: String) {
        let preset = FilterPreset(
            id: UUID(),
            name: name,
            icon: icon,
            filter: filterState,
            isBuiltIn: false
        )
        presets.append(preset)

        // Save user presets
        let userPresets = presets.filter { !$0.isBuiltIn }
        if let data = try? JSONEncoder().encode(userPresets) {
            userDefaults.set(data, forKey: presetsKey)
        }
    }

    func deletePreset(_ preset: FilterPreset) {
        guard !preset.isBuiltIn else { return }
        presets.removeAll { $0.id == preset.id }

        let userPresets = presets.filter { !$0.isBuiltIn }
        if let data = try? JSONEncoder().encode(userPresets) {
            userDefaults.set(data, forKey: presetsKey)
        }
    }
}
