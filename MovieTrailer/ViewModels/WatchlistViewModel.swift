//
//  WatchlistViewModel.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import Foundation
import Combine

/// ViewModel for the Watchlist tab
@MainActor
final class WatchlistViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var sortOption: WatchlistItem.SortOption = .dateAdded
    @Published var isGeneratingImage = false
    @Published var shareImage: UIImage?
    
    // MARK: - Dependencies
    
    private let watchlistManager: WatchlistManager
    private let liveActivityManager: LiveActivityManager
    
    // MARK: - Computed Properties
    
    var items: [WatchlistItem] {
        watchlistManager.sorted(by: sortOption)
    }
    
    var isEmpty: Bool {
        watchlistManager.isEmpty
    }
    
    var count: Int {
        watchlistManager.count
    }
    
    // MARK: - Initialization
    
    init(
        watchlistManager: WatchlistManager,
        liveActivityManager: LiveActivityManager
    ) {
        self.watchlistManager = watchlistManager
        self.liveActivityManager = liveActivityManager
    }
    
    // MARK: - Public Methods
    
    /// Remove item from watchlist
    func removeItem(_ item: WatchlistItem) {
        watchlistManager.remove(item.id)
    }
    
    /// Clear all items
    func clearAll() {
        watchlistManager.clearAll()
    }
    
    /// Generate shareable image
    func generateShareImage() async {
        isGeneratingImage = true
        
        let image = await ImageGenerator.generateWatchlistImage(
            items: Array(items.prefix(12))
        )
        
        shareImage = image
        isGeneratingImage = false
    }
    
    /// Start Live Activity for an item
    func startLiveActivity(for item: WatchlistItem) async {
        await liveActivityManager.startActivity(for: item)
    }
    
    /// End current Live Activity
    func endLiveActivity() async {
        await liveActivityManager.endActivity()
    }
    
    /// Check if Live Activity is active
    var isLiveActivityActive: Bool {
        liveActivityManager.isActive
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension WatchlistViewModel {
    static func mock() -> WatchlistViewModel {
        WatchlistViewModel(
            watchlistManager: .mock(),
            liveActivityManager: .mock(isActive: true)
        )
    }
}
#endif
