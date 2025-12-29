//
//  CategoryPill.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Category filter pill component
//

import SwiftUI

// MARK: - Category Definition

enum MovieCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case new = "New"
    case classics = "Classics"
    case tvShows = "TV Shows"
    case animation = "Animation"
    case action = "Action"
    case comedy = "Comedy"
    case drama = "Drama"
    case horror = "Horror"
    case sciFi = "Sci-Fi"
    case romance = "Romance"
    case thriller = "Thriller"
    case documentary = "Documentary"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "sparkles"
        case .new: return "flame.fill"
        case .classics: return "film.fill"
        case .tvShows: return "tv.fill"
        case .animation: return "paintpalette.fill"
        case .action: return "bolt.fill"
        case .comedy: return "face.smiling.fill"
        case .drama: return "theatermasks.fill"
        case .horror: return "moon.fill"
        case .sciFi: return "sparkle"
        case .romance: return "heart.fill"
        case .thriller: return "eye.fill"
        case .documentary: return "video.fill"
        }
    }

    var color: Color {
        switch self {
        case .all: return .gray
        case .new: return .categoryNew
        case .classics: return .categoryClassics
        case .tvShows: return .categoryTV
        case .animation: return .categoryAnimation
        case .action: return .categoryAction
        case .comedy: return .categoryComedy
        case .drama: return .categoryDrama
        case .horror: return .categoryHorror
        case .sciFi: return .categorySciFi
        case .romance: return .categoryRomance
        case .thriller: return .categoryThriller
        case .documentary: return .categoryDocumentary
        }
    }

    /// TMDB genre IDs for filtering
    var genreIds: [Int]? {
        switch self {
        case .all: return nil
        case .new: return nil  // Will filter by release date
        case .classics: return nil  // Will filter by release date
        case .tvShows: return nil  // Different API endpoint
        case .animation: return [16]
        case .action: return [28]
        case .comedy: return [35]
        case .drama: return [18]
        case .horror: return [27]
        case .sciFi: return [878]
        case .romance: return [10749]
        case .thriller: return [53]
        case .documentary: return [99]
        }
    }
}

// MARK: - Category Pill View

struct CategoryPill: View {

    let category: MovieCategory
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            Haptics.shared.filterChanged()
            onTap()
        }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(isSelected ? .white : category.color)

                Text(category.rawValue)
                    .font(.pill)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : Color(.systemGray6))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 0.5)
            )
        }
        .buttonStyle(PillButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(AppTheme.Animation.standard, value: isSelected)
    }
}

// MARK: - Pill Button Style

struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(AppTheme.Animation.stiff, value: configuration.isPressed)
    }
}

// MARK: - Category Scroll View

struct CategoryScrollView: View {

    @Binding var selectedCategory: MovieCategory
    let categories: [MovieCategory]

    init(
        selectedCategory: Binding<MovieCategory>,
        categories: [MovieCategory] = MovieCategory.allCases
    ) {
        self._selectedCategory = selectedCategory
        self.categories = categories
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(categories) { category in
                    CategoryPill(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CategoryPill_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Individual pills
            HStack {
                CategoryPill(category: .all, isSelected: true) {}
                CategoryPill(category: .new, isSelected: false) {}
                CategoryPill(category: .action, isSelected: false) {}
            }

            // Scroll view
            CategoryScrollView(selectedCategory: .constant(.all))
        }
        .padding()
    }
}
#endif
