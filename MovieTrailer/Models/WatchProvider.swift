//
//  WatchProvider.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//

import Foundation

/// Response from TMDB Watch Providers API
struct WatchProvidersResponse: Codable {
    let id: Int
    let results: [String: WatchProviderCountry]
}

/// Watch provider data for a specific country
struct WatchProviderCountry: Codable {
    let link: String?
    let flatrate: [WatchProvider]?  // Streaming (Netflix, Disney+, etc.)
    let rent: [WatchProvider]?      // Rent (iTunes, Google Play, etc.)
    let buy: [WatchProvider]?       // Buy (iTunes, Google Play, etc.)
    let ads: [WatchProvider]?       // Free with ads (Tubi, etc.)
    let free: [WatchProvider]?      // Free (YouTube, etc.)
}

/// Individual streaming/rental provider
struct WatchProvider: Codable, Identifiable, Hashable {
    let providerId: Int
    let providerName: String
    let logoPath: String?
    let displayPriority: Int

    var id: Int { providerId }

    enum CodingKeys: String, CodingKey {
        case providerId = "provider_id"
        case providerName = "provider_name"
        case logoPath = "logo_path"
        case displayPriority = "display_priority"
    }

    /// Full URL for the provider logo
    var logoURL: URL? {
        guard let logoPath = logoPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w92\(logoPath)")
    }
}

/// Aggregated watch providers for display
struct WatchProviderInfo {
    let streaming: [WatchProvider]
    let rent: [WatchProvider]
    let buy: [WatchProvider]
    let free: [WatchProvider]
    let link: String?

    var isEmpty: Bool {
        streaming.isEmpty && rent.isEmpty && buy.isEmpty && free.isEmpty
    }

    var hasStreaming: Bool { !streaming.isEmpty }
    var hasRent: Bool { !rent.isEmpty }
    var hasBuy: Bool { !buy.isEmpty }
    var hasFree: Bool { !free.isEmpty }

    /// Get all unique providers
    var allProviders: [WatchProvider] {
        var seen = Set<Int>()
        var result: [WatchProvider] = []

        for provider in streaming + rent + buy + free {
            if !seen.contains(provider.id) {
                seen.insert(provider.id)
                result.append(provider)
            }
        }

        return result.sorted { $0.displayPriority < $1.displayPriority }
    }

    static let empty = WatchProviderInfo(streaming: [], rent: [], buy: [], free: [], link: nil)
}

// MARK: - Preview Helpers

#if DEBUG
extension WatchProvider {
    static let netflix = WatchProvider(
        providerId: 8,
        providerName: "Netflix",
        logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
        displayPriority: 0
    )

    static let disneyPlus = WatchProvider(
        providerId: 337,
        providerName: "Disney Plus",
        logoPath: "/7rwgEs15tFwyR9NPQ5vpzxTj19Q.jpg",
        displayPriority: 1
    )

    static let amazonPrime = WatchProvider(
        providerId: 9,
        providerName: "Amazon Prime Video",
        logoPath: "/emthp39XA2YScoYL1p0sdbAH2WA.jpg",
        displayPriority: 2
    )

    static let appleTVPlus = WatchProvider(
        providerId: 350,
        providerName: "Apple TV Plus",
        logoPath: "/6uhKBfmtzFqOcLousHwZuzcrScK.jpg",
        displayPriority: 3
    )
}

extension WatchProviderInfo {
    static let sample = WatchProviderInfo(
        streaming: [.netflix, .disneyPlus],
        rent: [.amazonPrime],
        buy: [.appleTVPlus],
        free: [],
        link: "https://www.themoviedb.org/movie/123/watch"
    )
}
#endif
