//
//  Spacing.swift
//  MovieTrailer
//
//  Apple 2025 Premium Spacing System
//  Consistent spacing and sizing constants
//

import SwiftUI

// MARK: - Spacing Constants

/// 4pt base unit spacing system
enum Spacing {

    // MARK: - Base Scale (4pt increments)

    /// 2pt - Micro spacing
    static let micro: CGFloat = 2

    /// 4pt - Minimal spacing
    static let xxs: CGFloat = 4

    /// 8pt - Extra small spacing
    static let xs: CGFloat = 8

    /// 12pt - Small spacing
    static let sm: CGFloat = 12

    /// 16pt - Medium spacing (default)
    static let md: CGFloat = 16

    /// 20pt - Large spacing
    static let lg: CGFloat = 20

    /// 24pt - Extra large spacing
    static let xl: CGFloat = 24

    /// 32pt - 2x large spacing
    static let xxl: CGFloat = 32

    /// 40pt - 3x large spacing
    static let xxxl: CGFloat = 40

    /// 48pt - 4x large spacing
    static let xxxxl: CGFloat = 48

    /// 64pt - 5x large spacing
    static let massive: CGFloat = 64

    // MARK: - Semantic Spacing

    /// Section spacing - 32pt
    static let section: CGFloat = 32

    /// Large section spacing - 48pt
    static let sectionLarge: CGFloat = 48

    /// Content row spacing - 24pt
    static let rowSpacing: CGFloat = 24

    /// List item spacing - 12pt
    static let listItem: CGFloat = 12

    /// Inline element spacing - 8pt
    static let inline: CGFloat = 8

    /// Standard horizontal padding - 20pt
    static let horizontal: CGFloat = 20

    /// Standard vertical padding - 16pt
    static let vertical: CGFloat = 16

    /// Card internal padding - 16pt
    static let cardPadding: CGFloat = 16

    /// Safe area bottom padding for floating elements - 100pt
    static let floatingBottom: CGFloat = 100

    /// Tab bar safe area - 90pt
    static let tabBarSafeArea: CGFloat = 90

    /// Sheet handle area - 24pt
    static let sheetHandle: CGFloat = 24

    /// Navigation bar content inset - 16pt
    static let navBarInset: CGFloat = 16

    // MARK: - Grid Spacing

    /// Grid gap small - 8pt
    static let gridGapSmall: CGFloat = 8

    /// Grid gap medium - 12pt
    static let gridGapMedium: CGFloat = 12

    /// Grid gap large - 16pt
    static let gridGapLarge: CGFloat = 16

    // MARK: - Component-Specific

    /// Poster card spacing
    static let posterCardSpacing: CGFloat = 12

    /// Carousel item spacing
    static let carouselSpacing: CGFloat = 16

    /// Swipe card gap
    static let swipeCardGap: CGFloat = 20

    /// Filter pill spacing
    static let filterPillSpacing: CGFloat = 8

    /// Badge padding
    static let badgePadding: CGFloat = 6
}

// MARK: - Size Constants

enum Size {

    // MARK: - Icons

    /// Tiny icon size - 12pt
    static let iconTiny: CGFloat = 12

    /// Small icon size - 16pt
    static let iconSmall: CGFloat = 16

    /// Medium icon size - 24pt
    static let iconMedium: CGFloat = 24

    /// Large icon size - 32pt
    static let iconLarge: CGFloat = 32

    /// Extra large icon size - 44pt
    static let iconXL: CGFloat = 44

    /// Huge icon size - 56pt
    static let iconHuge: CGFloat = 56

    // MARK: - Avatars

    /// Tiny avatar size - 24pt
    static let avatarTiny: CGFloat = 24

    /// Small avatar size - 32pt
    static let avatarSmall: CGFloat = 32

    /// Medium avatar size - 44pt
    static let avatarMedium: CGFloat = 44

    /// Large avatar size - 64pt
    static let avatarLarge: CGFloat = 64

    /// Extra large avatar size - 80pt
    static let avatarXL: CGFloat = 80

    // MARK: - Movie Cards

    /// Movie card width (compact) - 100pt
    static let movieCardCompact: CGFloat = 100

    /// Movie card width (small) - 120pt
    static let movieCardSmall: CGFloat = 120

    /// Movie card width (standard) - 150pt
    static let movieCardStandard: CGFloat = 150

