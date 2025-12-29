# MovieTrailer: Ultra-Comprehensive Improvement Plan

**Analysis Date:** December 29, 2025
**Analyzed by:** Claude Opus 4.5 (Deep Code Analysis)
**App Status:** Production-Ready Foundation with Premium Polish Opportunities

---

## Executive Summary

The MovieTrailer app demonstrates **solid architectural foundations** with modern SwiftUI patterns, proper MVVM separation, and a sophisticated UI layer inspired by Apple TV aesthetics. However, several opportunities exist to elevate the app from "good" to "Apple Design Award contender" status.

### Current Strengths
- Clean MVVM architecture with proper dependency injection
- Well-implemented coordinator pattern with deep link support
- Sophisticated haptic feedback system
- Premium glass morphism design system
- Robust networking with retry logic and certificate pinning
- Background I/O for watchlist persistence with debouncing
- Voice search capability
- Live Activities support
- Smart Collections feature

### Key Areas for Improvement
1. **Performance Optimization** - Image loading, memory management, prefetching
2. **UI/UX Polish** - Micro-interactions, skeleton loading, accessibility
3. **Feature Completeness** - Offline mode, personalization, social features
4. **Code Architecture** - Testing, error handling, state management
5. **Platform Optimization** - iPad support, visionOS preparation, widgets

---

## 1. Performance Optimization

### 1.1 Image Loading & Caching

**Current State:**
- Using Kingfisher for image loading
- Basic prefetching in `HomeViewModel` for featured movies
- No explicit memory pressure handling

**Improvements:**

```swift
// Create a centralized image manager
final class ImageCacheManager {
    static let shared = ImageCacheManager()

    private let prefetcher = ImagePrefetcher()
    private var activePrefetchURLs: Set<URL> = []

    init() {
        // Configure aggressive memory limits for iPhone
        let cache = ImageCache.default
        cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024 // 100MB
        cache.memoryStorage.config.countLimit = 100
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024 // 500MB

        // Listen for memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    @objc private func handleMemoryWarning() {
        ImageCache.default.clearMemoryCache()
        prefetcher.stop()
    }

    func prefetchForCarousel(movies: [Movie]) {
        let urls = movies.compactMap { $0.backdropURL ?? $0.posterURL }
        let newURLs = Set(urls).subtracting(activePrefetchURLs)
        guard !newURLs.isEmpty else { return }

        activePrefetchURLs.formUnion(newURLs)
        prefetcher.prefetch(urls: Array(newURLs))
    }

    func cancelPrefetch(for movies: [Movie]) {
        let urls = movies.compactMap { $0.posterURL }
        activePrefetchURLs.subtract(urls)
        prefetcher.stop()
    }
}
```

**Priority:** HIGH
**Impact:** Faster perceived performance, reduced memory crashes

---

### 1.2 View Recycling & Lazy Loading

**Current Issues:**
- `HomeView` loads all genre sections at once
- Movie cards in grids don't use proper view recycling
- No pagination indicators in horizontal scrolls

**Improvements:**

```swift
// Implement progressive loading for HomeView sections
struct LazyMovieSection: View {
    let title: String
    let fetchMovies: () async -> [Movie]

    @State private var movies: [Movie] = []
    @State private var isLoading = false
    @State private var hasAppeared = false

    var body: some View {
        Group {
            if hasAppeared {
                if isLoading {
                    SkeletonMovieRow(title: title)
                } else if !movies.isEmpty {
                    ContentRow(title: title, movies: movies, onMovieTap: { _ in })
                }
            } else {
                // Placeholder to maintain layout
                Color.clear.frame(height: 200)
            }
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            loadMovies()
        }
    }

    private func loadMovies() {
        isLoading = true
        Task {
            movies = await fetchMovies()
            isLoading = false
        }
    }
}
```

**Priority:** MEDIUM
**Impact:** Faster initial load, smoother scrolling

---

### 1.3 Network Request Optimization

