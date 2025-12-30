//
//  AuthenticationManager.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Handles Firebase Authentication with Google, Apple, and Email providers
//

import Foundation
import SwiftUI
import AuthenticationServices
import CryptoKit

#if canImport(FirebaseAuth)
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
#endif

// MARK: - Auth State

enum AuthState: Equatable {
    case unknown
    case loading
    case guest
    case authenticated(FirebaseUser)

    var isAuthenticated: Bool {
        if case .authenticated = self { return true }
        return false
    }

    var isGuest: Bool {
        if case .guest = self { return true }
        return false
    }

    var currentUser: FirebaseUser? {
        if case .authenticated(let user) = self { return user }
        return nil
    }
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case signInCancelled
    case invalidCredential
    case networkError
    case emailAlreadyInUse
    case weakPassword
    case invalidEmail
    case userNotFound
    case wrongPassword
    case accountLinkingFailed
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .signInCancelled:
            return "Sign in was cancelled"
        case .invalidCredential:
            return "Invalid credentials. Please try again."
        case .networkError:
            return "Network error. Please check your connection."
        case .emailAlreadyInUse:
            return "This email is already registered. Try signing in instead."
        case .weakPassword:
            return "Password is too weak. Use at least 6 characters."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .userNotFound:
            return "No account found with this email."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .accountLinkingFailed:
            return "Failed to link accounts. Please try again."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Authentication Manager

@MainActor
final class AuthenticationManager: NSObject, ObservableObject {

    // MARK: - Singleton

    static let shared = AuthenticationManager()

    // MARK: - Published Properties

    @Published private(set) var authState: AuthState = .unknown
    @Published private(set) var isLoading = false
    @Published var error: AuthError?

    // MARK: - Private Properties

    private var currentNonce: String?
    private var appleSignInContinuation: CheckedContinuation<ASAuthorization, Error>?

    #if canImport(FirebaseAuth)
    private var authStateListener: AuthStateDidChangeListenerHandle?
    #endif

    // MARK: - Initialization

    override init() {
        super.init()
        setupAuthStateListener()
    }

    deinit {
        #if canImport(FirebaseAuth)
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
        #endif
    }

    // MARK: - Setup

