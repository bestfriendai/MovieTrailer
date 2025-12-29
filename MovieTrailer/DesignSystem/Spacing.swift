//
//  Spacing.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Consistent spacing system
//

import SwiftUI

// MARK: - Spacing Constants

enum Spacing {
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

    /// 40pt - Section spacing
    static let section: CGFloat = 40

    /// 48pt - Large section spacing
    static let largeSection: CGFloat = 48

    /// Standard horizontal padding
    static let horizontal: CGFloat = 20

    /// Standard vertical padding
    static let vertical: CGFloat = 16

    /// Card internal padding
    static let cardPadding: CGFloat = 16

    /// Safe area bottom padding for floating elements
    static let floatingBottom: CGFloat = 100
}

// MARK: - Size Constants

enum Size {
    /// Small icon size
    static let iconSmall: CGFloat = 16

    /// Medium icon size
    static let iconMedium: CGFloat = 24

    /// Large icon size
    static let iconLarge: CGFloat = 32

    /// Extra large icon size
    static let iconXL: CGFloat = 44

    /// Small avatar size
    static let avatarSmall: CGFloat = 32

    /// Medium avatar size
    static let avatarMedium: CGFloat = 44

    /// Large avatar size
    static let avatarLarge: CGFloat = 64

    /// Movie card width (compact)
    static let movieCardCompact: CGFloat = 120

    /// Movie card width (standard)
    static let movieCardStandard: CGFloat = 150

    /// Movie card width (large)
    static let movieCardLarge: CGFloat = 180

    /// Featured card height
    static let featuredCardHeight: CGFloat = 420

    /// Hero carousel height
    static let heroHeight: CGFloat = 480

    /// Tab bar height
    static let tabBarHeight: CGFloat = 80

    /// Navigation bar height
    static let navBarHeight: CGFloat = 44

    /// Minimum touch target
    static let minTouchTarget: CGFloat = 44

    /// Pill height
    static let pillHeight: CGFloat = 36

    /// Button height (standard)
    static let buttonHeight: CGFloat = 50

    /// Button height (compact)
    static let buttonHeightCompact: CGFloat = 40

    /// Provider logo size
    static let providerLogo: CGFloat = 50

    /// Swipe card width ratio
    static let swipeCardWidthRatio: CGFloat = 0.9

    /// Swipe card height ratio
    static let swipeCardHeightRatio: CGFloat = 0.75
}

// MARK: - Aspect Ratios

enum AspectRatio {
    /// Movie poster ratio (2:3)
    static let poster: CGFloat = 2/3

    /// Backdrop ratio (16:9)
    static let backdrop: CGFloat = 16/9

    /// Square ratio (1:1)
    static let square: CGFloat = 1

    /// Wide ratio (21:9)
    static let ultrawide: CGFloat = 21/9

    /// YouTube thumbnail ratio
    static let youtube: CGFloat = 16/9
}

// MARK: - View Spacing Extensions

extension View {
    /// Apply standard horizontal padding
    func horizontalPadding() -> some View {
        self.padding(.horizontal, Spacing.horizontal)
    }

    /// Apply standard vertical padding
    func verticalPadding() -> some View {
        self.padding(.vertical, Spacing.vertical)
    }

    /// Apply card padding
    func cardPadding() -> some View {
        self.padding(Spacing.cardPadding)
    }

    /// Apply section spacing on top
    func sectionSpacing() -> some View {
        self.padding(.top, Spacing.section)
    }
}
