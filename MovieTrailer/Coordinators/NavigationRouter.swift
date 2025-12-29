//
//  NavigationRouter.swift
//  MovieTrailer
//
//  Phase 3: Centralized Navigation State
//  Replaces NotificationCenter-based navigation with type-safe routing
//

import SwiftUI
import Combine

// MARK: - Navigation Destination

/// Type-safe navigation destinations
enum NavigationDestination: Hashable {
    case movieDetail(Movie)
    case movieDetailById(Int)
    case search(query: String)
    case settings

    // Hashable conformance for movie (by ID only)
    func hash(into hasher: inout Hasher) {
        switch self {
        case .movieDetail(let movie):
            hasher.combine("movieDetail")
            hasher.combine(movie.id)
        case .movieDetailById(let id):
            hasher.combine("movieDetailById")
            hasher.combine(id)
        case .search(let query):
            hasher.combine("search")
            hasher.combine(query)
        case .settings:
            hasher.combine("settings")
        }
    }

    static func == (lhs: NavigationDestination, rhs: NavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.movieDetail(let m1), .movieDetail(let m2)):
            return m1.id == m2.id
        case (.movieDetailById(let id1), .movieDetailById(let id2)):
            return id1 == id2
        case (.search(let q1), .search(let q2)):
            return q1 == q2
        case (.settings, .settings):
            return true
        default:
            return false
        }
    }
}

// MARK: - Navigation Router

/// Centralized navigation state manager
/// Replaces NotificationCenter-based navigation with observable state
@MainActor
final class NavigationRouter: ObservableObject {

    // MARK: - Published State

    /// Current navigation path for each tab
    @Published var homePath = NavigationPath()
    @Published var swipePath = NavigationPath()
    @Published var searchPath = NavigationPath()
    @Published var libraryPath = NavigationPath()

    /// Pending deep link destination
    @Published var pendingDestination: NavigationDestination?

    /// Search query to be set programmatically
    @Published var pendingSearchQuery: String?

    // MARK: - Navigation Methods

    /// Navigate to a destination in the current context
    func navigate(to destination: NavigationDestination) {
        pendingDestination = destination
    }

    /// Set search query programmatically
    func setSearchQuery(_ query: String) {
        pendingSearchQuery = query
    }

    /// Clear pending navigation
    func clearPending() {
        pendingDestination = nil
        pendingSearchQuery = nil
    }

    /// Pop to root in a specific tab
    func popToRoot(tab: TabCoordinator.Tab) {
        switch tab {
        case .home:
            homePath = NavigationPath()
        case .swipe:
            swipePath = NavigationPath()
        case .search:
            searchPath = NavigationPath()
        case .library:
            libraryPath = NavigationPath()
        }
    }

    /// Pop to root in all tabs
    func popAllToRoot() {
        homePath = NavigationPath()
        swipePath = NavigationPath()
        searchPath = NavigationPath()
        libraryPath = NavigationPath()
    }
}

// MARK: - Environment Key

private struct NavigationRouterKey: EnvironmentKey {
    static let defaultValue: NavigationRouter? = nil
}

extension EnvironmentValues {
    var navigationRouter: NavigationRouter? {
        get { self[NavigationRouterKey.self] }
        set { self[NavigationRouterKey.self] = newValue }
    }
}
