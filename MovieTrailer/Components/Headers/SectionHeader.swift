//
//  SectionHeader.swift
//  MovieTrailer
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var iconColor: Color = .blue
    var showSeeAll: Bool = false
    var onSeeAll: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let icon = icon {
                IconBadge(icon: icon, color: iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Spacer()

            if showSeeAll, let action = onSeeAll {
                Button(action: action) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, Spacing.horizontal)
    }
}

// MARK: - Icon Badge

struct IconBadge: View {
    let icon: String
    var color: Color = .blue
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)

            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Compact Section Header

struct CompactSectionHeader: View {
    let title: String
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Spacer()

            if let action = action {
                Button(action: action) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, Spacing.horizontal)
    }
}

// MARK: - Category Section Header

struct CategorySectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    var movieCount: Int? = nil

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                if let count = movieCount {
                    Text("\(count) movies")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.horizontal)
    }
}
