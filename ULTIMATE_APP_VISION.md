# MovieTrailer: Ultimate Vision Document
## Transforming into the Premier Movie & TV Discovery Platform

**Date**: December 2025
**Goal**: Create the most beautiful, intuitive, and comprehensive entertainment discovery app - designed as if Apple themselves built it.

---

# Table of Contents

1. [Executive Vision](#executive-vision)
2. [Design Philosophy](#design-philosophy)
3. [UI/UX Complete Overhaul](#uiux-complete-overhaul)
4. [Feature Roadmap](#feature-roadmap)
5. [Screen-by-Screen Redesign](#screen-by-screen-redesign)
6. [Animation & Motion Design](#animation--motion-design)
7. [The Ultimate Swipe Experience](#the-ultimate-swipe-experience)
8. [Comprehensive Filter System](#comprehensive-filter-system)
9. [Trailer Experience](#trailer-experience)
10. [Library & Collections](#library--collections)
11. [Technical Architecture](#technical-architecture)
12. [Implementation Priority](#implementation-priority)

---

# Executive Vision

## The Problem We're Solving

People spend an average of **23 minutes** deciding what to watch. With content fragmented across 8+ streaming services, theatrical releases, and endless catalogs, decision paralysis is real. Current solutions (Netflix browse, Google search, Rotten Tomatoes) are fragmented, ugly, or overwhelming.

## Our Solution

**MovieTrailer** becomes the single source of truth for entertainment discovery:

- **One app** to rule all streaming services, theaters, and content
- **Intelligent swiping** that learns your taste in seconds
- **Beautiful design** that makes browsing a pleasure, not a chore
- **Instant trailers** to help you decide in 30 seconds
- **Smart filters** that surface exactly what you want
- **Personal library** that syncs your watchlist everywhere

## Target User

> *"I want to find something great to watch tonight without spending 30 minutes scrolling through Netflix. Show me trailers, tell me where it's streaming, and save it if I'm interested."*

---

# Design Philosophy

## Apple's 2025 Design Language

We're adopting Apple's latest design principles from visionOS, iOS 18, and Apple TV+:

### 1. **Spatial Depth**
- Multi-layered interfaces with clear visual hierarchy
- Depth through shadows, blur, and parallax
- Elements feel like they exist in 3D space

### 2. **Fluid Glass Morphism**
- Ultra-thin materials with variable blur
- Subtle gradients that respond to content
- Transparent surfaces that reveal hierarchy

### 3. **Dynamic Typography**
- SF Pro with variable font weights
- Responsive text that scales gracefully
- Clear hierarchy through size and weight alone

### 4. **Meaningful Motion**
- Physics-based animations (springs, not linear)
- Continuous gesture-driven interactions
- Micro-animations that provide feedback

### 5. **Adaptive Color**
- Content-aware backgrounds that extract poster colors
- Subtle ambient lighting effects
- Dark mode first with OLED optimization

### 6. **Spacious Layouts**
- Generous whitespace (actually "dark space")
- Breathing room between elements
- Focus on one thing at a time

---

# UI/UX Complete Overhaul

## Current State Analysis

### What's Working
- Basic swipe mechanics exist
- TMDB integration is solid
- Architecture is clean (MVVM + Coordinators)
- Watchlist persistence works

### What Needs Transformation

| Area | Current State | Target State |
|------|---------------|--------------|
| Visual Design | Basic dark theme | Premium Apple aesthetic |
| Swipe Experience | Functional but plain | Delightful & addictive |
| Home Screen | Simple list | Cinematic discovery |
| Filters | Almost none | Comprehensive system |
| Trailers | Hidden in detail view | Front and center |
| Library | Basic list | Smart collections |
| Animations | Minimal | Fluid & purposeful |
| Onboarding | None | Personalized setup |

---

## The New Design System

### Color Palette 2025

```swift
// Primary Backgrounds
static let background = Color.black // True black for OLED
static let surfacePrimary = Color(white: 0.08) // #141414
static let surfaceSecondary = Color(white: 0.12) // #1F1F1F
static let surfaceTertiary = Color(white: 0.16) // #292929

// Glass Materials
static let glassUltraThin = Color.white.opacity(0.03)
static let glassThin = Color.white.opacity(0.06)
static let glassRegular = Color.white.opacity(0.10)
static let glassThick = Color.white.opacity(0.15)

// Text Hierarchy
static let textPrimary = Color.white
static let textSecondary = Color(white: 0.70)
static let textTertiary = Color(white: 0.45)
static let textQuaternary = Color(white: 0.30)

// Accent Colors (Vibrant, Apple-style)
static let accentBlue = Color(red: 0.04, green: 0.52, blue: 1.0) // #0A84FF
static let accentPurple = Color(red: 0.75, green: 0.35, blue: 0.95) // #BF5AF2
static let accentPink = Color(red: 1.0, green: 0.27, blue: 0.53) // #FF4588
static let accentOrange = Color(red: 1.0, green: 0.62, blue: 0.04) // #FF9F0A
static let accentGreen = Color(red: 0.20, green: 0.84, blue: 0.29) // #34D349
static let accentRed = Color(red: 1.0, green: 0.27, blue: 0.23) // #FF453A

// Swipe Actions (More Vibrant)
static let swipeLove = Color(red: 1.0, green: 0.27, blue: 0.53) // Hot Pink
static let swipeSkip = Color(white: 0.35) // Neutral Gray
static let swipeWatchLater = Color(red: 0.04, green: 0.52, blue: 1.0) // Blue
static let swipeSuperLike = Color(red: 0.95, green: 0.80, blue: 0.0) // Gold

// Streaming Service Colors (Official Brand Colors)
static let netflix = Color(red: 0.90, green: 0.12, blue: 0.15)
static let disneyPlus = Color(red: 0.02, green: 0.31, blue: 0.78)
static let primeVideo = Color(red: 0.0, green: 0.66, blue: 0.88)
static let hboMax = Color(red: 0.60, green: 0.30, blue: 0.90)
static let appleTVPlus = Color(white: 0.90)
static let hulu = Color(red: 0.12, green: 0.82, blue: 0.42)
static let peacock = Color(red: 0.0, green: 0.0, blue: 0.0) // Multi-color gradient
static let paramount = Color(red: 0.0, green: 0.40, blue: 0.90)
```

### Typography Scale

```swift
// Display (Hero Headlines)
static let displayXL = Font.system(size: 56, weight: .bold, design: .default)
static let displayLarge = Font.system(size: 44, weight: .bold, design: .default)
static let displayMedium = Font.system(size: 34, weight: .bold, design: .default)

// Headlines
static let headline1 = Font.system(size: 28, weight: .bold, design: .default)
static let headline2 = Font.system(size: 24, weight: .semibold, design: .default)
static let headline3 = Font.system(size: 20, weight: .semibold, design: .default)

// Body
static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

// Labels
static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)
static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)
static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

// Specialized
static let caption = Font.system(size: 12, weight: .regular, design: .default)
static let overline = Font.system(size: 10, weight: .semibold, design: .default).uppercaseSmallCaps()
static let mono = Font.system(size: 14, weight: .medium, design: .monospaced)
```

### Spacing System

```swift
// Base unit: 4pt
static let space1 = 4.0   // Minimal
static let space2 = 8.0   // Tight
static let space3 = 12.0  // Compact
static let space4 = 16.0  // Standard
static let space5 = 20.0  // Comfortable
static let space6 = 24.0  // Relaxed
static let space7 = 32.0  // Loose
static let space8 = 40.0  // Spacious
static let space9 = 48.0  // Airy
static let space10 = 64.0 // Expansive

// Semantic Spacing
static let contentPadding = 20.0
static let sectionSpacing = 32.0
static let cardPadding = 16.0
static let listItemSpacing = 12.0
static let inlineSpacing = 8.0
```

### Corner Radius System

```swift
static let radiusSmall = 8.0    // Buttons, tags
static let radiusMedium = 12.0  // Cards, inputs
static let radiusLarge = 16.0   // Posters
static let radiusXL = 20.0      // Feature cards
static let radiusXXL = 28.0     // Sheets
static let radiusFull = 999.0   // Pills, avatars
```

### Shadow System

```swift
// Elevation Levels
static let shadowSubtle = Shadow(color: .black.opacity(0.15), radius: 4, y: 2)
static let shadowMedium = Shadow(color: .black.opacity(0.25), radius: 8, y: 4)
static let shadowStrong = Shadow(color: .black.opacity(0.35), radius: 16, y: 8)
static let shadowHero = Shadow(color: .black.opacity(0.5), radius: 32, y: 16)

// Colored Shadows (for vibrancy)
static func glowShadow(_ color: Color) -> Shadow {
    Shadow(color: color.opacity(0.4), radius: 20, y: 0)
}
```

---

# Screen-by-Screen Redesign

## 1. Home Screen - "Discover"

### Current Issues
- Generic "Home" doesn't convey purpose
- Hero carousel is basic
- Content rows lack variety
- No personalization visible
- Limited content types

### New Design: Cinematic Discovery Hub

```
┌─────────────────────────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│ ▓                                                 ▓ │
│ ▓              [HERO POSTER IMAGE]                ▓ │
│ ▓                  Full Width                     ▓ │
│ ▓                   480pt                         ▓ │
│ ▓                                                 ▓ │
│ ▓  ┌─────────────────────────────────────────┐   ▓ │
│ ▓  │  DUNE: PART THREE                       │   ▓ │
│ ▓  │  ★ 8.9  •  2025  •  Sci-Fi, Adventure   │   ▓ │
│ ▓  │                                         │   ▓ │
│ ▓  │  [▶ Watch Trailer]  [+ My List]        │   ▓ │
│ ▓  └─────────────────────────────────────────┘   ▓ │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│                    • ○ ○ ○ ○                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  🎬 In Theaters Now          [See All →]           │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐               │
│  │    │ │    │ │    │ │    │ │    │               │
│  │    │ │    │ │    │ │    │ │    │               │
│  │    │ │    │ │    │ │    │ │    │               │
│  └────┘ └────┘ └────┘ └────┘ └────┘               │
│  Gladiat  Wicked  Moana2  Sonic3  Mufasa          │
│  ─────────────────────────────────────→           │
│                                                     │
│  📺 New on Your Services     [Filters ▼]           │
│  ┌────────────────────────────────────────┐       │
│  │ [Netflix] [Disney+] [HBO] [Prime] [+3] │       │
│  └────────────────────────────────────────┘       │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐               │
│  │ N  │ │ D+ │ │ HBO│ │ P  │ │ N  │               │
│  └────┘ └────┘ └────┘ └────┘ └────┘               │
│                                                     │
│  🔥 Trending This Week                             │
│  ┌───────────────────────────────────────────┐    │
│  │  1  [Large Featured Card - #1 Trending]   │    │
│  │     Squid Game Season 3                   │    │
│  │     ★ 8.7  •  Netflix  •  Drama, Thriller │    │
│  └───────────────────────────────────────────┘    │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                      │
│  │ 2  │ │ 3  │ │ 4  │ │ 5  │                      │
│  └────┘ └────┘ └────┘ └────┘                      │
│                                                     │
│  📺 Continue Your Series                           │
│  [Shows you've started watching]                   │
│                                                     │
│  🎭 Because You Liked "Oppenheimer"               │
│  [Personalized recommendations]                    │
│                                                     │
│  🏆 Award Winners & Nominees                       │
│  [Oscar, Emmy, Golden Globe content]               │
│                                                     │
│  🌙 Perfect for Tonight                           │
│  [< 2 hours, highly rated, on your services]      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Hero Carousel Features

1. **Full-Bleed Backdrop Images**
   - Edge-to-edge imagery with gradient overlay
   - Subtle parallax on scroll
   - Auto-advances every 6 seconds (pauses on touch)

2. **Content Overlay**
   - Title in Display font
   - Metadata row: Rating, Year, Genres
   - Two primary actions: Watch Trailer, Add to List
   - Streaming service badge showing where to watch

3. **Pagination Dots**
   - Current dot enlarged and filled
   - Tap to jump to specific slide
   - Horizontal swipe to navigate

4. **Hero Interactions**
   - Tap anywhere to open full detail
   - Long-press for Quick Look preview
   - 3D Touch for peek/pop (on supported devices)

### Content Row Types

1. **Standard Poster Row**
   - Horizontal scroll
   - 120pt wide posters
   - Title + rating below
   - Streaming service badge overlay

2. **Large Feature Row**
   - Landscape cards (16:9 ratio)
   - Full backdrop image
   - Overlay with title, rating, service
   - Great for "New This Week"

3. **Top 10 Row**
   - Large ranking numbers (1-10)
   - Posters offset behind numbers
   - Trophy icon for #1
   - Weekly change indicator (↑3, ↓2, NEW)

4. **Theater Row**
   - Movie poster + showtime pills
   - Distance to nearest theater
   - "Playing near you" context
   - Buy tickets CTA

5. **Continue Watching Row**
   - Progress bar on poster
   - "X episodes left" label
   - Resume button overlay
   - Aired date for new episodes

6. **Person Row**
   - Circular actor/director photos
   - Name below
   - "X movies" count
   - For cast browsing

### Section Headers

```
┌─────────────────────────────────────────────────────┐
│  🎬 In Theaters Now                    [See All →] │
└─────────────────────────────────────────────────────┘
```

- Emoji prefix for visual recognition
- Bold section title
- "See All" links to filtered view
- Optional filter chips below header

---

## 2. Swipe Screen - "Tonight"

### Current Issues
- Cards look basic and flat
- Swipe feedback is minimal
- No filter options visible
- Stats are hidden
- No undo visibility
- Queue status unclear

### New Design: Premium Swipe Experience

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Tonight                      [🎯] [⚙️ Filters]    │
│                                                     │
│  "Finding your next favorite"                       │
│  ████████████░░░░░░░░░░░  12 of 50 remaining       │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│         ┌─────────────────────────────┐            │
│         │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│            │
│         │▓                         ▓│            │
│         │▓                         ▓│            │
│         │▓      MOVIE POSTER       ▓│            │
│         │▓                         ▓│            │
│         │▓         420pt           ▓│            │
│         │▓                         ▓│            │
│         │▓                         ▓│            │
│         │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│            │
│         │                           │            │
│         │  MOVIE TITLE              │            │
│         │  ★ 8.5  •  2024  •  2h 15m│            │
│         │  Action, Sci-Fi           │            │
│         │                           │            │
│         │  [Netflix] [Prime Video]  │            │
│         │                           │            │
│         │  [▶ Quick Trailer]        │            │
│         │                           │            │
│         └─────────────────────────────┘            │
│                    ↑                               │
│              [Next card visible                    │
│               behind, scaled 0.95]                 │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│     [↩️]      [✕]      [▶]      [♥]      [i]      │
│     Undo     Skip   Trailer    Love    Details    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Card Design Specifications

1. **Card Container**
   - 340pt width, dynamic height
   - 20pt corner radius
   - Subtle shadow (shadowStrong)
   - Glass border (1pt white @ 10%)

2. **Poster Area**
   - 2:3 aspect ratio (340 x 510)
   - High-quality image (w780 from TMDB)
   - Subtle vignette overlay at bottom
   - Streaming badge top-right

3. **Info Area**
   - Semi-transparent glass background
   - Title: headline2 weight
   - Metadata row with bullet separators
   - Genre pills (scrollable if many)
   - Streaming service icons

4. **Quick Trailer Button**
   - Centered below metadata
   - Glass background with play icon
   - Tapping shows 30-sec preview inline

### Swipe Mechanics

```
         WATCH LATER
              ↑
              |
    SKIP ←----●----→ LOVE
              |
              ↓
         (cancel)
```

1. **Directional Thresholds**
   - Horizontal: 120pt to trigger
   - Vertical (up): 100pt to trigger
   - Below threshold: Rubber-band return

2. **Visual Feedback During Drag**

   ```
   Swiping RIGHT (Love):
   - Card tints pink/red gradient
   - Heart icon scales up in corner
   - "LOVE" text fades in
   - Haptic: Light impact

   Swiping LEFT (Skip):
   - Card tints gray
   - X icon appears in corner
   - "SKIP" text fades in
   - Haptic: Light impact

   Swiping UP (Watch Later):
   - Card tints blue
   - Bookmark icon appears
   - "WATCH LATER" text fades in
   - Haptic: Medium impact
   ```

3. **Release Animations**

   ```swift
   // Love swipe
   withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
       offset.x = 500
       rotation = 15
       scale = 0.9
   }
   // Confetti burst from card center

   // Skip swipe
   withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
       offset.x = -500
       rotation = -10
       opacity = 0
   }

   // Watch Later swipe
   withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
       offset.y = -600
       scale = 0.8
   }
   // Checkmark animation overlay
   ```

### Action Bar Design

```
┌────────────────────────────────────────────────────┐
│                                                    │
│   ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌────┐ │
│   │  ↩️  │  │  ✕   │  │  ▶   │  │  ♥   │  │ i  │ │
│   │      │  │      │  │      │  │      │  │    │ │
│   │ 44pt │  │ 56pt │  │ 56pt │  │ 56pt │  │44pt│ │
│   └──────┘  └──────┘  └──────┘  └──────┘  └────┘ │
│    Undo      Skip    Trailer    Love     Info    │
│                                                    │
└────────────────────────────────────────────────────┘
```

- **Undo**: Smaller, secondary - brings back last card
- **Skip**: Large circle, gray background
- **Trailer**: Large circle, accent blue, play icon
- **Love**: Large circle, pink/red gradient, heart
- **Info**: Smaller - opens detail sheet

Button Press Animation:
```swift
.scaleEffect(isPressed ? 0.92 : 1.0)
.animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
```

### Filter Quick Access

Top-right filter button opens bottom sheet:

```
┌─────────────────────────────────────────────────────┐
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                 │ ← drag indicator
│                                                     │
│  Swipe Filters                      [Reset All]    │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  Content Type                                       │
│  [● Movies] [○ TV Shows] [○ Both]                  │
│                                                     │
│  Streaming Services                                 │
│  [✓ Netflix] [✓ Disney+] [□ HBO] [□ Prime]        │
│  [□ Apple TV+] [□ Hulu] [□ Peacock] [□ Para+]     │
│                                                     │
│  Genres (select multiple)                          │
│  [✓ Action] [□ Comedy] [✓ Thriller] [□ Drama]    │
│  [□ Sci-Fi] [□ Horror] [□ Romance] [□ Anim...]   │
│                                                     │
│  Release Year                                       │
│  [2020 ●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━● 2025]       │
│                                                     │
│  Minimum Rating                                     │
│  [★★★★★★☆☆☆☆] 6.0+                               │
│                                                     │
│  Runtime                                            │
│  [○ Any] [● < 2 hrs] [○ < 90 min]                 │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  [        Apply Filters (24 matches)        ]      │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Stats & Progress

Tapping the target icon (🎯) shows stats sheet:

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Your Swipe Stats                                  │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │                                             │   │
│  │    127        43         84                │   │
│  │   SWIPED    LOVED     SKIPPED              │   │
│  │                                             │   │
│  │          33.8% Match Rate                  │   │
│  │          ████████░░░░░░░░░░░               │   │
│  │                                             │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  Your Taste Profile                                │
│                                                     │
│  Top Genres You Love:                              │
│  1. Sci-Fi (78% liked)                            │
│  2. Thriller (65% liked)                          │
│  3. Action (54% liked)                            │
│                                                     │
│  Genres You Skip:                                  │
│  • Horror (85% skipped)                           │
│  • Romance (72% skipped)                          │
│                                                     │
│  Average Rating of Liked: ★ 7.8                   │
│  Preferred Runtime: 90-120 minutes                │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 3. Search Screen

### Current Issues
- Basic search bar
- No advanced filters
- Results are plain grid
- No voice search
- No trending searches

### New Design: Intelligent Search Hub

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Search                                            │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ 🔍 Movies, shows, actors, directors...  🎤 │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  [🎬 Movies] [📺 TV] [🎭 People] [🏢 Studios]     │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  🔥 Trending Searches                              │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐               │
│  │ Gladiator 2  │  │ Wicked       │               │
│  └──────────────┘  └──────────────┘               │
│  ┌──────────────┐  ┌──────────────┐               │
│  │ Squid Game 3 │  │ Dune 3       │               │
│  └──────────────┘  └──────────────┘               │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  🎭 Browse by Genre                                │
│                                                     │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐       │
│  │ 🎬 │ │ 😂 │ │ 😱 │ │ 💕 │ │ 🚀 │ │ 🎭 │       │
│  │Act │ │Com │ │Hor │ │Rom │ │ScFi│ │Dra │       │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘       │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  📺 Browse by Service                              │
│                                                     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐              │
│  │ NETFLIX │ │ DISNEY+ │ │ HBO MAX │              │
│  └─────────┘ └─────────┘ └─────────┘              │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐              │
│  │ PRIME   │ │ APPLE   │ │ HULU    │              │
│  └─────────┘ └─────────┘ └─────────┘              │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  🕐 Recent Searches                                │
│                                                     │
│  Christopher Nolan                          [✕]    │
│  Best horror movies 2024                    [✕]    │
│  Timothée Chalamet                          [✕]    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Search Results View

When user starts typing:

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ 🔍 interstellar                          ✕ │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  [🎬 All] [📺 TV] [🎭 People] [⚙️ Filters]        │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Top Result                                        │
│  ┌─────────────────────────────────────────────┐   │
│  │ ┌─────┐                                     │   │
│  │ │     │  Interstellar                       │   │
│  │ │     │  ★ 8.6  •  2014  •  2h 49m         │   │
│  │ │     │  Sci-Fi, Drama, Adventure          │   │
│  │ │     │                                     │   │
│  │ │     │  [▶ Trailer] [+ Add]               │   │
│  │ └─────┘                                     │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  Related Movies                                    │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                      │
│  │    │ │    │ │    │ │    │                      │
│  │    │ │    │ │    │ │    │                      │
│  └────┘ └────┘ └────┘ └────┘                      │
│  Inception  Tenet   Gravity  Arrival              │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  All Results (23)                                  │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐       │
│  │    │ │    │ │    │ │    │ │    │ │    │       │
│  │    │ │    │ │    │ │    │ │    │ │    │       │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Search Features

1. **Smart Suggestions**
   - Auto-complete as you type
   - Show matching titles, people, genres
   - Keyboard suggestions

2. **Voice Search**
   - Tap microphone icon
   - Speech-to-text search
   - "Find action movies from 2023"

3. **Filter Chips**
   - Quick toggles for content type
   - Full filter sheet access
   - Active filters shown as chips

4. **Results Layout**
   - Top Result: Large featured card
   - Related: Horizontal scroll
   - All Results: 3-column grid

---

## 4. Library Screen - "My List"

### Current Issues
- Basic list view
- No organization options
- No collections/folders
- Limited sorting
- No watch progress

### New Design: Smart Collections Library

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  My Library                              [Edit]    │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ 🔍 Search your library...                   │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Quick Stats                                       │
│  ┌──────────┬──────────┬──────────┐               │
│  │    47    │    12    │    8     │               │
│  │  Movies  │ TV Shows │ Watched  │               │
│  └──────────┴──────────┴──────────┘               │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  📁 Collections                      [+ Create]    │
│                                                     │
│  ┌────────────────────┐ ┌────────────────────┐    │
│  │  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │ │  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │    │
│  │  Watch Tonight     │ │  Date Night       │    │
│  │  5 items           │ │  12 items         │    │
│  └────────────────────┘ └────────────────────┘    │
│  ┌────────────────────┐ ┌────────────────────┐    │
│  │  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │ │  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │    │
│  │  Must-See Classics │ │  + New Collection │    │
│  │  8 items           │ │                    │    │
│  └────────────────────┘ └────────────────────┘    │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  📺 Continue Watching                              │
│  ┌─────────────────────────────────────────────┐   │
│  │ ┌─────┐                                     │   │
│  │ │ S2  │  Severance                          │   │
│  │ │ E3  │  S2 E3 • 4 episodes left           │   │
│  │ │▓▓▓░░│  ███████████░░░░░ 67%              │   │
│  │ └─────┘                                     │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  🎬 All Saved Items             [Sort: Recent ▼]  │
│                                                     │
│  [🎬 Movies (35)] [📺 TV (12)] [✓ Watched (8)]   │
│                                                     │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐       │
│  │    │ │    │ │    │ │    │ │    │ │    │       │
│  │    │ │    │ │    │ │    │ │    │ │    │       │
│  │    │ │    │ │    │ │    │ │    │ │    │       │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Library Features

1. **Smart Collections**
   - Auto-generated: "Watch Tonight", "New Releases in List", "Leaving Soon"
   - User-created collections with custom covers
   - Drag-and-drop organization

2. **Watch Progress Tracking**
   - Mark as watched/unwatched
   - Episode progress for TV
   - Completion statistics

3. **Sort & Filter Options**
   - Sort: Date added, Title, Rating, Release, Runtime
   - Filter: Movies/TV, Genre, Service, Watched status

4. **List Actions**
   - Swipe to delete
   - Long-press for options
   - Multi-select for bulk actions
   - Share collection as list

---

## 5. Movie Detail Screen

### Current Issues
- Standard detail layout
- Trailer not prominent
- Streaming info buried
- No social features

### New Design: Immersive Detail Experience

```
┌─────────────────────────────────────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
│▓                                                  ▓│
│▓              [BACKDROP IMAGE]                    ▓│
│▓                  Full bleed                      ▓│
│▓                   300pt                          ▓│
│▓                                                  ▓│
│▓         [▶ WATCH TRAILER - 2:34]                ▓│
│▓                                                  ▓│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
│                                                     │
│  INTERSTELLAR                                      │
│  ★ 8.6  •  2014  •  PG-13  •  2h 49m              │
│                                                     │
│  [Sci-Fi] [Drama] [Adventure]                      │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ [▶ Watch Now]        [+ My List] [↗ Share] │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  Where to Watch                                    │
│  ┌───────────────────────────────────────────┐    │
│  │ Stream                                     │    │
│  │ [Paramount+] [Prime Video]                │    │
│  │                                           │    │
│  │ Rent from $3.99                           │    │
│  │ [Apple TV] [Prime] [Vudu] [Google]       │    │
│  │                                           │    │
│  │ Buy from $14.99                           │    │
│  │ [Apple TV] [Prime] [Vudu]                │    │
│  └───────────────────────────────────────────┘    │
│                                                     │
│  Overview                                          │
│  The adventures of a group of explorers who       │
│  make use of a newly discovered wormhole to       │
│  surpass the limitations on human space travel    │
│  and conquer the vast distances involved in       │
│  an interstellar voyage...              [More]    │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  Cast & Crew                                       │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐              │
│  │ 👤 │ │ 👤 │ │ 👤 │ │ 👤 │ │ 👤 │              │
│  │Matt│ │Anne│ │Jess│ │Mich│ │Casey│             │
│  │ hew│ │ way│ │ica │ │ael │ │     │             │
│  └────┘ └────┘ └────┘ └────┘ └────┘              │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  Videos & Trailers                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌──────────┐    │
│  │ ▶ Trailer  │ │ ▶ Teaser   │ │ ▶ Behind │    │
│  │   2:34     │ │   1:45     │ │   5:23   │    │
│  └─────────────┘ └─────────────┘ └──────────┘    │
│                                                     │
│  ─────────────────────────────────────────────────  │
│                                                     │
│  More Like This                                    │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐       │
│  │    │ │    │ │    │ │    │ │    │ │    │       │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘       │
│                                                     │
│  From Christopher Nolan                            │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐       │
│  │    │ │    │ │    │ │    │ │    │ │    │       │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Detail View Features

1. **Hero Trailer Section**
   - Backdrop with play button overlay
   - Tap to play inline or full-screen
   - Shows trailer duration
   - Auto-plays preview on scroll (optional)

2. **Watch Now Integration**
   - Primary CTA to best streaming option
   - Shows cheapest rent/buy options
   - Deep links to streaming apps
   - "JustWatch" style comparison

3. **Interactive Elements**
   - Add to list with collection picker
   - Share with rich preview
   - Rate the movie (affects recommendations)

4. **Rich Content**
   - Cast with tap to see filmography
   - Multiple trailers/teasers/featurettes
   - Reviews from critics
   - Awards and nominations

---

# Animation & Motion Design

## Core Animation Principles

1. **Physics-Based**: Everything uses springs, never linear
2. **Purposeful**: Animation communicates state changes
3. **Interruptible**: Animations can be cancelled mid-flight
4. **Consistent**: Same actions = same animations

## Animation Specifications

### Navigation Transitions

```swift
// Tab switching
withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
    selectedTab = newTab
}

// Sheet presentation
.sheet(isPresented: $showDetail) {
    DetailView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
}

// Full screen cover
.fullScreenCover(isPresented: $showTrailer) {
    TrailerPlayerView()
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
}
```

### Card Interactions

```swift
// Card press
.scaleEffect(isPressed ? 0.96 : 1.0)
.animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)

// Card hover (iPad/Mac)
.scaleEffect(isHovered ? 1.03 : 1.0)
.shadow(radius: isHovered ? 16 : 8)
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)

// Card selection
.overlay {
    RoundedRectangle(cornerRadius: 16)
        .stroke(Color.accentBlue, lineWidth: isSelected ? 3 : 0)
}
.animation(.spring(response: 0.25, dampingFraction: 0.8), value: isSelected)
```

### Swipe Card Physics

```swift
// Drag gesture
.offset(x: dragOffset.width, y: dragOffset.height)
.rotationEffect(.degrees(Double(dragOffset.width / 20)))
.scaleEffect(1 - abs(dragOffset.height) / 2000)

// Return to center
.animation(.spring(response: 0.4, dampingFraction: 0.65), value: dragOffset)

// Exit animation
.animation(.spring(response: 0.5, dampingFraction: 0.7)) {
    offset = CGSize(width: direction == .right ? 500 : -500, height: 0)
    opacity = 0
}
```

### List Animations

```swift
// Staggered appearance
ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
    ItemRow(item: item)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .offset(y: 20)),
            removal: .opacity
        ))
        .animation(
            .spring(response: 0.35, dampingFraction: 0.8)
            .delay(Double(index) * 0.05),
            value: items
        )
}

// Swipe to delete
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    Button(role: .destructive) { deleteItem() }
        .tint(.red)
}
```

### Micro-interactions

```swift
// Button tap
.buttonStyle(ScaleButtonStyle())

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Heart animation on like
struct HeartAnimation: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Image(systemName: "heart.fill")
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.3
                }
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8).delay(0.15)) {
                    scale = 1.0
                }
            }
    }
}

