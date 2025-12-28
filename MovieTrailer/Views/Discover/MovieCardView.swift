//
//  MovieCardView.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Implemented by Claude Code Audit on 28/12/2025.
//

import SwiftUI
import Kingfisher

/// Compact movie card for horizontal scrolling lists in Discover view
struct MovieCardView: View {

    // MARK: - Properties

    let movie: Movie
    let size: CardSize
    var onTap: (() -> Void)?

    // MARK: - Card Sizes

    enum CardSize {
        case small   // 120x180 - for compact lists
        case medium  // 150x225 - for featured lists
        case large   // 200x300 - for hero sections

        var width: CGFloat {
            switch self {
            case .small: return 120
            case .medium: return 150
            case .large: return 200
            }
        }

        var height: CGFloat {
            width * 1.5 // 2:3 aspect ratio
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }

        var titleFont: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .headline
            }
        }
    }

    // MARK: - Body

    var body: some View {
        Button {
            HapticManager.shared.openedDetail()
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Poster image
                posterImage

                // Title and rating
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(size.titleFont)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)

                        Text(movie.formattedRating)
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        if let year = movie.releaseYear {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(year)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(width: size.width, alignment: .leading)
            }
        }
        .buttonStyle(DiscoverCardButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(movie.title), rated \(movie.formattedRating)")
        .accessibilityHint("Double tap to view details")
    }

    // MARK: - Poster Image

    private var posterImage: some View {
        KFImage(movie.posterURL)
            .placeholder {
                posterPlaceholder
            }
            .resizable()
            .aspectRatio(2/3, contentMode: .fill)
            .frame(width: size.width, height: size.height)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }

    private var posterPlaceholder: some View {
        RoundedRectangle(cornerRadius: size.cornerRadius)
            .fill(
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size.width, height: size.height)
            .overlay(
                Image(systemName: "film")
                    .font(.system(size: size.width * 0.25))
                    .foregroundColor(.white.opacity(0.5))
            )
    }
}

// MARK: - Discover Card Button Style

struct DiscoverCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#if DEBUG
struct MovieCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                MovieCardView(movie: .sample, size: .small)
                MovieCardView(movie: .sample, size: .medium)
                MovieCardView(movie: .sample, size: .large)
            }
            .padding()
        }
    }
}
#endif
