# MovieTrailer App - Comprehensive Code & UI/UX Review

**Review Date**: January 2, 2026  
**Reviewed By**: Automated Code Analysis  
**App Version**: 1.0  
**Target**: iOS 16.1+, SwiftUI

---

## Executive Summary

MovieTrailer is a well-architected iOS movie discovery app with sophisticated features including Live Activities, glassmorphism design, and a recommendation engine. The codebase demonstrates senior-level patterns (Actors, Coordinators, certificate pinning) but has several areas requiring attention before production release.

### Overall Assessment: **B+ (Strong Foundation, Needs Polish)**

| Category | Score | Status |
|----------|-------|--------|
| **Build Status** | FAILING | Compilation errors in DesignSystem |
| Architecture | 8/10 | Good MVVM+Coordinator, minor DI inconsistency |
| Networking | 9/10 | Excellent - Actors, retry logic, rate limiting |
| UI/UX | 7/10 | Beautiful design, accessibility gaps |
| Code Quality | 7.5/10 | Clean code, some force unwraps |
| Test Coverage | 6/10 | Basic coverage, needs expansion |
| TMDB Integration | 7/10 | Good coverage, missing key features |
| Offline Support | 4/10 | **Critical**: Mock implementation |

> **BLOCKING**: The project has build errors that must be resolved before any other work. See Section 0.

---

## Table of Contents

