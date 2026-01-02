//
//  MultiSelectToolbar.swift
//  MovieTrailer
//

import SwiftUI

struct WatchlistMultiSelectToolbar: View {
    let selectedCount: Int
    let onMarkWatched: () -> Void
    let onDelete: () -> Void
    let onCreateCollection: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                }

                Spacer()

                Text("\(selectedCount) selected")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button("Select All") {
                    Haptics.shared.light()
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            }
            .padding(.horizontal, Spacing.horizontal)
            .padding(.vertical, Spacing.sm)

            Divider()
                .background(Color.white.opacity(0.1))

            HStack(spacing: 0) {
                MultiSelectAction(
                    icon: "checkmark.circle",
                    label: "Watched",
                    color: .green,
                    action: onMarkWatched
                )

                MultiSelectAction(
                    icon: "folder.badge.plus",
                    label: "Collection",
                    color: .blue,
                    action: onCreateCollection
                )

                MultiSelectAction(
                    icon: "trash",
                    label: "Remove",
                    color: .red,
                    action: onDelete
                )
            }
            .padding(.vertical, Spacing.md)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Multi Select Action Button

struct MultiSelectAction: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            Haptics.shared.medium()
            action()
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Selectable Watchlist Item Modifier

struct SelectableModifier: ViewModifier {
    let isSelected: Bool
    let isSelectionMode: Bool
    let onToggle: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if isSelectionMode {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color.blue : Color.black.opacity(0.5))
                            .frame(width: 28, height: 28)

                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding(8)
                    .onTapGesture {
                        Haptics.shared.selectionChanged()
                        onToggle()
                    }
                }
            }
            .scaleEffect(isSelected && isSelectionMode ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
    }
}

extension View {
    func selectable(
        isSelected: Bool,
        isSelectionMode: Bool,
        onToggle: @escaping () -> Void
    ) -> some View {
        modifier(SelectableModifier(
            isSelected: isSelected,
            isSelectionMode: isSelectionMode,
            onToggle: onToggle
        ))
    }
}

// MARK: - Selection Mode State

@MainActor
final class SelectionState: ObservableObject {
    @Published var isSelectionMode = false
    @Published var selectedItems: Set<Int> = []

    func toggleSelection(for id: Int) {
        if selectedItems.contains(id) {
            selectedItems.remove(id)
        } else {
            selectedItems.insert(id)
        }

        if selectedItems.isEmpty {
            isSelectionMode = false
        }
    }

    func selectAll(ids: [Int]) {
        selectedItems = Set(ids)
    }

    func deselectAll() {
        selectedItems.removeAll()
        isSelectionMode = false
    }

    func enterSelectionMode(with id: Int) {
        isSelectionMode = true
        selectedItems.insert(id)
    }
}
