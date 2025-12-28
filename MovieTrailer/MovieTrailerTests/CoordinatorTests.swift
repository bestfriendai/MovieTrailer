//
//  CoordinatorTests.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Enhanced by Claude Code Audit on 28/12/2025.
//

import XCTest
@testable import MovieTrailer

/// Unit tests for Coordinators and Deep Link parsing
@MainActor
final class CoordinatorTests: XCTestCase {

    // MARK: - DeepLinkRoute Tests

    func testDeepLinkRouteFromMovieURL() {
        let url = URL(string: "movietrailer://movie/550")!
        let route = DeepLinkRoute.from(url: url)

        XCTAssertNotNil(route)
        if case .movie(let id) = route {
            XCTAssertEqual(id, 550)
        } else {
            XCTFail("Expected movie route")
        }
    }

    func testDeepLinkRouteFromMovieURLWithQueryParam() {
        let url = URL(string: "movietrailer://movie?id=550")!
        let route = DeepLinkRoute.from(url: url)

        XCTAssertNotNil(route)
        if case .movie(let id) = route {
            XCTAssertEqual(id, 550)
        } else {
            XCTFail("Expected movie route")
        }
    }

    func testDeepLinkRouteFromSearchURL() {
        let url = URL(string: "movietrailer://search?q=matrix")!
        let route = DeepLinkRoute.from(url: url)

        XCTAssertNotNil(route)
        if case .search(let query) = route {
            XCTAssertEqual(query, "matrix")
        } else {
            XCTFail("Expected search route")
        }
    }

    func testDeepLinkRouteFromSearchURLWithQueryParam() {
        let url = URL(string: "movietrailer://search?query=inception")!
        let route = DeepLinkRoute.from(url: url)

        XCTAssertNotNil(route)
        if case .search(let query) = route {
            XCTAssertEqual(query, "inception")
        } else {
            XCTFail("Expected search route")
        }
    }

    func testDeepLinkRouteFromWatchlistURL() {
        let url = URL(string: "movietrailer://watchlist")!
        let route = DeepLinkRoute.from(url: url)

        XCTAssertEqual(route, .watchlist)
    }

    func testDeepLinkRouteFromDiscoverURL() {
        let url = URL(string: "movietrailer://discover")!
        let route = DeepLinkRoute.from(url: url)

        XCTAssertEqual(route, .discover)
    }

    func testDeepLinkRouteFromTonightURL() {
        let url = URL(string: "movietrailer://tonight")!
        let route = DeepLinkRoute.from(url: url)

        XCTAssertEqual(route, .tonight)
    }

    func testDeepLinkRouteFromInvalidURL() {
        let url = URL(string: "movietrailer://invalid")!
        let route = DeepLinkRoute.from(url: url)

        XCTAssertNil(route)
    }

    // MARK: - Universal Link Tests

    func testUniversalLinkFromTMDBMovieURL() {
        let url = URL(string: "https://www.themoviedb.org/movie/550")!
        let route = DeepLinkRoute.fromUniversalLink(url: url)

        XCTAssertNotNil(route)
        if case .movie(let id) = route {
            XCTAssertEqual(id, 550)
        } else {
            XCTFail("Expected movie route")
        }
    }

    func testUniversalLinkFromInvalidHost() {
        let url = URL(string: "https://www.example.com/movie/550")!
        let route = DeepLinkRoute.fromUniversalLink(url: url)

        XCTAssertNil(route)
    }

    func testUniversalLinkFromInvalidPath() {
        let url = URL(string: "https://www.themoviedb.org/person/123")!
        let route = DeepLinkRoute.fromUniversalLink(url: url)

        XCTAssertNil(route)
    }

    // MARK: - TabCoordinator.Tab Tests

    func testTabEnumValues() {
        XCTAssertEqual(TabCoordinator.Tab.discover.rawValue, 0)
        XCTAssertEqual(TabCoordinator.Tab.tonight.rawValue, 1)
        XCTAssertEqual(TabCoordinator.Tab.search.rawValue, 2)
        XCTAssertEqual(TabCoordinator.Tab.watchlist.rawValue, 3)
    }

    func testTabTitles() {
        XCTAssertEqual(TabCoordinator.Tab.discover.title, "Discover")
        XCTAssertEqual(TabCoordinator.Tab.tonight.title, "Tonight")
        XCTAssertEqual(TabCoordinator.Tab.search.title, "Search")
        XCTAssertEqual(TabCoordinator.Tab.watchlist.title, "Watchlist")
    }

