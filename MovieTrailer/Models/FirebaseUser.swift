//
//  FirebaseUser.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Model representing an authenticated Firebase user
//

import Foundation

/// Represents an authenticated user from Firebase
struct FirebaseUser: Codable, Identifiable, Equatable {

    // MARK: - Properties

    /// Unique user ID from Firebase
    let id: String

    /// User's email address (optional for Apple Sign-In)
    let email: String?

    /// Display name (from provider or set by user)
    let displayName: String?

    /// Profile photo URL
    let photoURL: URL?

    /// Authentication provider used
    let authProvider: AuthProvider

    /// Account creation timestamp
    let createdAt: Date

    /// Last sign-in timestamp
    var lastSignInAt: Date

    // MARK: - Auth Provider

    enum AuthProvider: String, Codable, CaseIterable {
        case google = "google.com"
        case apple = "apple.com"
        case email = "password"
        case anonymous = "anonymous"

        var displayName: String {
            switch self {
            case .google: return "Google"
            case .apple: return "Apple"
            case .email: return "Email"
            case .anonymous: return "Guest"
            }
        }

        var iconName: String {
            switch self {
            case .google: return "g.circle.fill"
            case .apple: return "apple.logo"
            case .email: return "envelope.fill"
            case .anonymous: return "person.fill"
            }
        }
    }

    // MARK: - Computed Properties

    /// Returns user's first name or a default
    var firstName: String {
        if let displayName = displayName {
            return displayName.components(separatedBy: " ").first ?? displayName
        }
        return "User"
    }

    /// Returns initials for avatar
    var initials: String {
        if let displayName = displayName {
            let components = displayName.components(separatedBy: " ")
            let first = components.first?.prefix(1) ?? ""
            let last = components.count > 1 ? components.last?.prefix(1) ?? "" : ""
            return "\(first)\(last)".uppercased()
        }
        if let email = email {
            return String(email.prefix(1)).uppercased()
        }
        return "U"
    }

    /// Check if user is a guest (anonymous)
    var isGuest: Bool {
        authProvider == .anonymous
    }

    /// Check if user has verified email
    var hasEmail: Bool {
        email != nil && !email!.isEmpty
    }
}

// MARK: - Sample Data

#if DEBUG
extension FirebaseUser {
    static let sample = FirebaseUser(
        id: "sample-user-123",
        email: "user@example.com",
        displayName: "John Doe",
        photoURL: URL(string: "https://example.com/photo.jpg"),
        authProvider: .google,
        createdAt: Date(),
        lastSignInAt: Date()
    )

    static let guestSample = FirebaseUser(
        id: "guest-user-456",
        email: nil,
        displayName: nil,
        photoURL: nil,
        authProvider: .anonymous,
        createdAt: Date(),
        lastSignInAt: Date()
    )
}
#endif
