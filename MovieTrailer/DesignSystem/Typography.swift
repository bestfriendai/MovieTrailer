//
//  Typography.swift
//  MovieTrailer
//
//  Apple 2025 Premium Typography System
//  SF Pro with comprehensive type scale
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Typography Extensions

extension Font {

    // MARK: - Display Fonts (Hero Headlines)

    /// Extra large display - 56pt Bold
    static let displayXL = Font.system(size: 56, weight: .bold, design: .default)

    /// Large display title - 44pt Bold
    static let displayLarge = Font.system(size: 44, weight: .bold, design: .default)

    /// Medium display title - 34pt Bold
    static let displayMedium = Font.system(size: 34, weight: .bold, design: .default)

    /// Small display title - 28pt Bold
    static let displaySmall = Font.system(size: 28, weight: .bold, design: .default)

    // MARK: - Headline Fonts

    /// Headline 1 - 28pt Bold
    static let headline1 = Font.system(size: 28, weight: .bold, design: .default)

    /// Headline 2 - 24pt Semibold
    static let headline2 = Font.system(size: 24, weight: .semibold, design: .default)

    /// Headline 3 - 20pt Semibold
    static let headline3 = Font.system(size: 20, weight: .semibold, design: .default)

    /// Section header - 22pt Semibold (legacy)
    static let sectionHeader = Font.system(size: 22, weight: .semibold, design: .default)

    /// Section title - 20pt Bold (legacy)
    static let sectionTitle = Font.system(size: 20, weight: .bold, design: .default)

    // MARK: - Title Fonts

    /// Title large - 22pt Semibold
    static let titleLarge = Font.system(size: 22, weight: .semibold, design: .default)

    /// Title medium - 18pt Semibold
    static let titleMedium = Font.system(size: 18, weight: .semibold, design: .default)

    /// Title small - 16pt Semibold
    static let titleSmall = Font.system(size: 16, weight: .semibold, design: .default)

    /// Card title - 18pt Semibold (legacy)
    static let cardTitle = Font.system(size: 18, weight: .semibold, design: .default)

    /// Subsection header - 16pt Semibold (legacy)
    static let subsectionHeader = Font.system(size: 16, weight: .semibold, design: .default)

    // MARK: - Body Fonts

    /// Body large - 17pt Regular
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)

    /// Body medium - 15pt Regular
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)

    /// Body small - 13pt Regular
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    /// Body emphasized - 17pt Medium
    static let bodyEmphasized = Font.system(size: 17, weight: .medium, design: .default)

    // MARK: - Label Fonts

    /// Label large - 15pt Medium
    static let labelLarge = Font.system(size: 15, weight: .medium, design: .default)

    /// Label medium - 13pt Medium
    static let labelMedium = Font.system(size: 13, weight: .medium, design: .default)

    /// Label small - 11pt Medium
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Caption Fonts

    /// Caption large - 13pt Regular
    static let captionLarge = Font.system(size: 13, weight: .regular, design: .default)

    /// Caption regular - 12pt Regular
    static let captionRegular = Font.system(size: 12, weight: .regular, design: .default)

    /// Caption bold - 12pt Semibold
    static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)

    /// Caption small - 11pt Regular
    static let captionSmall = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: - Overline

    /// Overline - 10pt Semibold uppercase
    static let overline = Font.system(size: 10, weight: .semibold, design: .default)

    // MARK: - Button Fonts

    /// Button large - 17pt Semibold
    static let buttonLarge = Font.system(size: 17, weight: .semibold, design: .default)

    /// Button medium - 15pt Semibold
    static let buttonMedium = Font.system(size: 15, weight: .semibold, design: .default)

    /// Button small - 13pt Semibold
    static let buttonSmall = Font.system(size: 13, weight: .semibold, design: .default)

    /// Button extra small - 11pt Semibold
    static let buttonXS = Font.system(size: 11, weight: .semibold, design: .default)

    // MARK: - Special Fonts

    /// Rating number - 14pt Bold Rounded
    static let rating = Font.system(size: 14, weight: .bold, design: .rounded)

    /// Rating large - 18pt Bold Rounded
    static let ratingLarge = Font.system(size: 18, weight: .bold, design: .rounded)

    /// Movie year - 13pt Regular
    static let movieYear = Font.system(size: 13, weight: .regular, design: .default)

    /// Runtime - 13pt Medium
    static let runtime = Font.system(size: 13, weight: .medium, design: .default)

    /// Pill text - 14pt Medium
    static let pill = Font.system(size: 14, weight: .medium, design: .default)

    /// Pill small - 12pt Medium
    static let pillSmall = Font.system(size: 12, weight: .medium, design: .default)

    /// Badge text - 11pt Bold Rounded
    static let badge = Font.system(size: 11, weight: .bold, design: .rounded)

    /// Badge large - 13pt Bold Rounded
    static let badgeLarge = Font.system(size: 13, weight: .bold, design: .rounded)

    /// Monospaced for numbers - 14pt Medium
    static let monoNumber = Font.system(size: 14, weight: .medium, design: .monospaced)

    /// Monospaced large - 18pt Medium
    static let monoNumberLarge = Font.system(size: 18, weight: .medium, design: .monospaced)

    /// Tab bar label - 10pt Medium
    static let tabLabel = Font.system(size: 10, weight: .medium, design: .default)

    /// Ranking number - 72pt Heavy
    static let rankingNumber = Font.system(size: 72, weight: .heavy, design: .rounded)

    /// Ranking number small - 48pt Heavy
    static let rankingNumberSmall = Font.system(size: 48, weight: .heavy, design: .rounded)

    /// Stats number - 32pt Bold Rounded
    static let statsNumber = Font.system(size: 32, weight: .bold, design: .rounded)

    /// Stats label - 12pt Medium
    static let statsLabel = Font.system(size: 12, weight: .medium, design: .default)

    /// Countdown - 24pt Bold Monospaced
    static let countdown = Font.system(size: 24, weight: .bold, design: .monospaced)

    /// Metadata - 12pt Regular
    static let metadata = Font.system(size: 12, weight: .regular, design: .default)

    /// Provider name - 11pt Medium
    static let providerName = Font.system(size: 11, weight: .medium, design: .default)
}

