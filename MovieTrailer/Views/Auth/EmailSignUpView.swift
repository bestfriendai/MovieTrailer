//
//  EmailSignUpView.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Email/password registration form
//

import SwiftUI

struct EmailSignUpView: View {

    @ObservedObject private var authManager = AuthenticationManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @FocusState private var focusedField: Field?

    var onComplete: (Bool) -> Void

    enum Field {
        case displayName, email, password, confirmPassword
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection

                        // Form
                        formSection

                        // Password requirements
                        passwordRequirements

                        // Sign up button
                        signUpButton

                        // Error display
                        if let error = authManager.error {
                            errorText(error)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
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
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus.fill")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Create Account")
                .font(.title2.bold())
                .foregroundColor(.white)

            Text("Sign up to sync your preferences")
                .font(.body)
                .foregroundColor(.white.opacity(0.6))
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 16) {
            // Display name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                TextField("", text: $displayName)
                    .textContentType(.name)
                    .focused($focusedField, equals: .displayName)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(focusedField == .displayName ? Color.blue : Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .foregroundColor(.white)
                    .placeholder(when: displayName.isEmpty) {
                        Text("Your name")
                            .foregroundColor(.white.opacity(0.3))
                    }
            }

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
                    .textContentType(.newPassword)
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

            // Confirm password field
            VStack(alignment: .leading, spacing: 8) {
                Text("Confirm Password")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                SecureField("", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .focused($focusedField, equals: .confirmPassword)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(passwordsMatch ? (focusedField == .confirmPassword ? Color.blue : Color.white.opacity(0.2)) : Color.red, lineWidth: 1)
                    )
                    .foregroundColor(.white)
            }

            if !confirmPassword.isEmpty && !passwordsMatch {
                Text("Passwords don't match")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Password Requirements

    private var passwordRequirements: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password must:")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))

            HStack(spacing: 8) {
                Image(systemName: password.count >= 6 ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(password.count >= 6 ? .green : .white.opacity(0.3))
                    .font(.caption)

                Text("Be at least 6 characters")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Sign Up Button

    private var signUpButton: some View {
        Button {
            Task {
                focusedField = nil
                try? await authManager.createAccount(
                    email: email,
                    password: password,
                    displayName: displayName.isEmpty ? nil : displayName
                )
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
                    Text("Create Account")
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

    private var passwordsMatch: Bool {
        confirmPassword.isEmpty || password == confirmPassword
    }

    private var isFormValid: Bool {
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
}

// MARK: - Preview

#if DEBUG
struct EmailSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        EmailSignUpView { _ in }
    }
}
#endif