**Current Issues:**
- `HomeViewModel` makes 4+ parallel API calls on load
- No request coalescing for duplicate calls
- Missing ETag/304 support for conditional requests

**Improvements:**

```swift
// Add request coalescing to TMDBService
actor RequestCoalescer<T> {
    private var pendingRequests: [String: Task<T, Error>] = [:]

    func coalesce(key: String, request: @escaping () async throws -> T) async throws -> T {
        if let existing = pendingRequests[key] {
            return try await existing.value
        }

        let task = Task { () -> T in
            defer { pendingRequests[key] = nil }
            return try await request()
        }

        pendingRequests[key] = task
        return try await task.value
    }
}

// Usage in TMDBService
private let coalescer = RequestCoalescer<MovieResponse>()

func fetchTrending(page: Int = 1) async throws -> MovieResponse {
    try await coalescer.coalesce(key: "trending_\(page)") {
        try await request(endpoint: .trending(page: page), responseType: MovieResponse.self)
    }
}
```

**Priority:** MEDIUM
**Impact:** Reduced API calls, faster responses

---

## 2. UI/UX Polish

### 2.1 Skeleton Loading States

**Current State:**
- Basic loading spinner overlays
- Content pops in abruptly
- No shimmer animations on placeholders

**Improvements:**

```swift
// Create reusable skeleton components
struct SkeletonMovieCard: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster skeleton
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.surfaceSecondary)
                .frame(width: 120, height: 180)
                .shimmer(isActive: true, angle: 70)

            // Title skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.surfaceSecondary)
                .frame(width: 100, height: 14)
                .shimmer(isActive: true, angle: 70, delay: 0.1)

            // Rating skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.surfaceSecondary)
                .frame(width: 60, height: 12)
                .shimmer(isActive: true, angle: 70, delay: 0.2)
        }
    }
}

struct SkeletonMovieRow: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline2)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<5) { _ in
                        SkeletonMovieCard()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// Enhanced shimmer modifier
struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    let angle: Double
    let delay: Double

    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    GeometryReader { geo in
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white.opacity(0.15), location: 0.3),
                                .init(color: .white.opacity(0.25), location: 0.5),
                                .init(color: .white.opacity(0.15), location: 0.7),
                                .init(color: .clear, location: 1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .rotationEffect(.degrees(angle))
                        .offset(x: phase * (geo.size.width * 2))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                                withAnimation(
                                    .linear(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                                ) {
                                    phase = 1
                                }
                            }
                        }
                    }
                    .clipped()
                }
            }
    }
}
```

**Priority:** HIGH
**Impact:** Much more polished perceived performance

---

### 2.2 Micro-Interactions & Animations

**Current Issues:**
- Card press animations exist but feel generic
- No parallax scrolling effects
- Tab transitions are basic
- Missing "spring" physics on key interactions

**Improvements:**

```swift
// Enhanced card interaction with parallax
struct ParallaxMovieCard: View {
    let movie: Movie
    let onTap: () -> Void

    @State private var offset: CGSize = .zero
    @State private var isPressed = false
    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let midX = geo.size.width / 2
            let midY = geo.size.height / 2
            let screenMidX = UIScreen.main.bounds.width / 2
            let screenMidY = UIScreen.main.bounds.height / 2

            let rotationX = (geo.frame(in: .global).midY - screenMidY) / 20
            let rotationY = (geo.frame(in: .global).midX - screenMidX) / -20

            ZStack {
                // Background shadow layer (parallax offset)
                KFImage(movie.backdropURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 30)
                    .scaleEffect(1.2)
                    .offset(x: -rotationY * 2, y: rotationX * 2)
                    .opacity(0.5)

                // Main card
                KFImage(movie.posterURL)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .rotation3DEffect(
                .degrees(isPressed ? rotationX * 0.5 : 0),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect(
                .degrees(isPressed ? rotationY * 0.5 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(
                color: .black.opacity(0.4),
                radius: isPressed ? 5 : 15,
                x: 0,
                y: isPressed ? 5 : 10
            )
        }
        .aspectRatio(2/3, contentMode: .fit)
        .onTapGesture(perform: onTap)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                        isPressed = false
                    }
                }
        )
    }
}

// Staggered appear animation for grids
struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    let totalCount: Int
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                let delay = Double(index) * 0.05
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                    isVisible = true
                }
            }
    }
}
```