// Loading shimmer
.modifier(ShimmerModifier(isLoading: isLoading))

struct ShimmerModifier: ViewModifier {
    let isLoading: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.1), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: phase)
                    .animation(
                        .linear(duration: 1.2).repeatForever(autoreverses: false),
                        value: phase
                    )
                    .onAppear { phase = 300 }
                }
            }
    }
}
```

### Haptic Feedback Map

```swift
enum HapticFeedback {
    case tabChange      // .light
    case buttonTap      // .light
    case swipeThreshold // .medium
    case swipeComplete  // .success / .error
    case addToList      // .success
    case removeFromList // .warning
    case error          // .error
    case longPress      // .heavy
}

extension HapticFeedback {
    func trigger() {
        switch self {
        case .tabChange, .buttonTap:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .swipeThreshold:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .swipeComplete:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .addToList:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .removeFromList:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .longPress:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
    }
}
```

---

# The Ultimate Swipe Experience

## Swipe Modes

### 1. Classic Mode (Current)
- Movies only
- Simple left/right/up
- Best for quick discovery

### 2. Deep Dive Mode (New)
- Shows trailer preview on each card
- More info visible upfront
- For deliberate browsing

### 3. Speed Mode (New)
- Smaller cards, faster swiping
- Double-tap shortcuts
- For power users

### 4. Tonight Mode (New)
- Only movies < 2 hours
- On your streaming services
- Highly rated (7.0+)

## Smart Queue Algorithm

```swift
func buildSmartQueue() async -> [Movie] {
    var queue: [Movie] = []

    // 1. Personalized picks (40%)
    // Based on liked genres, actors, directors
    let personalized = await fetchPersonalizedRecommendations()

    // 2. Trending (25%)
    // What's popular this week
    let trending = await tmdb.fetchTrending()

    // 3. Hidden gems (20%)
    // High rated, low popularity
    let hiddenGems = await fetchHiddenGems()

    // 4. New releases (15%)
    // Fresh content
    let newReleases = await fetchNewReleases()

    // Interleave for variety
    return interleave([
        (personalized, 0.40),
        (trending, 0.25),
        (hiddenGems, 0.20),
        (newReleases, 0.15)
    ])
}
```

## Match Animation

When user swipes right on a movie they'll love:

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│                    ✨ IT'S A MATCH ✨                │
│                                                     │
│              ┌─────────────────────┐               │
│              │                     │               │
│              │   [MOVIE POSTER]    │               │
│              │                     │               │
│              └─────────────────────┘               │
│                                                     │
│           Based on your taste, you'll              │
│              probably love this one!               │
│                                                     │
│        [▶ Watch Trailer]   [+ Add to List]        │
│                                                     │
│                  [Keep Swiping]                    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

Triggers when:
- Movie matches 3+ of user's top genres
- Rating > user's average liked rating
- Stars an actor they've liked before

---

# Comprehensive Filter System

## Global Filter Architecture

```swift
struct FilterState: Codable {
    // Content Type
    var contentTypes: Set<ContentType> = [.movie, .tvShow]

