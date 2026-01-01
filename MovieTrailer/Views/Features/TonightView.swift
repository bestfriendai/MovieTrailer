//
//  TonightView.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI

struct TonightView: View {
    
    @StateObject private var viewModel: TonightViewModel
    let onMovieTap: (Movie) -> Void
    
    init(viewModel: TonightViewModel, onMovieTap: @escaping (Movie) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onMovieTap = onMovieTap
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.recommendations.isEmpty {
                LoadingView()
            } else if let error = viewModel.error, viewModel.recommendations.isEmpty {
                ErrorView(error: error) {
                    Task {
                        await viewModel.generateRecommendations()
                    }
                }
            } else if viewModel.recommendations.isEmpty {
                emptyStateView
            } else {
                recommendationsView
            }
        }
        .navigationTitle("Tonight")
        .refreshable {
            HapticManager.shared.pulledToRefresh()
            await viewModel.refresh()
        }
        .task {
            if viewModel.recommendations.isEmpty {
                await viewModel.generateRecommendations()
            }
        }
    }
    
    // MARK: - Recommendations View
    
    private var recommendationsView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("What to Watch Tonight")
                        .font(.title.bold())
                    
                    Text("Personalized picks just for you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Recommendations grid
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 20
                ) {
                    ForEach(viewModel.recommendations) { movie in
                        MovieCard(
                            movie: movie,
                            isInWatchlist: viewModel.isInWatchlist(movie),
                            onTap: {
                                onMovieTap(movie)
                            },
                            onWatchlistToggle: {
                                viewModel.toggleWatchlist(for: movie)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "sparkles",
            title: "No Recommendations Yet",
            message: "Add some movies to your watchlist to get personalized recommendations!"
        ) {
            Button {
                Task {
                    await viewModel.generateRecommendations()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Generate Recommendations")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TonightView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TonightView(viewModel: .mock())
        }
    }
}
#endif