**Priority:** MEDIUM
**Impact:** Premium, tactile feel

---

### 2.3 Accessibility Improvements

**Current Issues:**
- Missing VoiceOver labels on many interactive elements
- No Dynamic Type support audit
- Reduce Motion not fully respected
- No high contrast mode support

**Improvements:**

```swift
// Accessibility audit and improvements
extension View {
    func movieCardAccessibility(movie: Movie, isInWatchlist: Bool) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(movie.title), rated \(movie.formattedRating) stars")
            .accessibilityHint(isInWatchlist ? "In your watchlist. Double tap to view details." : "Double tap to view details.")
            .accessibilityAddTraits(.isButton)
            .accessibilityValue(movie.releaseYear ?? "")
    }
}

// Reduce Motion support
struct ReducedMotionWrapper<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let fullMotion: Content
    let reducedMotion: Content

    var body: some View {
        if reduceMotion {
            reducedMotion
        } else {
            fullMotion
        }
    }
}

// Dynamic Type scaling
extension Font {
    static func scaledHeadline(relativeTo textStyle: TextStyle = .headline) -> Font {
        .custom("System", size: UIFontMetrics(forTextStyle: .headline).scaledValue(for: 17), relativeTo: textStyle)
    }
}
```

**Priority:** HIGH
**Impact:** Required for App Store feature consideration, legal compliance

---

### 2.4 Pull-to-Refresh Enhancement

**Current State:**
- Basic `.refreshable` modifier
- No visual feedback during refresh
- Content shifts awkwardly

**Improvements:**

```swift
// Custom premium pull-to-refresh
struct PremiumRefreshableModifier: ViewModifier {
    let action: () async -> Void
    @State private var pullOffset: CGFloat = 0
    @State private var isRefreshing = false

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack(alignment: .top) {
                    // Refresh indicator
                    refreshIndicator
                        .offset(y: pullOffset > 0 ? pullOffset - 60 : -60)

                    // Content
                    content
                        .offset(y: isRefreshing ? 60 : 0)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetKey.self,
                            value: proxy.frame(in: .named("scroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                pullOffset = max(0, value)

                if pullOffset > 80 && !isRefreshing {
                    triggerRefresh()
                }
            }
        }
    }

    private var refreshIndicator: some View {
        VStack(spacing: 8) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.glassThin, lineWidth: 3)
                    .frame(width: 32, height: 32)

                // Progress ring
                Circle()
                    .trim(from: 0, to: min(pullOffset / 80, 1))
                    .stroke(
                        LinearGradient(
                            colors: [.accentPrimary, .accentSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))
                    .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                    .animation(
                        isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                        value: isRefreshing
                    )
            }

            if pullOffset > 60 {
                Text(isRefreshing ? "Updating..." : "Release to refresh")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .transition(.opacity)
            }
        }
    }

    private func triggerRefresh() {
        Haptics.shared.pulledToRefresh()
        withAnimation(.spring()) {
            isRefreshing = true
        }

        Task {
            await action()
            await MainActor.run {
                withAnimation(.spring()) {
                    isRefreshing = false
                }
            }
        }
    }
}
```

**Priority:** LOW
**Impact:** Premium feel

---

## 3. Feature Completeness

### 3.1 Offline Mode

**Current State:**
- No offline support
- Network errors show retry button but no cached data
- Watchlist works offline but movies can't be viewed

**Improvements:**