    // Streaming Services
    var streamingServices: Set<StreamingService> = []
    var includeTheaters: Bool = true
    var includeRentBuy: Bool = false

    // Genres
    var includedGenres: Set<Genre> = []
    var excludedGenres: Set<Genre> = []

    // Ratings
    var minimumRating: Double = 0.0  // 0-10
    var minimumVotes: Int = 0        // For confidence

    // Release
    var releaseYearRange: ClosedRange<Int> = 1900...2025
    var releaseDateRange: DateInterval?

    // Runtime
    var runtimeRange: ClosedRange<Int> = 0...300  // minutes

    // Content
    var includeAdult: Bool = false
    var originalLanguages: Set<String> = []  // ISO codes

    // Sorting
    var sortBy: SortOption = .popularity
    var sortOrder: SortOrder = .descending
}

enum ContentType: String, Codable {
    case movie, tvShow
}

enum StreamingService: String, Codable, CaseIterable {
    case netflix = "8"
    case disneyPlus = "337"
    case primeVideo = "9"
    case hboMax = "384"
    case appleTVPlus = "350"
    case hulu = "15"
    case peacock = "386"
    case paramountPlus = "531"
    case showtime = "37"
    case starz = "43"
    case amc = "526"
    case mubi = "11"
    case criterion = "258"