// MARK: - Text Style Modifiers

extension View {

    /// Apply display XL style
    func displayXLStyle() -> some View {
        self
            .font(.displayXL)
            .foregroundColor(.textPrimary)
    }

    /// Apply display large style
    func displayLargeStyle() -> some View {
        self
            .font(.displayLarge)
            .foregroundColor(.textPrimary)
    }

    /// Apply display medium style
    func displayMediumStyle() -> some View {
        self
            .font(.displayMedium)
            .foregroundColor(.textPrimary)
    }

    /// Apply headline 1 style
    func headline1Style() -> some View {
        self
            .font(.headline1)
            .foregroundColor(.textPrimary)
    }

    /// Apply headline 2 style
    func headline2Style() -> some View {
        self
            .font(.headline2)
            .foregroundColor(.textPrimary)
    }

    /// Apply section header style
    func sectionHeaderStyle() -> some View {
        self
            .font(.sectionHeader)
            .foregroundColor(.textPrimary)
    }

    /// Apply card title style
    func cardTitleStyle() -> some View {
        self
            .font(.cardTitle)
            .foregroundColor(.textPrimary)
            .lineLimit(2)
    }

    /// Apply title style
    func titleStyle() -> some View {
        self
            .font(.titleMedium)
            .foregroundColor(.textPrimary)
    }

    /// Apply body style
    func bodyStyle() -> some View {
        self
            .font(.bodyMedium)
            .foregroundColor(.textPrimary)
    }

    /// Apply body large style
    func bodyLargeStyle() -> some View {
        self
            .font(.bodyLarge)
            .foregroundColor(.textPrimary)
    }

    /// Apply secondary text style
    func secondaryStyle() -> some View {
        self
            .font(.bodySmall)
            .foregroundColor(.textSecondary)
    }

    /// Apply tertiary text style
    func tertiaryStyle() -> some View {
        self
            .font(.bodySmall)
            .foregroundColor(.textTertiary)
    }

    /// Apply caption style
    func captionStyle() -> some View {
        self
            .font(.captionRegular)
            .foregroundColor(.textSecondary)
    }

    /// Apply label style
    func labelStyle() -> some View {
        self
            .font(.labelMedium)
            .foregroundColor(.textSecondary)
    }

    /// Apply overline style
    func overlineStyle() -> some View {
        self
            .font(.overline)
            .foregroundColor(.textTertiary)
            .textCase(.uppercase)
            .tracking(1.2)
    }

    /// Apply metadata style
    func metadataStyle() -> some View {
        self
            .font(.metadata)
            .foregroundColor(.textTertiary)
    }

    /// Apply button text style
    func buttonTextStyle() -> some View {
        self
            .font(.buttonMedium)
            .foregroundColor(.textPrimary)
    }

    /// Apply rating style with color
    func ratingStyle(score: Double) -> some View {
        self
            .font(.rating)
            .foregroundColor(.rating(for: score))
    }
}

// MARK: - Text Line Heights & Spacing

extension Text {

    /// Apply proper line spacing for readability
    func readable() -> some View {
        self.lineSpacing(4)
    }

    /// Apply tight line spacing
    func tight() -> some View {
        self.lineSpacing(2)
    }

    /// Apply loose line spacing
    func loose() -> some View {
        self.lineSpacing(6)
    }

    /// Apply letter spacing
    func spaced() -> Text {
        self.tracking(0.5)
    }

    /// Apply wide letter spacing for titles
    func wideSpaced() -> Text {
        self.tracking(1.0)
    }

    /// Apply uppercase with proper tracking
    func uppercaseStyled() -> some View {
        self
            .textCase(.uppercase)
            .tracking(1.5)
    }
}

// MARK: - Dynamic Type Support

extension Font {
    
    static func scaledSystem(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default, relativeTo textStyle: Font.TextStyle = .body) -> Font {
        Font.system(size: size, weight: weight, design: design).dynamicTypeSize(relativeTo: textStyle)
    }
}

extension Font {
    func dynamicTypeSize(relativeTo textStyle: Font.TextStyle) -> Font {
        self
    }
}

#if canImport(UIKit)
struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    let size: CGFloat
    let weight: Font.Weight
    let design: Font.Design
    let relativeTo: Font.TextStyle
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics(forTextStyle: mapToUIFontTextStyle(relativeTo)).scaledValue(for: size)
        return content.font(.system(size: scaledSize, weight: weight, design: design))
    }
    
    private func mapToUIFontTextStyle(_ style: Font.TextStyle) -> UIFont.TextStyle {
        switch style {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}
#endif

#if canImport(UIKit)
extension View {
    func scaledFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default, relativeTo: Font.TextStyle = .body) -> some View {
        self.modifier(ScaledFont(size: size, weight: weight, design: design, relativeTo: relativeTo))
    }
}
#endif

// MARK: - Text Gradient

extension View {

    /// Apply gradient to text
    func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .mask(self)
    }

    /// Apply accent gradient to text
    func accentGradientText() -> some View {
        self.gradientForeground(colors: [.accentPurple, .accentPink])
    }

    /// Apply gold gradient to text
    func goldGradientText() -> some View {
        self.gradientForeground(colors: [Color(hex: "D4AF37"), Color(hex: "FFD700"), Color(hex: "D4AF37")])
    }
}