```swift
// Offline-capable movie cache
actor OfflineMovieCache {
    private let fileManager = FileManager.default
    private var cacheURL: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("movies")
    }

    private var cache: [Int: CachedMovie] = [:]

    struct CachedMovie: Codable {
        let movie: Movie
        let cachedAt: Date
        let expiresAt: Date
    }

    func cache(movie: Movie, ttl: TimeInterval = 86400) async {
        let cached = CachedMovie(
            movie: movie,
            cachedAt: Date(),
            expiresAt: Date().addingTimeInterval(ttl)
        )
        cache[movie.id] = cached
        await persistToDisk()
    }

    func get(id: Int) async -> Movie? {
        if let cached = cache[id], cached.expiresAt > Date() {
            return cached.movie
        }
        return nil
    }

    func cacheMovies(_ movies: [Movie], category: String) async {
        for movie in movies {
            await cache(movie: movie)
        }
        await saveCategoryIndex(category: category, movieIds: movies.map(\.id))
    }

    func getMovies(for category: String) async -> [Movie] {
        let ids = await loadCategoryIndex(category: category)
        return ids.compactMap { cache[$0]?.movie }
    }

    private func persistToDisk() async {
        guard let url = cacheURL else { return }

        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(cache)
            try data.write(to: url.appendingPathComponent("movies.json"))
        } catch {
            print("Failed to persist cache: \(error)")
        }
    }
}

// Network-aware ViewModel base
@MainActor
class OfflineAwareViewModel: ObservableObject {
    @Published var isOffline = false
    @Published var isUsingCachedData = false

    let networkMonitor: NetworkMonitor
    let offlineCache: OfflineMovieCache

    init(networkMonitor: NetworkMonitor = .shared, offlineCache: OfflineMovieCache) {
        self.networkMonitor = networkMonitor
        self.offlineCache = offlineCache

        observeNetworkStatus()
    }

    private func observeNetworkStatus() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: &$isOffline.map { !$0 })
    }
}
```

**Priority:** HIGH
**Impact:** Major user experience improvement

---

### 3.2 Personalization Engine

**Current State:**
- Basic `UserPreferences` storing swipe history
- `QuickFilter` presets hardcoded
- No ML-based recommendations

**Improvements:**

```swift
// Enhanced recommendation engine
actor RecommendationEngine {
    private var swipeHistory: [SwipePreference] = []
    private var genreWeights: [Int: Double] = [:]
    private var ratingPreference: Double = 7.0

    struct SwipePreference: Codable {
        let movieId: Int
        let action: SwipeAction
        let genres: [Int]
        let rating: Double
        let timestamp: Date
    }

    enum SwipeAction: String, Codable {
        case liked, superLiked, skipped

        var weight: Double {
            switch self {
            case .superLiked: return 2.0
            case .liked: return 1.0
            case .skipped: return -0.5
            }
        }
    }

    func recordSwipe(_ preference: SwipePreference) {
        swipeHistory.append(preference)
        updateWeights(preference)

        // Trim old history
        let cutoff = Date().addingTimeInterval(-30 * 24 * 60 * 60) // 30 days
        swipeHistory = swipeHistory.filter { $0.timestamp > cutoff }
    }

    private func updateWeights(_ pref: SwipePreference) {
        for genre in pref.genres {
            genreWeights[genre, default: 0] += pref.action.weight
        }

        // Adjust rating preference
        if pref.action == .liked || pref.action == .superLiked {
            ratingPreference = (ratingPreference * 0.9) + (pref.rating * 0.1)
        }
    }

    func score(movie: Movie) -> Double {
        var score: Double = 0

        // Genre matching
        for genre in movie.genreIds {
            score += genreWeights[genre, default: 0] * 0.3
        }

        // Rating preference
        let ratingDiff = abs(movie.voteAverage - ratingPreference)
        score += (10 - ratingDiff) * 0.2

        // Popularity boost for high-rated
        if movie.voteAverage >= 7.5 {
            score += 1.0
        }

        // Recency boost
        if let date = movie.releaseDate, date >= "2024" {
            score += 0.5
        }

        return score
    }

    func sortByRecommendation(_ movies: [Movie]) -> [Movie] {
        movies.sorted { score(movie: $0) > score(movie: $1) }
    }

    func getTopGenres() -> [Int] {
        genreWeights
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map(\.key)
    }

    func generateQuickFilters() -> [QuickFilter] {
        let topGenres = getTopGenres()

        // Generate dynamic filters based on preferences
        var filters: [QuickFilter] = [.none]

        if topGenres.contains(where: { [28, 53, 27, 878].contains($0) }) {
            filters.append(.tonight)
        }
        if topGenres.contains(where: { [10749, 35, 18].contains($0) }) {
            filters.append(.dateNight)
        }
        if topGenres.contains(where: { [10751, 16, 12].contains($0) }) {
            filters.append(.family)
        }

        filters.append(.newReleases)
        return filters
    }
}
```