    var displayName: String { /* ... */ }
    var color: Color { /* ... */ }
    var logoURL: URL { /* ... */ }
}

enum SortOption: String, Codable {
    case popularity
    case rating
    case releaseDate
    case title
    case runtime
    case voteCount
}
```

## Filter UI Components

### Filter Pills (Horizontal Scroll)

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  [✓ All] [Movies] [TV Shows] [In Theaters]         │
│                                                     │
│  [Netflix ✕] [Disney+ ✕] [HBO Max ✕] [+ Services]  │
│                                                     │
│  [Action ✕] [Sci-Fi ✕] [+ Genres]                  │
│                                                     │
│  [7.0+ Rating ✕] [< 2 hours ✕] [⚙ More Filters]   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Full Filter Sheet

```
┌─────────────────────────────────────────────────────┐
│  ━━━━━━━━━━━━━━━━━━━━                              │
│                                                     │
│  Filters                            [Reset All]    │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                     │
│  CONTENT TYPE                                       │
│  ┌─────────────────────────────────────────────┐   │
│  │  [● Movies]  [● TV Shows]  [○ Both]        │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                     │
│  WHERE TO WATCH                                     │
│                                                     │
│  Your Services                                      │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐              │
│  │  ✓   │ │  ✓   │ │      │ │      │              │
│  │ NFLX │ │  D+  │ │ HBO  │ │Prime │              │
│  └──────┘ └──────┘ └──────┘ └──────┘              │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐              │
│  │      │ │      │ │      │ │      │              │
│  │Apple │ │ Hulu │ │Peacok│ │Para+ │              │
│  └──────┘ └──────┘ └──────┘ └──────┘              │
│                                                     │
│  [□] Include movies in theaters                    │
│  [□] Include rent/buy options                      │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                     │
│  GENRES                                            │
│                                                     │
│  Include (tap to select)                           │
│  [Action] [Comedy] [Drama] [Horror] [Sci-Fi]      │
│  [Thriller] [Romance] [Animation] [Documentary]    │
│  [Fantasy] [Mystery] [Crime] [Adventure]          │
│                                                     │
│  Exclude (tap to hide)                             │
│  [ ] Horror  [ ] Romance  [ ] Animation           │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                     │
│  RATING & QUALITY                                  │
│                                                     │
│  Minimum Rating                                     │
│  [Any] [5+] [6+] [★ 7+] [8+] [9+]                 │
│                                                     │
│  Minimum Reviews                                   │
│  [Any] [100+] [500+] [★ 1000+] [5000+]           │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                     │
│  RELEASE PERIOD                                    │
│                                                     │
│  Quick Select                                       │
│  [This Year] [Last 5 Years] [2010s] [Classics]   │
│                                                     │
│  Custom Range                                       │
│  [1980 ●━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━● 2025]    │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                     │
│  RUNTIME                                           │
│                                                     │
│  [Any] [< 90min] [★ < 2hrs] [2-3hrs] [3hrs+]     │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                     │
│  SORT BY                                           │
│                                                     │
│  [★ Popularity] [Rating] [Release] [Title]        │
│  [○ Descending]  [○ Ascending]                    │
│                                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │         Show 247 Results                    │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Saved Filter Presets

```swift
struct FilterPreset: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var filter: FilterState
    var isDefault: Bool
}

// Built-in presets
let builtInPresets: [FilterPreset] = [
    FilterPreset(
        name: "Tonight",
        icon: "moon.stars",
        filter: FilterState(
            runtimeRange: 0...120,
            minimumRating: 7.0
        )
    ),
    FilterPreset(
        name: "Date Night",
        icon: "heart.fill",
        filter: FilterState(
            includedGenres: [.romance, .comedy, .drama],
            minimumRating: 7.0,
            runtimeRange: 90...150
        )
    ),
    FilterPreset(
        name: "Family Movie",
        icon: "figure.2.and.child.holdinghands",
        filter: FilterState(
            excludedGenres: [.horror, .thriller],
            includeAdult: false
        )
    ),
    FilterPreset(
        name: "Hidden Gems",
        icon: "sparkles",
        filter: FilterState(
            minimumRating: 7.5,
            sortBy: .voteCount,
            sortOrder: .ascending
        )
    )
]
```

---

# Trailer Experience

## Trailer Integration Points

### 1. Swipe Card Quick Preview
- Tap play button on card
- 30-second preview plays inline
- Sound off by default (tap for sound)
- Full trailer on tap or swipe up

### 2. Home Screen Hero
- Backdrop is actually first frame of trailer
- Auto-plays muted on focus
- "Watch Trailer" button for full experience

### 3. Detail View Hero Section
- Large play button overlay
- Shows trailer duration
- Tap for immersive full-screen player

### 4. Search Results
- Trailer preview on long-press
- Quick way to evaluate before adding

## Trailer Player Design

```
┌─────────────────────────────────────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
│▓                                                  ▓│
│▓                                                  ▓│
│▓                                                  ▓│
│▓                [VIDEO PLAYER]                    ▓│
│▓                                                  ▓│
│▓                    16:9                          ▓│
│▓                                                  ▓│
│▓                                                  ▓│
│▓                                                  ▓│
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
│                                                     │
│  ━━━━━━━━━━━━━━━●━━━━━━  1:23 / 2:34              │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  INTERSTELLAR                                      │
│  Official Trailer #2                               │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │    [+ Add to List]      [▶ Watch Now]      │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  More Videos                                       │
│  ┌────────┐ ┌────────┐ ┌────────┐                 │
│  │▶ Teaser│ │▶ Behind│ │▶ Cast  │                 │
│  │  1:45  │ │  5:23  │ │  3:12  │                 │
│  └────────┘ └────────┘ └────────┘                 │
│                                                     │
│                   [✕ Close]                        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Trailer Player Features

1. **Native Video Player**
   - AVPlayer with custom controls
   - Picture-in-Picture support
   - AirPlay casting

2. **YouTube Fallback**
   - For trailers only on YouTube
   - WKWebView with YouTube embed
   - No ads (direct embed URL)

3. **Player Controls**
   - Play/pause tap
   - Swipe to seek
   - Double-tap for ±15 seconds
   - Volume slider
   - Fullscreen toggle

4. **After Trailer Actions**
   - "Add to My List" prominent CTA
   - "Watch Now" if available
   - Auto-suggest next trailer

---

# Library & Collections

## Collection Types

### 1. Smart Collections (Auto-Generated)

```swift
struct SmartCollection {
    let id: String
    let name: String
    let icon: String
    let predicate: (WatchlistItem) -> Bool
    let sortOrder: SortOption
}

let smartCollections: [SmartCollection] = [
    SmartCollection(
        id: "watch-tonight",
        name: "Watch Tonight",
        icon: "moon.stars.fill",
        predicate: { $0.runtime <= 120 && $0.rating >= 7.0 },
        sortOrder: .rating
    ),
    SmartCollection(
        id: "new-releases",
        name: "New in Your List",
        icon: "sparkles",
        predicate: { $0.releaseDate > Date().addingTimeInterval(-90*24*60*60) },
        sortOrder: .releaseDate
    ),
    SmartCollection(
        id: "leaving-soon",
        name: "Leaving Soon",
        icon: "clock.badge.exclamationmark",
        predicate: { /* Check JustWatch leaving dates */ },
        sortOrder: .custom
    ),
    SmartCollection(
        id: "unwatched",
        name: "Not Yet Watched",
        icon: "eye.slash",
        predicate: { !$0.isWatched },
        sortOrder: .dateAdded
    ),
    SmartCollection(
        id: "rewatchable",
        name: "Watch Again",
        icon: "repeat",
        predicate: { $0.isWatched && $0.userRating >= 4 },
        sortOrder: .userRating
    )
]
```

### 2. User Collections

```swift
struct UserCollection: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String?          // SF Symbol or emoji
    var coverImageURL: URL?    // Custom cover from poster
    var itemIds: [Int]         // Movie/show IDs
    var createdAt: Date
    var modifiedAt: Date
    var isPrivate: Bool
    var sortOrder: SortOption

