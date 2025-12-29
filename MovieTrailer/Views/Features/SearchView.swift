//
//  SearchView.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//  Enhanced: Keyboard dismissal, accessibility, haptic feedback
//

import SwiftUI

struct SearchView: View {

    @StateObject private var viewModel: SearchViewModel
    @FocusState private var isSearchFocused: Bool
    let onMovieTap: (Movie) -> Void

    @State private var animateResults = false

    init(viewModel: SearchViewModel, onMovieTap: @escaping (Movie) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMovieTap = onMovieTap
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar

            // Content
            if viewModel.isSearching {
                LoadingView()
            } else if let error = viewModel.error, viewModel.searchResults.isEmpty {
                ErrorView(error: error) {
                    viewModel.search()
                }
            } else if viewModel.searchQuery.isEmpty {
                emptySearchState
            } else if viewModel.searchResults.isEmpty && !viewModel.isSearching {
                noResultsState
            } else {
                searchResultsView
            }
        }
        .navigationTitle("Search")
        // MARK: - Keyboard Dismissal
        .onTapGesture {
            dismissKeyboard()
        }
        .gesture(
            DragGesture()
                .onChanged { _ in
                    dismissKeyboard()
                }
        )
        .scrollDismissesKeyboard(.interactively)
        // MARK: - Accessibility
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Search Movies")
    }

    // MARK: - Keyboard Dismissal

    private func dismissKeyboard() {
        isSearchFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search movies...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit {
                        HapticManager.shared.searchResultTapped()
                        viewModel.search()
                    }
                    .onChange(of: viewModel.searchQuery) { _ in
                        viewModel.search()
                    }
                    .accessibilityLabel("Search field")
                    .accessibilityHint("Enter movie title to search")

                if !viewModel.searchQuery.isEmpty {
                    Button {
                        HapticManager.shared.lightImpact()
                        viewModel.clearSearch()
                        isSearchFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Clear search")
                    .accessibilityHint("Double tap to clear search text")
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(uiColor: .systemGray6))
            )

            // Cancel button when keyboard is active
            if isSearchFocused {
                Button("Cancel") {
                    HapticManager.shared.lightImpact()
                    dismissKeyboard()
                    viewModel.clearSearch()
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSearchFocused)
    }

    // MARK: - Search Results

    private var searchResultsView: some View {
        ScrollView {
            // Results count header
            if !viewModel.searchResults.isEmpty {
                HStack {
                    Text("\(viewModel.searchResults.count) results")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 20
            ) {
                ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, movie in
                    MovieCard(
                        movie: movie,
                        isInWatchlist: viewModel.isInWatchlist(movie),
                        onTap: {
                            dismissKeyboard()
                            HapticManager.shared.searchResultTapped()
                            onMovieTap(movie)
                        },
                        onWatchlistToggle: {
                            viewModel.toggleWatchlist(for: movie)
                        }
                    )
                    .opacity(animateResults ? 1 : 0)
                    .offset(y: animateResults ? 0 : 20)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7)
                            .delay(Double(index) * 0.05),
                        value: animateResults
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            withAnimation {
                animateResults = true
            }
        }
        .onChange(of: viewModel.searchResults) { _ in
            animateResults = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1)) {
                animateResults = true
            }
        }
    }

    // MARK: - Empty Search State

    private var emptySearchState: some View {
        VStack(spacing: 24) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityHidden(true)

            Text("Search for Movies")
                .font(.title2.bold())

            Text("Find your favorite movies, discover new ones, and add them to your watchlist")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Quick search suggestions
            VStack(spacing: 12) {
                Text("Popular Searches")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                HStack(spacing: 8) {
                    ForEach(["Action", "Comedy", "Thriller"], id: \.self) { suggestion in
                        Button {
                            HapticManager.shared.buttonPressed()
                            viewModel.searchQuery = suggestion
                            viewModel.search()
                        } label: {
                            Text(suggestion)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color(uiColor: .systemGray5))
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            dismissKeyboard()
        }
    }

    // MARK: - No Results State

    private var noResultsState: some View {
        VStack(spacing: 24) {
            Image(systemName: "film.stack")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.gray, .secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityHidden(true)

            Text("No Results Found")
                .font(.title2.bold())

            Text("No movies found for \"\(viewModel.searchQuery)\"")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                HapticManager.shared.buttonPressed()
                viewModel.clearSearch()
                isSearchFocused = true
            } label: {
                Text("Clear Search")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
            .accessibilityHint("Double tap to clear search and try again")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            dismissKeyboard()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView(viewModel: .mock())
        }
    }
}
#endif
