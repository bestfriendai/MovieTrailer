//
//  SearchView.swift
//  MovieTrailer
//
//  Premium Search & Discovery Experience
//

import SwiftUI
import Kingfisher

struct SearchView: View {

    @StateObject private var viewModel: SearchViewModel
    @StateObject private var voiceSearch = VoiceSearchManager()
    @FocusState private var isSearchFocused: Bool

    let onMovieTap: (Movie) -> Void

    init(viewModel: SearchViewModel, onMovieTap: @escaping (Movie) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMovieTap = onMovieTap
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 24)

                    // Content
                    if viewModel.isSearching {
                        loadingView
                    } else if viewModel.searchQuery.isEmpty {
                        browseContent
                    } else if viewModel.searchResults.isEmpty {
                        noResultsView
                    } else {
                        searchResultsGrid
                    }
                }
                .padding(.bottom, 100)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))

                TextField("Search movies, TV shows...", text: $viewModel.searchQuery)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .focused($isSearchFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.search()
                    }

                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                // Voice Search Button
                Button {
                    Haptics.shared.lightImpact()
                    voiceSearch.toggle()
                } label: {
                    Image(systemName: voiceSearch.state.isActive ? "mic.fill" : "mic")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(voiceSearch.state.isActive ? .cyan : .white.opacity(0.5))
                        .symbolEffect(.pulse, isActive: voiceSearch.state == .listening)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(voiceSearch.state.isActive ? Color.cyan.opacity(0.15) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(voiceSearch.state.isActive ? Color.cyan.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.2), value: voiceSearch.state.isActive)

            if isSearchFocused || voiceSearch.state.isActive {
                Button("Cancel") {
                    isSearchFocused = false
                    voiceSearch.stopListening()
                    viewModel.clearSearch()
                }
                .font(.system(size: 17))
                .foregroundColor(.white)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
        .animation(.easeInOut(duration: 0.2), value: voiceSearch.state.isActive)
        .onAppear {
            voiceSearch.onTranscriptFinalized = { transcript in
                viewModel.searchQuery = transcript
                viewModel.search()
            }
        }
        .onChange(of: voiceSearch.transcript) { _, newTranscript in
            if voiceSearch.state == .listening && !newTranscript.isEmpty {
                viewModel.searchQuery = newTranscript
            }
        }
    }

    // MARK: - Browse Content

    private var browseContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Quick Actions
            VStack(alignment: .leading, spacing: 14) {
                Text("Quick Actions")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        QuickActionCard(
                            title: "Trending Now",
                            subtitle: "What's hot",
                            icon: "flame.fill",
                            color: .orange
                        ) {
                            viewModel.searchQuery = "popular 2024"
                            viewModel.search()
                        }

                        QuickActionCard(
                            title: "New Releases",
                            subtitle: "Just dropped",
                            icon: "sparkles",
                            color: .cyan
                        ) {
                            viewModel.searchQuery = "2024"
                            viewModel.search()
                        }
                    }

                    HStack(spacing: 10) {
                        QuickActionCard(
                            title: "Top Rated",
                            subtitle: "Best of all time",
                            icon: "star.fill",
                            color: .yellow
                        ) {
                            viewModel.searchQuery = "top rated"
                            viewModel.search()
                        }

                        QuickActionCard(
                            title: "Coming Soon",
                            subtitle: "Mark your calendar",
                            icon: "calendar",
                            color: .green
                        ) {
                            viewModel.searchQuery = "upcoming 2025"
                            viewModel.search()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            // Trending Searches
            VStack(alignment: .leading, spacing: 14) {
                Text("Trending Searches")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(["Dune", "Oppenheimer", "Barbie", "Avatar", "Marvel", "Star Wars", "Batman"], id: \.self) { term in
                            Button {
                                viewModel.searchQuery = term
                                viewModel.search()
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 12))
                                    Text(term)
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            // Browse by Genre
            VStack(alignment: .leading, spacing: 14) {
                Text("Browse by Genre")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 12) {
                    ForEach(Genre.all.prefix(12)) { genre in
                        GenreCard(genre: genre) {
                            viewModel.searchQuery = genre.name
                            viewModel.search()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            // Browse by Streaming
            VStack(alignment: .leading, spacing: 14) {
                Text("Browse by Streaming")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    StreamingCard(name: "Netflix", color: Color(red: 0.89, green: 0.12, blue: 0.15)) {
                        viewModel.searchQuery = "Netflix"
                        viewModel.search()
                    }
                    StreamingCard(name: "Disney+", color: Color(red: 0.07, green: 0.22, blue: 0.56)) {
                        viewModel.searchQuery = "Disney"
                        viewModel.search()
                    }
                    StreamingCard(name: "Prime", color: Color(red: 0.0, green: 0.66, blue: 0.88)) {
                        viewModel.searchQuery = "Amazon"
                        viewModel.search()
                    }
                    StreamingCard(name: "Max", color: Color(red: 0.0, green: 0.14, blue: 0.53)) {
                        viewModel.searchQuery = "HBO"
                        viewModel.search()
                    }
                    StreamingCard(name: "Apple TV+", color: Color.gray) {
                        viewModel.searchQuery = "Apple"
                        viewModel.search()
                    }
                    StreamingCard(name: "Hulu", color: Color(red: 0.11, green: 0.81, blue: 0.49)) {
                        viewModel.searchQuery = "Hulu"
                        viewModel.search()
                    }
                    StreamingCard(name: "Peacock", color: Color(red: 0.0, green: 0.0, blue: 0.0)) {
                        viewModel.searchQuery = "Peacock"
                        viewModel.search()
                    }
                    StreamingCard(name: "Paramount+", color: Color(red: 0.0, green: 0.34, blue: 0.73)) {
                        viewModel.searchQuery = "Paramount"
                        viewModel.search()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
            Text("Searching...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    // MARK: - No Results

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))

            Text("No results found")
                .font(.title3.bold())
                .foregroundColor(.white)

            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    // MARK: - Search Results

    private var searchResultsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(viewModel.searchResults.count) Results")
                .font(.headline)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(viewModel.searchResults) { movie in
                    SearchResultCard(movie: movie) {
                        onMovieTap(movie)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.2))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(12)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - Genre Card

struct GenreCard: View {
    let genre: Genre
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(genre.emoji)
                    .font(.system(size: 24))

                Text(genre.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}

// MARK: - Streaming Card

struct StreamingCard: View {
    let name: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color)
                )
        }
    }
}

// MARK: - Search Result Card

struct SearchResultCard: View {
    let movie: Movie
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Poster
                KFImage(movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                    }
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                // Title
                Text(movie.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)

                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text(movie.formattedRating)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - Genre Emoji Extension

extension Genre {
    var emoji: String {
        switch id {
        case 28: return "💥" // Action
        case 12: return "🗺️" // Adventure
        case 16: return "🎨" // Animation
        case 35: return "😂" // Comedy
        case 80: return "🔪" // Crime
        case 99: return "📹" // Documentary
        case 18: return "🎭" // Drama
        case 10751: return "👨‍👩‍👧" // Family
        case 14: return "🧙" // Fantasy
        case 36: return "📜" // History
        case 27: return "👻" // Horror
        case 10402: return "🎵" // Music
        case 9648: return "🔍" // Mystery
        case 10749: return "💕" // Romance
        case 878: return "🚀" // Science Fiction
        case 10770: return "📺" // TV Movie
        case 53: return "😰" // Thriller
        case 10752: return "⚔️" // War
        case 37: return "🤠" // Western
        default: return "🎬"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(
            viewModel: SearchViewModel(
                tmdbService: .shared,
                watchlistManager: WatchlistManager()
            )
        )
        .preferredColorScheme(.dark)
    }
}
#endif
