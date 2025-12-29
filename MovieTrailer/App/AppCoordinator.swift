//
//  AppCoordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//  Enhanced by Claude Code Audit on 28/12/2025.
//  Added: Comprehensive deep link handling
//

import SwiftUI
import Combine

/// Deep link route definitions
enum DeepLinkRoute: Equatable {
    case movie(id: Int)
    case search(query: String)
    case watchlist
    case discover
    case tonight

    /// Parse URL into route
    static func from(url: URL) -> DeepLinkRoute? {
        // Handle custom URL scheme: movietrailer://
        // Examples:
        // - movietrailer://movie/123
        // - movietrailer://search?q=matrix
        // - movietrailer://watchlist
        // - movietrailer://discover
        // - movietrailer://tonight

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }

        let pathComponents = components.path.split(separator: "/").map(String.init)

        switch components.host?.lowercased() ?? pathComponents.first?.lowercased() {
        case "movie":
            // movietrailer://movie/123
            let idString = pathComponents.first ?? pathComponents.dropFirst().first ?? ""
            if let id = Int(idString) {
                return .movie(id: id)
            }
            // Try query parameter: movietrailer://movie?id=123
            if let idParam = components.queryItems?.first(where: { $0.name == "id" })?.value,
               let id = Int(idParam) {
                return .movie(id: id)
            }

        case "search":
            // movietrailer://search?q=matrix
            if let query = components.queryItems?.first(where: { $0.name == "q" || $0.name == "query" })?.value {
                return .search(query: query)
            }

        case "watchlist":
            return .watchlist

        case "discover":
            return .discover

        case "tonight":
            return .tonight

        default:
            break
        }

        return nil
    }

    /// Parse universal link (HTTPS URL)
    static func fromUniversalLink(url: URL) -> DeepLinkRoute? {
        // Handle universal links from TMDB
        // Example: https://www.themoviedb.org/movie/550
        guard let host = url.host?.lowercased() else { return nil }

        if host.contains("themoviedb.org") {
            let pathComponents = url.pathComponents.filter { $0 != "/" }
            if pathComponents.first == "movie",
               let idString = pathComponents.dropFirst().first,
               let id = Int(idString) {
                return .movie(id: id)
            }
        }

        return nil
    }
}

