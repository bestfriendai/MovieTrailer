//
//  SignInView.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Main sign-in view with multiple auth providers
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {

    @ObservedObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showEmailSignIn = false
    @State private var showEmailSignUp = false

    var onSuccess: (() -> Void)?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Header
                    headerSection

                    Spacer()

                    // Sign in options
                    signInOptions

                    // Error display
                    if let error = authManager.error {
                        errorBanner(error)
                    }

                    Spacer()

                    // Guest mode
                    guestModeButton

                    // Footer
                    termsText
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)

                // Loading overlay
                if authManager.isLoading {
                    loadingOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showEmailSignIn) {
            EmailSignInView { success in
                if success {
                    showEmailSignIn = false
                    onSuccess?()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showEmailSignUp) {
            EmailSignUpView { success in
                if success {
                    showEmailSignUp = false
                    onSuccess?()
                    dismiss()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Welcome Back")
                .font(.title.bold())
                .foregroundColor(.white)

            Text("Sign in to access your watchlist and sync your preferences")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Sign In Options

    private var signInOptions: some View {
        VStack(spacing: 12) {
            // Apple Sign In
            Button {
                Task {
                    try? await authManager.signInWithApple()
                    if authManager.authState.isAuthenticated {
                        onSuccess?()
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "apple.logo")
                        .font(.title3)
                    Text("Continue with Apple")
                        .font(.headline)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            // Google Sign In
            Button {
                Task {
                    try? await authManager.signInWithGoogle()
                    if authManager.authState.isAuthenticated {
                        onSuccess?()
                        dismiss()
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "g.circle.fill")
                        .font(.title3)
                    Text("Continue with Google")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.white.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            }

            // Divider
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1)

                Text("or")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal, 16)

                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1)
            }
            .padding(.vertical, 8)

            // Email options
            HStack(spacing: 12) {
                Button {
                    showEmailSignIn = true
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }

                Button {
                    showEmailSignUp = true
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }

    // MARK: - Guest Mode

    private var guestModeButton: some View {
        Button {
            Task {
                await authManager.continueAsGuest()
                dismiss()
            }
        } label: {
            Text("Continue without an account")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .underline()
        }
    }

    // MARK: - Error Banner

    private func errorBanner(_ error: AuthError) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)

            Text(error.errorDescription ?? "An error occurred")
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()

            Button {
                authManager.error = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .background(Color.red.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)

                    Text("Signing in...")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            )
    }

    // MARK: - Terms Text

    private var termsText: some View {
        Text("By continuing, you agree to our Terms of Service and Privacy Policy")
            .font(.caption2)
            .foregroundColor(.white.opacity(0.4))
            .multilineTextAlignment(.center)
    }
}

// MARK: - Preview

#if DEBUG
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
#endif