    // Computed
    var itemCount: Int { itemIds.count }
}
```

### Collection Cover Design

```
┌────────────────────────────┐
│ ┌────┬────┬────┬────┐     │
│ │    │    │    │    │     │  4 posters in grid
│ │    │    │    │    │     │
│ └────┴────┴────┴────┘     │
│ Date Night Movies          │
│ 12 items                   │
└────────────────────────────┘
```

## Watch Progress Tracking

```swift
struct WatchProgress: Codable {
    let itemId: Int
    let itemType: ContentType

    // For movies
    var percentWatched: Double?
    var lastWatchedAt: Date?

    // For TV shows
    var watchedEpisodes: [EpisodeKey: Bool]
    var currentSeason: Int?
    var currentEpisode: Int?

    // Computed
    var isCompleted: Bool
    var nextEpisode: EpisodeKey?
}

struct EpisodeKey: Hashable, Codable {
    let season: Int
    let episode: Int
}
```

---

# Technical Architecture

## Updated Project Structure

```
MovieTrailer/
├── App/
│   ├── MovieTrailerApp.swift
│   ├── AppCoordinator.swift
│   └── AppState.swift              # Global app state
│
├── Core/
│   ├── DesignSystem/
│   │   ├── Colors.swift            # Updated palette
│   │   ├── Typography.swift        # Updated type scale
│   │   ├── Spacing.swift           # Spacing system
│   │   ├── Theme.swift             # Animation presets
│   │   ├── Shadows.swift           # Shadow system
│   │   └── Haptics.swift           # Haptic patterns
│   │
│   ├── Extensions/
│   │   ├── View+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   ├── Animation+Extensions.swift
│   │   └── Date+Extensions.swift
│   │
│   └── Utilities/
│       ├── Constants.swift
│       └── Logger.swift
│
├── Data/
│   ├── Models/
│   │   ├── Movie.swift
│   │   ├── TVShow.swift
│   │   ├── Person.swift
│   │   ├── Video.swift
│   │   ├── WatchProvider.swift
│   │   ├── Genre.swift
│   │   ├── Collection.swift
│   │   └── FilterState.swift
│   │
│   ├── Networking/
│   │   ├── TMDBService.swift
│   │   ├── TMDBEndpoint.swift
│   │   ├── NetworkError.swift
│   │   ├── CachingManager.swift
│   │   └── CertificatePinning.swift
│   │
│   └── Persistence/
│       ├── WatchlistManager.swift
│       ├── CollectionManager.swift
│       ├── FilterPresetManager.swift
│       ├── SwipeHistoryManager.swift
│       └── UserPreferences.swift
│
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift
│   │   └── Components/
│   │       ├── HeroCarousel.swift
│   │       ├── ContentRow.swift
│   │       ├── Top10Row.swift
│   │       ├── TheaterRow.swift
│   │       └── ContinueWatchingRow.swift
│   │
│   ├── Swipe/
│   │   ├── SwipeView.swift
│   │   ├── SwipeViewModel.swift
│   │   └── Components/
│   │       ├── SwipeCard.swift
│   │       ├── SwipeActionBar.swift
│   │       ├── SwipeIndicators.swift
│   │       ├── SwipeProgressBar.swift
│   │       ├── SwipeStatsSheet.swift
│   │       └── MatchOverlay.swift
│   │
│   ├── Search/
│   │   ├── SearchView.swift
│   │   ├── SearchViewModel.swift
│   │   └── Components/
│   │       ├── SearchBar.swift
│   │       ├── SearchSuggestions.swift
│   │       ├── SearchResults.swift
│   │       └── SearchFilters.swift
│   │
│   ├── Library/
│   │   ├── LibraryView.swift
│   │   ├── LibraryViewModel.swift
│   │   └── Components/
│   │       ├── CollectionGrid.swift
│   │       ├── CollectionDetail.swift
│   │       ├── WatchlistGrid.swift
│   │       └── LibraryStats.swift
│   │
│   ├── Detail/
│   │   ├── MovieDetailView.swift
│   │   ├── TVShowDetailView.swift
│   │   ├── DetailViewModel.swift
│   │   └── Components/
│   │       ├── DetailHeader.swift
│   │       ├── WatchProvidersSection.swift
│   │       ├── CastSection.swift
│   │       ├── VideosSection.swift
│   │       └── SimilarSection.swift
│   │
│   ├── Trailer/
│   │   ├── TrailerPlayerView.swift
│   │   ├── TrailerViewModel.swift
│   │   └── Components/
│   │       ├── VideoControls.swift
│   │       └── TrailerList.swift
│   │
│   └── Filter/
│       ├── FilterSheet.swift
│       ├── FilterViewModel.swift
│       └── Components/
│           ├── FilterSection.swift
│           ├── ServicePicker.swift
│           ├── GenrePicker.swift
│           ├── RatingSlider.swift
│           ├── YearRangePicker.swift
│           └── RuntimePicker.swift
│
├── Shared/
│   ├── Components/
│   │   ├── Cards/
│   │   │   ├── PosterCard.swift
│   │   │   ├── LandscapeCard.swift
│   │   │   ├── FeaturedCard.swift
│   │   │   └── CompactCard.swift
│   │   │
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   ├── SecondaryButton.swift
│   │   │   ├── IconButton.swift
│   │   │   └── PillButton.swift
│   │   │
│   │   ├── Pills/
│   │   │   ├── GenrePill.swift
│   │   │   ├── RatingPill.swift
│   │   │   ├── ServiceBadge.swift
│   │   │   └── FilterPill.swift
│   │   │
│   │   ├── Layout/
│   │   │   ├── GlassBackground.swift
│   │   │   ├── SectionHeader.swift
│   │   │   ├── LoadingView.swift
│   │   │   ├── ErrorView.swift
│   │   │   └── EmptyStateView.swift
│   │   │
│   │   └── Media/
│   │       ├── AsyncPosterImage.swift
│   │       ├── BackdropImage.swift
│   │       └── AvatarImage.swift
│   │
│   ├── Modifiers/
│   │   ├── ShimmerModifier.swift
│   │   ├── CardModifier.swift
│   │   └── GlassModifier.swift
│   │
│   └── Styles/
│       ├── ButtonStyles.swift
│       └── TextFieldStyles.swift
│
├── Navigation/
│   ├── Coordinator.swift
│   ├── TabCoordinator.swift
│   ├── DeepLinkHandler.swift
│   └── Router.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.strings
    └── Info.plist
