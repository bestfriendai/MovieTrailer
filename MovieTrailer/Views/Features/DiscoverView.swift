//
//  DiscoverView.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI

struct DiscoverView: View {
    
    @StateObject private var viewModel: DiscoverViewModel
    let onMovieTap: (Movie) -> Void
    
    init(viewModel: DiscoverViewModel, onMovieTap: @escaping (Movie) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMovieTap = onMovieTap
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Trending Section
                MovieSection(
                    title: "Trending This Week",
                    icon: "flame.fill",
                    iconColor: .orange,
                    movies: viewModel.trendingMovies,
                    isLoading: viewModel.isLoadingTrending,
                    isInWatchlist: viewModel.isInWatchlist,
                    onMovieTap: onMovieTap,
                    onWatchlistToggle: viewModel.toggleWatchlist
                )
                
                // Popular Section
                MovieSection(
                    title: "Popular Now",
                    icon: "star.fill",
                    iconColor: .yellow,
                    movies: viewModel.popularMovies,
                    isLoading: viewModel.isLoadingPopular,
                    isInWatchlist: viewModel.isInWatchlist,
                    onMovieTap: onMovieTap,
                    onWatchlistToggle: viewModel.toggleWatchlist
                )
                
                // Top Rated Section
                MovieSection(
                    title: "Top Rated",
                    icon: "trophy.fill",
                    iconColor: .purple,
                    movies: viewModel.topRatedMovies,
                    isLoading: viewModel.isLoadingTopRated,
                    isInWatchlist: viewModel.isInWatchlist,
                    onMovieTap: onMovieTap,
                    onWatchlistToggle: viewModel.toggleWatchlist
                )
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            HapticManager.shared.pulledToRefresh()
            await viewModel.refresh()
        }
        .task {
            if viewModel.trendingMovies.isEmpty {
                await viewModel.loadContent()
            }
        }
        .overlay {
            if let error = viewModel.error, viewModel.trendingMovies.isEmpty {
                ErrorView(error: error) {
                    Task {
                        await viewModel.loadContent()
                    }
                }
            }
        }
    }
}

// MARK: - Movie Section

struct MovieSection: View {
    
    let title: String
    let icon: String
    let iconColor: Color
    let movies: [Movie]
    let isLoading: Bool
    let isInWatchlist: (Movie) -> Bool
    let onMovieTap: (Movie) -> Void
    let onWatchlistToggle: (Movie) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [iconColor, iconColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Movies scroll
            if isLoading && movies.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<5, id: \.self) { _ in
                            MovieCardSkeleton()
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(movies) { movie in
                            MovieCard(
                                movie: movie,
                                isInWatchlist: isInWatchlist(movie),
                                onTap: {
                                    onMovieTap(movie)
                                },
                                onWatchlistToggle: {
                                    onWatchlistToggle(movie)
                                }
                            )
                            .frame(width: 160)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Skeleton Loader

struct MovieCardSkeleton: View {
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster skeleton
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.3),
                            Color.gray.opacity(0.1),
                            Color.gray.opacity(0.3)
                        ],
                        startPoint: isAnimating ? .leading : .trailing,
                        endPoint: isAnimating ? .trailing : .leading
                    )
                )
                .aspectRatio(2/3, contentMode: .fill)
            
            // Title skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
            
            // Rating skeleton
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 12)
        }
        .frame(width: 160)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DiscoverView(viewModel: .mock(), onMovieTap: { _ in })
        }
    }
}
#endif
