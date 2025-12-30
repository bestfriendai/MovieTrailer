//
//  EmailSignInView.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Email/password sign-in form
//

import SwiftUI

struct EmailSignInView: View {

    @ObservedObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showForgotPassword = false
    @FocusState private var focusedField: Field?

    var onComplete: (Bool) -> Void

    enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        headerSection

                        // Form
                        formSection

                        // Sign in button
                        signInButton

                        // Forgot password
                        forgotPasswordButton

                        // Error display
                        if let error = authManager.error {
                            errorText(error)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
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
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "envelope.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)

            Text("Sign In with Email")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Enter your email and password")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 16) {
            // Email field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                TextField("", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .email ? Color.blue : Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .placeholder(when: email.isEmpty) {
                        Text("you@example.com")
                            .foregroundColor(.white.opacity(0.3))
                    }
            }

            // Password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                HStack {
                    Group {
                        if showPassword {
                            TextField("", text: $password)
                        } else {
                            SecureField("", text: $password)
                        }
                    }
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .foregroundColor(.white)

                    Button {
                        showPassword.toggle()
                    } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focusedField == .password ? Color.blue : Color.white.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Sign In Button

    private var signInButton: some View {
        Button {
            Task {
                focusedField = nil
                try? await authManager.signInWithEmail(email: email, password: password)
                if authManager.authState.isAuthenticated {
                    onComplete(true)
                }
            }
        } label: {
            Group {
                if authManager.isLoading {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text("Sign In")
                        .font(.headline)
                }
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isFormValid ? Color.white : Color.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .disabled(!isFormValid || authManager.isLoading)
    }

    // MARK: - Forgot Password

    private var forgotPasswordButton: some View {
        Button {
            showForgotPassword = true
        } label: {
            Text("Forgot password?")
                .font(.subheadline)
                .foregroundColor(.blue)
        }
    }

    // MARK: - Error Text

    private func errorText(_ error: AuthError) -> some View {
        Text(error.errorDescription ?? "An error occurred")
            .font(.caption)
            .foregroundColor(.red)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 6
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {

    @ObservedObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var emailSent = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 32) {
                    if emailSent {
                        successView
                    } else {
                        formView
                    }
                }
                .padding(.horizontal, 24)
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
        .preferredColorScheme(.dark)
    }

    private var formView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "key.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text("Reset Password")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Enter your email address and we'll send you a link to reset your password")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            TextField("", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundColor(.white)
                .placeholder(when: email.isEmpty) {
                    Text("you@example.com")
                        .foregroundColor(.white.opacity(0.3))
                }

            Button {
                Task {
                    try? await authManager.sendPasswordReset(email: email)
                    emailSent = true
                }
            } label: {
                Group {
                    if authManager.isLoading {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text("Send Reset Link")
                            .font(.headline)
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(email.contains("@") ? Color.white : Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(!email.contains("@") || authManager.isLoading)

            Spacer()
        }
    }

    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.green)

            Text("Email Sent!")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Check your inbox for a password reset link")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.top)

            Spacer()
        }
    }
}

// MARK: - Placeholder Modifier

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview

#if DEBUG
struct EmailSignInView_Previews: PreviewProvider {
    static var previews: some View {
        EmailSignInView { _ in }
    }
}
#endif
