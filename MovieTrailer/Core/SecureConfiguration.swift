//
//  SecureConfiguration.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Secure configuration loading with API key protection
//

import Foundation
import Security

// MARK: - Secure Configuration

actor SecureConfiguration {

    // MARK: - Singleton

    static let shared = SecureConfiguration()

    // MARK: - Properties

    private var cachedAPIKey: String?
    private let keychainKey = "com.movietrailer.tmdb.apikey"

    // MARK: - API Key Management

    /// Get the TMDB API key securely
    func getAPIKey() async throws -> String {
        // Return cached key if available
        if let cached = cachedAPIKey {
            return cached
        }

        // Try to load from Keychain first
        if let stored = loadFromKeychain() {
            cachedAPIKey = stored
            return stored
        }

        // Load from bundled configuration (obfuscated)
        guard let key = loadObfuscatedKey() else {
            throw ConfigurationError.missingAPIKey
        }

        // Store in keychain for future use
        try saveToKeychain(key)
        cachedAPIKey = key

        return key
    }

    /// Update API key (for user-provided keys)
    func setAPIKey(_ key: String) async throws {
        guard isValidAPIKey(key) else {
            throw ConfigurationError.invalidAPIKey
        }

        try saveToKeychain(key)
        cachedAPIKey = key
    }

    /// Clear stored API key
    func clearAPIKey() async {
        deleteFromKeychain()
        cachedAPIKey = nil
    }

    /// Check if API key is configured
    func isConfigured() async -> Bool {
        if cachedAPIKey != nil {
            return true
        }

        if loadFromKeychain() != nil {
            return true
        }

        return loadObfuscatedKey() != nil
    }

    // MARK: - Validation

    private func isValidAPIKey(_ key: String) -> Bool {
        // TMDB API keys are 32 characters
        guard key.count >= 32 else { return false }

        // Should be alphanumeric
        let alphanumeric = CharacterSet.alphanumerics
        return key.unicodeScalars.allSatisfy { alphanumeric.contains($0) }
    }

    // MARK: - Obfuscated Key Loading

    /// Load API key from obfuscated bundle
    /// In production, this would use proper obfuscation
    private func loadObfuscatedKey() -> String? {
        // Try to load from Info.plist first (for development)
        if let key = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String,
           !key.isEmpty,
           !key.hasPrefix("$") {
            return key
        }

        // Try environment variable (for CI/CD)
        if let key = ProcessInfo.processInfo.environment["TMDB_API_KEY"],
           !key.isEmpty {
            return key
        }

        // Try to load from secure config file
        if let url = Bundle.main.url(forResource: "SecureConfig", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let key = plist["TMDB_API_KEY"] as? String,
           !key.isEmpty {
            return deobfuscate(key)
        }

        return nil
    }

    /// Deobfuscate a stored key
    /// In production, implement proper deobfuscation
    private func deobfuscate(_ obfuscated: String) -> String {
        // Simple XOR deobfuscation example
        // In production, use a more secure method
        let key: [UInt8] = [0x4D, 0x6F, 0x76, 0x69, 0x65] // "Movie"

        var result: [UInt8] = []
        let bytes = Array(obfuscated.utf8)

        for (i, byte) in bytes.enumerated() {
            result.append(byte ^ key[i % key.count])
        }

        return String(bytes: result, encoding: .utf8) ?? obfuscated
    }

    // MARK: - Keychain Operations

    private func saveToKeychain(_ value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw ConfigurationError.encodingError
        }

        // Delete existing item first
        deleteFromKeychain()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainKey,
            kSecAttrAccount as String: "api_key",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw ConfigurationError.keychainError(status)
        }
    }

    private func loadFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainKey,
            kSecAttrAccount as String: "api_key",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func deleteFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainKey,
            kSecAttrAccount as String: "api_key"
        ]

        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Configuration Error

enum ConfigurationError: LocalizedError {
    case missingAPIKey
    case invalidAPIKey
    case encodingError
    case keychainError(OSStatus)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key is not configured"
        case .invalidAPIKey:
            return "Invalid API key format"
        case .encodingError:
            return "Failed to encode API key"
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .missingAPIKey:
            return "Please configure your TMDB API key in Settings"
        case .invalidAPIKey:
            return "Check your API key and try again"
        case .encodingError:
            return "Please try again"
        case .keychainError:
            return "Please restart the app and try again"
        case .networkError:
            return "Check your internet connection and try again"
        }
    }
}

// MARK: - Keychain Manager (Extended)

extension KeychainManager {

    /// Save secure string to keychain
    func saveSecure(_ value: String, key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw ConfigurationError.encodingError
        }

        // Delete existing
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.movietrailer",
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.movietrailer",
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw ConfigurationError.keychainError(status)
        }
    }

    /// Load secure string from keychain
    func loadSecure(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.movietrailer",
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    /// Delete secure string from keychain
    func deleteSecure(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.movietrailer",
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - App Configuration

struct AppConfiguration {
    static let shared = AppConfiguration()

    // API Configuration
    let apiBaseURL = "https://api.themoviedb.org/3"
    let imageBaseURL = "https://image.tmdb.org/t/p"

    // Cache Configuration
    let memoryCacheLimit = 100 * 1024 * 1024 // 100 MB
    let diskCacheLimit: UInt = 500 * 1024 * 1024 // 500 MB
    let cacheExpirationDays = 7

    // Network Configuration
    let requestTimeout: TimeInterval = 30
    let resourceTimeout: TimeInterval = 60
    let maxRetries = 3
    let retryDelay: TimeInterval = 1.0

    // Feature Flags
    var isOfflineModeEnabled: Bool { true }
    var isRecommendationsEnabled: Bool { true }
    var isVoiceSearchEnabled: Bool { true }
    var isLiveActivitiesEnabled: Bool { true }

    // Analytics
    var isAnalyticsEnabled: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }

    // Debug
    var isDebugModeEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
