//
//  Coordinator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI

/// Base protocol for all coordinators in the app
@MainActor
protocol Coordinator: AnyObject, ObservableObject {
    
    /// Associated type for the coordinator's view
    associatedtype Body: View
    
    /// The main view managed by this coordinator
    @ViewBuilder var body: Body { get }
    
    /// Start the coordinator's flow
    func start()
    
    /// Optional cleanup when coordinator is dismissed
    func finish()
}

// MARK: - Default Implementations

extension Coordinator {
    /// Default implementation of finish (does nothing)
    func finish() {
        // Override in subclass if needed
    }
}

// MARK: - Child Coordinator Management

/// Protocol for coordinators that can manage child coordinators
@MainActor
protocol ParentCoordinator: Coordinator {
    
    /// Type-erased child coordinators
    var childCoordinators: [any Coordinator] { get set }
    
    /// Add a child coordinator
    func addChild(_ coordinator: any Coordinator)
    
    /// Remove a child coordinator
    func removeChild(_ coordinator: any Coordinator)
    
    /// Remove all child coordinators
    func removeAllChildren()
}

// MARK: - Default Implementations for Parent Coordinator

extension ParentCoordinator {
    
    func addChild(_ coordinator: any Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: any Coordinator) {
        childCoordinators.removeAll { child in
            ObjectIdentifier(child) == ObjectIdentifier(coordinator)
        }
    }
    
    func removeAllChildren() {
        childCoordinators.forEach { $0.finish() }
        childCoordinators.removeAll()
    }
}

// MARK: - Navigation Coordinator

/// Protocol for coordinators that handle navigation
@MainActor
protocol NavigationCoordinator: Coordinator {
    
    /// Navigation path for programmatic navigation
    var navigationPath: NavigationPath { get set }
    
    /// Navigate to a specific destination
    func navigate(to destination: any Hashable)
    
    /// Pop to root
    func popToRoot()
    
    /// Pop one level
    func pop()
}

// MARK: - Default Implementations for Navigation Coordinator

extension NavigationCoordinator {
    
    func navigate(to destination: any Hashable) {
        navigationPath.append(destination)
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

// MARK: - Tab Coordinator

/// Protocol for coordinators that manage tabs
@MainActor
protocol TabCoordinatorProtocol: ParentCoordinator {
    
    /// Currently selected tab
    var selectedTab: Int { get set }
    
    /// Switch to a specific tab
    func switchToTab(_ index: Int)
}

// MARK: - Default Implementations for Tab Coordinator

extension TabCoordinatorProtocol {
    
    func switchToTab(_ index: Int) {
        selectedTab = index
    }
}

// MARK: - Coordinator Factory

/// Factory for creating coordinators with dependencies
@MainActor
protocol CoordinatorFactory {
    
    /// Create a coordinator with injected dependencies
    static func create() -> Self
}

// MARK: - Deep Link Coordinator

/// Protocol for coordinators that handle deep links
@MainActor
protocol DeepLinkCoordinator: Coordinator {
    
    /// Handle a deep link URL
    func handleDeepLink(_ url: URL) -> Bool
}

// MARK: - Coordinator Helpers

extension Coordinator {
    
    /// Type-erased identifier for coordinator comparison
    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