**Priority:** MEDIUM
**Impact:** Higher engagement, personalized experience

---

### 3.3 Social Features

**Current State:**
- Can share watchlist as image
- No collaborative lists
- No friend activity

**Improvements:**

```swift
// Shareable watchlist links
struct ShareableWatchlist: Codable {
    let id: UUID
    let name: String
    let createdBy: String
    let movieIds: [Int]
    let createdAt: Date
    let isPublic: Bool

    var shareURL: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "movietrailer.app"
        components.path = "/list/\(id.uuidString)"
        return components.url
    }

    var deepLinkURL: URL? {
        URL(string: "movietrailer://list/\(id.uuidString)")
    }
}

// Activity sharing
struct WatchActivity: Codable {
    let id: UUID
    let userId: String
    let username: String
    let action: ActivityAction
    let movieId: Int
    let movieTitle: String
    let timestamp: Date

    enum ActivityAction: String, Codable {
        case watched
        case addedToList
        case rated
        case reviewed
    }
}

// Activity feed view
struct ActivityFeedView: View {
    @StateObject var viewModel: ActivityFeedViewModel

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.activities) { activity in
                ActivityRow(activity: activity)
                Divider()
                    .background(Color.glassBorder)
            }
        }
    }
}
```

**Priority:** LOW (Future consideration)
**Impact:** Virality, engagement

---

## 4. Code Architecture

### 4.1 State Management Improvements

**Current Issues:**
- ViewModels are created fresh on each tab switch
- No centralized app state
- Watchlist manager is passed manually through init

**Improvements:**

```swift
// Centralized app state with Environment
@MainActor
final class AppState: ObservableObject {
    @Published var user: User?
    @Published var isOnboarded: Bool

    let tmdbService: TMDBService
    let watchlistManager: WatchlistManager
    let recommendationEngine: RecommendationEngine
    let offlineCache: OfflineMovieCache

    static let shared = AppState()

    private init() {
        self.isOnboarded = UserDefaults.standard.bool(forKey: "isOnboarded")
        self.tmdbService = .shared
        self.watchlistManager = WatchlistManager()
        self.recommendationEngine = RecommendationEngine()
        self.offlineCache = OfflineMovieCache()
    }
}

// Custom environment key
private struct AppStateKey: EnvironmentKey {
    static let defaultValue: AppState = .shared
}

extension EnvironmentValues {
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
}

// Usage
struct ContentView: View {
    @Environment(\.appState) var appState

    var body: some View {
        HomeView(viewModel: HomeViewModel(
            tmdbService: appState.tmdbService,
            watchlistManager: appState.watchlistManager
        ))
    }
}
```

**Priority:** MEDIUM
**Impact:** Cleaner code, easier testing

---

### 4.2 Error Handling Enhancement

**Current State:**
- `ViewState` enum in HomeViewModel is a good pattern
- Some views still have silent failures
- No retry policies visible to user

**Improvements:**

