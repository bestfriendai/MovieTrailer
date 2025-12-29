//
//  WatchlistView.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 11/12/2025.
//

import SwiftUI

struct WatchlistView: View {
    
    @StateObject private var viewModel: WatchlistViewModel
    @State private var showingSortOptions = false
    @State private var showingShareSheet = false
    let onItemTap: (WatchlistItem) -> Void
    
    init(viewModel: WatchlistViewModel, onItemTap: @escaping (WatchlistItem) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onItemTap = onItemTap
    }
    
    var body: some View {
        ZStack {
            if viewModel.isEmpty {
                emptyStateView
            } else {
                watchlistContent
            }
        }
        .navigationTitle("Watchlist")
        .toolbar {
            if !viewModel.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        sortMenu
                        Divider()
                        shareMenu
                    } label: {
                        Image(systemName: "ellipsis.circle")
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
    
    // MARK: - Watchlist Content
    
    private var watchlistContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Stats banner
                statsBanner
                
                // Movie list
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.items) { item in
                        WatchlistItemRow(
                            item: item,
                            onTap: {
                                onItemTap(item)
                            },
                            onDelete: {
                                withAnimation {
                                    viewModel.removeItem(item)
                                }
                            },
                            onStartLiveActivity: {
                                Task {
                                    await viewModel.startLiveActivity(for: item)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Stats Banner
    
    private var statsBanner: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("\(viewModel.count)")
                    .font(.title.bold())
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Text("Movies")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
                .frame(height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "bookmark.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text("Sorted by")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(viewModel.sortOption.displayName)
                    .font(.subheadline.bold())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Sort Menu
    
    private var sortMenu: some View {
        ForEach(WatchlistItem.SortOption.allCases, id: \.self) { option in
            Button {
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
        VStack(spacing: 24) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Your Watchlist is Empty")
                .font(.title2.bold())
            
            Text("Start adding movies to your watchlist to keep track of what you want to watch!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Watchlist Item Row

struct WatchlistItemRow: View {
    
    let item: WatchlistItem
    let onTap: () -> Void
    let onDelete: () -> Void
    let onStartLiveActivity: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Poster
                AsyncImage(url: item.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(width: 60, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if let year = item.releaseYear {
                        Text(year)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        
                        Text(item.formattedRating)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Live Activity button
                Button(action: onStartLiveActivity) {
                    Image(systemName: "bell.badge")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
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
    }
}
#endif
