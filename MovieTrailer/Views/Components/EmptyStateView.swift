//
//  EmptyStateView.swift
//  MovieTrailer
//
//  Standardized empty state component
//

import SwiftUI

struct EmptyStateView<Actions: View>: View {

    let icon: String
    let title: String
    let message: String?
    let actions: Actions

    init(
        icon: String,
        title: String,
        message: String? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actions = actions()
    }

    var body: some View {
        VStack(spacing: Spacing.lg) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentPrimary.opacity(0.25),
                                Color.accentSecondary.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: icon)
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.textSecondary, .textTertiary],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)

                if let message, !message.isEmpty {
                    Text(message)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, Spacing.xl)

            actions
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Spacing.xl)
    }
}

extension EmptyStateView where Actions == EmptyView {
    init(icon: String, title: String, message: String? = nil) {
        self.init(icon: icon, title: title, message: message) {
            EmptyView()
        }
    }
}