```

## State Management

```swift
// Global app state using Observation framework (iOS 17+)
@Observable
class AppState {
    // User state
    var isOnboarded: Bool = false
    var selectedServices: Set<StreamingService> = []

    // Current filter (shared across views)
    var globalFilter: FilterState = FilterState()

    // Navigation
    var selectedTab: AppTab = .home
    var presentedSheet: SheetType?
    var navigationPath: NavigationPath = NavigationPath()

    // Playback
    var currentlyPlayingTrailer: Video?
    var isTrailerPlaying: Bool = false
}

// Feature-specific state in ViewModels
@Observable
class SwipeViewModel {
    var cards: [Movie] = []
    var currentIndex: Int = 0
    var swipeDirection: SwipeDirection?
    var isLoading: Bool = false
    var error: Error?

    // Swipe history for undo
    var swipeHistory: [(movie: Movie, direction: SwipeDirection)] = []

    // Stats
    var totalSwiped: Int = 0
    var likedCount: Int = 0
    var skippedCount: Int = 0
}
```

## Performance Optimizations

```swift
// 1. Image Loading with Prefetching
class ImagePrefetcher {
    private let prefetcher = ImagePrefetcher()

    func prefetchImages(for movies: [Movie]) {
        let urls = movies.compactMap { $0.posterURL }
        prefetcher.startPrefetching(with: urls)
    }
}

