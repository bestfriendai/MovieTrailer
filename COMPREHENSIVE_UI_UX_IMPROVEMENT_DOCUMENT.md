# MovieTrailer: Comprehensive UI/UX Improvement & Functionality Document

**Document Version:** 2.0  
**Analysis Date:** January 2026  
**Status:** Production-Ready Foundation with Premium Enhancement Opportunities

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Current Implementation Analysis](#2-current-implementation-analysis)
3. [Design System Assessment](#3-design-system-assessment)
4. [Feature-by-Feature Analysis](#4-feature-by-feature-analysis)
5. [UI/UX Improvement Recommendations](#5-uiux-improvement-recommendations)
6. [Functionality Improvements](#6-functionality-improvements)
7. [Accessibility Audit](#7-accessibility-audit)
8. [Performance Optimization](#8-performance-optimization)
9. [Implementation Roadmap](#9-implementation-roadmap)
10. [Code Examples & Patterns](#10-code-examples--patterns)
11. [Quality Assurance Checklist](#11-quality-assurance-checklist)
12. [Success Metrics](#12-success-metrics)

---

## 1. Executive Summary

### Current State Assessment

The MovieTrailer app represents a **sophisticated, production-ready iOS application** with a mature architecture and premium visual design. The codebase demonstrates senior-level engineering practices including:

| Aspect | Rating | Notes |
|--------|--------|-------|
| **Architecture** | A | Clean MVVM + Coordinator pattern, proper dependency injection |
| **Design System** | A- | 85% complete, Liquid Glass aesthetic, comprehensive tokens |
| **UI/UX Polish** | B+ | Premium components exist, some consistency gaps |
| **Accessibility** | B- | Basic support, needs comprehensive audit |
| **Performance** | A- | Actor-based networking, offline caching, image prefetching |
| **Feature Completeness** | B+ | Core flows complete, some advanced features stubbed |

### Key Strengths

1. **Liquid Glass Design Language**: Full implementation of Apple's 2025 design aesthetic
2. **Robust Networking**: Actor-based TMDBService with retry logic, certificate pinning, and request coalescing
3. **Offline-First Architecture**: Multi-layer caching with graceful degradation
4. **Premium Animations**: Physics-based springs, micro-interactions, haptic feedback
5. **Smart Discovery**: Personalization, quick filters, recommendation engine

### Priority Improvement Areas

1. **Component Consistency**: Unify button styles, standardize card variants
2. **Accessibility Excellence**: Full VoiceOver support, Dynamic Type, Reduce Motion
3. **Error State Polish**: Consistent error handling UX across all screens
4. **iPad Optimization**: Adaptive layouts, split view support
5. **Social Features**: Shareable watchlists, collaborative viewing

---

## 2. Current Implementation Analysis

### 2.1 File Structure Overview

```
MovieTrailer/
├── App/                          # App entry, coordinators
├── Components/                   # Reusable UI components
│   ├── Accessibility/           # AccessibilityModifiers
│   ├── Animations/              # ParallaxMovieCard, PremiumRefreshable
│   ├── AppleTV/                 # CinematicHero, ContentRow, Top10Row
│   ├── Cards/                   # FeaturedCard, GlassMovieCard, SwipeCard
│   ├── Cast/                    # CastComponents
│   ├── Collections/             # CollectionBanner
│   ├── Filters/                 # FilterSheetView, FilterSystem
│   ├── Layout/                  # AdaptiveLayout
│   ├── Pills/                   # CategoryPill, StreamingBadge
│   ├── Reviews/                 # ReviewComponents
│   ├── Sheets/                  # StreamingFilterSheet
│   ├── Skeleton/                # SkeletonLoading (comprehensive)
│   └── TabBar/                  # GlassTabBar
├── DesignSystem/                # Design tokens and theming
│   ├── Accessibility.swift
│   ├── Colors.swift             # 500+ lines, OLED-optimized
│   ├── GlassCard.swift
│   ├── Haptics.swift
│   ├── LiquidGlass.swift        # Premium glass components
│   ├── MicroInteractions.swift
│   ├── Spacing.swift            # 4pt grid system
│   ├── Theme.swift              # Animation presets, shadows
│   └── Typography.swift         # SF Pro scale
├── Networking/                  # API layer
│   ├── NetworkError.swift
│   ├── RequestCoalescer.swift   # Prevents duplicate requests
│   ├── TMDBEndpoint.swift       # 40+ endpoints defined
│   └── TMDBService.swift        # Actor-based, retry logic
├── Services/                    # Business logic services
│   ├── OfflineMovieCache.swift  # Category-indexed caching
│   ├── RecommendationEngine.swift
│   ├── WatchlistManager.swift   # Debounced persistence + Firestore
│   └── NetworkMonitor.swift     # Connectivity tracking
├── ViewModels/                  # Screen-level state management
└── Views/                       # SwiftUI views organized by feature
```

### 2.2 Technology Stack

| Category | Technology | Version/Notes |
|----------|------------|---------------|
| UI Framework | SwiftUI | 100% SwiftUI, no UIKit |
| Concurrency | Swift Concurrency | async/await, Actors |
| Image Loading | Kingfisher | With prefetching |
| Persistence | FileManager + Firestore | Local-first with cloud sync |
| State Management | @Observable (iOS 17+) | Observable macro pattern |
| Navigation | Coordinator Pattern | Deep link support |
| Haptics | UIFeedbackGenerator | Contextual feedback |

---

## 3. Design System Assessment

### 3.1 Color System (Colors.swift) - COMPLETE

The color system is **production-ready** with comprehensive token coverage:

```swift
// Implemented Token Categories:
- Background Colors (5 levels): appBackground, surfacePrimary...Tertiary, cardBackground
- Glass Materials (5 levels): glassUltraThin (0.03) to glassThick (0.15)
- Text Hierarchy (4 levels): textPrimary, Secondary, Tertiary, Quaternary
- Accent Colors (10): Blue, Purple, Pink, Orange, Green, Red, Cyan, Yellow
- Swipe Actions: swipeLove, swipeLike, swipeSkip, swipeWatchLater, swipeSuperLike
- Streaming Brands: Netflix, Disney+, Prime, HBO Max, Apple TV+, Hulu, Peacock, Paramount+
- Genre Colors: Action, Comedy, Drama, Horror, Sci-Fi, etc.
- Rating Colors: Excellent (8+), Good (7-8), Average (5-7), Poor (<5)
- Gradients: heroOverlay, cardOverlay, accent, premium, warm, cool, gold
```

**Status**: No gaps identified. Light mode support would be the only enhancement.

### 3.2 Typography System (Typography.swift) - COMPLETE

```swift
// Implemented Scale:
Display:    displayXL (56pt), displayLarge (44pt), displayMedium (34pt)
Headlines:  headline1 (28pt), headline2 (24pt), headline3 (20pt)
Titles:     titleLarge (22pt), titleMedium (18pt), titleSmall (16pt)
Body:       bodyLarge (17pt), bodyMedium (15pt), bodySmall (13pt)
Labels:     labelLarge (15pt), labelMedium (13pt), labelSmall (11pt)
Captions:   captionLarge (13pt), captionRegular (12pt), captionSmall (11pt)
Special:    rating (14pt Rounded), rankingNumber (72pt Heavy), monoNumber
```

**Gap**: Dynamic Type support is inconsistent. Need to audit all views for `@ScaledMetric` usage.

### 3.3 Spacing System (Spacing.swift) - COMPLETE

```swift
// 4pt Base Grid:
micro: 2pt    xxs: 4pt     xs: 8pt      sm: 12pt
md: 16pt      lg: 20pt     xl: 24pt     xxl: 32pt
xxxl: 40pt    xxxxl: 48pt  massive: 64pt

// Semantic Spacing:
section: 32pt, horizontal: 20pt, cardPadding: 16pt, tabBarSafeArea: 90pt
```

**Status**: Well-implemented with view extensions for convenience.

### 3.4 Animation System (Theme.swift) - ADVANCED

```swift
// Spring Presets (Physics-Based):
snappy:      response: 0.25, damping: 0.75  // Buttons, instant feel
smooth:      response: 0.35, damping: 0.82  // Standard transitions
bouncy:      response: 0.40, damping: 0.60  // Playful elements
cinematic:   response: 0.50, damping: 0.78  // Hero reveals
interactive: response: 0.30, damping: 0.80  // Gesture-driven

// Easing:
pageTransition: 0.4s ease-in-out
shimmer: linear 1.2s repeat
pulse: ease-in-out 1.0s repeat
```

**Status**: Comprehensive. Missing: standardized `Transition` tokens for navigation.

### 3.5 Component Library Assessment

| Component | Status | Quality | Notes |
|-----------|--------|---------|-------|
| **GlassMovieCard** | Complete | A | Shimmer, rating badge, press effect |
| **FeaturedCard** | Complete | A | Hero-style with trailer button |
| **SwipeCard** | Complete | A+ | Full gesture handling, stamps |
| **CinematicHero** | Complete | A+ | Parallax, auto-advance, page indicators |
| **Top10Row** | Complete | A | Large ranking numbers |
| **ContentRow** | Complete | A | Standard horizontal scroll |
| **GlassTabBar** | Complete | A | Floating pill, selection animation |
| **SkeletonLoading** | Complete | A+ | 7 skeleton variants |
| **CategoryPill** | Complete | A | Icon, color, selection states |
| **StreamingBadge** | Complete | A | Provider logos and colors |
| **LiquidGlassButton** | Partial | B | Exists but not in Components/ |
| **SwipeStamp** | Missing | - | Documented but not implemented |
| **AdaptiveLayout** | Partial | B | Needs iPad-specific handling |

### 3.6 Design Debt Summary

| Issue | Priority | Effort | Impact |
|-------|----------|--------|--------|
| Unify Haptics.swift and HapticManager.swift | High | Low | Code clarity |
| Create Components/Buttons/ directory with standard styles | High | Medium | Consistency |
| Implement SwipeStamp overlays | Medium | Low | Polish |
| Add Light Mode support | Low | High | Accessibility |
| Standardize navigation transitions | Medium | Medium | UX consistency |

---

## 4. Feature-by-Feature Analysis

### 4.1 Home Screen (HomeView.swift)

**Current Implementation:**
- Cinematic hero carousel with auto-advance
- Quick filter pills (Tonight, Date Night, Family, New)
- Multiple content sections: Trending, Top 10, Popular, Genre-specific
- Personalization section for user preferences
- Offline banner with cached data fallback
- Error handling with retry capability

**Working Well:**
- Skeleton loading during initial load
- Pull-to-refresh with haptic feedback
- Filter state management in ViewModel
- Lazy loading of genre sections

**Issues Identified:**

| Issue | Severity | Description |
|-------|----------|-------------|
| Section Header Inconsistency | Medium | Some sections use icons, some don't |
| "See All" Navigation | Medium | Opens sheet instead of push navigation |
| Loading State Jank | Low | Hero carousel can flash during load |
| Memory Pressure | Low | All sections load at once |

**Recommended Improvements:**

```swift
// 1. Standardize section headers
struct SectionHeader: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let showSeeAll: Bool
    let onSeeAll: (() -> Void)?
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon = icon {
                IconBadge(icon: icon, color: .accentPrimary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline1)
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.labelMedium)
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            if showSeeAll, let action = onSeeAll {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.labelMedium)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.accentPrimary)
                }
            }
        }
        .padding(.horizontal, Spacing.horizontal)
    }
}

// 2. Lazy section loading
struct LazyContentSection<Content: View>: View {
    let threshold: CGFloat = 100
    @State private var hasAppeared = false
    let content: () -> Content
    
    var body: some View {
        Group {
            if hasAppeared {
                content()
            } else {
                SkeletonMovieRow()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                hasAppeared = true
            }
        }
    }
}
```

### 4.2 Movie Swipe (MovieSwipeView.swift)

**Current Implementation:**
- Tinder-style card stack with depth effect
- Three-direction swipe: Right (Love), Left (Skip), Up (Save)
- Filter chips with genre/year/rating options
- Stats sheet with session analytics
- Match celebration overlay with confetti
- Recommendation reasons ("Because you liked...")

**Working Well:**
- Smooth gesture handling with spring physics
- Haptic feedback on swipe threshold
- Undo functionality
- Background card scaling/opacity

**Issues Identified:**

| Issue | Severity | Description |
|-------|----------|-------------|
| No Tutorial | High | First-time users don't know swipe directions |
| Filter Sync | Medium | Filters don't persist across sessions |
| Empty State UX | Low | "All Done" could suggest more actions |
| Card Information Density | Low | Could show more at-a-glance info |

**Recommended Improvements:**

```swift
// 1. First-time user tutorial overlay
struct SwipeTutorialOverlay: View {
    @Binding var hasSeenTutorial: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("How to Discover")
                    .font(.displaySmall)
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 40) {
                    TutorialGesture(
                        icon: "arrow.left",
                        label: "Skip",
                        color: .swipeSkip
                    )
                    
                    TutorialGesture(
                        icon: "arrow.up",
                        label: "Save",
                        color: .swipeWatchLater
                    )
                    
                    TutorialGesture(
                        icon: "heart.fill",
                        label: "Love",
                        color: .swipeLove
                    )
                }
                
                Button("Got it!") {
                    withAnimation {
                        hasSeenTutorial = true
                        UserDefaults.standard.set(true, forKey: "hasSeenSwipeTutorial")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .transition(.opacity)
    }
}

// 2. Enhanced swipe card with streaming info
struct EnhancedSwipeCardOverlay: View {
    let movie: Movie
    let providers: [WatchProvider]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Existing content...
            
            // Add streaming availability
            if !providers.isEmpty {
                HStack(spacing: Spacing.xs) {
                    Text("Watch on")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                    
                    ForEach(providers.prefix(3)) { provider in
                        StreamingProviderIcon(provider: provider, size: 24)
                    }
                    
                    if providers.count > 3 {
                        Text("+\(providers.count - 3)")
                            .font(.caption.bold())
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
    }
}
```

### 4.3 Search (SearchView.swift)

**Current Implementation:**
- Debounced search with 300ms delay
- Recent searches persistence
- Voice search capability
- Genre browsing grid
- Trending searches display
- Search results with poster grid

**Working Well:**
- Request cancellation on new search
- Search history management
- Empty state with suggestions

**Issues Identified:**

| Issue | Severity | Description |
|-------|----------|-------------|
| No Sort Options | Medium | Can't sort results by rating/year |
| Limited Filters | Medium | Only genre filter, no year/rating |
| Voice Search Feedback | Low | No visual indication of listening state |
| Result Count | Low | Doesn't show total results found |

**Recommended Improvements:**

```swift
// 1. Search result header with sort/filter
struct SearchResultsHeader: View {
    let resultCount: Int
    @Binding var sortOption: SortOption
    @Binding var showFilters: Bool
    
    enum SortOption: String, CaseIterable {
        case relevance = "Relevance"
        case rating = "Rating"
        case newest = "Newest"
        case popularity = "Popularity"
    }
    
    var body: some View {
        HStack {
            Text("\(resultCount) results")
                .font(.labelMedium)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button {
                        sortOption = option
                    } label: {
                        HStack {
                            Text(option.rawValue)
                            if sortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(sortOption.rawValue)
                }
                .font(.labelMedium)
                .foregroundColor(.accentPrimary)
            }
            
            Button {
                showFilters = true
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title3)
                    .foregroundColor(.accentPrimary)
            }
        }
        .padding(.horizontal, Spacing.horizontal)
        .padding(.vertical, Spacing.sm)
    }
}

// 2. Voice search visual feedback
struct VoiceSearchButton: View {
    @Binding var isListening: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Pulsing rings when listening
                if isListening {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.accentPrimary.opacity(0.3), lineWidth: 2)
                            .scaleEffect(isListening ? 1.5 + CGFloat(i) * 0.3 : 1)
                            .opacity(isListening ? 0 : 1)
                            .animation(
                                .easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.3),
                                value: isListening
                            )
                    }
                }
                
                Circle()
                    .fill(isListening ? Color.accentPrimary : Color.glassThin)
                    .frame(width: 44, height: 44)
                
                Image(systemName: isListening ? "waveform" : "mic.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isListening ? .white : .textPrimary)
                    .symbolEffect(.variableColor, isActive: isListening)
            }
        }
        .sensoryFeedback(.impact, trigger: isListening)
    }
}
```

### 4.4 Watchlist (WatchlistView.swift)

**Current Implementation:**
- Grid/list view toggle
- Smart collections (Date Night, etc.)
- Swipe-to-delete
- Share watchlist as image
- Watch status tracking
- Firestore cloud sync

**Working Well:**
- Debounced persistence
- Offline-first design
- Empty state with CTA

**Issues Identified:**

| Issue | Severity | Description |
|-------|----------|-------------|
| No Batch Actions | Medium | Can't select multiple to delete/move |
| Limited Sorting | Medium | Only by date added |
| No Custom Collections | Medium | Can't create user folders |
| Share Quality | Low | Image export could be higher quality |

**Recommended Improvements:**

```swift
// 1. Multi-select mode
struct WatchlistMultiSelectToolbar: View {
    let selectedCount: Int
    let onMarkWatched: () -> Void
    let onDelete: () -> Void
    let onCreateCollection: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.lg) {
            Button(action: onMarkWatched) {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                    Text("Watched")
                        .font(.caption)
                }
            }
            .foregroundColor(.accentGreen)
            
            Button(action: onCreateCollection) {
                VStack(spacing: 4) {
                    Image(systemName: "folder.badge.plus")
                        .font(.title2)
                    Text("Collection")
                        .font(.caption)
                }
            }
            .foregroundColor(.accentPrimary)
            
            Button(action: onDelete) {
                VStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.title2)
                    Text("Remove")
                        .font(.caption)
                }
            }
            .foregroundColor(.accentRed)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .overlay(
            Text("\(selectedCount) selected")
                .font(.labelMedium)
                .foregroundColor(.textSecondary),
            alignment: .top
        )
    }
}

// 2. Custom collection creation
struct CreateCollectionSheet: View {
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    let onCreate: (String, String) -> Void
    
    let iconOptions = [
        "folder.fill", "heart.fill", "star.fill", "moon.stars.fill",
        "film.fill", "popcorn.fill", "tv.fill", "play.circle.fill"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Collection Name") {
                    TextField("e.g., Weekend Binge", text: $name)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .accentPrimary : .textSecondary)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.accentPrimary.opacity(0.15) : Color.glassThin)
                                    )
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(name, selectedIcon)
                        isPresented = false
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
```

### 4.5 Movie Detail (MovieDetailView.swift)

**Current Implementation:**
- Parallax hero backdrop with gradient
- Poster, title, metadata section
- Watch providers with deep links
- Cast horizontal scroll
- Similar movies section
- Trailer playback

**Working Well:**
- Streaming availability display
- Add to watchlist integration
- Share functionality

**Issues Identified:**

| Issue | Severity | Description |
|-------|----------|-------------|
| No Reviews Section | Medium | TMDB reviews not displayed |
| Limited Cast Info | Medium | Tapping cast doesn't navigate |
| No Collection Display | Medium | Movie franchises not shown |
| Trailer Loading | Low | No loading state for YouTube |

**Recommended Improvements:**

```swift
// 1. Reviews section
struct ReviewsSection: View {
    let reviews: [Review]
    @State private var expandedReviewId: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Reviews", subtitle: "\(reviews.count) reviews")
            
            VStack(spacing: Spacing.md) {
                ForEach(reviews.prefix(3)) { review in
                    ReviewCard(
                        review: review,
                        isExpanded: expandedReviewId == review.id,
                        onToggle: {
                            withAnimation(.smooth) {
                                expandedReviewId = expandedReviewId == review.id ? nil : review.id
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }
}

struct ReviewCard: View {
    let review: Review
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Author header
            HStack {
                AsyncImage(url: review.authorDetails?.avatarURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(Color.surfaceSecondary)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.author)
                        .font(.labelLarge)
                        .foregroundColor(.textPrimary)
                    
                    if let rating = review.authorDetails?.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.ratingStar)
                            Text("\(Int(rating))/10")
                        }
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                Text(review.formattedDate)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            
            // Review content
            Text(review.content)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .lineLimit(isExpanded ? nil : 4)
            
            if review.content.count > 200 {
                Button(action: onToggle) {
                    Text(isExpanded ? "Show less" : "Read more")
                        .font(.labelMedium)
                        .foregroundColor(.accentPrimary)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large))
    }
}

// 2. Collection/franchise display
struct CollectionBannerView: View {
    let collection: MovieCollection
    let onMovieTap: (Movie) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Part of")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                    
                    Text(collection.name)
                        .font(.headline2)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                Text("\(collection.parts.count) movies")
                    .font(.labelMedium)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, Spacing.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(collection.sortedParts) { movie in
                        CollectionMovieCard(movie: movie, onTap: { onMovieTap(movie) })
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
        .padding(.vertical, Spacing.md)
        .background(
            LinearGradient(
                colors: [.clear, Color.accentPrimary.opacity(0.08), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
```

---

## 5. UI/UX Improvement Recommendations

### 5.1 Visual Consistency Matrix

| Element | Current State | Recommended Standard |
|---------|--------------|---------------------|
| **Section Headers** | Inconsistent (some with icons, varying fonts) | Use `SectionHeader` component everywhere |
| **Button Styles** | Ad-hoc implementations | Create `ButtonStyle` catalog |
| **Card Corners** | Mix of 12pt, 16pt, 20pt | Standardize: Small=12, Medium=16, Large=20 |
| **Shadows** | Direct shadow() calls | Use `AppTheme.Shadow` presets |
| **Touch Feedback** | Inconsistent scale effects | Use `.pressEffect()` modifier |
| **Loading States** | Mix of spinners and skeletons | Use skeletons exclusively |

### 5.2 Button Style System

Create a unified button style system in `Components/Buttons/`:

```swift
// PrimaryButtonStyle.swift
struct PrimaryButtonStyle: ButtonStyle {
    var isDestructive: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonMedium)
            .foregroundColor(.textInverted)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(isDestructive ? Color.accentRed : Color.white)
            .clipShape(Capsule())
            .shadow(color: (isDestructive ? Color.accentRed : Color.white).opacity(0.3), radius: 12, y: 6)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AppTheme.Animation.buttonPress, value: configuration.isPressed)
    }
}

// SecondaryButtonStyle.swift
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonMedium)
            .foregroundColor(.textPrimary)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.md)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(AppTheme.Animation.buttonPress, value: configuration.isPressed)
    }
}

// GhostButtonStyle.swift
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.buttonMedium)
            .foregroundColor(.accentPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(AppTheme.Animation.micro, value: configuration.isPressed)
    }
}

// IconButtonStyle.swift
struct IconButtonStyle: ButtonStyle {
    var size: CGFloat = 44
    var background: IconButtonBackground = .glass
    
    enum IconButtonBackground {
        case glass, solid(Color), none
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundColor(.textPrimary)
            .frame(width: size, height: size)
            .background(backgroundView)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(AppTheme.Animation.buttonPress, value: configuration.isPressed)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch background {
        case .glass:
            Circle().fill(.ultraThinMaterial)
        case .solid(let color):
            Circle().fill(color)
        case .none:
            Color.clear
        }
    }
}
```

### 5.3 Navigation Transitions

Implement consistent navigation transitions:

```swift
// NavigationTransition.swift
extension View {
    func heroTransition(id: String, namespace: Namespace.ID) -> some View {
        self
            .matchedGeometryEffect(id: id, in: namespace)
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                removal: .opacity
            ))
    }
    
    func slideTransition(edge: Edge = .trailing) -> some View {
        self.transition(
            .asymmetric(
                insertion: .move(edge: edge).combined(with: .opacity),
                removal: .opacity
            )
        )
    }
    
    func fadeScaleTransition() -> some View {
        self.transition(
            .asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.9)),
                removal: .opacity.combined(with: .scale(scale: 1.05))
            )
        )
    }
}
```

### 5.4 Empty State Standardization

```swift
struct StandardEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Icon with subtle animation
            ZStack {
                Circle()
                    .fill(Color.surfaceSecondary)
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.textTertiary)
            }
            
            VStack(spacing: Spacing.xs) {
                Text(title)
                    .font(.headline2)
                    .foregroundColor(.textPrimary)
                
                Text(message)
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.top, Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xxl)
    }
}
```

---

## 6. Functionality Improvements

### 6.1 Enhanced Personalization

```swift
// PreferenceLearning.swift
actor PreferenceLearningEngine {
    private var genreScores: [Int: Double] = [:]
    private var actorScores: [Int: Double] = [:]
    private var directorScores: [Int: Double] = [:]
    private var avgPreferredRating: Double = 7.0
    private var avgPreferredRuntime: Int = 120
    
    // Update scores based on user actions
    func recordInteraction(_ movie: Movie, action: UserAction) async {
        let weight = action.weight
        
        // Update genre scores
        for genreId in movie.genreIds {
            genreScores[genreId, default: 0] += weight
        }
        
        // Update rating preference
        if action == .liked || action == .superLiked {
            avgPreferredRating = (avgPreferredRating * 0.9) + (movie.voteAverage * 0.1)
        }
    }
    
    // Score a movie based on learned preferences
    func score(_ movie: Movie) async -> Double {
        var score: Double = 0
        
        // Genre matching (40% weight)
        let genreScore = movie.genreIds.reduce(0.0) { sum, id in
            sum + (genreScores[id] ?? 0)
        } / max(Double(movie.genreIds.count), 1)
        score += genreScore * 0.4
        
        // Rating proximity (30% weight)
        let ratingDiff = abs(movie.voteAverage - avgPreferredRating)
        let ratingScore = max(0, 10 - ratingDiff) / 10
        score += ratingScore * 0.3
        
        // Recency bonus (20% weight)
        if let year = movie.releaseYear, let yearInt = Int(year) {
            let currentYear = Calendar.current.component(.year, from: Date())
            let agePenalty = max(0, 1 - Double(currentYear - yearInt) / 20)
            score += agePenalty * 0.2
        }
        
        // Popularity normalization (10% weight)
        let popularityScore = min(movie.popularity / 100, 1.0)
        score += popularityScore * 0.1
        
        return score
    }
    
    // Get personalized "For You" recommendations
    func getRecommendations(from movies: [Movie], limit: Int = 20) async -> [Movie] {
        var scoredMovies: [(Movie, Double)] = []
        
        for movie in movies {
            let score = await score(movie)
            scoredMovies.append((movie, score))
        }
        
        return scoredMovies
            .sorted { $0.1 > $1.1 }
            .prefix(limit)
            .map { $0.0 }
    }
    
    enum UserAction {
        case viewed, liked, superLiked, skipped, watchLater
        
        var weight: Double {
            switch self {
            case .superLiked: return 2.0
            case .liked: return 1.0
            case .watchLater: return 0.5
            case .viewed: return 0.2
            case .skipped: return -0.3
            }
        }
    }
}
```

### 6.2 Enhanced Offline Mode

```swift
// OfflineModeManager.swift
@MainActor
final class OfflineModeManager: ObservableObject {
    @Published var isOffline = false
    @Published var cachedCategories: Set<MovieCategory> = []
    @Published var lastSyncDate: Date?
    
    private let networkMonitor: NetworkMonitor
    private let offlineCache: OfflineMovieCache
    
    var offlineCapabilityMessage: String {
        if cachedCategories.isEmpty {
            return "No content available offline"
        }
        let categories = cachedCategories.map(\.rawValue).joined(separator: ", ")
        return "Available offline: \(categories)"
    }
    
    func downloadForOffline(categories: [MovieCategory]) async {
        for category in categories {
            do {
                let movies = try await fetchMovies(for: category)
                await offlineCache.cacheMovies(movies, category: category)
                cachedCategories.insert(category)
            } catch {
                print("Failed to cache \(category): \(error)")
            }
        }
        lastSyncDate = Date()
    }
    
    func clearOfflineData() async {
        await offlineCache.clearAll()
        cachedCategories.removeAll()
    }
}

// Offline indicator banner
struct OfflineStatusBanner: View {
    @ObservedObject var offlineManager: OfflineModeManager
    
    var body: some View {
        if offlineManager.isOffline {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.warning)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("You're Offline")
                        .font(.labelMedium)
                        .foregroundColor(.textPrimary)
                    
                    Text(offlineManager.offlineCapabilityMessage)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if let lastSync = offlineManager.lastSyncDate {
                    Text("Synced \(lastSync.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(Spacing.md)
            .background(Color.warning.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .padding(.horizontal, Spacing.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
```

### 6.3 Social Sharing Enhancements

```swift
// ShareableWatchlist.swift
struct ShareableWatchlistView: View {
    let watchlist: [WatchlistItem]
    let username: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("\(username)'s Watchlist")
                        .font(.headline1)
                        .foregroundColor(.textPrimary)
                    
                    Text("\(watchlist.count) movies to watch")
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image("AppLogo")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
            .padding(Spacing.lg)
            .background(Color.surfaceElevated)
            
            // Movie grid (3x3 for sharing)
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(watchlist.prefix(9)) { item in
                    AsyncImage(url: item.posterURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.surfaceSecondary
                    }
                    .aspectRatio(2/3, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(Spacing.lg)
            
            // Footer with QR code
            HStack {
                if let shareURL = generateShareURL() {
                    QRCodeView(url: shareURL)
                        .frame(width: 60, height: 60)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scan to view full list")
                        .font(.labelMedium)
                        .foregroundColor(.textPrimary)
                    
                    Text("movietrailer.app")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
                
                Spacer()
            }
            .padding(Spacing.lg)
            .background(Color.surfacePrimary)
        }
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl))
    }
    
    func generateShareURL() -> URL? {
        // Generate deep link or web URL for the watchlist
        let movieIds = watchlist.prefix(20).map { String($0.movieId) }.joined(separator: ",")
        return URL(string: "https://movietrailer.app/list?movies=\(movieIds)&by=\(username)")
    }
    
    func renderAsImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3.0
        return renderer.uiImage
    }
}
```

---

## 7. Accessibility Audit

### 7.1 Current State

| Feature | VoiceOver | Dynamic Type | Reduce Motion | Reduce Transparency |
|---------|-----------|--------------|---------------|---------------------|
| Home | Partial | Partial | Not checked | Not checked |
| Swipe | Limited | No | No | No |
| Search | Good | Partial | Yes | No |
| Watchlist | Good | Partial | Yes | No |
| Detail | Partial | No | Yes | No |

### 7.2 Required Improvements

```swift
// AccessibilityModifiers.swift - Additions needed

// 1. Movie card accessibility
extension View {
    func movieAccessibility(
        title: String,
        rating: Double,
        year: String?,
        genres: [String],
        isInWatchlist: Bool
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(buildAccessibilityLabel(
                title: title,
                rating: rating,
                year: year,
                genres: genres
            ))
            .accessibilityHint(isInWatchlist ? "In your watchlist. Double tap for details." : "Double tap for details.")
            .accessibilityAddTraits(.isButton)
    }
    
    private func buildAccessibilityLabel(
        title: String,
        rating: Double,
        year: String?,
        genres: [String]
    ) -> String {
        var parts = [title]
        parts.append("Rated \(String(format: "%.1f", rating)) out of 10")
        if let year = year {
            parts.append("Released in \(year)")
        }
        if !genres.isEmpty {
            parts.append(genres.joined(separator: ", "))
        }
        return parts.joined(separator: ". ")
    }
}

// 2. Swipe card accessibility
struct AccessibleSwipeCard: View {
    let movie: Movie
    let onSwipe: (SwipeDirection) -> Void
    
    var body: some View {
        SwipeCard(movie: movie, onSwipe: onSwipe)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(movie.title). \(movie.formattedRating) stars.")
            .accessibilityHint("Swipe right to love, left to skip, or up to save for later.")
            .accessibilityActions {
                Button("Love this movie") {
                    onSwipe(.right)
                }
                Button("Skip this movie") {
                    onSwipe(.left)
                }
                Button("Save for later") {
                    onSwipe(.up)
                }
            }
    }
}

// 3. Reduce Motion support
struct MotionAwareModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    
    func body(content: Content) -> some View {
        content.animation(reduceMotion ? .none : animation)
    }
}

extension View {
    func motionAware(_ animation: Animation) -> some View {
        modifier(MotionAwareModifier(animation: animation))
    }
}

// 4. Reduce Transparency support
struct AdaptiveGlassModifier: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                reduceTransparency
                    ? AnyView(Color.surfaceElevated)
                    : AnyView(Color.clear.background(.ultraThinMaterial))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// 5. Dynamic Type scaling
extension View {
    func scaledPadding(_ edges: Edge.Set = .all, _ length: CGFloat) -> some View {
        self.modifier(ScaledPaddingModifier(edges: edges, length: length))
    }
}

struct ScaledPaddingModifier: ViewModifier {
    @ScaledMetric var scaledLength: CGFloat
    let edges: Edge.Set
    
    init(edges: Edge.Set, length: CGFloat) {
        self.edges = edges
        _scaledLength = ScaledMetric(wrappedValue: length)
    }
    
    func body(content: Content) -> some View {
        content.padding(edges, scaledLength)
    }
}
```

### 7.3 Accessibility Checklist

- [ ] All interactive elements have minimum 44x44pt touch targets
- [ ] All images have accessibility labels
- [ ] Color is never the only indicator of state
- [ ] Focus order is logical
- [ ] Custom actions available for complex gestures
- [ ] Animations respect Reduce Motion
- [ ] Glass effects have solid fallbacks for Reduce Transparency
- [ ] All text scales with Dynamic Type (up to accessibility sizes)
- [ ] Contrast ratios meet WCAG AA (4.5:1 for normal text)

---

## 8. Performance Optimization

### 8.1 Current Performance Profile

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| Cold Launch | ~1.8s | <1.5s | Needs work |
| Tab Switch | <100ms | <100ms | Good |
| Image Load (cached) | ~80ms | <50ms | Needs work |
| Memory (browsing) | ~140MB | <150MB | Good |
| Memory (swipe session) | ~180MB | <150MB | Needs work |

### 8.2 Optimization Recommendations

```swift
// 1. Image loading optimization
extension KFImage {
    static func optimized(url: URL?, size: ImageSize) -> KFImage {
        let processor = DownsamplingImageProcessor(size: size.cgSize)
        
        return KFImage(url)
            .setProcessor(processor)
            .loadDiskFileSynchronously()
            .cacheMemoryOnly()
            .fade(duration: 0.2)
            .onFailure { _ in }
    }
    
    enum ImageSize {
        case thumbnail  // 100x150
        case card       // 150x225
        case detail     // 300x450
        case hero       // Full width
        
        var cgSize: CGSize {
            switch self {
            case .thumbnail: return CGSize(width: 100, height: 150)
            case .card: return CGSize(width: 150, height: 225)
            case .detail: return CGSize(width: 300, height: 450)
            case .hero: return CGSize(width: UIScreen.main.bounds.width, height: 400)
            }
        }
    }
}

// 2. Lazy section loading for Home
struct LazyMovieSection: View {
    let title: String
    let fetchMovies: () async -> [Movie]
    
    @State private var movies: [Movie] = []
    @State private var hasLoaded = false
    
    var body: some View {
        Group {
            if hasLoaded {
                if movies.isEmpty {
                    EmptyView()
                } else {
                    ContentRow(title: title, movies: movies, onMovieTap: { _ in })
                }
            } else {
                SkeletonMovieRow(title: title)
            }
        }
        .onAppear {
            guard !hasLoaded else { return }
            Task {
                movies = await fetchMovies()
                hasLoaded = true
            }
        }
    }
}

// 3. Memory-efficient swipe queue
actor SwipeQueueManager {
    private var fullQueue: [Int] = []  // Just IDs
    private var loadedMovies: [Int: Movie] = [:]
    private let preloadCount = 5
    
    func preloadAhead(currentIndex: Int, using service: TMDBService) async {
        let idsToLoad = fullQueue
            .dropFirst(currentIndex)
            .prefix(preloadCount)
            .filter { loadedMovies[$0] == nil }
        
        for id in idsToLoad {
            if let movie = try? await service.fetchMovieDetails(id: id) {
                loadedMovies[id] = movie
            }
        }
        
        // Clean up movies we've passed
        let idsToRemove = fullQueue.prefix(max(0, currentIndex - 2))
        for id in idsToRemove {
            loadedMovies.removeValue(forKey: id)
        }
    }
}

// 4. View recycling for grids
struct RecyclingMovieGrid: View {
    let movies: [Movie]
    let onMovieTap: (Movie) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100, maximum: 150))],
                spacing: Spacing.md
            ) {
                ForEach(movies) { movie in
                    MovieGridItem(movie: movie, onTap: { onMovieTap(movie) })
                        .id(movie.id)  // Stable identity for recycling
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }
}
```

---

## 9. Implementation Roadmap

### Phase 1: Foundation Polish (Week 1-2)
**Priority: Critical**

| Task | Effort | Impact |
|------|--------|--------|
| Unify Haptics.swift and HapticManager.swift | Low | High |
| Create Components/Buttons/ with standard styles | Medium | High |
| Implement SwipeStamp overlays | Low | Medium |
| Standardize all section headers | Medium | High |
| Add accessibility labels to all cards | Medium | Critical |

### Phase 2: UX Consistency (Week 3-4)
**Priority: High**

| Task | Effort | Impact |
|------|--------|--------|
| Implement swipe tutorial for first-time users | Medium | High |
| Add search result sorting and filtering | Medium | Medium |
| Implement watchlist multi-select mode | Medium | Medium |
| Add reviews section to movie detail | Medium | Medium |
| Standardize empty states across all screens | Low | Medium |

### Phase 3: Advanced Features (Week 5-6)
**Priority: Medium**

| Task | Effort | Impact |
|------|--------|--------|
| Implement preference learning engine | High | High |
| Add custom collections to watchlist | Medium | Medium |
| Implement collection/franchise display | Medium | Medium |
| Enhanced share functionality with QR codes | Medium | Low |
| Cast/crew navigation and detail views | High | Medium |

### Phase 4: Platform Optimization (Week 7-8)
**Priority: Medium**

| Task | Effort | Impact |
|------|--------|--------|
| iPad split view support | High | Medium |
| Full accessibility audit and fixes | High | Critical |
| Performance optimization pass | Medium | Medium |
| Reduce Motion/Transparency support | Medium | Medium |
| Widget enhancements | Medium | Low |

### Phase 5: Polish & QA (Week 9-10)
**Priority: High**

| Task | Effort | Impact |
|------|--------|--------|
| Animation timing review | Low | Medium |
| Edge case handling | Medium | High |
| Memory profiling and fixes | Medium | Medium |
| Localization preparation | Medium | Medium |
| Final visual polish pass | Low | High |

---

## 10. Code Examples & Patterns

### 10.1 Standard View Structure

```swift
struct FeatureView: View {
    // MARK: - Properties
    @StateObject private var viewModel: FeatureViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Initialization
    init(viewModel: FeatureViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            content
        }
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
        .overlay {
            if let error = viewModel.error {
                ErrorOverlay(error: error, onRetry: viewModel.retry)
            }
        }
        .task {
            await viewModel.load()
        }
    }
    
    // MARK: - Content
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            SkeletonFeatureView()
        case .success:
            successContent
        case .empty:
            StandardEmptyState(
                icon: "film",
                title: "Nothing Here",
                message: "Check back later",
                actionTitle: nil,
                action: nil
            )
        case .error:
            EmptyView()  // Handled by overlay
        }
    }
    
    private var successContent: some View {
        // Main content
    }
    
    private var loadingOverlay: some View {
        SkeletonFeatureView()
            .transition(.opacity)
    }
}
```

### 10.2 ViewModel Pattern

```swift
@MainActor
final class FeatureViewModel: ObservableObject {
    // MARK: - Published State
    @Published private(set) var state: ViewState = .idle
    @Published private(set) var items: [Item] = []
    @Published var error: AppError?
    
    var isLoading: Bool { state == .loading }
    
    // MARK: - Dependencies
    private let service: ServiceProtocol
    
    // MARK: - Initialization
    init(service: ServiceProtocol) {
        self.service = service
    }
    
    // MARK: - Public Methods
    func load() async {
        guard state != .loading else { return }
        state = .loading
        error = nil
        
        do {
            items = try await service.fetchItems()
            state = items.isEmpty ? .empty : .success
        } catch let networkError as NetworkError {
            error = AppError.network(networkError)
            state = .error
        } catch {
            self.error = AppError.unknown(error)
            state = .error
        }
    }
    
    func retry() {
        Task { await load() }
    }
    
    // MARK: - View State
    enum ViewState: Equatable {
        case idle, loading, success, empty, error
    }
}
```

### 10.3 Error Handling Pattern

```swift
// AppError.swift - Enhanced
enum AppError: LocalizedError {
    case network(NetworkError)
    case noContent
    case unauthorized
    case offline
    case rateLimit(retryAfter: TimeInterval)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .network(let error): return error.localizedDescription
        case .noContent: return "No content available"
        case .unauthorized: return "Session expired"
        case .offline: return "You're offline"
        case .rateLimit(let seconds): return "Too many requests. Try again in \(Int(seconds))s"
        case .unknown: return "Something went wrong"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .network: return "Check your connection and try again"
        case .noContent: return "Try a different search"
        case .unauthorized: return "Please restart the app"
        case .offline: return "Connect to the internet to see new content"
        case .rateLimit: return "Please wait before trying again"
        case .unknown: return "Try again later"
        }
    }
    
    var icon: String {
        switch self {
        case .network: return "wifi.exclamationmark"
        case .noContent: return "magnifyingglass"
        case .unauthorized: return "lock.fill"
        case .offline: return "wifi.slash"
        case .rateLimit: return "clock"
        case .unknown: return "exclamationmark.triangle"
        }
    }
    
    var canRetry: Bool {
        switch self {
        case .network, .rateLimit, .unknown: return true
        case .noContent, .unauthorized, .offline: return false
        }
    }
}

// ErrorOverlay.swift
struct ErrorOverlay: View {
    let error: AppError
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.error.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: error.icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.error)
            }
            
            VStack(spacing: Spacing.xs) {
                Text(error.errorDescription ?? "Error")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)
                
                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            HStack(spacing: Spacing.md) {
                if let dismiss = onDismiss {
                    Button("Dismiss", action: dismiss)
                        .buttonStyle(SecondaryButtonStyle())
                }
                
                if error.canRetry, let retry = onRetry {
                    Button("Try Again", action: retry)
                        .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
        .padding(Spacing.xxl)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl))
        .padding(Spacing.horizontal)
    }
}
```

---

## 11. Quality Assurance Checklist

### 11.1 Visual QA

- [ ] All colors match design tokens
- [ ] Typography scale is consistent
- [ ] Spacing follows 4pt grid
- [ ] Corner radii use standard values
- [ ] Shadows use AppTheme presets
- [ ] Glass materials render correctly
- [ ] Gradients display properly on OLED
- [ ] Dark mode is fully supported

### 11.2 Interaction QA

- [ ] All buttons have press feedback
- [ ] Haptics fire at appropriate moments
- [ ] Animations are smooth (60fps)
- [ ] Gestures don't conflict
- [ ] Pull-to-refresh works everywhere needed
- [ ] Swipe-to-delete confirmation
- [ ] Loading states show immediately
- [ ] Error states have recovery actions

### 11.3 Accessibility QA

- [ ] VoiceOver reads all content
- [ ] Dynamic Type scales all text
- [ ] Reduce Motion disables animations
- [ ] Reduce Transparency uses solid backgrounds
- [ ] Color blind safe (no color-only indicators)
- [ ] Minimum touch targets (44pt)
- [ ] Focus order is logical

### 11.4 Performance QA

- [ ] Launch time < 1.5s
- [ ] Scroll jank < 16ms frames
- [ ] Memory stable during browsing
- [ ] No leaked network requests
- [ ] Images prefetch appropriately
- [ ] Offline mode works correctly

### 11.5 Edge Cases

- [ ] Empty search results
- [ ] Network timeout handling
- [ ] Invalid API responses
- [ ] Extremely long titles
- [ ] Missing poster images
- [ ] Corrupt cache recovery
- [ ] Deep link handling

---

## 12. Success Metrics

### 12.1 User Experience Metrics

| Metric | Current Baseline | Target | Measurement |
|--------|-----------------|--------|-------------|
| Time to First Watchlist Add | Unknown | < 2 min | Analytics |
| Swipe Session Duration | Unknown | > 3 min | Analytics |
| Search-to-Save Conversion | Unknown | > 15% | Analytics |
| App Rating | N/A | 4.7+ | App Store |

### 12.2 Technical Metrics

| Metric | Current | Target | Tool |
|--------|---------|--------|------|
| Crash-Free Users | Unknown | > 99.5% | Firebase |
| Cold Launch | ~1.8s | < 1.5s | Instruments |
| Memory Peak | ~180MB | < 150MB | Instruments |
| API Success Rate | Unknown | > 99% | Backend logs |

### 12.3 Accessibility Metrics

| Metric | Current | Target | Tool |
|--------|---------|--------|------|
| VoiceOver Coverage | ~60% | 100% | Manual audit |
| Dynamic Type Support | ~50% | 100% | Manual audit |
| WCAG AA Compliance | Partial | Full | Accessibility Inspector |

---

## Appendix A: File Changes Summary

### New Files to Create

```
Components/
├── Buttons/
│   ├── PrimaryButtonStyle.swift
│   ├── SecondaryButtonStyle.swift
│   ├── GhostButtonStyle.swift
│   └── IconButtonStyle.swift
├── Headers/
│   └── SectionHeader.swift
├── EmptyStates/
│   └── StandardEmptyState.swift
├── Overlays/
│   ├── SwipeStamp.swift
│   └── ErrorOverlay.swift
└── Tutorial/
    └── SwipeTutorialOverlay.swift

Views/
├── Detail/
│   └── ReviewsSection.swift
└── Watchlist/
    ├── MultiSelectToolbar.swift
    └── CreateCollectionSheet.swift
```

### Files to Modify

1. `DesignSystem/Haptics.swift` - Merge with HapticManager
2. `Views/Features/HomeView.swift` - Use SectionHeader component
3. `Views/Features/MovieSwipeView.swift` - Add tutorial overlay
4. `Views/Features/SearchView.swift` - Add sort/filter header
5. `Views/Features/WatchlistView.swift` - Add multi-select
6. `Views/Features/MovieDetailView.swift` - Add reviews section

### Files to Delete

1. `Services/HapticManager.swift` - Merged into Haptics.swift

---

## Appendix B: Design Token Quick Reference

### Colors
```swift
// Backgrounds
.appBackground      // Pure black
.surfacePrimary     // #0F0F0F
.surfaceSecondary   // #1A1A1A
.cardBackground     // #1F1F1F

// Glass
.glassUltraThin     // 3% white
.glassThin          // 6% white
.glassRegular       // 10% white

// Text
.textPrimary        // White
.textSecondary      // 70% white
.textTertiary       // 45% white

// Accent
.accentPrimary      // #0A84FF (Apple Blue)
.accentSecondary    // #BF5AF2 (Purple)
```

### Typography
```swift
.displayXL          // 56pt Bold
.headline1          // 28pt Bold
.headline2          // 24pt Semibold
.bodyLarge          // 17pt Regular
.labelMedium        // 13pt Medium
.caption            // 12pt Regular
```

### Spacing
```swift
Spacing.xs          // 8pt
Spacing.sm          // 12pt
Spacing.md          // 16pt
Spacing.lg          // 20pt
Spacing.xl          // 24pt
Spacing.horizontal  // 20pt (standard edge padding)
```

### Animation
```swift
AppTheme.Animation.snappy     // Buttons
AppTheme.Animation.smooth     // Transitions
AppTheme.Animation.bouncy     // Playful
AppTheme.Animation.cinematic  // Hero reveals
```

---

**Document Maintained By:** Development Team  
**Last Updated:** January 2026  
**Next Review:** After Phase 2 completion