/// Root coordinator for the entire app with deep link support
@MainActor
final class AppCoordinator: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var pendingDeepLink: DeepLinkRoute?
    @Published private(set) var isProcessingDeepLink = false

    // MARK: - Dependencies

    /// Shared TMDB service
    let tmdbService: TMDBService

    /// Shared watchlist manager
    let watchlistManager: WatchlistManager

    /// Shared Live Activity manager
    let liveActivityManager: LiveActivityManager

    // MARK: - Child Coordinators

    private(set) var tabCoordinator: TabCoordinator?

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(
        tmdbService: TMDBService = .shared,
        watchlistManager: WatchlistManager,
        liveActivityManager: LiveActivityManager = .shared
    ) {
        self.tmdbService = tmdbService
        self.watchlistManager = watchlistManager
        self.liveActivityManager = liveActivityManager
    }

    /// Convenience initializer with default dependencies
    convenience init() {
        self.init(
            tmdbService: .shared,
            watchlistManager: WatchlistManager(),
            liveActivityManager: .shared
        )
    }

    // MARK: - Public Methods

    /// Start the app coordinator
    func start() -> some View {
        let tabCoordinator = TabCoordinator(
            tmdbService: tmdbService,
            watchlistManager: watchlistManager,
            liveActivityManager: liveActivityManager
        )
        self.tabCoordinator = tabCoordinator

        return tabCoordinator.body
    }

    /// Handle deep link URL
    func handleDeepLink(_ url: URL) {
        print("📱 Deep link received: \(url.absoluteString)")

        // Try custom URL scheme first
        if let route = DeepLinkRoute.from(url: url) {
            processRoute(route)
            return
        }

        // Try universal link
        if let route = DeepLinkRoute.fromUniversalLink(url: url) {
            processRoute(route)
            return
        }

        print("⚠️ Unrecognized deep link: \(url.absoluteString)")
    }

    /// Handle user activity (for Handoff, Spotlight, etc.)
    func handleUserActivity(_ userActivity: NSUserActivity) {
        print("📱 User activity received: \(userActivity.activityType)")

        // Handle Spotlight search
        if userActivity.activityType == "com.apple.corespotlightitem",
           let movieIdString = userActivity.userInfo?["kCSSearchableItemActivityIdentifier"] as? String,
           let movieId = Int(movieIdString.replacingOccurrences(of: "movie_", with: "")) {
            processRoute(.movie(id: movieId))
            return
        }

        // Handle web URL from universal link
        if let url = userActivity.webpageURL {
            handleDeepLink(url)
        }
    }

    /// Handle shortcut item (Quick Actions)
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        print("📱 Shortcut item: \(shortcutItem.type)")

        switch shortcutItem.type {
        case "com.movietrailer.search":
            processRoute(.search(query: ""))
            return true

        case "com.movietrailer.watchlist":
            processRoute(.watchlist)
            return true

        case "com.movietrailer.discover":
            processRoute(.discover)
            return true

        case "com.movietrailer.tonight":
            processRoute(.tonight)
            return true

        default:
            // Check if it's a movie shortcut
            if let movieIdString = shortcutItem.userInfo?["movieId"] as? String,
               let movieId = Int(movieIdString) {
                processRoute(.movie(id: movieId))
                return true
            }
        }

        return false
    }

    /// Clear pending deep link
    func clearPendingDeepLink() {
        pendingDeepLink = nil
        isProcessingDeepLink = false
    }

    // MARK: - Private Methods

    private func processRoute(_ route: DeepLinkRoute) {
        print("📱 Processing route: \(route)")

        isProcessingDeepLink = true
        pendingDeepLink = route

        // Give UI time to initialize if needed
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))

            switch route {
            case .movie(let id):
                await navigateToMovie(id: id)

            case .search(let query):
                navigateToSearch(query: query)

            case .watchlist:
                navigateToWatchlist()

            case .discover:
                navigateToDiscover()

            case .tonight:
                navigateToTonight()
            }

            isProcessingDeepLink = false
        }
    }

    private func navigateToMovie(id: Int) async {
        print("📱 Navigating to movie: \(id)")

        // Directly call TabCoordinator to navigate by ID
        await tabCoordinator?.navigateToMovie(id: id)
    }

    private func navigateToSearch(query: String) {
        print("📱 Navigating to search: \(query)")

        // Directly call TabCoordinator to perform search
        if query.isEmpty {
            tabCoordinator?.selectTab(TabCoordinator.Tab.search)
        } else {
            tabCoordinator?.performSearch(query: query)
        }
    }

    private func navigateToWatchlist() {
        print("📱 Navigating to library")
        tabCoordinator?.selectTab(TabCoordinator.Tab.library)
    }

    private func navigateToDiscover() {
        print("📱 Navigating to home")
        tabCoordinator?.selectTab(TabCoordinator.Tab.home)
    }

    private func navigateToTonight() {
        print("📱 Navigating to swipe")
        tabCoordinator?.selectTab(TabCoordinator.Tab.swipe)
    }
}

// MARK: - Notification Names (Deprecated)
// These notification names are kept for backwards compatibility
// but are no longer used. Navigation is now handled directly
// through TabCoordinator methods.

extension Notification.Name {
    @available(*, deprecated, message: "Use TabCoordinator.navigateToMovie(id:) instead")
    static let showMovieDetail = Notification.Name("showMovieDetail")

    @available(*, deprecated, message: "Use TabCoordinator.performSearch(query:) instead")
    static let performSearch = Notification.Name("performSearch")
}

// MARK: - Widget Deep Link Support

extension AppCoordinator {
    /// Handle widget URL
    func handleWidgetURL(_ url: URL) {
        // Widgets use same deep link format
        handleDeepLink(url)
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension AppCoordinator {
    static func mock() -> AppCoordinator {
        AppCoordinator(
            tmdbService: .shared,
            watchlistManager: .mock(),
            liveActivityManager: .shared
        )
    }
}
#endif