0. [BUILD ERRORS (Blocking)](#0-build-errors-blocking)
1. [Critical Issues (Must Fix)](#1-critical-issues-must-fix)
2. [Architecture Improvements](#2-architecture-improvements)
3. [UI/UX Issues](#3-uiux-issues)
4. [Networking & API Issues](#4-networking--api-issues)
5. [TMDB Feature Gaps](#5-tmdb-feature-gaps)
6. [Accessibility Compliance](#6-accessibility-compliance)
7. [Performance Optimizations](#7-performance-optimizations)
8. [Code Quality Issues](#8-code-quality-issues)
9. [Test Coverage Gaps](#9-test-coverage-gaps)
10. [Recommended Feature Roadmap](#10-recommended-feature-roadmap)

---

## 0. BUILD ERRORS (Blocking)

**The project currently has compilation errors that must be fixed first.**

### 0.1 UIColor Not in Scope

**File**: `DesignSystem/Colors.swift:330`

```swift
let components = UIColor(self).cgColor.components ?? [0, 0, 0]
```

**Problem**: `UIColor` requires `import UIKit`, but the file only imports `SwiftUI`.

**Fix**:
```swift
#if canImport(UIKit)
import UIKit
#endif

// In the property:
var hexString: String {
    #if canImport(UIKit)
    let components = UIColor(self).cgColor.components ?? [0, 0, 0]
    // ... rest of implementation
    #else
    return "#000000" // Fallback for non-UIKit platforms
    #endif
}
```

### 0.2 Missing Type Members in Theme/LiquidGlass

Multiple files reference Color members that may be defined conditionally or have import issues:
- `Color.surfaceElevated`
- `Color.cardBackground`
- `Color.accentBlue`
- `Color.textPrimary`
- `Color.ratingStar`

**Note**: These ARE defined in `Colors.swift` - the errors suggest a build order or module visibility issue. Ensure all DesignSystem files are in the same target.

### 0.3 Font Member Issues

**File**: `DesignSystem/Theme.swift:502`

```swift
.font(.buttonMedium) // Error: Type 'Font?' has no member 'buttonMedium'
```

These font extensions ARE defined in `Typography.swift`. This is likely a build configuration issue.

**Action Required**: 
1. Verify all DesignSystem files are included in the correct build target
2. Check for circular dependencies between DesignSystem files
3. Clean build folder (Cmd+Shift+K) and rebuild

---

## 1. Critical Issues (Must Fix)

### 1.1 Offline Download is a Placeholder (CRITICAL)

**File**: `Services/OfflineModeManager.swift:82-84`

```swift
private func downloadCategory(_ category: String) async throws {
    try await Task.sleep(nanoseconds: 500_000_000) // MOCK - Does nothing!
}
```

**Impact**: Users see a progress bar that simulates downloading but no actual data is cached. The app claims offline support but delivers none.

**Fix Required**:
```swift
private func downloadCategory(_ category: String) async throws {
    let movies: [Movie]
    switch category {
    case "Trending":
        movies = try await tmdbService.fetchTrending(page: 1).results
    case "Popular":
        movies = try await tmdbService.fetchPopular(page: 1).results
    // ... handle other categories
    }
    await offlineCache.cacheMovies(movies, for: category)
}
```

### 1.2 Image Prefetching Passes Empty Array

**File**: `Services/ImageCacheManager.swift` (View extension)

The `prefetchImages` view modifier passes `movies: []` to the prefetcher, making image prefetching non-functional.

**Fix Required**: Pass actual movie data to the prefetcher.

### 1.3 Force Unwraps Can Crash

**Files**:
- `Services/ImageGenerator.swift:224` - `firstIndex(where: ...)!`
- `Services/OfflineMovieCache.swift:116-117` - `categoryIndex[category]!`

**Fix Required**: Replace with `guard let` or optional chaining.

---

## 2. Architecture Improvements

### 2.1 Mixed Dependency Injection Patterns

**Current State**: The app uses both `AppState.shared` singleton AND constructor injection, creating confusion.

**Files Affected**:
- `Core/AppState.swift` (singleton pattern)
- `ViewModels/*.swift` (constructor injection)

**Recommendation**: Standardize on constructor injection. Use `@Environment` for shared dependencies.

```swift
// Instead of:
let watchlistManager = AppState.shared.watchlistManager

// Use:
@Environment(\.watchlistManager) var watchlistManager
```

### 2.2 Migrate to @Observable (iOS 17+)

**Current State**: All ViewModels use `ObservableObject` with `@Published`.

**Problem**: `@Published` triggers view updates for ANY property change, not just accessed properties.

**Recommendation**:
```swift
// Before
final class MovieSwipeViewModel: ObservableObject {
    @Published var movieQueue: [Movie] = []
}

// After (2025 Standard)
@Observable
@MainActor
final class MovieSwipeViewModel {
    var movieQueue: [Movie] = []
}
```

### 2.3 TabCoordinator Becoming a God Object

**File**: `Coordinators/TabCoordinator.swift`

The TabCoordinator handles sheet presentation for ALL features. Delegate sheet management to child coordinators.

### 2.4 WatchlistManager Sync Creates Minimal Movie Objects

**File**: `Services/WatchlistManager.swift:524-539`

When syncing from Firestore, minimal `Movie` objects are created with empty overview, missing backdrop, zero popularity. This causes degraded UI when viewing synced watchlist items.

**Recommendation**: Fetch full movie details after sync, or store more data in Firestore.

---

## 3. UI/UX Issues

### 3.1 Typography Does Not Support Dynamic Type

**File**: `DesignSystem/Typography.swift`

All fonts use fixed `Font.system(size: X)` which does NOT scale with system accessibility settings.

**Current** (Broken):
```swift
static let headline1 = Font.system(size: 28, weight: .bold, design: .default)
```

**Fix Required**:
```swift
static let headline1 = Font.system(.title, design: .default).weight(.bold)
// OR
static func headline1() -> Font {
    Font.custom("SF Pro", size: 28, relativeTo: .title)
}
```

### 3.2 Inconsistent Empty State Implementations

Each view implements its own empty state differently:
- `TonightView.swift` - Custom inline implementation
- `WatchlistView.swift` - Different custom implementation
- `SearchView.swift` - Uses `EmptyStateView` component

**Recommendation**: Create unified `EmptyStateView` and use consistently everywhere.

### 3.3 Hardcoded Spacing Values

**Files**: `MovieDetailView.swift`, `OnboardingContainerView.swift`, many others

Extensive use of `.padding(20)`, `.spacing: 12` instead of design tokens.

**Current**:
```swift
.padding(.horizontal, 20)
.padding(.vertical, 20)
```

**Recommended**:
```swift
.padding(.horizontal, Spacing.horizontal)
.padding(.vertical, Spacing.lg)
```

### 3.4 iPad Layout Needs Work

Hardcoded padding values (e.g., `padding(20)`) look cramped on larger screens. Use `horizontalSizeClass` to adapt layouts.

### 3.5 Abrupt Loading-to-Content Transitions

State changes in `loadAllContent()` happen without animation, causing jarring transitions.

**Fix**: Wrap state updates in `withAnimation`:
```swift
withAnimation(.easeInOut(duration: 0.3)) {
    isLoading = false
}
```

---

## 4. Networking & API Issues

### 4.1 No Dynamic Rate Limit Handling

**File**: `Networking/TMDBService.swift`

The service uses static 100ms delays between batch requests but doesn't parse TMDB's `X-RateLimit-Reset` header for dynamic adjustment.

**Recommendation**: Parse rate limit headers and adjust delays accordingly.

### 4.2 Resource Timeout Too High

**File**: `Networking/TMDBService.swift:61`

```swift
configuration.timeoutIntervalForResource = 60
```

60 seconds is too long for mobile. Users will give up waiting. Reduce to 30 seconds.

### 4.3 API Key in Query String

TMDB API key is passed as a query parameter (`?api_key=...`), which can appear in logs.

**Recommendation**: While TMDB requires this, ensure logging is disabled in production.

### 4.4 Missing Whitespace Trimming in Search

**File**: `Networking/TMDBService.swift:229`

Searching for `"   "` (whitespace) makes an API call instead of being handled locally.

```swift
func searchMovies(query: String, page: Int = 1) async throws -> MovieResponse {
    guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        return MovieResponse(page: 1, results: [], totalPages: 0, totalResults: 0)
    }
    // ...
}
```

---

## 5. TMDB Feature Gaps

### 5.1 No TV Show Support (Major Gap)

The app is 100% movie-focused. TMDB has full TV show data. Competitors like TV Time and JustWatch include TV.

**Recommendation**: Add TV show models, endpoints, and UI. Reuse existing patterns.

### 5.2 No Multi-Search

Currently, movie search and person search are separate. TMDB's `/search/multi` endpoint returns movies, TV shows, AND people in one call.

**Recommendation**: Implement unified search bar with results grouped by type.

### 5.3 No "My Services" Streaming Filter

Users can browse by streaming service, but cannot set preferred services to filter ALL discovery results.

**Recommendation**: Add persistent "My Services" setting. Use `with_watch_providers` parameter globally.

### 5.4 No TMDB Account Integration

The app uses Firestore for watchlist sync. Power users may want to sync with their actual TMDB account.

**Recommendation**: Implement TMDB OAuth for advanced users.

### 5.5 Missing Trending Weekly Option

Only daily trending (`/trending/movie/day`) is implemented. Weekly trending is often more stable and user-friendly.

### 5.6 No Keyword/Tag Browsing

TMDB supports keywords (e.g., "time travel", "heist"). This enables mood-based discovery.

**Recommendation**: Implement keyword-based "Mood" filters using `/discover` with `with_keywords`.

### 5.7 Image Sizes Not Optimized

**File**: `Models/Movie.swift:104`

Hardcoded `w500` for posters. For thumbnails in grids, `w185` or `w342` would save bandwidth significantly.

**Recommendation**: Create computed properties for different sizes:
```swift
var thumbnailURL: URL? {
    guard let posterPath = posterPath else { return nil }
    return URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)")
}
```

---

## 6. Accessibility Compliance

### 6.1 Underutilized Accessibility Helpers

**File**: `DesignSystem/Accessibility.swift`

Excellent accessibility helpers exist (`movieAccessibility()`, `ratingAccessibility()`) but are underutilized in feature views.

**Files needing accessibility audit**:
- `Views/Features/MovieDetailView.swift`
- `Views/Features/SearchView.swift`
- `Components/Cards/*.swift`

### 6.2 Missing VoiceOver Labels

Many interactive elements lack proper accessibility labels:
- Streaming provider logos in SearchView
- Trailer thumbnails in MovieDetailView
- Collection movie posters

### 6.3 accessibilityElement(children: .combine) Needed

In `MovieDetailView.swift`, groups of related text (title + year + rating) should be combined for VoiceOver.

### 6.4 No Reduce Motion Testing

While `Accessibility.swift` has motion-aware helpers, verify all animations respect `accessibilityReduceMotion`.

---

## 7. Performance Optimizations

### 7.1 Kingfisher Downsampling Missing

High-resolution backdrop images (original size) are loaded into small views, wasting memory.

**Recommendation**:
```swift
KFImage(movie.backdropURL)
    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 400, height: 225)))
```

### 7.2 MovieDetailView Makes 7 Parallel Requests

**File**: `Views/Features/MovieDetailView.swift:121-129`

Loading all data at once is efficient, but consider using `fetchMovieDetailsFull()` (already implemented) which uses `append_to_response` to get most data in ONE request.

### 7.3 View Body Complexity

`MovieDetailView` has a very large `body` property. Break into smaller subviews for better SwiftUI diffing performance.

### 7.4 Memory Pressure on Swipe View

The swipe card system loads multiple high-res images. Ensure proper cleanup when cards leave the stack.

---

## 8. Code Quality Issues

### 8.1 Force Unwraps (3 instances)

| File | Line | Code |
|------|------|------|
| `ImageGenerator.swift` | 224 | `firstIndex(where: ...)!` |
| `OfflineMovieCache.swift` | 116 | `categoryIndex[category]!` |
| `OfflineMovieCache.swift` | 117 | Related force unwrap |

### 8.2 Empty Catch Blocks

**File**: `Views/Features/MovieDetailView.swift:138, 145, 152, etc.`

```swift
} catch {} // Silently swallows errors
```

At minimum, add logging:
```swift
} catch {
    print("Failed to load trailers: \(error.localizedDescription)")
}
```

### 8.3 Hidden Gems Filter Bug

**File**: `Networking/TMDBEndpoint.swift:587-588`

```swift
filters.voteCountMin = 100
filters.voteCountMin = 500 // Overwrites previous line!
```

The first assignment is immediately overwritten. Likely a typo - should be `voteCountMax`:
```swift
filters.voteCountMin = 100
filters.voteCountMax = 500
```

### 8.4 Unused HapticManager Reference

**File**: `Views/Features/TonightView.swift:38`

```swift
HapticManager.shared.pulledToRefresh()
```

But elsewhere the app uses `Haptics.shared`. Ensure consistency.

---

## 9. Test Coverage Gaps

### 9.1 Current Test Files (8 total)

```
MovieTrailerTests/
  Services/OfflineCacheTests.swift
  ViewModels/HomeViewModelTests.swift
  TonightViewModelTests.swift
  WatchlistViewModelTests.swift
  SearchViewModelTests.swift
  CoordinatorTests.swift
  WatchlistManagerTests.swift
  TMDBServiceTests.swift
```

### 9.2 Missing Test Coverage

| Component | Current Coverage | Needed |
|-----------|------------------|--------|
| RecommendationEngine | None | Algorithm tests with parameterized inputs |
| AuthenticationManager | None | Auth flow tests with mocks |
| ImageCacheManager | None | Cache hit/miss tests |
| Coordinators | Basic | Navigation flow tests |
| Error Handling | Basic | All error states |
| Offline Mode | None | **Critical** - must test mock vs real |

### 9.3 No Snapshot Tests

UI components (GlassCard, Premium cards) need snapshot tests to prevent visual regression.

**Recommendation**: Add `swift-snapshot-testing` package.

### 9.4 No Integration Tests

Network mocking exists, but no integration tests verify end-to-end flows.

---

## 10. Recommended Feature Roadmap

### Phase 1: Critical Fixes (Week 1-2)

- [ ] Implement real offline download in `OfflineModeManager`
- [ ] Fix image prefetching empty array bug
- [ ] Replace all force unwraps with safe unwrapping
- [ ] Fix Hidden Gems filter typo
- [ ] Add Dynamic Type support to Typography

### Phase 2: Accessibility & Polish (Week 3-4)

- [ ] Apply accessibility modifiers to all interactive elements
- [ ] Test with VoiceOver and Reduce Motion
- [ ] Unify empty state implementations
- [ ] Replace hardcoded padding with design tokens
- [ ] Add animated transitions for loading states

### Phase 3: TMDB Enhancement (Week 5-6)

- [ ] Add TV Show support (models, endpoints, UI)
- [ ] Implement "My Services" persistent streaming filter
- [ ] Add Multi-Search combining movies, TV, people
- [ ] Optimize image sizes for different use cases
- [ ] Add Trending Weekly option

### Phase 4: Architecture & Testing (Week 7-8)

- [ ] Migrate ViewModels to @Observable
- [ ] Standardize dependency injection
- [ ] Add snapshot tests for UI components
- [ ] Add integration tests for critical flows
- [ ] Add RecommendationEngine tests

### Phase 5: Advanced Features (Future)

- [ ] TMDB account integration
- [ ] Keyword/mood-based discovery
- [ ] Price drop notifications
- [ ] visionOS spatial experience
- [ ] Widgets with movie recommendations

---

## 11. Screen-by-Screen UI/UX Analysis

### 11.1 Home Screen (`HomeView.swift`)

**Strengths:**
- Cinematic hero carousel is visually impressive
- Good use of quick filters (Tonight, Date Night, Family, New)
- Proper loading skeleton states
- Offline banner with retry functionality

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| HomeView is 2000+ lines | `HomeView.swift` | Medium | Break into smaller components |
| `HapticManager.shared` vs `Haptics.shared` | Line 38 | Low | Standardize to `Haptics.shared` |
| No pull-to-refresh animation indicator | - | Low | Add custom refresh indicator |
| Quick filter pills don't show loading state individually | `quickFilterSection` | Medium | Add per-pill loading spinner |
| Genre sections hardcoded | `genreSections` | Low | Make dynamic from API |
| Missing "Trending This Week" option | - | Medium | Add weekly trending toggle |

**Missing Features:**
- [ ] "Continue where you left off" with actual progress
- [ ] Personalized "Because you liked X" sections
- [ ] Regional content availability indicator

---

### 11.2 Movie Swipe Screen (`MovieSwipeView.swift`)

**Strengths:**
- Excellent swipe gesture handling with haptic feedback
- Card stack visual effect is polished
- Accessibility actions for VoiceOver users
- Match celebration overlay is engaging

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| Filter state not persisted | View `@State` | Medium | Move to ViewModel or UserDefaults |
| Match overlay auto-dismisses in 4s | Line 792 | Low | Make configurable or add setting |
| No undo last swipe | - | High | Add undo button/gesture |
| Cards don't show streaming availability | `SwipeCard` | Medium | Add streaming badges |
| Empty state only shows "All Done" | `emptyStateView` | Medium | Suggest loading more or changing filters |
| Stats sheet uses `AsyncImage` not `KFImage` | `statsSheet` | Low | Use KFImage for consistency |

**Missing Features:**
- [ ] Undo last swipe action
- [ ] "Super Like" with special animation (currently just "Watch Later")
- [ ] Daily swipe limit or gamification
- [ ] Share movie directly from card

---

### 11.3 Search Screen (`SearchView.swift`)

**Strengths:**
- Voice search integration
- Browse by genre with emoji icons
- Browse by streaming service with logos
- Sorting options for results

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| Streaming filter searches by NAME not provider ID | Line 383 | High | Use `with_watch_providers` API parameter |
| No recent searches persistence shown | - | Medium | Display recent searches section |
| Search placeholder says "TV shows" but app doesn't support TV | Line 165 | Medium | Change to "Search movies, actors..." |
| No search suggestions/autocomplete | - | Medium | Add search suggestions API |
| Results don't show streaming availability | `SearchResultCard` | Medium | Add streaming badges |
| Keyboard doesn't dismiss on scroll reliably | - | Low | Verify `scrollDismissesKeyboard` works |

**Missing Features:**
- [ ] Multi-search (movies + people in one query)
- [ ] Search filters (year, rating, genre)
- [ ] Search history with clear option
- [ ] Voice search transcript preview

---

### 11.4 Watchlist/Library Screen (`WatchlistView.swift`)

**Strengths:**
- Grid/List view toggle
- Multi-select mode with bulk actions
- Smart collections (All, Favorites, To Watch, Watched)
- Swipe actions for quick mark as watched/delete
- Stats section (total movies, watch time, top genre)

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| "Favorites" collection has no way to add favorites | - | High | Add favorite toggle in detail view |
| Watch time estimate assumes 2h per movie | Line 203 | Low | Fetch actual runtime from API |
| No sorting persistence | - | Medium | Save sort preference |
| Share watchlist generates image but no link | `shareMenu` | Medium | Add shareable link option |
| No drag-to-reorder in list view | - | Low | Add manual sorting option |
| Collection counts not animated when changing | - | Low | Animate count badges |

**Missing Features:**
- [ ] Custom collections (user-created)
- [ ] Import/export watchlist
- [ ] Watchlist collaboration (share with friends)
- [ ] "Random pick" button from watchlist

---

### 11.5 Movie Detail Screen (`MovieDetailView.swift`)

**Strengths:**
- Comprehensive information (cast, crew, reviews, similar, collections)
- Watch providers with streaming links
- Trailer playback integration
- Keywords section

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| 7 parallel API calls instead of using `fetchMovieDetailsFull` | `loadAllContent` | Medium | Use single optimized endpoint |
| Empty catch blocks silently fail | Lines 138-194 | Medium | Add error logging/UI feedback |
| No loading state for individual sections | - | Low | Add section-level loading |
| Hardcoded `padding(20)` throughout | Multiple | Medium | Use `Spacing.horizontal` |
| No "Share movie" button | - | Medium | Add share functionality |
| Reviews truncated at 3 | Line 532 | Low | Add "See all reviews" button |
| Collection movies not sorted by release date | Line 490 | Low | Already sorted, verify works |
| Missing runtime display | - | Medium | Show movie duration |
| No age rating/certification prominent display | - | Medium | Make certification more visible |

**Missing Features:**
- [ ] "Where to Watch" deep links to streaming apps
- [ ] User rating input
- [ ] Add to custom collection
- [ ] Similar/Recommended section navigation

---

### 11.6 Person Detail Screen (`PersonDetailView.swift`)

**Strengths:**
- Clean profile layout
- Biography with expand/collapse
- Known For horizontal scroll
- Filmography list with poster thumbnails
- Social media links

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| Only shows first 10 filmography items | Line 288 | Medium | Add pagination or "See All" |
| No filtering by role (actor vs director) | - | Medium | Add filter tabs |
| Missing photo gallery | - | Low | Add images section |
| Age calculation not shown | - | Low | Calculate and display current age |
| Dead vs alive not indicated | - | Low | Show if person has death date |

**Missing Features:**
- [ ] Filmography timeline visualization
- [ ] Awards/nominations section
- [ ] "Also worked with" (frequent collaborators)

---

### 11.7 Chat/AI Screen (`ChatView.swift`)

**Strengths:**
- Clean chat bubble UI
- Movie cards embedded in responses
- Streaming text effect for AI responses
- Typing indicator

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| No conversation persistence | - | High | Save chat history |
| Timer in TypingView never invalidated | Line 279 | Medium | Invalidate timer on disappear |
| Movie cards don't show rating prominently | `ChatMovieCard` | Low | Increase rating visibility |
| No way to copy message text | - | Low | Add long-press to copy |
| Chat doesn't resume after app restart | - | High | Persist conversation |
| Error alert is basic | Line 57-64 | Low | Use custom error banner |

**Missing Features:**
- [ ] Suggested prompts/quick actions
- [ ] "Ask about this movie" from detail screen
- [ ] Chat history persistence
- [ ] Export conversation

---

### 11.8 Onboarding Flow (`OnboardingContainerView.swift`)

**Strengths:**
- Beautiful animated gradient background
- Progress indicator with animated capsules
- Step-by-step flow (Welcome → Features → Streaming → Genres → Auth)
- Guest mode option

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| Demo cards don't actually swipe in Features step | `DemoCard` | Medium | Add interactive swipe demo |
| No skip entire onboarding option | - | Medium | Add "Skip" button |
| Genre selection doesn't show count limit | - | Low | Suggest "Pick at least 3" |
| Streaming services don't show logos | `StreamingServiceButton` | Medium | Use actual service logos |
| Can't go back from Auth step to change selections | - | Low | Allow full back navigation |
| No indication of what each auth method provides | - | Low | Explain sync benefits |

**Missing Features:**
- [ ] Interactive swipe tutorial on cards
- [ ] Skip to main app option
- [ ] Progress can be continued later

---

### 11.9 Sign In / Auth Screens (`SignInView.swift`)

**Strengths:**
- Multiple auth options (Apple, Google, Email)
- Clean error banner display
- Loading overlay during auth
- Terms of service mention

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| Google icon uses SF Symbol not actual logo | Line 155 | Low | Use Google logo image |
| No "Forgot Password" visible on main screen | - | Medium | Add forgot password link |
| Terms/Privacy links not tappable | Line 293 | High | Make links functional |
| Error banner dismiss doesn't clear error properly | Line 257 | Medium | Verify error clears on dismiss |
| No biometric authentication option | - | Low | Add Face ID/Touch ID |

**Missing Features:**
- [ ] Biometric login for returning users
- [ ] "Remember me" option
- [ ] Account deletion option in profile

---

### 11.10 Tab Bar (`GlassTabBar.swift` / `MainTabView.swift`)

**Issues to Fix:**

| Issue | Location | Severity | Fix |
|-------|----------|----------|-----|
| Tab icons don't show badge for notifications | - | Medium | Add badge support |
| No haptic on tab switch | - | Low | Add selection haptic |
| Tab bar covers content on some screens | - | Medium | Verify safe area insets |

---

### 11.11 Components Analysis

#### SwipeCard Component

**Strengths:**
- Excellent parallax effect on drag
- Accessibility fully implemented
- Haptic feedback per swipe direction
- Smooth spring animations

**Issues:**
- No streaming service indicator on cards
- Recommendation reason badge could be more prominent

#### MovieCard / GlassMovieCard Components

**Issues:**
- Inconsistent card styles across the app
- Some use `KFImage`, some use `AsyncImage`
- Rating badge styles vary

#### Error / Loading / Empty States

**Issues:**
- `LoadingView` is generic - could show contextual message
- `ErrorView` doesn't distinguish network vs server errors visually
- Empty states have inconsistent styling across screens

---

## 12. Cross-Cutting UI/UX Concerns

### 12.1 Consistency Issues

| Issue | Impact | Recommendation |
|-------|--------|----------------|
| Mix of `KFImage` and `AsyncImage` | Inconsistent loading behavior | Standardize on `KFImage` |
| `HapticManager.shared` vs `Haptics.shared` | Confusion | Use only `Haptics.shared` |
| Hardcoded colors vs design tokens | Maintenance burden | Use `Color.textPrimary` etc everywhere |
| Various button styles | Visual inconsistency | Create standard button components |
| Movie card designs vary | Fragmented UX | Create one reusable `MovieCardView` |

### 12.2 Missing Global Features

| Feature | Priority | Notes |
|---------|----------|-------|
| Deep linking | High | Can't share links to movies |
| Push notifications | Medium | No reminder for watchlist items |
| Widget support | Medium | No home screen widgets |
| Spotlight search | Low | Movies not indexed |
| Siri shortcuts | Low | No voice shortcuts |
| iPad split view | Medium | No multi-column layout |
| Apple TV support | Low | Components exist but not integrated |

### 12.3 Animation & Transition Issues

| Issue | Location | Fix |
|-------|----------|-----|
| Abrupt loading→content transitions | Multiple views | Wrap in `withAnimation` |
| No shared element transitions | Navigation | Add `matchedGeometryEffect` |
| Sheet presentations not animated | Some sheets | Use `.animation` modifier |
| Pull-to-refresh has no custom indicator | All lists | Add custom refresh view |

### 12.4 Accessibility Audit Summary

| Screen | VoiceOver | Dynamic Type | Reduce Motion |
|--------|-----------|--------------|---------------|
| Home | Partial | No | Partial |
| Swipe | Good | No | Yes |
| Search | Partial | No | Partial |
| Watchlist | Good | No | Partial |
| Detail | Needs work | No | Partial |
| Chat | Partial | No | No |
| Onboarding | Partial | No | Yes |

**Priority Accessibility Fixes:**
1. Add Dynamic Type support to Typography.swift
2. Apply `movieAccessibility()` modifier to all movie cards
3. Test all screens with VoiceOver
4. Verify all interactive elements have labels

---

## Appendix: File Reference

### Files Requiring Immediate Attention

| Priority | File | Issue |
|----------|------|-------|
| CRITICAL | `Services/OfflineModeManager.swift` | Mock implementation |
| CRITICAL | `Services/ImageCacheManager.swift` | Empty prefetch array |
| HIGH | `DesignSystem/Typography.swift` | No Dynamic Type |
| HIGH | `Networking/TMDBEndpoint.swift:587` | Filter typo |
| MEDIUM | `Views/Features/MovieDetailView.swift` | Empty catch blocks |
| MEDIUM | `Services/ImageGenerator.swift:224` | Force unwrap |
| MEDIUM | `Services/OfflineMovieCache.swift:116` | Force unwrap |

### Files With Good Patterns to Preserve

| File | Good Pattern |
|------|-------------|
| `Networking/TMDBService.swift` | Actor isolation, retry with backoff |
| `Services/WatchlistManager.swift` | Debounced persistence, background I/O |
| `DesignSystem/Accessibility.swift` | Motion-aware modifiers |
| `Core/AppError.swift` | User-friendly error mapping |
| `Networking/NetworkError.swift` | Retryable error classification |

---

## Conclusion

MovieTrailer has a strong foundation with sophisticated architecture patterns. The main concerns are:

1. **Critical**: Offline mode is fake - must implement real caching
2. **High**: Accessibility gaps will limit App Store approval
3. **Medium**: Architecture inconsistencies create maintenance burden

Address Phase 1 issues before any production release. The TMDB integration is solid but missing key competitive features (TV shows, streaming filters).

**Estimated effort to production-ready**: 4-6 weeks with focused development.
