//
//  SearchView.swift
//  MovieTrailer
//
//  Premium Search & Discovery Experience
//

import SwiftUI
import Kingfisher

// MARK: - Streaming Provider (Embedded)

/// Represents a major streaming service with its TMDB provider ID
enum StreamingProvider: Int, CaseIterable, Identifiable {
    case netflix = 8
    case amazonPrime = 9
    case disneyPlus = 337
    case hboMax = 384
    case hulu = 15
    case appleTVPlus = 350
    case paramount = 531
    case peacock = 386

    var id: Int { rawValue }

    var shortName: String {
        switch self {
        case .netflix: return "Netflix"
        case .amazonPrime: return "Prime"
        case .disneyPlus: return "Disney+"
        case .hboMax: return "Max"
        case .hulu: return "Hulu"
        case .appleTVPlus: return "Apple TV+"
        case .paramount: return "Paramount+"
        case .peacock: return "Peacock"
        }
    }

    var logoPath: String {
        switch self {
        case .netflix: return "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg"
        case .amazonPrime: return "/emthp39XA2YScoYL1p0sdbAH2WA.jpg"
        case .disneyPlus: return "/7rwgEs15tFwyR9NPQ5vpzxTj19Q.jpg"
        case .hboMax: return "/aS2zvJWn9mwiCOeaaCkIh4wleZS.jpg"
        case .hulu: return "/zxrVdFjIjLqkfnwyghnfywTn3Lh.jpg"
        case .appleTVPlus: return "/6uhKBfmtzFqOcLousHwZuzcrScK.jpg"
        case .paramount: return "/xbhHHa1YgtpwhC8lb1NQ3ACVcLd.jpg"
        case .peacock: return "/8VCV78prwd9QzZnEm0ReO6bERDa.jpg"
        }
    }

    var logoURL: URL? {
        URL(string: "https://image.tmdb.org/t/p/w92\(logoPath)")
    }

    var brandColor: Color {
        switch self {
        case .netflix: return Color(red: 0.89, green: 0.12, blue: 0.15)
        case .amazonPrime: return Color(red: 0.0, green: 0.66, blue: 0.88)
        case .disneyPlus: return Color(red: 0.07, green: 0.22, blue: 0.56)
        case .hboMax: return Color(red: 0.0, green: 0.14, blue: 0.53)
        case .hulu: return Color(red: 0.11, green: 0.81, blue: 0.49)
        case .appleTVPlus: return Color.gray
        case .paramount: return Color(red: 0.0, green: 0.34, blue: 0.73)
        case .peacock: return Color(red: 0.0, green: 0.0, blue: 0.0)
        }
    }

    static var featured: [StreamingProvider] {
        [.netflix, .disneyPlus, .amazonPrime, .hboMax, .appleTVPlus, .hulu, .peacock, .paramount]
    }

    var searchQuery: String {
        switch self {
        case .hboMax: return "HBO"
        case .amazonPrime: return "Amazon"
        default: return shortName
        }
    }
}

private enum SearchSortOption: String, CaseIterable {
    case popularity = "Popularity"
    case rating = "Rating"
    case releaseDate = "Release Date"

    var icon: String {
        switch self {
        case .popularity:
            return "flame.fill"
        case .rating:
            return "star.fill"
        case .releaseDate:
            return "calendar"
        }
    }
}

struct SearchView: View {

    @StateObject private var viewModel: SearchViewModel
    @StateObject private var voiceSearch = VoiceSearchManager()
    @FocusState private var isSearchFocused: Bool
    @State private var sortOption: SearchSortOption = .popularity

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
                    } else if let error = viewModel.error, !viewModel.searchQuery.isEmpty {
                        searchErrorView(error)
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

    private var sortedSearchResults: [Movie] {
        switch sortOption {
        case .popularity:
            return viewModel.searchResults.sorted { $0.popularity > $1.popularity }
        case .rating:
            return viewModel.searchResults.sorted { $0.voteAverage > $1.voteAverage }
        case .releaseDate:
            return viewModel.searchResults.sorted { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
        }
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
                            Task {
                                await viewModel.fetchTrending()
                            }
                        }

                        QuickActionCard(
                            title: "New Releases",
                            subtitle: "Just dropped",
                            icon: "sparkles",
                            color: .cyan
                        ) {
                            Task {
                                await viewModel.fetchNewReleases()
                            }
                        }
                    }

                    HStack(spacing: 10) {
                        QuickActionCard(
                            title: "Top Rated",
                            subtitle: "Best of all time",
                            icon: "star.fill",
                            color: .yellow
                        ) {
                            Task {
                                await viewModel.fetchTopRated()
                            }
                        }

                        QuickActionCard(
                            title: "Coming Soon",
                            subtitle: "Mark your calendar",
                            icon: "calendar",
                            color: .green
                        ) {
                            Task {
                                await viewModel.fetchUpcoming()
                            }
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
                        if viewModel.isLoadingTrending {
                            ForEach(0..<5, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 80, height: 36)
                                    .shimmer(isActive: true)
                            }
                        } else {
                            ForEach(viewModel.trendingSearches, id: \.self) { term in
                                Button {
                                    viewModel.searchQuery = term
                                    viewModel.search()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "flame.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(.orange)
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
                    }
                    .padding(.horizontal, 20)
                }
                .task {
                    await viewModel.loadTrendingSearches()
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
                    ForEach(Genre.all) { genre in
                        GenreCard(genre: genre) {
                            Task {
                                await viewModel.fetchByGenre(genre.id, genreName: genre.name)
                            }
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
                    ForEach(StreamingProvider.featured) { provider in
                        StreamingProviderCard(provider: provider) {
                            Task {
                                await viewModel.fetchByStreamingProvider(provider.id, providerName: provider.shortName)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: 16) {
            Text("Searching...")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 12)

            SkeletonMovieGrid(columns: 3, rowCount: 3)
        }
    }

    // MARK: - No Results

    private var noResultsView: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No results found",
            message: "Try a different search term"
        ) {
            Button {
                viewModel.clearSearch()
            } label: {
                Text("Clear Search")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func searchErrorView(_ error: NetworkError) -> some View {
        ErrorView(error: error) {
            viewModel.search()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Search Results

    private var searchResultsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(viewModel.searchResults.count) Results")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                Menu {
                    ForEach(SearchSortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            Label(option.rawValue, systemImage: option.icon)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(sortedSearchResults) { movie in
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

// MARK: - Streaming Provider Card with Logo

struct StreamingProviderCard: View {
    let provider: StreamingProvider
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Provider Logo
                KFImage(provider.logoURL)
                    .placeholder {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(provider.brandColor)
                            .overlay(
                                Text(provider.shortName.prefix(1))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                // Provider Name
                Text(provider.shortName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// MARK: - Streaming Card (Legacy)

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
