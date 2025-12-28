//
//  NetworkMonitor.swift
//  MovieTrailer
//
//  Created by Claude Code Audit on 28/12/2025.
//  Monitors network connectivity and provides offline mode support
//

import Foundation
import Network
import Combine
import SwiftUI

/// Network connection type
enum NetworkConnectionType: String {
    case wifi = "WiFi"
    case cellular = "Cellular"
    case wiredEthernet = "Ethernet"
    case unknown = "Unknown"
    case none = "None"
}

/// Network status for the app
struct NetworkStatus {
    let isConnected: Bool
    let connectionType: NetworkConnectionType
    let isExpensive: Bool  // Cellular or hotspot
    let isConstrained: Bool  // Low data mode

    static let disconnected = NetworkStatus(
        isConnected: false,
        connectionType: .none,
        isExpensive: false,
        isConstrained: false
    )
}

/// Monitors network connectivity and publishes changes
@MainActor
final class NetworkMonitor: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var status: NetworkStatus = .disconnected
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var connectionType: NetworkConnectionType = .none

    /// Shows offline banner when disconnected
    @Published var showOfflineBanner: Bool = false

    // MARK: - Private Properties

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.movietrailer.networkmonitor", qos: .utility)
    private var isMonitoring = false

    // MARK: - Singleton

    static let shared = NetworkMonitor()

    // MARK: - Initialization

    private init() {
        self.monitor = NWPathMonitor()
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    /// Start monitoring network changes
    func startMonitoring() {
        guard !isMonitoring else { return }

        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.handlePathUpdate(path)
            }
        }

        monitor.start(queue: queue)
        isMonitoring = true

        print("📶 Network monitoring started")
    }

    /// Stop monitoring network changes
    func stopMonitoring() {
        guard isMonitoring else { return }

        monitor.cancel()
        isMonitoring = false

        print("📶 Network monitoring stopped")
    }

    /// Check current connectivity (synchronous)
    func checkConnection() -> Bool {
        return isConnected
    }

    /// Perform action only when online
    func performWhenOnline(_ action: @escaping () async -> Void) async {
        guard isConnected else {
            showOfflineBanner = true
            HapticManager.shared.warning()
            return
        }

        await action()
    }

    /// Dismiss offline banner
    func dismissOfflineBanner() {
        showOfflineBanner = false
    }

    // MARK: - Private Methods

    private func handlePathUpdate(_ path: NWPath) {
        let newStatus = NetworkStatus(
            isConnected: path.status == .satisfied,
            connectionType: determineConnectionType(path),
            isExpensive: path.isExpensive,
            isConstrained: path.isConstrained
        )

        // Check for connectivity change
        let wasConnected = isConnected
        let nowConnected = newStatus.isConnected

        // Update published properties
        self.status = newStatus
        self.isConnected = newStatus.isConnected
        self.connectionType = newStatus.connectionType

        // Handle connectivity change
        if wasConnected && !nowConnected {
            // Lost connection
            showOfflineBanner = true
            HapticManager.shared.warning()
            print("📶 Network disconnected")

            NotificationCenter.default.post(
                name: .networkStatusChanged,
                object: nil,
                userInfo: ["isConnected": false]
            )
        } else if !wasConnected && nowConnected {
            // Regained connection
            showOfflineBanner = false
            HapticManager.shared.success()
            print("📶 Network connected via \(newStatus.connectionType.rawValue)")

            NotificationCenter.default.post(
                name: .networkStatusChanged,
                object: nil,
                userInfo: ["isConnected": true]
            )
        }
    }

    private func determineConnectionType(_ path: NWPath) -> NetworkConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        } else if path.status == .satisfied {
            return .unknown
        } else {
            return .none
        }
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}

// MARK: - Offline Banner View

/// Banner view displayed when offline
struct OfflineBannerView: View {
    @ObservedObject var networkMonitor: NetworkMonitor

    var body: some View {
        if networkMonitor.showOfflineBanner {
            HStack(spacing: 12) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 16, weight: .semibold))

                Text("You're offline")
                    .font(.subheadline.bold())

                Spacer()

                Button {
                    networkMonitor.dismissOfflineBanner()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.9))
            )
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: networkMonitor.showOfflineBanner)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Offline. No internet connection.")
            .accessibilityHint("Tap dismiss button to hide this banner")
        }
    }
}

/// View modifier to add offline banner to any view
struct OfflineBannerModifier: ViewModifier {
    @ObservedObject var networkMonitor = NetworkMonitor.shared

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            OfflineBannerView(networkMonitor: networkMonitor)
                .padding(.top, 8)
        }
    }
}

extension View {
    /// Add offline banner to view
    func withOfflineBanner() -> some View {
        modifier(OfflineBannerModifier())
    }
}

// MARK: - Offline-First Data Strategy

/// Protocol for offline-capable data sources
protocol OfflineCapable {
    associatedtype DataType

    /// Load from cache first, then network
    func loadWithOfflineSupport() async throws -> DataType

    /// Check if cached data exists
    var hasCachedData: Bool { get }

    /// Get cached data without network
    func getCachedData() -> DataType?

    /// Force refresh from network
    func forceRefresh() async throws -> DataType
}

/// Offline cache strategy
enum OfflineCacheStrategy {
    case cacheFirst      // Return cache immediately, update in background
    case networkFirst    // Try network first, fallback to cache
    case cacheOnly       // Only use cache (offline mode)
    case networkOnly     // Only use network (no caching)
}

// MARK: - Preview Helpers

#if DEBUG
extension NetworkMonitor {
    /// Configure for connected state (for previews)
    func configureAsConnected() {
        self.showOfflineBanner = false
    }

    /// Configure for disconnected state (for previews)
    func configureAsDisconnected() {
        self.showOfflineBanner = true
    }
}

struct OfflineBannerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // Create a preview with banner showing
            OfflineBannerView(networkMonitor: {
                let monitor = NetworkMonitor.shared
                monitor.configureAsDisconnected()
                return monitor
            }())
            Spacer()
        }
        .background(Color(uiColor: .systemBackground))
    }
}
#endif
