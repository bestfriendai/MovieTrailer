//
//  KeychainManager.swift
//  MovieTrailer
//
//  Created by Claude Code Audit on 28/12/2025.
//  Secure API key storage using iOS Keychain
//

import Foundation
import Security

/// Secure storage manager using iOS Keychain
/// Use this instead of storing API keys in Info.plist or code
final class KeychainManager {

    // MARK: - Singleton

    static let shared = KeychainManager()

    private init() {}

    // MARK: - Keys

    enum KeychainKey: String {
        case tmdbAPIKey = "com.movietrailer.tmdb.apikey"
    }

    // MARK: - Errors

    enum KeychainError: LocalizedError {
        case duplicateEntry
        case unknown(OSStatus)
        case notFound
        case invalidData

        var errorDescription: String? {
            switch self {
            case .duplicateEntry:
                return "Item already exists in Keychain"
            case .unknown(let status):
                return "Keychain error: \(status)"
            case .notFound:
                return "Item not found in Keychain"
            case .invalidData:
                return "Invalid data format"
            }
        }
    }

    // MARK: - Save

    /// Save a string value to Keychain
    func save(_ value: String, for key: KeychainKey) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        // Delete existing item if present
        try? delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateEntry
            }
            throw KeychainError.unknown(status)
        }
    }

    // MARK: - Read

    /// Read a string value from Keychain
    func read(key: KeychainKey) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.notFound
            }
            throw KeychainError.unknown(status)
        }

        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return string
    }

    /// Read a string value from Keychain, returning nil if not found
    func readOptional(key: KeychainKey) -> String? {
        try? read(key: key)
    }

    // MARK: - Delete

    /// Delete an item from Keychain
    func delete(key: KeychainKey) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }

    // MARK: - Update

    /// Update an existing item in Keychain
    func update(_ value: String, for key: KeychainKey) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidData
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                // Item doesn't exist, save it
                try save(value, for: key)
                return
            }
            throw KeychainError.unknown(status)
        }
    }

    // MARK: - Convenience Methods

    /// Get TMDB API Key from Keychain, falling back to Info.plist for migration
    var tmdbAPIKey: String? {
        // First try Keychain
        if let keychainKey = readOptional(key: .tmdbAPIKey), !keychainKey.isEmpty {
            return keychainKey
        }

        // Fall back to Info.plist for migration
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String,
           !plistKey.isEmpty,
           plistKey != "$(TMDB_API_KEY)" {
            // Migrate to Keychain
            try? save(plistKey, for: .tmdbAPIKey)
            return plistKey
        }

        return nil
    }

    /// Check if TMDB API Key is configured
    var isTMDBAPIKeyConfigured: Bool {
        guard let key = tmdbAPIKey else { return false }
        return !key.isEmpty
    }

    /// Set TMDB API Key (for settings screen or initial setup)
    func setTMDBAPIKey(_ key: String) throws {
        try save(key, for: .tmdbAPIKey)
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension KeychainManager {
    /// Clear all app keychain items (for testing)
    func clearAll() {
        try? delete(key: .tmdbAPIKey)
    }

    /// Print keychain status (for debugging)
    func debugPrintStatus() {
        print("🔐 Keychain Status:")
        print("   TMDB API Key configured: \(isTMDBAPIKeyConfigured)")
        if let key = tmdbAPIKey {
            print("   Key length: \(key.count) characters")
            print("   Key prefix: \(String(key.prefix(8)))...")
        }
    }
}
#endif
