//
//  WatchlistGridView.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Implemented by Claude Code Audit on 28/12/2025.
//

import SwiftUI
import Kingfisher

/// Grid view for displaying watchlist items with context menu
struct WatchlistGridView: View {

    // MARK: - Properties

    let items: [WatchlistItem]
    let columns: Int
    var onItemTap: ((WatchlistItem) -> Void)?
    var onDelete: ((WatchlistItem) -> Void)?

    @State private var itemToDelete: WatchlistItem?
    @State private var showDeleteConfirmation = false

    // MARK: - Grid Layout

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: columns)
    }

    // MARK: - Body

    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 20) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                WatchlistGridItem(
                    item: item,
                    onTap: { onItemTap?(item) },
                    onDelete: {
                        itemToDelete = item
                        showDeleteConfirmation = true
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 0.8))
                ))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: items.count)
        .confirmationDialog(
            "Remove from Watchlist?",
            isPresented: $showDeleteConfirmation,
            presenting: itemToDelete
        ) { item in
            Button("Remove", role: .destructive) {
                HapticManager.shared.removedFromWatchlist()
                onDelete?(item)
            }
            Button("Cancel", role: .cancel) {}
        } message: { item in
            Text("Remove \"\(item.title)\" from your watchlist?")
        }
    }
}

// MARK: - Watchlist Grid Item

struct WatchlistGridItem: View {

    let item: WatchlistItem
    var onTap: (() -> Void)?
    var onDelete: (() -> Void)?

    var body: some View {
        Button {
            HapticManager.shared.openedDetail()
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Poster with context menu
                posterImage
                    .contextMenu {
                        Button(role: .destructive) {
                            onDelete?()
                        } label: {
                            Label("Remove from Watchlist", systemImage: "bookmark.slash")
                        }

                        Button {
                            // Share action placeholder
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }

                // Movie info
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)

                        Text(item.formattedRating)
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(item.timeSinceAdded)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .buttonStyle(WatchlistGridButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), rated \(item.formattedRating), added \(item.timeSinceAdded)")
        .accessibilityHint("Double tap to view details. Long press for options.")
    }

    private var posterImage: some View {
        KFImage(item.posterURL)
            .placeholder {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: "film")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
            .resizable()
            .aspectRatio(2/3, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Button Style

struct WatchlistGridButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

#if DEBUG
struct WatchlistGridView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            WatchlistGridView(
                items: WatchlistItem.samples,
                columns: 2,
                onItemTap: { print("Tapped: \($0.title)") },
                onDelete: { print("Delete: \($0.title)") }
            )
            .padding()
        }
    }
}
#endif