```swift
// Standardized error handling
enum AppError: LocalizedError {
    case network(NetworkError)
    case noContent
    case unauthorized
    case offline
    case rateLimit(retryAfter: TimeInterval)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .noContent:
            return "No content available"
        case .unauthorized:
            return "Session expired. Please restart the app."
        case .offline:
            return "You're offline. Showing cached content."
        case .rateLimit(let seconds):
            return "Too many requests. Try again in \(Int(seconds)) seconds."
        case .unknown:
            return "Something went wrong"
        }
    }

    var recoveryAction: RecoveryAction {
        switch self {
        case .network, .unknown:
            return .retry
        case .offline:
            return .showCached
        case .rateLimit:
            return .waitAndRetry
        case .unauthorized:
            return .restart
        case .noContent:
            return .none
        }
    }

    enum RecoveryAction {
        case retry
        case showCached
        case waitAndRetry
        case restart
        case none
    }
}

// Error presentation
struct ErrorOverlay: View {
    let error: AppError
    let onRetry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(iconColor)

            Text(error.errorDescription ?? "Unknown error")
                .font(.headline)
                .multilineTextAlignment(.center)

            if case .retry = error.recoveryAction {
                Button("Try Again", action: onRetry)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }

    private var iconName: String {
        switch error {
        case .network: return "wifi.exclamationmark"
        case .offline: return "wifi.slash"
        case .rateLimit: return "clock"
        default: return "exclamationmark.triangle"
        }
    }

    private var iconColor: Color {
        switch error {
        case .offline: return .orange
        case .rateLimit: return .yellow
        default: return .red
        }
    }
}
```

**Priority:** HIGH
**Impact:** Better user experience, clearer feedback

---

### 4.3 Testing Infrastructure

**Current State:**
- Some unit tests exist for ViewModels and services
- No UI tests
- No snapshot tests
- Mock objects exist but incomplete

**Improvements:**

```swift
// Protocol-based dependencies for testing
protocol TMDBServiceProtocol: Sendable {
    func fetchTrending(page: Int) async throws -> MovieResponse
    func fetchPopular(page: Int) async throws -> MovieResponse
    func searchMovies(query: String, page: Int) async throws -> MovieResponse
}

extension TMDBService: TMDBServiceProtocol {}

// Mock for testing
actor MockTMDBService: TMDBServiceProtocol {
    var trendingResponse: MovieResponse = .sample
    var popularResponse: MovieResponse = .sample
    var searchResponse: MovieResponse = .sample
    var shouldFail = false

    func fetchTrending(page: Int) async throws -> MovieResponse {
        if shouldFail { throw NetworkError.unknown }
        return trendingResponse
    }

    func fetchPopular(page: Int) async throws -> MovieResponse {
        if shouldFail { throw NetworkError.unknown }
        return popularResponse
    }

    func searchMovies(query: String, page: Int) async throws -> MovieResponse {
        if shouldFail { throw NetworkError.unknown }
        return searchResponse
    }
}

// Example test
@MainActor
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockService: MockTMDBService!
    var mockWatchlist: WatchlistManager!

    override func setUp() async throws {
        mockService = MockTMDBService()
        mockWatchlist = WatchlistManager.mockEmpty()
        sut = HomeViewModel(
            tmdbService: mockService,
            watchlistManager: mockWatchlist
        )
    }

    func testLoadContent_Success() async {
        // Given
        mockService.trendingResponse = MovieResponse.sample

        // When
        await sut.loadContent()

        // Then
        XCTAssertEqual(sut.viewState, .success)
        XCTAssertFalse(sut.trendingMovies.isEmpty)
    }

    func testLoadContent_NetworkError_ShowsBanner() async {
        // Given
        await mockService.setFail(true)

        // When
        await sut.loadContent()

        // Then
        XCTAssertTrue(sut.showErrorBanner)
    }
}
```

**Priority:** MEDIUM
**Impact:** Code reliability, confidence in changes

---

## 5. Platform Optimization

### 5.1 iPad & Large Screen Support

