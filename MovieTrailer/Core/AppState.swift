//
//  AppState.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Centralized app state management with Environment integration
//

import Foundation
import SwiftUI
import Combine

// MARK: - App State

@MainActor
final class AppState: ObservableObject {

    // MARK: - Singleton

    static let shared = AppState()

    // MARK: - Published Properties

    @Published var isOnboarded: Bool {
        didSet {
            UserDefaults.standard.set(isOnboarded, forKey: "isOnboarded")
        }
    }

    @Published var hasSeenSwipeTutorial: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenSwipeTutorial, forKey: "hasSeenSwipeTutorial")
        }
    }

    @Published var prefersDarkMode: Bool = true
    @Published var prefersReducedMotion: Bool = false
    @Published var isLowPowerMode: Bool = false

    // MARK: - Services (Shared Dependencies)

    let tmdbService: TMDBService
    let watchlistManager: WatchlistManager
    let networkMonitor: NetworkMonitor
    let offlineCache: OfflineMovieCache
    let recommendationEngine: RecommendationEngine
    let imageCacheManager: ImageCacheManager

    // MARK: - App State

    @Published var currentTab: Int = 0
    @Published var selectedMovie: Movie?
    @Published var isShowingMovieDetail: Bool = false
    @Published var globalError: AppError?
    @Published var isLoading: Bool = false

    // MARK: - Initialization

    private init() {
        // Load persisted state
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        self.hasSeenSwipeTutorial = UserDefaults.standard.bool(forKey: "hasSeenSwipeTutorial")

        // Initialize services
        self.tmdbService = .shared
        self.watchlistManager = WatchlistManager()
        self.networkMonitor = .shared
        self.offlineCache = .shared
        self.recommendationEngine = .shared
        self.imageCacheManager = .shared

        // Setup observers
        setupObservers()
    }

    // MARK: - Setup

    private func setupObservers() {
        // Observe low power mode
        NotificationCenter.default.addObserver(
            forName: .NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        }

        // Initial check
        isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    }

    // MARK: - Navigation

    func showMovieDetail(_ movie: Movie) {
        selectedMovie = movie
        isShowingMovieDetail = true
        Haptics.shared.mediumImpact()
    }

    func dismissMovieDetail() {
        isShowingMovieDetail = false
        selectedMovie = nil
    }

    func switchToTab(_ tab: Int) {
        currentTab = tab
        Haptics.shared.selectionChanged()
    }

    // MARK: - Error Handling

    func showError(_ error: AppError) {
        globalError = error
        Haptics.shared.error()
    }

    func clearError() {
        globalError = nil
    }

    // MARK: - Watchlist Helpers

    func isInWatchlist(_ movie: Movie) -> Bool {
        watchlistManager.contains(movie)
    }

    func toggleWatchlist(_ movie: Movie) {
        if watchlistManager.contains(movie) {
            watchlistManager.remove(movie)
            Haptics.shared.lightImpact()
        } else {
            watchlistManager.add(movie)
            Haptics.shared.success()
        }
    }

    // MARK: - App Lifecycle

    func applicationWillTerminate() {
        Task {
            await watchlistManager.forceSave()
            await offlineCache.forceSave()
        }
    }

    func applicationDidBecomeActive() {
        imageCacheManager.cleanExpiredCache()
    }

    func applicationDidEnterBackground() {
        Task {
            await watchlistManager.forceSave()
            await offlineCache.forceSave()
        }
    }
}

// MARK: - Environment Key

private struct AppStateKey: EnvironmentKey {
    static let defaultValue: AppState = .shared
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func withAppState() -> some View {
        self.environmentObject(AppState.shared)
    }
}

// MARK: - Dependency Container

@MainActor
struct DependencyContainer {
    let tmdbService: TMDBService
    let watchlistManager: WatchlistManager
    let networkMonitor: NetworkMonitor
    let offlineCache: OfflineMovieCache
    let recommendationEngine: RecommendationEngine

    static var live: DependencyContainer {
        DependencyContainer(
            tmdbService: .shared,
            watchlistManager: AppState.shared.watchlistManager,
            networkMonitor: .shared,
            offlineCache: .shared,
            recommendationEngine: .shared
        )
    }

    #if DEBUG
    static var mock: DependencyContainer {
        DependencyContainer(
            tmdbService: .mock(),
            watchlistManager: .mock(),
            networkMonitor: .shared,
            offlineCache: .shared,
            recommendationEngine: .shared
        )
    }
    #endif
}

// MARK: - Feature Flags

extension AppState {
    struct FeatureFlags {
        var isOfflineModeEnabled: Bool = true
        var isRecommendationEngineEnabled: Bool = true
        var isVoiceSearchEnabled: Bool = true
        var isLiveActivitiesEnabled: Bool = true
        var isIPadLayoutEnabled: Bool = true
        var isParallaxEnabled: Bool = true

        // Debug flags
        #if DEBUG
        var showDebugOverlay: Bool = false
        var simulateSlowNetwork: Bool = false
        var simulateOffline: Bool = false
        #endif
    }

    static var features: FeatureFlags {
        FeatureFlags()
    }
}

// MARK: - App Analytics Events

extension AppState {
    enum AnalyticsEvent {
        case appLaunched
        case tabSelected(Int)
        case movieViewed(Int)
        case movieAddedToWatchlist(Int)
        case movieRemovedFromWatchlist(Int)
        case searchPerformed(resultsCount: Int)
        case swipeCompleted(action: SwipeAction)
        case trailerPlayed(Int)
        case shareInitiated(type: String)
        case errorOccurred(String)

        var name: String {
            switch self {
            case .appLaunched: return "app_launched"
            case .tabSelected: return "tab_selected"
            case .movieViewed: return "movie_viewed"
            case .movieAddedToWatchlist: return "movie_added_to_watchlist"
            case .movieRemovedFromWatchlist: return "movie_removed_from_watchlist"
            case .searchPerformed: return "search_performed"
            case .swipeCompleted: return "swipe_completed"
            case .trailerPlayed: return "trailer_played"
            case .shareInitiated: return "share_initiated"
            case .errorOccurred: return "error_occurred"
            }
        }

        var parameters: [String: Any] {
            switch self {
            case .appLaunched:
                return [:]
            case .tabSelected(let index):
                return ["tab_index": index]
            case .movieViewed(let id):
                return ["movie_id": id]
            case .movieAddedToWatchlist(let id):
                return ["movie_id": id]
            case .movieRemovedFromWatchlist(let id):
                return ["movie_id": id]
            case .searchPerformed(let count):
                return ["results_count": count]
            case .swipeCompleted(let action):
                return ["action": action.rawValue]
            case .trailerPlayed(let id):
                return ["movie_id": id]
            case .shareInitiated(let type):
                return ["share_type": type]
            case .errorOccurred(let error):
                return ["error": error]
            }
        }
    }

    func trackEvent(_ event: AnalyticsEvent) {
        // In production, send to analytics service
        #if DEBUG
        print("📊 Analytics: \(event.name) - \(event.parameters)")
        #endif
    }
}