    /// Movie card width (large) - 180pt
    static let movieCardLarge: CGFloat = 180

    /// Movie card width (featured) - 220pt
    static let movieCardFeatured: CGFloat = 220

    // MARK: - Swipe Cards

    /// Swipe card width ratio
    static let swipeCardWidthRatio: CGFloat = 0.88

    /// Swipe card aspect ratio (2:3 poster)
    static let swipeCardAspectRatio: CGFloat = 2/3

    /// Swipe card max width
    static let swipeCardMaxWidth: CGFloat = 340

    // MARK: - Feature Elements

    /// Featured card height - 420pt
    static let featuredCardHeight: CGFloat = 420

    /// Hero carousel height - 520pt
    static let heroHeight: CGFloat = 520

    /// Hero carousel compact height - 400pt
    static let heroHeightCompact: CGFloat = 400

    /// Landscape card height - 200pt
    static let landscapeCardHeight: CGFloat = 200

    /// Top 10 card height - 180pt
    static let top10CardHeight: CGFloat = 180

    // MARK: - Navigation

    /// Tab bar height - 83pt (with safe area)
    static let tabBarHeight: CGFloat = 83

    /// Tab bar content height - 49pt
    static let tabBarContentHeight: CGFloat = 49

    /// Navigation bar height - 44pt
    static let navBarHeight: CGFloat = 44

    /// Large navigation bar height - 96pt
    static let navBarLargeHeight: CGFloat = 96

    /// Search bar height - 36pt
    static let searchBarHeight: CGFloat = 36

    // MARK: - Buttons & Controls

    /// Minimum touch target - 44pt
    static let minTouchTarget: CGFloat = 44

    /// Button height (large) - 56pt
    static let buttonHeightLarge: CGFloat = 56

    /// Button height (standard) - 50pt
    static let buttonHeight: CGFloat = 50

    /// Button height (medium) - 44pt
    static let buttonHeightMedium: CGFloat = 44

    /// Button height (compact) - 36pt
    static let buttonHeightCompact: CGFloat = 36

    /// Button height (small) - 32pt
    static let buttonHeightSmall: CGFloat = 32

    /// Pill height - 36pt
    static let pillHeight: CGFloat = 36

    /// Pill height small - 28pt
    static let pillHeightSmall: CGFloat = 28

    /// Chip height - 32pt
    static let chipHeight: CGFloat = 32

    // MARK: - Action Buttons (Swipe)

    /// Action button small - 44pt
    static let actionButtonSmall: CGFloat = 44

    /// Action button medium - 56pt
    static let actionButtonMedium: CGFloat = 56

    /// Action button large - 64pt
    static let actionButtonLarge: CGFloat = 64

    // MARK: - Providers & Badges

    /// Provider logo size - 44pt
    static let providerLogo: CGFloat = 44

    /// Provider logo small - 32pt
    static let providerLogoSmall: CGFloat = 32

    /// Provider logo large - 56pt
    static let providerLogoLarge: CGFloat = 56

    /// Badge size - 20pt
    static let badgeSize: CGFloat = 20

    /// Badge size large - 24pt
    static let badgeSizeLarge: CGFloat = 24

    // MARK: - Progress & Indicators

    /// Progress bar height - 4pt
    static let progressBarHeight: CGFloat = 4

    /// Progress bar height thick - 6pt
    static let progressBarHeightThick: CGFloat = 6

    /// Indicator dot size - 8pt
    static let indicatorDot: CGFloat = 8

    /// Indicator dot large - 10pt
    static let indicatorDotLarge: CGFloat = 10

    // MARK: - Sheets & Modals

    /// Sheet minimum height - 200pt
    static let sheetMinHeight: CGFloat = 200

    /// Sheet drag indicator width - 36pt
    static let sheetDragIndicatorWidth: CGFloat = 36

    /// Sheet drag indicator height - 5pt
    static let sheetDragIndicatorHeight: CGFloat = 5

    // MARK: - Ranking Numbers

    /// Ranking number width - 60pt
    static let rankingNumberWidth: CGFloat = 60

    /// Ranking number height - 90pt
    static let rankingNumberHeight: CGFloat = 90
}

// MARK: - Aspect Ratios

enum AspectRatio {

    /// Movie poster ratio (2:3)
    static let poster: CGFloat = 2/3

