//
//  OfflineModeManager.swift
//  MovieTrailer
//

import SwiftUI
import Combine

@MainActor
final class OfflineModeManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isOffline = false
    @Published var cachedCategories: Set<String> = []
    @Published var lastSyncDate: Date?
    @Published var downloadProgress: Double = 0
    @Published var isDownloading = false
    
    // MARK: - Dependencies
    
    private let networkMonitor: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()
    
    var offlineCapabilityMessage: String {
        if cachedCategories.isEmpty {
            return "No content available offline"
        }
        let categories = cachedCategories.joined(separator: ", ")
        return "Available offline: \(categories)"
    }
    
    var hasOfflineContent: Bool {
        !cachedCategories.isEmpty
    }
    
    // MARK: - Initialization
    
    init(networkMonitor: NetworkMonitor = .shared) {
        self.networkMonitor = networkMonitor
        
        observeNetworkStatus()
        loadCachedStatus()
    }
    
    // MARK: - Network Observation
    
    private func observeNetworkStatus() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isOffline = !isConnected
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Download for Offline
    
    func downloadForOffline(categories: [String]) async {
        guard !isDownloading else { return }
        
        isDownloading = true
        downloadProgress = 0
        
        let totalCategories = Double(categories.count)
        
        for (index, category) in categories.enumerated() {
            do {
                try await downloadCategory(category)
                cachedCategories.insert(category)
                downloadProgress = Double(index + 1) / totalCategories
            } catch {
                print("Failed to cache \(category): \(error)")
            }
        }
        
        lastSyncDate = Date()
        saveCachedStatus()
        isDownloading = false
    }
    
    private func downloadCategory(_ category: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // MARK: - Clear Offline Data
    
    func clearOfflineData() async {
        cachedCategories.removeAll()
        lastSyncDate = nil
        downloadProgress = 0
        saveCachedStatus()
    }
    
    // MARK: - Persistence
    
    private func loadCachedStatus() {
        if let data = UserDefaults.standard.data(forKey: "offline_cached_categories"),
           let categories = try? JSONDecoder().decode(Set<String>.self, from: data) {
            cachedCategories = categories
        }
        
        if let timestamp = UserDefaults.standard.object(forKey: "offline_last_sync") as? Date {
            lastSyncDate = timestamp
        }
    }
    
    private func saveCachedStatus() {
        if let data = try? JSONEncoder().encode(cachedCategories) {
            UserDefaults.standard.set(data, forKey: "offline_cached_categories")
        }
        
        if let date = lastSyncDate {
            UserDefaults.standard.set(date, forKey: "offline_last_sync")
        }
    }
}

// MARK: - Offline Status Banner

struct OfflineStatusBanner: View {
    @ObservedObject var offlineManager: OfflineModeManager
    
    var body: some View {
        if offlineManager.isOffline {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("You're Offline")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(offlineManager.offlineCapabilityMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if let lastSync = offlineManager.lastSyncDate {
                    Text(lastSync.formatted(.relative(presentation: .named)))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(Spacing.md)
            .background(Color.orange.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, Spacing.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Download Progress View

struct OfflineDownloadProgress: View {
    @ObservedObject var offlineManager: OfflineModeManager
    
    var body: some View {
        if offlineManager.isDownloading {
            VStack(spacing: Spacing.sm) {
                HStack {
                    Text("Downloading for offline...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(Int(offlineManager.downloadProgress * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: offlineManager.downloadProgress)
                    .tint(.blue)
            }
            .padding(Spacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, Spacing.horizontal)
        }
    }
}
