//
//  AppError.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Standardized error handling with recovery actions
//

import Foundation
import SwiftUI

// MARK: - App Error

enum AppError: LocalizedError, Equatable {
    case network(NetworkError)
    case noContent
    case unauthorized
    case offline
    case rateLimit(retryAfter: TimeInterval)
    case cacheExpired
    case invalidData
    case unknown(String)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .network(let error):
            return error.localizedDescription
        case .noContent:
            return "No content available"
        case .unauthorized:
            return "Session expired. Please restart the app."
        case .offline:
            return "You're offline"
        case .rateLimit(let seconds):
            return "Too many requests. Try again in \(Int(seconds)) seconds."
        case .cacheExpired:
            return "Cached data has expired"
        case .invalidData:
            return "Invalid data received"
        case .unknown(let message):
            return message.isEmpty ? "Something went wrong" : message
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .network:
            return "Check your internet connection and try again."
        case .noContent:
            return "Try adjusting your filters or search terms."
        case .unauthorized:
            return "Please force quit and restart the app."
        case .offline:
            return "Connect to the internet to see fresh content."
        case .rateLimit:
            return "Please wait a moment before trying again."
        case .cacheExpired:
            return "Refresh to get the latest content."
        case .invalidData:
            return "Try again later."
        case .unknown:
            return "Please try again later."
        }
    }

    // MARK: - Recovery Action

    var recoveryAction: RecoveryAction {
        switch self {
        case .network, .unknown, .invalidData:
            return .retry
        case .offline, .cacheExpired:
            return .showCached
        case .rateLimit:
            return .waitAndRetry
        case .unauthorized:
            return .restart
        case .noContent:
            return .none
        }
    }

    enum RecoveryAction {
        case retry
        case showCached
        case waitAndRetry
        case restart
        case none
    }

    // MARK: - UI Properties

    var canRetry: Bool {
        recoveryAction == .retry || recoveryAction == .waitAndRetry
    }

    var icon: String {
        switch self {
        case .network:
            return "wifi.exclamationmark"
        case .offline:
            return "wifi.slash"
        case .rateLimit:
            return "clock"
        case .unauthorized:
            return "lock.slash"
        case .noContent:
            return "doc.text.magnifyingglass"
        case .cacheExpired:
            return "arrow.clockwise"
        case .invalidData:
            return "exclamationmark.triangle"
        case .unknown:
            return "exclamationmark.circle"
        }
    }

    var iconColor: Color {
        switch self {
        case .offline, .cacheExpired:
            return .orange
        case .rateLimit:
            return .yellow
        case .noContent:
            return .gray
        default:
            return .red
        }
    }

    var bannerColor: Color {
        switch self {
        case .offline, .cacheExpired:
            return .orange
        case .rateLimit:
            return .yellow
        case .noContent:
            return .gray
        default:
            return .red
        }
    }

    // MARK: - Equatable

    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.noContent, .noContent),
             (.unauthorized, .unauthorized),
             (.offline, .offline),
             (.cacheExpired, .cacheExpired),
             (.invalidData, .invalidData):
            return true
        case (.rateLimit(let a), .rateLimit(let b)):
            return a == b
        case (.unknown(let a), .unknown(let b)):
            return a == b
        case (.network(let a), .network(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - Error Overlay View

struct ErrorOverlay: View {
    let error: AppError
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?

    @State private var isVisible = false

    init(
        error: AppError,
        onRetry: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 20) {
            // Icon
            ZStack {
                Circle()
                    .fill(error.iconColor.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: error.icon)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundColor(error.iconColor)
            }

            // Text
            VStack(spacing: 8) {
                Text(error.errorDescription ?? "Something went wrong")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            // Actions
            HStack(spacing: 12) {
                if let onDismiss = onDismiss {
                    Button("Dismiss") {
                        Haptics.shared.lightImpact()
                        onDismiss()
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                if error.recoveryAction == .retry, let onRetry = onRetry {
                    Button("Try Again") {
                        Haptics.shared.mediumImpact()
                        onRetry()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.glassBorder, lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        .padding(.horizontal, 32)
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.9)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(error.errorDescription ?? "Error"). \(error.recoverySuggestion ?? "")")
    }
}

// MARK: - Inline Error Banner

struct InlineErrorBanner: View {
    let error: AppError
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: error.icon)
                .foregroundColor(error.iconColor)
                .font(.system(size: 18, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text(error.errorDescription ?? "Error")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.textPrimary)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()

            if let onRetry = onRetry {
                Button("Retry") {
                    Haptics.shared.lightImpact()
                    onRetry()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(error.iconColor)
            }

            if let onDismiss = onDismiss {
                Button {
                    Haptics.shared.lightImpact()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(error.bannerColor.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(error.bannerColor.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Simple Empty State View

struct SimpleEmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        title: String,
        message: String,
        icon: String = "tray",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .thin))
                .foregroundColor(.textTertiary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    Haptics.shared.mediumImpact()
                    action()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(40)
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(.textPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View Modifier for Error Handling

struct ErrorHandlingModifier: ViewModifier {
    @Binding var error: AppError?
    let onRetry: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content

            if let error = error {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            self.error = nil
                        }
                    }

                ErrorOverlay(
                    error: error,
                    onRetry: {
                        withAnimation {
                            self.error = nil
                        }
                        onRetry?()
                    },
                    onDismiss: {
                        withAnimation {
                            self.error = nil
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: error != nil)
    }
}

extension View {
    func errorHandling(error: Binding<AppError?>, onRetry: (() -> Void)? = nil) -> some View {
        modifier(ErrorHandlingModifier(error: error, onRetry: onRetry))
    }
}

// MARK: - Preview

#if DEBUG
struct AppError_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                ErrorOverlay(
                    error: .offline,
                    onRetry: {},
                    onDismiss: {}
                )

                InlineErrorBanner(
                    error: .network(.timeout),
                    onRetry: {},
                    onDismiss: {}
                )
                .padding(.horizontal)

                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Results",
                    message: "Try searching for something else"
                ) {
                    Button("Clear Search") {}
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
#endif
