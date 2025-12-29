//
//  Typography.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Typography system using SF Pro
//

import SwiftUI

// MARK: - Typography Extensions

extension Font {

    // MARK: - Display Fonts

    /// Large display title - 40pt Bold
    static let displayLarge = Font.system(size: 40, weight: .bold, design: .default)

    /// Medium display title - 34pt Bold
    static let displayMedium = Font.system(size: 34, weight: .bold, design: .default)

    /// Small display title - 28pt Bold
    static let displaySmall = Font.system(size: 28, weight: .bold, design: .default)

    // MARK: - Header Fonts

    /// Section header - 22pt Semibold
    static let sectionHeader = Font.system(size: 22, weight: .semibold, design: .default)

    /// Section title - alias for sectionHeader
    static let sectionTitle = Font.system(size: 20, weight: .bold, design: .default)

    /// Card title - 18pt Semibold
    static let cardTitle = Font.system(size: 18, weight: .semibold, design: .default)

    /// Subsection header - 16pt Semibold
    static let subsectionHeader = Font.system(size: 16, weight: .semibold, design: .default)

    // MARK: - Body Fonts

    /// Body large - 17pt Regular
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)

    /// Body medium - 15pt Regular
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)

    /// Body small - 13pt Regular
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Label Fonts

    /// Label large - 14pt Medium
    static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)

    /// Label medium - 12pt Medium
    static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)

    /// Label small - 11pt Medium
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)

    // MARK: - Caption Fonts

    /// Caption - 12pt Regular
    static let captionRegular = Font.system(size: 12, weight: .regular, design: .default)

    /// Caption bold - 12pt Semibold
    static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)

    // MARK: - Button Fonts

    /// Button large - 17pt Semibold
    static let buttonLarge = Font.system(size: 17, weight: .semibold, design: .default)

    /// Button medium - 15pt Semibold
    static let buttonMedium = Font.system(size: 15, weight: .semibold, design: .default)

    /// Button small - 13pt Semibold
    static let buttonSmall = Font.system(size: 13, weight: .semibold, design: .default)

    // MARK: - Special Fonts

    /// Rating number - 14pt Bold
    static let rating = Font.system(size: 14, weight: .bold, design: .rounded)

    /// Movie year - 13pt Regular
    static let movieYear = Font.system(size: 13, weight: .regular, design: .default)

    /// Pill text - 14pt Medium
    static let pill = Font.system(size: 14, weight: .medium, design: .default)

    /// Badge text - 11pt Bold
    static let badge = Font.system(size: 11, weight: .bold, design: .rounded)

    /// Monospaced for numbers
    static let monoNumber = Font.system(size: 14, weight: .medium, design: .monospaced)
}

// MARK: - Text Style Modifiers

extension View {
    /// Apply display large style
    func displayLargeStyle() -> some View {
        self
            .font(.displayLarge)
            .foregroundColor(.primary)
    }

    /// Apply section header style
    func sectionHeaderStyle() -> some View {
        self
            .font(.sectionHeader)
            .foregroundColor(.primary)
    }

    /// Apply card title style
    func cardTitleStyle() -> some View {
        self
            .font(.cardTitle)
            .foregroundColor(.primary)
            .lineLimit(2)
    }

    /// Apply body style
    func bodyStyle() -> some View {
        self
            .font(.bodyMedium)
            .foregroundColor(.primary)
    }

    /// Apply secondary text style
    func secondaryStyle() -> some View {
        self
            .font(.bodySmall)
            .foregroundColor(.secondary)
    }

    /// Apply caption style
    func captionStyle() -> some View {
        self
            .font(.captionRegular)
            .foregroundColor(.secondary)
    }
}

// MARK: - Text Line Heights

extension Text {
    /// Apply proper line spacing for readability
    func readable() -> some View {
        self.lineSpacing(4)
    }

    /// Apply tight line spacing
    func tight() -> some View {
        self.lineSpacing(2)
    }
}