**Current State:**
- App works on iPad but layout is just scaled up
- No split view support
- Side-by-side viewing not optimized

**Improvements:**

```swift
// Adaptive layout container
struct AdaptiveMovieGrid: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void

    var columns: [GridItem] {
        switch sizeClass {
        case .compact:
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        case .regular:
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        default:
            return [GridItem(.flexible())]
        }
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(movies) { movie in
                MovieCard(movie: movie, onTap: { onMovieTap(movie) })
            }
        }
    }
}

// Split view for iPad
struct iPadHomeView: View {
    @State private var selectedMovie: Movie?

    var body: some View {
        NavigationSplitView {
            // Sidebar with categories
            List {
                Section("Browse") {
                    Label("Trending", systemImage: "flame")
                    Label("Popular", systemImage: "star")
                    Label("New Releases", systemImage: "sparkles")
                }

                Section("Genres") {
                    ForEach(Genre.all.prefix(10)) { genre in
                        Label(genre.name, systemImage: genre.icon)
                    }
                }
            }
            .navigationTitle("Movies")
        } content: {
            // Movie grid
            MovieGridView(onMovieTap: { movie in
                selectedMovie = movie
            })
        } detail: {
            // Movie detail
            if let movie = selectedMovie {
                MovieDetailView(movie: movie, ...)
            } else {
                ContentUnavailableView(
                    "Select a Movie",
                    systemImage: "film",
                    description: Text("Choose a movie to see its details")
                )
            }
        }
    }
}
```

**Priority:** MEDIUM
**Impact:** Better iPad experience, app store featuring

---

### 5.2 visionOS Preparation

**Current State:**
- No visionOS considerations
- UI is 2D focused

**Improvements:**

```swift
#if os(visionOS)
// Ornament-based tab bar for visionOS
struct VisionTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<4) { index in
                Button {
                    selectedTab = index
                } label: {
                    Image(systemName: TabCoordinator.Tab(rawValue: index)?.icon ?? "")
                        .font(.title2)
                }
                .buttonStyle(.borderless)
            }
        }
        .padding()
        .glassBackgroundEffect()
    }
}

// 3D movie poster for spatial experience
struct SpatialMoviePoster: View {
    let movie: Movie

    var body: some View {
        ZStack {
            // Shadow plane
            Color.black.opacity(0.3)
                .frame(width: 180, height: 270)
                .offset(z: -10)
                .blur(radius: 20)

            // Main poster
            KFImage(movie.posterURL)
                .resizable()
                .aspectRatio(2/3, contentMode: .fill)
                .frame(width: 160, height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .hoverEffect(.lift)
        }
    }
}
#endif
```

**Priority:** LOW (Future)
**Impact:** Future-proofing

---

### 5.3 Widget Enhancements

**Current State:**
- Basic widget infrastructure exists
- Live Activity support implemented

**Improvements:**

```swift
// Interactive widgets (iOS 17+)
struct WatchlistWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: "WatchlistWidget",
            intent: WatchlistWidgetIntent.self,
            provider: WatchlistWidgetProvider()
        ) { entry in
            WatchlistWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Watchlist")
        .description("Quick access to your movie watchlist")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct WatchlistWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Watchlist"

    @Parameter(title: "Show Rating")
    var showRating: Bool

    @Parameter(title: "Max Movies")
    var maxMovies: Int
}

// Lock screen widget
struct LockScreenWatchlistWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "LockScreenWatchlist",
            provider: LockScreenProvider()
        ) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Movie")
        .description("Your next movie to watch")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}
```

**Priority:** LOW
**Impact:** Platform integration

---

## 6. Security & Privacy

### 6.1 Data Protection

**Current State:**
- API key stored in code (via TMDBEndpoint)
- KeychainManager exists but underutilized
- User preferences in UserDefaults

**Improvements:**

