//
//  StreamingBadge.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Streaming service badge/pill component
//

import SwiftUI
import Kingfisher

// MARK: - Streaming Service Definition

enum StreamingService: String, CaseIterable, Identifiable, Codable {
    case netflix = "Netflix"
    case disneyPlus = "Disney+"
    case amazonPrime = "Prime Video"
    case hboMax = "Max"
    case appleTVPlus = "Apple TV+"
    case hulu = "Hulu"
    case peacock = "Peacock"
    case paramount = "Paramount+"
    case tubi = "Tubi"
    case plutoTV = "Pluto TV"
    case crunchyroll = "Crunchyroll"
    case showtime = "Showtime"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var providerId: Int {
        switch self {
        case .netflix: return 8
        case .disneyPlus: return 337
        case .amazonPrime: return 9
        case .hboMax: return 1899
        case .appleTVPlus: return 350
        case .hulu: return 15
        case .peacock: return 386
        case .paramount: return 531
        case .tubi: return 73
        case .plutoTV: return 300
        case .crunchyroll: return 283
        case .showtime: return 37
        }
    }

    var color: Color {
        switch self {
        case .netflix: return .netflix
        case .disneyPlus: return .disneyPlus
        case .amazonPrime: return .amazonPrime
        case .hboMax: return .hboMax
        case .appleTVPlus: return .appleTVPlus
        case .hulu: return .hulu
        case .peacock: return .peacock
        case .paramount: return .paramount
        case .tubi: return Color(hex: "FA382F")
        case .plutoTV: return Color(hex: "000000")
        case .crunchyroll: return Color(hex: "F47521")
        case .showtime: return Color(hex: "FF0000")
        }
    }

    var shortName: String {
        switch self {
        case .netflix: return "Netflix"
        case .disneyPlus: return "Disney+"
        case .amazonPrime: return "Prime"
        case .hboMax: return "Max"
        case .appleTVPlus: return "Apple TV+"
        case .hulu: return "Hulu"
        case .peacock: return "Peacock"
        case .paramount: return "P+"
        case .tubi: return "Tubi"
        case .plutoTV: return "Pluto"
        case .crunchyroll: return "CR"
        case .showtime: return "SHO"
        }
    }

    var logoURL: URL? {
        let basePath = "https://image.tmdb.org/t/p/w92"
        let paths: [StreamingService: String] = [
            .netflix: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
            .disneyPlus: "/7rwgEs15tFwyR9NPQ5vpzxTj19Q.jpg",
            .amazonPrime: "/emthp39XA2YScoYL1p0sdbAH2WA.jpg",
            .hboMax: "/6Q3ZYUNA9H52L5Znr4emJtwnpAl.jpg",
            .appleTVPlus: "/6uhKBfmtzFqOcLousHwZuzcrScK.jpg",
            .hulu: "/zxrVdFjIjLqkfnwyghnfywTn3Lh.jpg",
            .peacock: "/xTHltMrZPAJFLQ6qyCBjAnXSmZt.jpg",
            .paramount: "/xbhHHa1YgtpwhC8lb1NQ3ACVcLd.jpg"
        ]
        guard let path = paths[self] else { return nil }
        return URL(string: basePath + path)
    }

    var isFree: Bool {
        switch self {
        case .tubi, .plutoTV: return true
        default: return false
        }
    }
}

// MARK: - Streaming Badge View

struct StreamingBadge: View {

    let service: StreamingService
    let style: BadgeStyle
    let isSelected: Bool
    let onTap: (() -> Void)?

    enum BadgeStyle {
        case compact    // Icon only
        case standard   // Icon + name
        case large      // Large logo with name below
    }

    init(
        service: StreamingService,
        style: BadgeStyle = .standard,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        self.service = service
        self.style = style
        self.isSelected = isSelected
        self.onTap = onTap
    }

    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: {
                    Haptics.shared.selectionChanged()
                    onTap()
                }) {
                    content
                }
                .buttonStyle(PillButtonStyle())
            } else {
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch style {
        case .compact:
            compactBadge
        case .standard:
            standardBadge
        case .large:
            largeBadge
        }
    }

    // MARK: - Compact Badge

    private var compactBadge: some View {
        Group {
            if let url = service.logoURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text(service.shortName.prefix(1))
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(service.color)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }

    // MARK: - Standard Badge

    private var standardBadge: some View {
        HStack(spacing: Spacing.xs) {
            if let url = service.logoURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            Text(service.shortName)
                .font(.caption.weight(.medium))
                .foregroundColor(isSelected ? .white : .primary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(
            Capsule()
                .fill(isSelected ? service.color : Color(.systemGray6))
        )
        .overlay(
            Capsule()
                .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 0.5)
        )
    }

    // MARK: - Large Badge

    private var largeBadge: some View {
        VStack(spacing: Spacing.xs) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .fill(isSelected ? service.color.opacity(0.1) : Color(.systemGray6))
                    .frame(width: 70, height: 70)

                if let url = service.logoURL {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Text(service.shortName.prefix(2))
                        .font(.title2.bold())
                        .foregroundColor(service.color)
                }

                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(service.color)
                                .background(Circle().fill(.white))
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(isSelected ? service.color : Color.clear, lineWidth: 2)
            )

            Text(service.shortName)
                .font(.caption2)
                .foregroundColor(isSelected ? service.color : .secondary)
                .lineLimit(1)
        }
        .frame(width: 70)
    }
}

// MARK: - Streaming Badges Row

struct StreamingBadgesRow: View {

    let providers: [WatchProvider]
    let maxVisible: Int

    init(providers: [WatchProvider], maxVisible: Int = 4) {
        self.providers = providers
        self.maxVisible = maxVisible
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(providers.prefix(maxVisible)) { provider in
                if let url = provider.logoURL {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }

            if providers.count > maxVisible {
                Text("+\(providers.count - maxVisible)")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct StreamingBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Compact badges
            HStack {
                StreamingBadge(service: .netflix, style: .compact)
                StreamingBadge(service: .disneyPlus, style: .compact)
                StreamingBadge(service: .amazonPrime, style: .compact)
            }

            // Standard badges
            HStack {
                StreamingBadge(service: .netflix, style: .standard, isSelected: true)
                StreamingBadge(service: .disneyPlus, style: .standard)
            }

            // Large badges
            HStack {
                StreamingBadge(service: .netflix, style: .large, isSelected: true) {}
                StreamingBadge(service: .disneyPlus, style: .large) {}
                StreamingBadge(service: .hboMax, style: .large) {}
            }
        }
        .padding()
    }
}
#endif
