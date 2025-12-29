//
//  SearchBarView.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Implemented by Claude Code Audit on 28/12/2025.
//

import SwiftUI

/// Reusable search bar component with clear button and focus state
struct SearchBarView: View {

    // MARK: - Properties

    @Binding var text: String
    var placeholder: String = "Search movies..."
    var onSubmit: (() -> Void)?
    var onClear: (() -> Void)?

    @FocusState private var isFocused: Bool
    @State private var showCancelButton = false

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // Search field container
            HStack(spacing: 8) {
                // Search icon
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)

                // Text field
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .focused($isFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit {
                        HapticManager.shared.searchResultTapped()
                        onSubmit?()
                    }
                    .accessibilityLabel("Search field")
                    .accessibilityHint("Enter movie title to search")

                // Clear button
                if !text.isEmpty {
                    Button {
                        HapticManager.shared.lightImpact()
                        text = ""
                        onClear?()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)

            // Cancel button
            if showCancelButton {
                Button("Cancel") {
                    HapticManager.shared.lightImpact()
                    text = ""
                    isFocused = false
                    onClear?()
                }
                .font(.body)
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showCancelButton)
        .onChange(of: isFocused) { focused in
            withAnimation {
                showCancelButton = focused
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SearchBarView(text: .constant(""))

            SearchBarView(text: .constant("Matrix"))

            SearchBarView(
                text: .constant(""),
                placeholder: "Find your next movie...",
                onSubmit: { print("Submit") },
                onClear: { print("Clear") }
            )
        }
        .padding()
    }
}
#endif