```swift
// Secure configuration loading
actor SecureConfiguration {
    static let shared = SecureConfiguration()

    private var apiKey: String?

    func getAPIKey() async throws -> String {
        if let cached = apiKey {
            return cached
        }

        // Try Keychain first
        if let stored = KeychainManager.shared.get(key: "tmdb_api_key") {
            apiKey = stored
            return stored
        }

        // Fall back to bundled configuration (obfuscated)
        guard let key = loadObfuscatedKey() else {
            throw ConfigurationError.missingAPIKey
        }

        // Store in keychain for future use
        KeychainManager.shared.set(value: key, for: "tmdb_api_key")
        apiKey = key
        return key
    }

    private func loadObfuscatedKey() -> String? {
        // Key stored with XOR obfuscation
        let obfuscated: [UInt8] = [/* obfuscated bytes */]
        let key: [UInt8] = [/* deobfuscation key */]

        var result = [UInt8]()
        for (i, byte) in obfuscated.enumerated() {
            result.append(byte ^ key[i % key.count])
        }

        return String(bytes: result, encoding: .utf8)
    }
}

// Privacy-respecting analytics
struct AnalyticsEvent {
    let name: String
    let parameters: [String: Any]
    let timestamp: Date

    // Ensure no PII is logged
    static func movieViewed(id: Int) -> AnalyticsEvent {
        AnalyticsEvent(
            name: "movie_viewed",
            parameters: ["movie_id": id],
            timestamp: Date()
        )
    }

    static func searchPerformed(resultsCount: Int) -> AnalyticsEvent {
        // Don't log the actual search query
        AnalyticsEvent(
            name: "search_performed",
            parameters: ["results_count": resultsCount],
            timestamp: Date()
        )
    }
}
```

**Priority:** HIGH
**Impact:** Security, App Store compliance

---

## 7. Implementation Roadmap

### Phase 1: Foundation (Critical Fixes)
1. ✅ Skeleton loading states
2. ✅ Error handling standardization
3. ✅ Accessibility audit
4. ✅ Image caching optimization
5. ✅ API key security

### Phase 2: Polish (UX Excellence)
1. Micro-interaction animations
2. Pull-to-refresh enhancement
3. Staggered grid animations
4. Parallax effects
5. Dynamic Type support

### Phase 3: Features (Differentiation)
1. Offline mode
2. Personalization engine
3. Smart recommendations
4. Enhanced widgets
5. iPad split view

### Phase 4: Future (Platform Expansion)
1. visionOS preparation
2. Social features
3. Collaborative lists
4. Machine learning recommendations
5. App Clips

---

## 8. Technical Debt Summary

| Priority | Issue | Location | Fix |
|----------|-------|----------|-----|
| HIGH | Silent network failures | SearchViewModel | Add ViewState pattern |
| HIGH | No skeleton loading | HomeView, SearchView | Add SkeletonMovieRow |
| HIGH | Accessibility gaps | All cards | Add labels/hints |
| MEDIUM | ViewModel recreation | MainTabView | Cache in environment |
| MEDIUM | No request coalescing | TMDBService | Add coalescer actor |
| MEDIUM | Missing offline mode | All | Add OfflineMovieCache |
| LOW | iPad layout basic | All views | Add size class handling |
| LOW | No snapshot tests | Tests | Add ViewInspector |

---

## 9. Metrics for Success

### Performance Targets
- **Cold launch:** < 1.5 seconds
- **Tab switch:** < 100ms
- **Image load (cached):** < 50ms
- **Memory footprint:** < 150MB
- **Battery impact:** < 3% per hour of use

### UX Targets
- **VoiceOver score:** 100%
- **Dynamic Type:** All sizes supported
- **Reduce Motion:** Fully respected
- **Error recovery rate:** > 95%

### Engagement Targets
- **Daily active users:** Measure baseline
- **Session duration:** > 5 minutes
- **Movies added to watchlist:** > 3 per session
- **Swipe completion rate:** > 80%

---

**Document Author:** Claude Opus 4.5
**Last Updated:** December 29, 2025
**Version:** 2.0.0