    private func setupAuthStateListener() {
        #if canImport(FirebaseAuth)
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.handleAuthStateChange(user)
            }
        }
        #else
        // Firebase not available - check for stored guest state
        if UserDefaults.standard.bool(forKey: "isGuestUser") {
            authState = .guest
        } else if UserDefaults.standard.string(forKey: "mockUserId") != nil {
            // Load mock user for development
            authState = .authenticated(FirebaseUser.sample)
        } else {
            authState = .unknown
        }
        #endif
    }

    #if canImport(FirebaseAuth)
    private func handleAuthStateChange(_ user: User?) {
        if let user = user {
            let firebaseUser = FirebaseUser(
                id: user.uid,
                email: user.email,
                displayName: user.displayName,
                photoURL: user.photoURL,
                authProvider: detectAuthProvider(user),
                createdAt: user.metadata.creationDate ?? Date(),
                lastSignInAt: user.metadata.lastSignInDate ?? Date()
            )

            if user.isAnonymous {
                authState = .guest
            } else {
                authState = .authenticated(firebaseUser)
            }
        } else {
            authState = .unknown
        }
    }

    private func detectAuthProvider(_ user: User) -> FirebaseUser.AuthProvider {
        for info in user.providerData {
            switch info.providerID {
            case "google.com": return .google
            case "apple.com": return .apple
            case "password": return .email
            default: continue
            }
        }
        return user.isAnonymous ? .anonymous : .email
    }
    #endif

    // MARK: - Google Sign In

    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }

        #if canImport(FirebaseAuth)
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.invalidCredential
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.unknown(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller"]))
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.invalidCredential
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            try await signInWithCredential(credential)
        } catch let error as GIDSignInError {
            if error.code == .canceled {
                throw AuthError.signInCancelled
            }
            throw AuthError.unknown(error)
        }
        #else
        // Mock implementation for development
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let mockUser = FirebaseUser(
            id: "google-user-\(UUID().uuidString.prefix(8))",
            email: "user@gmail.com",
            displayName: "Google User",
            photoURL: nil,
            authProvider: .google,
            createdAt: Date(),
            lastSignInAt: Date()
        )
        authState = .authenticated(mockUser)
        UserDefaults.standard.set(mockUser.id, forKey: "mockUserId")
        #endif
    }

    // MARK: - Apple Sign In

    func signInWithApple() async throws {
        isLoading = true
        defer { isLoading = false }

        let nonce = randomNonceString()
        currentNonce = nonce

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorization = try await performAppleSignIn(request: request)

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.invalidCredential
        }

        #if canImport(FirebaseAuth)
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        try await signInWithCredential(credential)
        #else
        // Mock implementation for development
        let fullName = appleIDCredential.fullName
        let displayName = [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")

        let mockUser = FirebaseUser(
            id: "apple-user-\(UUID().uuidString.prefix(8))",
            email: appleIDCredential.email,
            displayName: displayName.isEmpty ? nil : displayName,
            photoURL: nil,
            authProvider: .apple,
            createdAt: Date(),
            lastSignInAt: Date()
        )
        authState = .authenticated(mockUser)
        UserDefaults.standard.set(mockUser.id, forKey: "mockUserId")
        #endif
    }

    private func performAppleSignIn(request: ASAuthorizationAppleIDRequest) async throws -> ASAuthorization {
        try await withCheckedThrowingContinuation { continuation in
            self.appleSignInContinuation = continuation

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    // MARK: - Email/Password Sign In

    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }

        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        #if canImport(FirebaseAuth)
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
        #else
        // Mock implementation
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let mockUser = FirebaseUser(
            id: "email-user-\(UUID().uuidString.prefix(8))",
            email: email,
            displayName: email.components(separatedBy: "@").first,
            photoURL: nil,
            authProvider: .email,
            createdAt: Date(),
            lastSignInAt: Date()
        )
        authState = .authenticated(mockUser)
        UserDefaults.standard.set(mockUser.id, forKey: "mockUserId")
        #endif
    }

    // MARK: - Create Account

    func createAccount(email: String, password: String, displayName: String? = nil) async throws {
        isLoading = true
        defer { isLoading = false }

        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }

        #if canImport(FirebaseAuth)
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)

            // Update display name if provided
            if let displayName = displayName {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try await changeRequest.commitChanges()
            }
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
        #else
        // Mock implementation
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let mockUser = FirebaseUser(
            id: "email-user-\(UUID().uuidString.prefix(8))",
            email: email,
            displayName: displayName ?? email.components(separatedBy: "@").first,
            photoURL: nil,
            authProvider: .email,
            createdAt: Date(),
            lastSignInAt: Date()
        )
        authState = .authenticated(mockUser)
        UserDefaults.standard.set(mockUser.id, forKey: "mockUserId")
        #endif
    }

    // MARK: - Password Reset

    func sendPasswordReset(email: String) async throws {
        isLoading = true
        defer { isLoading = false }

        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        #if canImport(FirebaseAuth)
        try await Auth.auth().sendPasswordReset(withEmail: email)
        #else
        // Mock - just wait
        try await Task.sleep(nanoseconds: 500_000_000)
        #endif
    }

    // MARK: - Guest Mode

    func continueAsGuest() async {
        isLoading = true
        defer { isLoading = false }

        #if canImport(FirebaseAuth)
        do {
            try await Auth.auth().signInAnonymously()
        } catch {
            // If anonymous sign in fails, just set guest state locally
            authState = .guest
        }
        #else
        authState = .guest
        #endif

        UserDefaults.standard.set(true, forKey: "isGuestUser")
    }

    // MARK: - Sign Out

    func signOut() throws {
        #if canImport(FirebaseAuth)
        try Auth.auth().signOut()
        #endif

        // Clear local state
        UserDefaults.standard.removeObject(forKey: "isGuestUser")
        UserDefaults.standard.removeObject(forKey: "mockUserId")
        authState = .unknown
    }

    // MARK: - Delete Account

    func deleteAccount() async throws {
        isLoading = true
        defer { isLoading = false }

        #if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else { return }

        // Delete Firestore data first
        try await FirestoreService.shared.deleteUserData(for: user.uid)

        // Delete auth account
        try await user.delete()
        #else
        // Clear mock data
        UserDefaults.standard.removeObject(forKey: "mockUserId")
        #endif

        authState = .unknown
    }

    // MARK: - Link Guest Account

    func linkGuestAccount(with provider: FirebaseUser.AuthProvider) async throws {
        guard authState.isGuest else { return }

        switch provider {
        case .google:
            try await signInWithGoogle()
        case .apple:
            try await signInWithApple()
        default:
            break
        }
    }

    // MARK: - Private Helpers

    #if canImport(FirebaseAuth)
    private func signInWithCredential(_ credential: AuthCredential) async throws {
        do {
            // If guest, try to link instead of sign in
            if let currentUser = Auth.auth().currentUser, currentUser.isAnonymous {
                do {
                    try await currentUser.link(with: credential)
                    return
                } catch {
                    // Linking failed, sign in with new account
                    try await Auth.auth().signIn(with: credential)
                }
            } else {
                try await Auth.auth().signIn(with: credential)
            }
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    private func mapFirebaseError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error)
        }

        switch errorCode {
        case .networkError:
            return .networkError
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .weakPassword:
            return .weakPassword
        case .invalidEmail:
            return .invalidEmail
        case .userNotFound:
            return .userNotFound
        case .wrongPassword:
            return .wrongPassword
        case .invalidCredential:
            return .invalidCredential
        default:
            return .unknown(error)
        }
    }
    #endif

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // MARK: - Apple Sign In Helpers

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthenticationManager: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            appleSignInContinuation?.resume(returning: authorization)
            appleSignInContinuation = nil
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                appleSignInContinuation?.resume(throwing: AuthError.signInCancelled)
            } else {
                appleSignInContinuation?.resume(throwing: AuthError.unknown(error))
            }
            appleSignInContinuation = nil
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthenticationManager: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - Preview Helper

#if DEBUG
extension AuthenticationManager {
    static func mockAuthenticated() -> AuthenticationManager {
        let manager = AuthenticationManager()
        manager.authState = .authenticated(.sample)
        return manager
    }

    static func mockGuest() -> AuthenticationManager {
        let manager = AuthenticationManager()
        manager.authState = .guest
        return manager
    }
}
#endif