    /// Backdrop ratio (16:9)
    static let backdrop: CGFloat = 16/9

    /// Square ratio (1:1)
    static let square: CGFloat = 1

    /// Wide ratio (2:1)
    static let wide: CGFloat = 2/1

    /// Ultra wide ratio (21:9)
    static let ultrawide: CGFloat = 21/9

    /// YouTube thumbnail ratio (16:9)
    static let youtube: CGFloat = 16/9

    /// Profile photo ratio (1:1)
    static let profile: CGFloat = 1

    /// Landscape card ratio (16:10)
    static let landscapeCard: CGFloat = 16/10

    /// Hero banner ratio (16:7)
    static let heroBanner: CGFloat = 16/7

    /// Collection cover ratio (4:3)
    static let collection: CGFloat = 4/3
}

// MARK: - Grid Columns

enum GridColumns {

    /// 2 column grid
    static let two: [GridItem] = [
        GridItem(.flexible(), spacing: Spacing.gridGapMedium),
        GridItem(.flexible(), spacing: Spacing.gridGapMedium)
    ]

    /// 3 column grid
    static let three: [GridItem] = [
        GridItem(.flexible(), spacing: Spacing.gridGapMedium),
        GridItem(.flexible(), spacing: Spacing.gridGapMedium),
        GridItem(.flexible(), spacing: Spacing.gridGapMedium)
    ]

    /// 4 column grid
    static let four: [GridItem] = [
        GridItem(.flexible(), spacing: Spacing.gridGapSmall),
        GridItem(.flexible(), spacing: Spacing.gridGapSmall),
        GridItem(.flexible(), spacing: Spacing.gridGapSmall),
        GridItem(.flexible(), spacing: Spacing.gridGapSmall)
    ]

    /// Adaptive grid with minimum size
    static func adaptive(minSize: CGFloat, spacing: CGFloat = Spacing.gridGapMedium) -> [GridItem] {
        [GridItem(.adaptive(minimum: minSize), spacing: spacing)]
    }
}

// MARK: - View Spacing Extensions

extension View {

    /// Apply standard horizontal padding
    func horizontalPadding(_ multiplier: CGFloat = 1) -> some View {
        self.padding(.horizontal, Spacing.horizontal * multiplier)
    }

    /// Apply standard vertical padding
    func verticalPadding(_ multiplier: CGFloat = 1) -> some View {
        self.padding(.vertical, Spacing.vertical * multiplier)
    }

    /// Apply card padding
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }

    /// Apply section spacing on top
    func sectionSpacing() -> some View {
        self.padding(.top, Spacing.section)
    }

    /// Apply large section spacing
    func sectionSpacingLarge() -> some View {
        self.padding(.top, Spacing.sectionLarge)
    }

    /// Apply content padding (horizontal + vertical)
    func contentPadding() -> some View {
        self
            .padding(.horizontal, Spacing.horizontal)
            .padding(.vertical, Spacing.vertical)
    }

    /// Apply safe area for tab bar
    func tabBarSafeArea() -> some View {
        self.padding(.bottom, Spacing.tabBarSafeArea)
    }

    /// Apply floating bottom safe area
    func floatingBottomSafeArea() -> some View {
        self.padding(.bottom, Spacing.floatingBottom)
    }
}

// MARK: - Frame Helpers

extension View {

    /// Apply minimum touch target size
    func touchTarget() -> some View {
        self.frame(minWidth: Size.minTouchTarget, minHeight: Size.minTouchTarget)
    }

    /// Apply standard button frame
    func buttonFrame() -> some View {
        self.frame(height: Size.buttonHeight)
    }

    /// Apply compact button frame
    func compactButtonFrame() -> some View {
        self.frame(height: Size.buttonHeightCompact)
    }

    /// Apply icon frame
    func iconFrame(_ size: CGFloat = Size.iconMedium) -> some View {
        self.frame(width: size, height: size)
    }

    /// Apply avatar frame
    func avatarFrame(_ size: CGFloat = Size.avatarMedium) -> some View {
        self
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    /// Apply poster aspect ratio
    func posterAspectRatio() -> some View {
        self.aspectRatio(AspectRatio.poster, contentMode: .fill)
    }

    /// Apply backdrop aspect ratio
    func backdropAspectRatio() -> some View {
        self.aspectRatio(AspectRatio.backdrop, contentMode: .fill)
    }
}
