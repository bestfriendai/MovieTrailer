//
//  MovieDetailView.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 11/12/2025.
//

import SwiftUI
import Kingfisher

struct MovieDetailView: View {
    
    let movie: Movie
    let isInWatchlist: Bool
    let onWatchlistToggle: () -> Void
    let onClose: () -> Void
    let tmdbService: TMDBService
    
    @State private var showingFullOverview = false
    @State private var trailers: [Video] = []
    @State private var selectedTrailer: Video?
    @State private var showingTrailer = false
    @State private var isLoadingTrailers = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Backdrop header - ignores top safe area only
                backdropHeader
                
                // Content - respects all safe areas with proper padding
                VStack(alignment: .leading, spacing: 24) {
                    // Title and rating
                    titleSection
                    
                    // Quick info
                    quickInfoSection
                    
                    // Overview
                    overviewSection
                    
                    // Trailers (if available)
                    if !trailers.isEmpty {
                        trailerSection
                    }
                    
                    // Genres
                    genresSection
                    
                    // Action buttons
                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .ignoresSafeArea(edges: .top) // Only ignore top for backdrop bleed
        .fullScreenCover(isPresented: $showingTrailer) {
            if let trailer = selectedTrailer {
                TrailerPlayerView(
                    video: trailer,
                    onClose: {
                        showingTrailer = false
                        selectedTrailer = nil
                    }
                )
            }
        }
        .task {
            await loadTrailers()
        }
    }
    
    // MARK: - Backdrop Header
    
    private var backdropHeader: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Backdrop image - constrained to geometry width
                KFImage(movie.backdropURL)
                    .placeholder {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: 280)
                    .clipped()
                
                // Gradient overlay
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geometry.size.width, height: 280)
                
                // Close button
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .padding()
            }
        }
        .frame(height: 280)
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(movie.title)
                .font(.title.bold())
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(movie.formattedRating)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                // Vote count
                Text("(\(movie.voteCount) reviews)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Quick Info
    
    private var quickInfoSection: some View {
        HStack(spacing: 20) {
            if let year = movie.releaseYear {
                Label(year, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Label(movie.originalLanguage.uppercased(), systemImage: "globe")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Overview
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.title3.bold())
            
            Text(movie.overview)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(showingFullOverview ? nil : 4)
            
            if movie.overview.count > 200 {
                Button {
                    withAnimation {
                        showingFullOverview.toggle()
                    }
                } label: {
                    Text(showingFullOverview ? "Show Less" : "Show More")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    // MARK: - Genres
    
    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Genres")
                .font(.title3.bold())
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Genre.names(for: movie.genreIds), id: \.self) { genreName in
                        Text(genreName)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Watchlist button
            Button(action: onWatchlistToggle) {
                HStack(spacing: 12) {
                    Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                    
                    Text(isInWatchlist ? "Remove from Watchlist" : "Add to Watchlist")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: isInWatchlist ? [.red, .orange] : [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .foregroundColor(.white)
                .shadow(color: (isInWatchlist ? Color.red : Color.blue).opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top)
    }
    
    // MARK: - Trailer Section
    
    private var trailerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trailers")
                .font(.title3.bold())
            
            if trailers.count == 1 {
                // Single trailer - large button
                Button {
                    selectedTrailer = trailers[0]
                    showingTrailer = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Watch Trailer")
                                .font(.headline)
                            Text(trailers[0].name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            } else {
                // Multiple trailers - horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(trailers) { trailer in
                            TrailerCardView(
                                trailer: trailer,
                                onTap: {
                                    selectedTrailer = trailer
                                    showingTrailer = true
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadTrailers() async {
        isLoadingTrailers = true
        defer { isLoadingTrailers = false }
        
        do {
            let videoResponse = try await tmdbService.fetchVideos(for: movie.id)
            await MainActor.run {
                trailers = videoResponse.allTrailers
            }
        } catch {
            print("⚠️ Failed to load trailers: \(error)")
            // Silently fail - trailers are optional
        }
    }
}

// MARK: - Trailer Card View

private struct TrailerCardView: View {
    let trailer: Video
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail with play icon overlay
                ZStack {
                    AsyncImage(url: trailer.youtubeThumbnailURL) { image in
                        image
                            .resizable()
                            .aspectRatio(16/9, contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.gray.opacity(0.3), .gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .aspectRatio(16/9, contentMode: .fill)
                    }
                    .frame(width: 200, height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Play button overlay
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                // Trailer name
                Text(trailer.name)
                    .font(.caption.bold())
                    .lineLimit(2)
                    .frame(width: 200, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MovieDetailView(
            movie: .sample,
            isInWatchlist: false,
            onWatchlistToggle: {},
            onClose: {}
        )
    }
}
#endif
