//
//  WatchlistView.swift
//  MovieTrailer
//
//  Apple 2025 Premium Library Experience
//  Smart collections, watch progress, and stats
//

import SwiftUI
import Kingfisher

struct WatchlistView: View {

    @StateObject private var viewModel: WatchlistViewModel
    @State private var showingSortOptions = false
    @State private var showingShareSheet = false
    @State private var selectedCollection: LibraryCollection = .all
    @State private var isGridView = false

    let onItemTap: (WatchlistItem) -> Void
    let onBrowseMovies: () -> Void
    let onDiscover: () -> Void

    init(
        viewModel: WatchlistViewModel,
        onItemTap: @escaping (WatchlistItem) -> Void = { _ in },
        onBrowseMovies: @escaping () -> Void = {},
        onDiscover: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onItemTap = onItemTap
        self.onBrowseMovies = onBrowseMovies
        self.onDiscover = onDiscover
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isEmpty {
                emptyStateView
            } else {
                libraryContent
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Library")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: Spacing.sm) {
                    // View toggle
                    Button {
                        Haptics.shared.selectionChanged()
                        withAnimation(AppTheme.Animation.smooth) {
                            isGridView.toggle()
                        }
                    } label: {
                        Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.textPrimary)
                    }

                    // More options
                    if !viewModel.isEmpty {
                        Menu {
                            sortMenu
                            Divider()
                            shareMenu
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = viewModel.shareImage {
                ShareSheet(items: [image])
            }
        }
    }

    // MARK: - Library Content

    private var libraryContent: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Premium stats section
                premiumStatsSection

                // Collection tabs
                collectionTabs

                // Content based on view mode
                if isGridView {
                    gridContent
                } else {
                    listContent
                }

                // Bottom padding
                Spacer()
                    .frame(height: 120)
            }
        }
    }

    // MARK: - Premium Stats Section

    private var premiumStatsSection: some View {
        HStack(spacing: Spacing.lg) {
            // Total movies stat
            statCard(
                value: "\(viewModel.count)",
                label: "Movies",
                icon: "film.fill",
                color: .accentPrimary
            )

            // Watch time estimate
            statCard(
                value: estimatedWatchTime,
                label: "Watch Time",
                icon: "clock.fill",
                color: .cyan
            )

            // Top genre
            statCard(
                value: topGenre,
                label: "Top Genre",
                icon: "star.fill",
                color: .orange
            )
        }
        .padding(.horizontal, Spacing.horizontal)
        .padding(.top, Spacing.md)
    }

    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(spacing: 2) {
                Text(value)
                    .font(.headline2)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(label)
                    .font(.labelSmall)
                    .foregroundColor(.textTertiary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .background(Color.glassLight)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(Color.glassBorder, lineWidth: 0.5)
        )
    }

    private var estimatedWatchTime: String {
        let hours = viewModel.count * 2 // Assume 2 hours per movie
        if hours >= 24 {
            return "\(hours / 24)d \(hours % 24)h"
        }
        return "\(hours)h"
    }

    private var topGenre: String {
        // Calculate the most common genre from watchlist items
        let allGenreIds = viewModel.items.flatMap { $0.genreIds }
        guard !allGenreIds.isEmpty else { return "None" }

        // Count occurrences of each genre
        var genreCounts: [Int: Int] = [:]
        for genreId in allGenreIds {
            genreCounts[genreId, default: 0] += 1
        }

        // Find the most common genre
        if let topGenreId = genreCounts.max(by: { $0.value < $1.value })?.key,
           let genre = Genre.genre(for: topGenreId) {
            return genre.name
        }

        return "Mixed"
    }

    // MARK: - Collection Tabs

    private var collectionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(LibraryCollection.allCases) { collection in
                    CollectionTabButton(
                        collection: collection,
                        isSelected: selectedCollection == collection,
                        count: collectionCount(for: collection)
                    ) {
                        Haptics.shared.selectionChanged()
                        withAnimation(AppTheme.Animation.smooth) {
                            selectedCollection = collection
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }

    private func collectionCount(for collection: LibraryCollection) -> Int {
        viewModel.count(for: collection)
    }

    /// Get items for the current selected collection
    private var filteredItems: [WatchlistItem] {
        viewModel.items(for: selectedCollection)
    }

    // MARK: - Grid Content

    private var gridContent: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md),
                GridItem(.flexible(), spacing: Spacing.md)
            ],
            spacing: Spacing.md
        ) {
            ForEach(filteredItems) { item in
                LibraryGridCard(
                    item: item,
                    onTap: { onItemTap(item) },
                    onDelete: {
                        withAnimation(AppTheme.Animation.smooth) {
                            viewModel.removeItem(item)
                        }
                    },
                    onToggleWatched: {
                        withAnimation(AppTheme.Animation.smooth) {
                            viewModel.toggleWatched(item)
                        }
                    }
                )
            }
        }
        .padding(.horizontal, Spacing.horizontal)
    }

    // MARK: - List Content

    private var listContent: some View {
        LazyVStack(spacing: Spacing.sm) {
            ForEach(filteredItems) { item in
                LibraryListRow(
                    item: item,
                    onTap: { onItemTap(item) },
                    onDelete: {
                        withAnimation(AppTheme.Animation.smooth) {
                            viewModel.removeItem(item)
                        }
                    },
                    onStartLiveActivity: {
                        Task {
                            await viewModel.startLiveActivity(for: item)
                        }
                    },
                    onToggleWatched: {
                        withAnimation(AppTheme.Animation.smooth) {
                            viewModel.toggleWatched(item)
                        }
                    }
                )
            }
        }
        .padding(.horizontal, Spacing.horizontal)
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        ForEach(WatchlistItem.SortOption.allCases, id: \.self) { option in
            Button {
                Haptics.shared.selectionChanged()
                viewModel.sortOption = option
            } label: {
                HStack {
                    Text(option.displayName)
                    if viewModel.sortOption == option {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }

    // MARK: - Share Menu

    private var shareMenu: some View {
        Button {
            Task {
                await viewModel.generateShareImage()
                showingShareSheet = true
            }
        } label: {
            Label("Share Watchlist", systemImage: "square.and.arrow.up")
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Spacing.xl) {
            // Animated empty state
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.accentPrimary.opacity(0.1), .accentSecondary.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(systemName: "bookmark.slash")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.textSecondary, .textTertiary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: Spacing.sm) {
                Text("Your Library is Empty")
                    .font(.displaySmall)
                    .foregroundColor(.textPrimary)

                Text("Start adding movies to your library to keep track of what you want to watch!")
                    .font(.bodyMedium)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.xl)

            // Suggestion buttons
            VStack(spacing: Spacing.md) {
                Text("Try these:")
                    .font(.labelMedium)
                    .foregroundColor(.textTertiary)

                HStack(spacing: Spacing.sm) {
                    suggestionButton(title: "Browse Movies", icon: "film.fill") {
                        onBrowseMovies()
                    }
                    suggestionButton(title: "Discover", icon: "rectangle.stack.fill") {
                        onDiscover()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func suggestionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.shared.buttonTapped()
            action()
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.buttonMedium)
            }
            .foregroundColor(.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.glassLight)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Library Collection

enum LibraryCollection: String, CaseIterable, Identifiable {
    case all = "All"
    case favorites = "Favorites"
    case toWatch = "To Watch"
    case watched = "Watched"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .favorites: return "heart.fill"
        case .toWatch: return "bookmark.fill"
        case .watched: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Collection Tab Button

struct CollectionTabButton: View {
    let collection: LibraryCollection
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: collection.icon)
                    .font(.system(size: 12, weight: .medium))

                Text(collection.rawValue)
                    .font(.labelMedium)

                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isSelected ? .textInverted : .textTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.2) : Color.glassLight)
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(isSelected ? .textInverted : .textSecondary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Color.accentPrimary : Color.glassThin)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.glassBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Library Grid Card

struct LibraryGridCard: View {
    let item: WatchlistItem
    let onTap: () -> Void
    let onDelete: () -> Void
    let onToggleWatched: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            Haptics.shared.cardTapped()
            onTap()
        }) {
            ZStack(alignment: .topTrailing) {
                // Poster
                KFImage(item.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                            .shimmer(isActive: true)
                    }
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                            .stroke(item.isWatched ? Color.green.opacity(0.5) : Color.glassBorder, lineWidth: item.isWatched ? 2 : 0.5)
                    )

                // Rating badge & watched indicator
                VStack(spacing: 4) {
                    if item.isWatched {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.green)
                            .background(Circle().fill(.ultraThinMaterial))
                    }

                    if item.voteAverage > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.ratingStar)
                            Text(item.formattedRating)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                }
                .padding(6)
            }
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(AppTheme.Animation.quick, value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .contextMenu {
            Button {
                Haptics.shared.selectionChanged()
                onToggleWatched()
            } label: {
                Label(item.isWatched ? "Mark as Unwatched" : "Mark as Watched",
                      systemImage: item.isWatched ? "eye.slash" : "checkmark.circle")
            }

            Button(role: .destructive) {
                Haptics.shared.lightImpact()
                onDelete()
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }
}

// MARK: - Library List Row

struct LibraryListRow: View {
    let item: WatchlistItem
    let onTap: () -> Void
    let onDelete: () -> Void
    let onStartLiveActivity: () -> Void
    let onToggleWatched: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            Haptics.shared.cardTapped()
            onTap()
        }) {
            HStack(spacing: Spacing.md) {
                // Poster with watched indicator
                ZStack(alignment: .bottomTrailing) {
                    KFImage(item.posterURL)
                        .placeholder {
                            Rectangle()
                                .fill(Color.surfaceSecondary)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 105)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                                .stroke(item.isWatched ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
                        )

                    if item.isWatched {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                            .background(Circle().fill(.ultraThinMaterial))
                            .offset(x: 4, y: 4)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    HStack {
                        Text(item.title)
                            .font(.headline3)
                            .foregroundColor(.textPrimary)
                            .lineLimit(2)

                        if item.isWatched {
                            Text("Watched")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }

                    if let year = item.releaseYear {
                        Text(year)
                            .font(.labelSmall)
                            .foregroundColor(.textTertiary)
                    }

                    HStack(spacing: Spacing.sm) {
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.ratingStar)
                            Text(item.formattedRating)
                                .font(.labelMedium)
                                .foregroundColor(.textSecondary)
                        }

                        // Added date
                        Text(item.timeSinceAdded)
                            .font(.labelSmall)
                            .foregroundColor(.textTertiary)
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: Spacing.sm) {
                    // Watched toggle button
                    Button {
                        Haptics.shared.selectionChanged()
                        onToggleWatched()
                    } label: {
                        Image(systemName: item.isWatched ? "eye.slash" : "checkmark.circle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(item.isWatched ? .orange : .green)
                            .frame(width: 36, height: 36)
                            .background((item.isWatched ? Color.orange : Color.green).opacity(0.15))
                            .clipShape(Circle())
                    }
                    .buttonStyle(ScaleButtonStyle())

                    // Notification button
                    Button {
                        Haptics.shared.buttonTapped()
                        onStartLiveActivity()
                    } label: {
                        Image(systemName: "bell.badge")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.accentPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.accentPrimary.opacity(0.15))
                            .clipShape(Circle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(Spacing.md)
            .background(Color.glassLight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(item.isWatched ? Color.green.opacity(0.3) : Color.glassBorder, lineWidth: item.isWatched ? 1 : 0.5)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.quick, value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Haptics.shared.lightImpact()
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                Haptics.shared.selectionChanged()
                onToggleWatched()
            } label: {
                Label(item.isWatched ? "Unwatched" : "Watched",
                      systemImage: item.isWatched ? "eye.slash" : "checkmark.circle")
            }
            .tint(item.isWatched ? .orange : .green)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#if DEBUG
struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WatchlistView(viewModel: .mock())
        }
        .preferredColorScheme(.dark)
    }
}
#endif