// 2. Lazy Loading in Lists
LazyVStack(spacing: Spacing.listItemSpacing) {
    ForEach(movies) { movie in
        MovieRow(movie: movie)
            .onAppear {
                loadMoreIfNeeded(current: movie)
            }
    }
}

// 3. View Recycling
struct OptimizedGrid: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(items) { item in
                    ItemCell(item: item)
                        .id(item.id) // Stable identity for recycling
                }
            }
        }
    }
}

// 4. Debounced Search
class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [Movie] = []

    private var searchTask: Task<Void, Never>?

    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
}

// 5. Memory Management
struct MovieCard: View {
    let movie: Movie

    var body: some View {
        // Use thumbnail for list views
        KFImage(movie.thumbnailURL)
            .resizable()
            .placeholder { ShimmerView() }
            .fade(duration: 0.2)
            .cacheMemoryOnly() // Don't disk cache thumbnails
    }
}
```

---

# Implementation Priority

## Phase 1: Foundation (Week 1-2)

### 1.1 Design System Overhaul
- [ ] Update Colors.swift with new palette
- [ ] Update Typography.swift with new scale
- [ ] Add Shadows.swift
- [ ] Add animation presets to Theme.swift
- [ ] Create GlassBackground component
- [ ] Create button styles (Primary, Secondary, Icon)

### 1.2 Card Components
- [ ] Redesign PosterCard with glass effect
- [ ] Create LandscapeCard for featured content
- [ ] Create CompactCard for search results
- [ ] Add shimmer loading states
- [ ] Implement press/hover animations

### 1.3 Navigation Polish
- [ ] Redesign tab bar with glass effect
- [ ] Add tab change animations
- [ ] Implement haptic feedback
- [ ] Add icon bounce on selection

---

## Phase 2: Home Screen (Week 3-4)

### 2.1 Hero Carousel
- [ ] Full-bleed backdrop images
- [ ] Auto-rotation with pause on touch
- [ ] Overlay with title, rating, actions
- [ ] Pagination dots
- [ ] Parallax scroll effect

### 2.2 Content Rows
- [ ] Standard poster row
- [ ] Top 10 row with numbers
- [ ] Featured landscape row
- [ ] Theater row with showtimes
- [ ] Continue watching row

### 2.3 Personalization
- [ ] "Because you liked X" row
- [ ] Genre-based rows
- [ ] New on your services row

---

## Phase 3: Swipe Experience (Week 5-6)

### 3.1 Card Redesign
- [ ] Glass effect card background
- [ ] Inline trailer preview button
- [ ] Streaming service badges
- [ ] Rating prominence

### 3.2 Swipe Mechanics
- [ ] Improved physics (spring animations)
- [ ] Visual feedback during drag
- [ ] Direction indicators
- [ ] Confetti on match

### 3.3 Action Bar
- [ ] Redesign with glass buttons
- [ ] Trailer quick-play button
- [ ] Undo functionality polish
- [ ] Info sheet access

### 3.4 Filters
- [ ] Quick filter chips at top
- [ ] Full filter sheet
- [ ] Filter presets
- [ ] Active filter indicators

---

## Phase 4: Search & Discovery (Week 7-8)

### 4.1 Search Bar
- [ ] Glass effect search field
- [ ] Voice search integration
- [ ] Category tabs (Movies, TV, People)

### 4.2 Browse Sections
- [ ] Trending searches
- [ ] Genre grid
- [ ] Service grid
- [ ] Recent searches

### 4.3 Results
- [ ] Top result feature card
- [ ] Related suggestions
- [ ] Grid results
- [ ] Filter integration

---

## Phase 5: Library & Collections (Week 9-10)

### 5.1 Library Redesign
- [ ] Stats dashboard
- [ ] Smart collections
- [ ] User collections
- [ ] Collection covers

### 5.2 Collection Features
- [ ] Create/edit collections
- [ ] Drag-and-drop sorting
- [ ] Multi-select actions
- [ ] Share as image

### 5.3 Watch Progress
- [ ] Mark as watched
- [ ] Episode tracking
- [ ] Continue watching integration

---

## Phase 6: Trailer Experience (Week 11-12)

### 6.1 Player
- [ ] Custom video controls
- [ ] Full-screen mode
- [ ] Picture-in-picture
- [ ] AirPlay support

### 6.2 Integration
- [ ] Inline preview on swipe cards
- [ ] Hero section autoplay
- [ ] Detail view hero player
- [ ] Multiple videos section

### 6.3 Polish
- [ ] Loading states
- [ ] Error handling
- [ ] Offline support

---

## Phase 7: Polish & Launch (Week 13-14)

### 7.1 Performance
- [ ] Profiling and optimization
- [ ] Image caching strategy
- [ ] Network request batching
- [ ] Memory management

### 7.2 Accessibility
- [ ] VoiceOver audit
- [ ] Dynamic type support
- [ ] Color contrast verification
- [ ] Reduce motion support

### 7.3 Testing
- [ ] Unit tests for ViewModels
- [ ] UI tests for critical flows
- [ ] Performance testing
- [ ] Device testing matrix

### 7.4 Launch Prep
- [ ] App Store screenshots
- [ ] Preview video
- [ ] App Store description
- [ ] Privacy policy update

---

# Success Metrics

## User Experience

| Metric | Current | Target |
|--------|---------|--------|
| App Store Rating | - | 4.7+ |
| Time to First Swipe | ~5s | <2s |
| Swipes per Session | ~20 | 50+ |
| Library Adds per Session | ~2 | 5+ |
| Trailer Views per Session | ~1 | 5+ |
| Session Duration | ~3min | 8min+ |
| Daily Active Users | - | Growth metric |
| Return Rate (7-day) | - | 40%+ |

## Technical

| Metric | Target |
|--------|--------|
| App Launch Time | <1.5s |
| Memory Usage | <150MB |
| API Response Cache Hit | >70% |
| Crash-Free Sessions | >99.5% |
| Frame Rate | 60fps |

---

# Conclusion

This document outlines the complete transformation of MovieTrailer from a functional app into a premium, Apple-quality entertainment discovery platform. The redesign focuses on:

1. **Visual Excellence**: A design system that rivals Apple's own apps
2. **Delightful Interactions**: Animations and haptics that make every touch feel premium
3. **Comprehensive Features**: Filters, trailers, and collections that make discovery effortless
4. **Technical Foundation**: Architecture that supports growth and performance

The phased implementation approach allows for iterative improvement while maintaining stability. Each phase builds upon the previous, ensuring that the app improves continuously until it reaches its ultimate form: **the definitive app for finding what to watch**.

---

*"The best interface is no interface. The best search is finding what you want before you search. The best app is one that becomes indispensable."*

---

**Document Version**: 1.0
**Last Updated**: December 2025
**Status**: Ready for Implementation
