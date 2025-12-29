# MovieTrailer App - UI/UX Redesign Document
## Apple 2025 Design Language (iOS 26)

---

## Table of Contents
1. [Design Philosophy](#design-philosophy)
2. [Design System](#design-system)
3. [Screen-by-Screen Redesign](#screen-by-screen-redesign)
4. [New Feature: Movie Swipe (Tinder-style)](#new-feature-movie-swipe)
5. [Implementation Priority](#implementation-priority)

---

## Design Philosophy

### Core Principles

**1. Liquid Glass Aesthetic**
- All navigation bars, tab bars, and floating elements use iOS 26's liquid glass material
- Content flows beneath translucent surfaces creating depth
- Subtle blur effects (16-24pt radius) with vibrancy

**2. Breathing Room**
- Generous padding (20-24pt minimum)
- Cards have 16pt internal padding
- Section spacing of 32-40pt
- No cramped layouts

**3. Hierarchy Through Typography**
- Large, bold titles (34pt SF Pro Bold for headers)
- Clear visual hierarchy with 3-4 text sizes max per screen
- Muted secondary text (60% opacity)

**4. Subtle Depth**
- Shadow: 0pt x 8pt blur, 24pt spread, 8% black opacity
- Cards lift on press with spring animation
- Z-axis layering for modals and sheets

**5. Micro-interactions Everywhere**
- Every tap has haptic feedback
- Spring animations (response: 0.35, damping: 0.7)
- Matched geometry transitions between screens
- Pull-to-refresh with custom animation

---

## Design System

### Color Palette

```swift
// Primary Brand Colors
static let accentGradient = LinearGradient(
    colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

// Category Colors
static let categoryNew = Color(hex: "FF6B6B")      // Coral Red
static let categoryClassics = Color(hex: "A78BFA") // Purple
static let categoryTV = Color(hex: "60A5FA")       // Blue
static let categoryAnimation = Color(hex: "34D399") // Green
static let categoryAction = Color(hex: "F59E0B")   // Amber
static let categoryComedy = Color(hex: "EC4899")   // Pink

// Semantic Colors
static let cardBackground = Color(.systemBackground).opacity(0.8)
static let glassBackground = Material.ultraThinMaterial
static let textPrimary = Color(.label)
static let textSecondary = Color(.secondaryLabel)
static let textTertiary = Color(.tertiaryLabel)
```

### Typography Scale

```swift
// Headers
.largeTitle    // 34pt Bold - Screen titles
.title         // 28pt Bold - Section headers
.title2        // 22pt Semibold - Card titles
.title3        // 20pt Semibold - Subsection headers

// Body
.headline      // 17pt Semibold - Emphasized body
.body          // 17pt Regular - Main content
.callout       // 16pt Regular - Secondary content
.subheadline   // 15pt Regular - Metadata

// Detail
.footnote      // 13pt Regular - Captions
.caption       // 12pt Regular - Labels
.caption2      // 11pt Regular - Timestamps
```

### Spacing System

```swift
static let spacing4: CGFloat = 4
static let spacing8: CGFloat = 8
static let spacing12: CGFloat = 12
static let spacing16: CGFloat = 16
static let spacing20: CGFloat = 20
static let spacing24: CGFloat = 24
static let spacing32: CGFloat = 32
static let spacing40: CGFloat = 40
static let spacing48: CGFloat = 48
```

### Card Styles

```swift
// Standard Movie Card
struct MovieCardStyle {
    static let cornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 12
    static let shadowOpacity: Double = 0.1
    static let aspectRatio: CGFloat = 2/3  // Poster ratio
}

// Glass Card
struct GlassCardStyle {
    static let cornerRadius: CGFloat = 20
    static let material: Material = .ultraThinMaterial
    static let strokeWidth: CGFloat = 0.5
    static let strokeOpacity: Double = 0.2
}

// Featured Card (Hero)
struct FeaturedCardStyle {
    static let cornerRadius: CGFloat = 24
    static let height: CGFloat = 420
    static let aspectRatio: CGFloat = 16/9
}
```

---

## Screen-by-Screen Redesign

### 1. Tab Bar (Global)

**Current:** Standard iOS tab bar
**New Design:**
```
┌─────────────────────────────────────────────────┐
│                                                 │
│              [Liquid Glass Bar]                 │
│                                                 │
│   🏠        🎬        🔍        ❤️        👤    │
│  Home     Swipe    Search   Watchlist  Profile │
│                                                 │
└─────────────────────────────────────────────────┘
```

- Floating pill-shaped tab bar with glass effect
- 60pt from bottom edge
- Icons: SF Symbols with fill variant when selected
- Selected state: Icon scales to 1.1x with spring animation
- Haptic: Light impact on tab change

---

### 2. Discover Screen (Home) - MAJOR REDESIGN

**Current Layout:**
- Navigation title "Discover"
- Horizontal scroll sections

**New Layout:**
```
┌─────────────────────────────────────────────────┐
│ [Status Bar]                                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  Good Evening, Movie Lover          [Filter 🎚️] │
│                                                 │
├─────────────────────────────────────────────────┤
│ CATEGORY PILLS (Horizontal Scroll)              │
│ ┌──────┐ ┌─────────┐ ┌──────────┐ ┌──────────┐ │
│ │ All  │ │   New   │ │ Classics │ │ TV Shows │ │
│ └──────┘ └─────────┘ └──────────┘ └──────────┘ │
│ ┌───────────┐ ┌─────────┐ ┌──────────┐        │
│ │ Animation │ │  Action │ │  Comedy  │  ...   │
│ └───────────┘ └─────────┘ └──────────┘        │
├─────────────────────────────────────────────────┤
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │                                             │ │
│ │           HERO FEATURED CARD                │ │
│ │         (Auto-scrolling carousel)           │ │
│ │                                             │ │
│ │  [Poster]     Title of Featured Movie       │ │
│ │               ★ 8.5 · 2025 · Action         │ │
│ │               [Watch Trailer] [+ Watchlist] │ │
│ │                                             │ │
│ └─────────────────────────────────────────────┘ │
│         ○ ○ ● ○ ○  (Page indicators)           │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│ 🔥 Trending This Week                    See All│
│ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐       │
│ │       │ │       │ │       │ │       │       │
│ │ Glass │ │ Glass │ │ Glass │ │ Glass │  -->  │
│ │ Card  │ │ Card  │ │ Card  │ │ Card  │       │
│ │       │ │       │ │       │ │       │       │
│ └───────┘ └───────┘ └───────┘ └───────┘       │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│ ⭐ Top Rated                             See All│
│ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐       │
│ │       │ │       │ │       │ │       │       │
│ │ Glass │ │ Glass │ │ Glass │ │ Glass │  -->  │
│ │ Card  │ │ Card  │ │ Card  │ │ Card  │       │
│ │       │ │       │ │       │ │       │       │
│ └───────┘ └───────┘ └───────┘ └───────┘       │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### Category Pills Design
```swift
struct CategoryPill: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
            Text(title)
                .font(.subheadline.weight(.medium))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? color : Color(.systemGray6))
        )
        .foregroundColor(isSelected ? .white : .primary)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
```

**Categories:**
| Category | Icon | Color |
|----------|------|-------|
| All | sparkles | Gray |
| New | flame.fill | Coral |
| Classics | film.fill | Purple |
| TV Shows | tv.fill | Blue |
| Animation | paintpalette.fill | Green |
| Action | bolt.fill | Amber |
| Comedy | face.smiling.fill | Pink |
| Drama | theatermasks.fill | Indigo |
| Horror | moon.fill | Red |
| Sci-Fi | sparkle | Cyan |

#### Streaming Filter Sheet
```
┌─────────────────────────────────────────────────┐
│ ─────  (Drag indicator)                         │
│                                                 │
│  My Streaming Services                          │
│  Select the platforms you subscribe to          │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🔍 Search services...                   │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  POPULAR                                        │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐  │
│  │Netflix │ │Disney+ │ │  HBO   │ │ Prime  │  │
│  │   ✓    │ │   ✓    │ │        │ │   ✓    │  │
│  └────────┘ └────────┘ └────────┘ └────────┘  │
│                                                 │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐  │
│  │ Apple  │ │  Hulu  │ │Peacock │ │Paramount│  │
│  │  TV+   │ │        │ │        │ │   +    │  │
│  └────────┘ └────────┘ └────────┘ └────────┘  │
│                                                 │
│  FREE WITH ADS                                  │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐  │
│  │  Tubi  │ │ Pluto  │ │ Freevee│ │  Roku  │  │
│  │        │ │   TV   │ │        │ │Channel │  │
│  └────────┘ └────────┘ └────────┘ └────────┘  │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │            Apply Filters (3)             │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### New Glass Movie Card Design
```swift
struct GlassMovieCard: View {
    let movie: Movie
    let isInWatchlist: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Poster with gradient overlay
            ZStack(alignment: .bottomLeading) {
                // Poster Image
                KFImage(movie.posterURL)
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)

                // Bottom gradient for text legibility
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 100)

                // Quick info overlay
                VStack(alignment: .leading, spacing: 4) {
                    // Rating badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text(String(format: "%.1f", movie.voteAverage))
                            .font(.caption.weight(.bold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Title and metadata (outside image)
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .foregroundColor(.primary)

                Text(movie.releaseYear)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)
            .padding(.horizontal, 4)
        }
        .frame(width: 150)
        // Glass card background effect
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }
}
```

---

### 3. Search Screen - POLISH

**New Design:**
```
┌─────────────────────────────────────────────────┐
│ [Status Bar - Glass]                            │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🔍 Search movies, shows, actors...      │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  QUICK FILTERS                                  │
│  ┌────────┐ ┌────────┐ ┌────────┐              │
│  │ Movies │ │TV Shows│ │ People │              │
│  └────────┘ └────────┘ └────────┘              │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  RECENT SEARCHES                     Clear All  │
│  ┌─────────────────────────────────────────┐   │
│  │ 🕐  Inception                        ✕  │   │
│  │ 🕐  Christopher Nolan                ✕  │   │
│  │ 🕐  The Dark Knight                  ✕  │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  TRENDING SEARCHES                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Zootopia │ │  Avatar  │ │ Wednesday│       │
│  └──────────┘ └──────────┘ └──────────┘       │
│                                                 │
└─────────────────────────────────────────────────┘
```

**Search Results Grid:**
```
┌─────────────────────────────────────────────────┐
│  Results for "Inception"              42 found  │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │           │  │           │  │           │  │
│  │  Poster   │  │  Poster   │  │  Poster   │  │
│  │           │  │           │  │           │  │
│  │───────────│  │───────────│  │───────────│  │
│  │ Inception │  │ Inception │  │  Tenet    │  │
│  │ ★ 8.4     │  │ ★ 7.2     │  │ ★ 7.3     │  │
│  └───────────┘  └───────────┘  └───────────┘  │
│                                                 │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐  │
│  │           │  │           │  │           │  │
│  │  Poster   │  │  Poster   │  │  Poster   │  │
│  │           │  │           │  │           │  │
│  └───────────┘  └───────────┘  └───────────┘  │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

### 4. Watchlist Screen - POLISH

**New Design:**
```
┌─────────────────────────────────────────────────┐
│ [Glass Navigation Bar]                          │
│  Watchlist                    [Sort] [Edit]     │
├─────────────────────────────────────────────────┤
│                                                 │
│  STATS BAR                                      │
│  ┌─────────────────────────────────────────┐   │
│  │  12 Movies  •  4 TV Shows  •  ~32 hours │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  🎬 WANT TO WATCH                               │
│  ┌────────────────────────────────────────────┐│
│  │ [Poster] Title of Movie                    ││
│  │          ★ 8.5 · 2h 28m · Action          ││
│  │          Added 2 days ago                  ││
│  │          📺 Netflix, Disney+         [▶️] ││
│  └────────────────────────────────────────────┘│
│                                                 │
│  ┌────────────────────────────────────────────┐│
│  │ [Poster] Another Great Movie               ││
│  │          ★ 7.9 · 1h 55m · Comedy          ││
│  │          Added 1 week ago                  ││
│  │          📺 Prime Video              [▶️] ││
│  └────────────────────────────────────────────┘│
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  ✅ WATCHED                                     │
│  ┌────────────────────────────────────────────┐│
│  │ [Poster] Movie I Already Saw    [Rate ⭐]  ││
│  │          Watched on Dec 15                 ││
│  └────────────────────────────────────────────┘│
│                                                 │
└─────────────────────────────────────────────────┘
```

---

### 5. Movie Detail Screen - POLISH

**New Design:**
```
┌─────────────────────────────────────────────────┐
│ [Backdrop Image - Full Bleed]                   │
│                                                 │
│     ← Back                          [Share]     │
│                                                 │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │                                         │   │
│  │    [Play Trailer Button - Centered]     │   │
│  │              ▶️ 2:34                    │   │
│  │                                         │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│  [Gradient fade to content]                     │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────┐  INCEPTION                           │
│  │Poster│  ★ 8.8 · 2010 · PG-13 · 2h 28m      │
│  │      │                                       │
│  │      │  ┌──────────┐ ┌──────────┐           │
│  └──────┘  │+ Watchlist│ │ Share 📤 │           │
│            └──────────┘ └──────────┘           │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  WHERE TO WATCH                                 │
│  ┌────────────────────────────────────────────┐│
│  │ STREAM      [Netflix] [HBO] [Peacock]      ││
│  │ RENT        [Apple TV] [Prime] [Vudu]      ││
│  │ BUY         [Apple TV] [Prime]             ││
│  └────────────────────────────────────────────┘│
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  STORY                                          │
│  A thief who steals corporate secrets through   │
│  the use of dream-sharing technology is given   │
│  the inverse task of planting an idea...        │
│                                          [More] │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  CAST & CREW                                    │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐          │
│  │ 👤   │ │ 👤   │ │ 👤   │ │ 👤   │    -->   │
│  │ Leo  │ │Joseph│ │Ellen │ │ Tom  │          │
│  └──────┘ └──────┘ └──────┘ └──────┘          │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  MORE LIKE THIS                                 │
│  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐      │
│  │       │ │       │ │       │ │       │      │
│  │ Tenet │ │Interstl│ │Memento│ │Prestige│ --> │
│  │       │ │       │ │       │ │       │      │
│  └───────┘ └───────┘ └───────┘ └───────┘      │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## New Feature: Movie Swipe

### Concept
A Tinder-like interface for discovering movies. Users swipe through full-screen movie cards to quickly build their watchlist and tell the algorithm what they like.

### Screen Layout
```
┌─────────────────────────────────────────────────┐
│ [Status Bar]                                    │
├─────────────────────────────────────────────────┤
│                                                 │
│  Movie Swipe              [Filters] [Undo ↩️]   │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │                                         │   │
│  │                                         │   │
│  │           [MOVIE POSTER]                │   │
│  │           (Full card - draggable)       │   │
│  │                                         │   │
│  │                                         │   │
│  │                                         │   │
│  │  ┌─────────────────────────────────┐   │   │
│  │  │  INCEPTION                      │   │   │
│  │  │  ★ 8.8 · 2010 · Sci-Fi/Action  │   │   │
│  │  │                                 │   │   │
│  │  │  "Your mind is the scene of    │   │   │
│  │  │   the crime"                    │   │   │
│  │  │                                 │   │   │
│  │  │  📺 Netflix · Prime · HBO      │   │   │
│  │  │                                 │   │   │
│  │  │  [▶️ Watch Trailer]            │   │   │
│  │  └─────────────────────────────────┘   │   │
│  │                                         │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│         ← NOPE        INFO        SAVE →        │
│           👎                        💚          │
│                                                 │
│    [Large tap targets for accessibility]        │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Swipe Gestures

| Gesture | Action | Visual Feedback | Haptic |
|---------|--------|-----------------|--------|
| Swipe Right | Add to Watchlist | Green "SAVE" stamp + confetti | Success |
| Swipe Left | Skip / Not Interested | Red "NOPE" stamp | Light |
| Swipe Up | Super Like / Must Watch | Gold "MUST WATCH" stamp | Heavy |
| Swipe Down | Already Watched | Blue "SEEN" stamp | Medium |
| Tap | Expand details | Card flips/expands | Light |
| Long Press | Quick actions menu | Context menu appears | Rigid |

### Card States

**1. Default State**
- Full poster image
- Glass overlay at bottom with info
- Streaming availability badges

**2. Dragging State**
- Card rotates slightly (max 15°)
- Opacity changes based on direction
- Stamp preview appears (NOPE/SAVE)
- Background cards peek from behind

**3. Expanded State (on tap)**
```
┌─────────────────────────────────────────────────┐
│  ← Back                                         │
├─────────────────────────────────────────────────┤
│                                                 │
│  [Backdrop with gradient]                       │
│                                                 │
│  ┌──────┐  INCEPTION                           │
│  │Poster│  ★ 8.8 · 2h 28m · PG-13             │
│  └──────┘                                       │
│                                                 │
│  STORY                                          │
│  A thief who steals corporate secrets...        │
│  [Full synopsis]                                │
│                                                 │
│  TRAILERS                                       │
│  [Horizontal scroll of trailer thumbnails]      │
│                                                 │
│  WHERE TO WATCH                                 │
│  [Streaming platforms grid]                     │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │  👎 SKIP    │    INFO    │    💚 SAVE   │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Algorithm Considerations

The swipe feature should learn user preferences:

```swift
struct SwipePreference {
    let movieId: Int
    let action: SwipeAction
    let timestamp: Date
    let genres: [Int]
    let rating: Double
    let year: Int
}

enum SwipeAction {
    case liked      // Swipe right
    case skipped    // Swipe left
    case superLiked // Swipe up
    case seen       // Swipe down
}
```

**Recommendation factors:**
- Genre preferences (based on likes vs skips)
- Rating threshold (user's average liked rating)
- Era preferences (decades user prefers)
- Runtime preferences
- Streaming availability (prioritize user's services)

### Implementation Components

```swift
// Main Swipe View
struct MovieSwipeView: View {
    @StateObject var viewModel: MovieSwipeViewModel
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Background cards (next 2 in stack)
            ForEach(viewModel.upcomingMovies.prefix(3).reversed()) { movie in
                SwipeCard(movie: movie)
                    .zIndex(zIndex(for: movie))
                    .offset(offset(for: movie))
                    .scaleEffect(scale(for: movie))
            }
        }
        .gesture(dragGesture)
    }
}

// Individual Swipe Card
struct SwipeCard: View {
    let movie: Movie
    @State private var isExpanded = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Poster
            KFImage(movie.posterURL)
                .resizable()
                .aspectRatio(2/3, contentMode: .fill)

            // Glass info overlay
            VStack(alignment: .leading, spacing: 12) {
                // Title & Rating
                HStack {
                    Text(movie.title)
                        .font(.title2.bold())
                    Spacer()
                    RatingBadge(rating: movie.voteAverage)
                }

                // Metadata
                Text("\(movie.releaseYear) · \(movie.genreNames)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Streaming badges
                StreamingBadges(providers: movie.watchProviders)

                // Watch trailer button
                Button("Watch Trailer") {
                    // Play trailer
                }
                .buttonStyle(.bordered)
            }
            .padding(20)
            .background(.ultraThinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 20)
        .onTapGesture { isExpanded = true }
    }
}
```

---

## Implementation Priority

### Phase 1: Foundation (Week 1)
1. ✅ Create Design System (colors, typography, spacing)
2. ✅ Implement Glass Card component
3. ✅ Update Tab Bar with liquid glass
4. ✅ Polish existing cards with new design

### Phase 2: Discover Redesign (Week 2)
1. ⬜ Add Category pills component
2. ⬜ Implement Hero carousel
3. ⬜ Create Streaming Filter sheet
4. ⬜ Add user streaming preferences storage
5. ⬜ Filter movies by streaming availability

### Phase 3: Movie Swipe Feature (Week 3)
1. ⬜ Create SwipeCard component
2. ⬜ Implement drag gesture handling
3. ⬜ Add swipe animations & stamps
4. ⬜ Create expanded card view
5. ⬜ Implement undo functionality
6. ⬜ Add preference learning algorithm

### Phase 4: Polish & Details (Week 4)
1. ⬜ Add micro-interactions everywhere
2. ⬜ Implement haptic feedback system
3. ⬜ Add skeleton loading states
4. ⬜ Polish transitions between screens
5. ⬜ Accessibility audit & fixes
6. ⬜ Performance optimization

---

## Animation Specifications

### Spring Animations
```swift
// Standard spring for UI elements
.spring(response: 0.35, dampingFraction: 0.7)

// Bouncy spring for playful elements
.spring(response: 0.4, dampingFraction: 0.6)

// Stiff spring for quick responses
.spring(response: 0.25, dampingFraction: 0.8)
```

### Haptic Patterns
```swift
enum HapticPattern {
    case tabSwitch      // UIImpactFeedbackGenerator(.light)
    case cardTap        // UIImpactFeedbackGenerator(.medium)
    case swipeComplete  // UINotificationFeedbackGenerator(.success)
    case swipeReject    // UIImpactFeedbackGenerator(.rigid)
    case pullRefresh    // UIImpactFeedbackGenerator(.soft)
    case longPress      // UIImpactFeedbackGenerator(.heavy)
}
```

### Transition Types
```swift
// Card to Detail
.matchedGeometryEffect(id: movie.id, in: namespace)

// Sheet presentation
.sheet(isPresented: $showSheet) {
    content
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(24)
}

// Navigation
.navigationTransition(.zoom(sourceID: movie.id, in: namespace))
```

---

## File Structure for New Components

```
MovieTrailer/
├── DesignSystem/
│   ├── Theme.swift
│   ├── Colors.swift
│   ├── Typography.swift
│   ├── Spacing.swift
│   └── Haptics.swift
│
├── Components/
│   ├── Cards/
│   │   ├── GlassMovieCard.swift
│   │   ├── FeaturedCard.swift
│   │   ├── SwipeCard.swift
│   │   └── WatchlistCard.swift
│   ├── Pills/
│   │   ├── CategoryPill.swift
│   │   └── StreamingBadge.swift
│   ├── Buttons/
│   │   ├── GlassButton.swift
│   │   └── IconButton.swift
│   └── Overlays/
│       ├── SwipeStamp.swift
│       └── LoadingOverlay.swift
│
├── Features/
│   ├── Discover/
│   │   ├── DiscoverView.swift
│   │   ├── CategoryScrollView.swift
│   │   ├── HeroCarousel.swift
│   │   └── StreamingFilterSheet.swift
│   ├── MovieSwipe/
│   │   ├── MovieSwipeView.swift
│   │   ├── MovieSwipeViewModel.swift
│   │   ├── SwipeCardStack.swift
│   │   └── SwipePreferenceManager.swift
│   └── ...
```

---

## Success Metrics

After implementation, measure:

1. **Engagement**
   - Time spent in app
   - Movies swiped per session
   - Watchlist additions

2. **Conversion**
   - Swipe to watchlist ratio
   - Trailer views from swipe
   - External streaming link clicks

3. **Retention**
   - Daily active users
   - Return visits
   - Feature adoption (% using swipe)

---

*Document Version: 1.0*
*Last Updated: December 28, 2025*
*Author: Claude Code*