    func testTabIcons() {
        XCTAssertEqual(TabCoordinator.Tab.discover.icon, "film")
        XCTAssertEqual(TabCoordinator.Tab.tonight.icon, "star.circle")
        XCTAssertEqual(TabCoordinator.Tab.search.icon, "magnifyingglass")
        XCTAssertEqual(TabCoordinator.Tab.watchlist.icon, "bookmark")
    }

    func testTabFilledIcons() {
        XCTAssertEqual(TabCoordinator.Tab.discover.iconFilled, "film.fill")
        XCTAssertEqual(TabCoordinator.Tab.tonight.iconFilled, "star.circle.fill")
        XCTAssertEqual(TabCoordinator.Tab.search.iconFilled, "magnifyingglass")
        XCTAssertEqual(TabCoordinator.Tab.watchlist.iconFilled, "bookmark.fill")
    }

    func testTabCaseIterable() {
        XCTAssertEqual(TabCoordinator.Tab.allCases.count, 4)
    }

    // MARK: - TabCoordinator Tests

    func testTabCoordinatorInitialization() {
        let coordinator = TabCoordinator(
            tmdbService: .mock(),
            watchlistManager: WatchlistManager(),
            liveActivityManager: .mock(isActive: false)
        )

        XCTAssertEqual(coordinator.selectedTab, 0)
        XCTAssertNotNil(coordinator.discoverCoordinator)
        XCTAssertNotNil(coordinator.tonightCoordinator)
        XCTAssertNotNil(coordinator.searchCoordinator)
        XCTAssertNotNil(coordinator.watchlistCoordinator)
    }

    func testTabCoordinatorSelectTab() {
        let coordinator = TabCoordinator(
            tmdbService: .mock(),
            watchlistManager: WatchlistManager(),
            liveActivityManager: .mock(isActive: false)
        )

        coordinator.selectTab(.watchlist)
        XCTAssertEqual(coordinator.selectedTab, 3)

        coordinator.selectTab(.search)
        XCTAssertEqual(coordinator.selectedTab, 2)
    }

    func testTabCoordinatorSelectTabByIndex() {
        let coordinator = TabCoordinator(
            tmdbService: .mock(),
            watchlistManager: WatchlistManager(),
            liveActivityManager: .mock(isActive: false)
        )

        coordinator.selectTab(index: 1)
        XCTAssertEqual(coordinator.selectedTab, 1)

        coordinator.selectTab(index: 3)
        XCTAssertEqual(coordinator.selectedTab, 3)
    }

    func testTabCoordinatorSelectTabByInvalidIndex() {
        let coordinator = TabCoordinator(
            tmdbService: .mock(),
            watchlistManager: WatchlistManager(),
            liveActivityManager: .mock(isActive: false)
        )

        coordinator.selectTab(index: 0)
        coordinator.selectTab(index: -1) // Invalid, should be ignored
        XCTAssertEqual(coordinator.selectedTab, 0)

        coordinator.selectTab(index: 100) // Invalid, should be ignored
        XCTAssertEqual(coordinator.selectedTab, 0)
    }

    // MARK: - AppCoordinator Tests

    func testAppCoordinatorInitialization() {
        let coordinator = AppCoordinator.mock()

        XCTAssertNil(coordinator.pendingDeepLink)
        XCTAssertFalse(coordinator.isProcessingDeepLink)
    }

    func testAppCoordinatorClearPendingDeepLink() {
        let coordinator = AppCoordinator.mock()

        coordinator.clearPendingDeepLink()

        XCTAssertNil(coordinator.pendingDeepLink)
        XCTAssertFalse(coordinator.isProcessingDeepLink)
    }

    // MARK: - DeepLinkRoute Equatable Tests

    func testDeepLinkRouteEquatable() {
        XCTAssertEqual(DeepLinkRoute.movie(id: 550), DeepLinkRoute.movie(id: 550))
        XCTAssertNotEqual(DeepLinkRoute.movie(id: 550), DeepLinkRoute.movie(id: 551))

        XCTAssertEqual(DeepLinkRoute.search(query: "test"), DeepLinkRoute.search(query: "test"))
        XCTAssertNotEqual(DeepLinkRoute.search(query: "test"), DeepLinkRoute.search(query: "other"))

        XCTAssertEqual(DeepLinkRoute.watchlist, DeepLinkRoute.watchlist)
        XCTAssertEqual(DeepLinkRoute.discover, DeepLinkRoute.discover)
        XCTAssertEqual(DeepLinkRoute.tonight, DeepLinkRoute.tonight)

        XCTAssertNotEqual(DeepLinkRoute.watchlist, DeepLinkRoute.discover)
    }
}
