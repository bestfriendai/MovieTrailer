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
    @State private var watchProviders: WatchProviderInfo = .empty
    @State private var isLoadingProviders = false
    
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

                    // Watch Providers (streaming platforms)
                    WatchProvidersView(providers: watchProviders) { link in
                        if let link = link, let url = URL(string: link) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding(.horizontal, -20) // Offset parent padding for full-width

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
        .background(Color.black)
        .ignoresSafeArea(edges: .top) // Only ignore top for backdrop bleed
        .fullScreenCover(isPresented: $showingTrailer) {
            if let trailer = selectedTrailer {
                TrailerPlayerView(
                    video: trailer,
                    onClose: {
                        print("🎬 MovieDetailView: User closed trailer player")
                        showingTrailer = false
                        selectedTrailer = nil
                    }
                )
                .onAppear {
                    print("🎬 MovieDetailView: fullScreenCover presenting trailer: \(trailer.name)")
                }
            } else {
                Color.red.ignoresSafeArea()
                    .overlay(
                        Text("Error: No trailer selected")
                            .foregroundColor(.white)
                    )
                    .onAppear {
                        print("⚠️ MovieDetailView: fullScreenCover triggered but selectedTrailer is nil!")
                    }
            }
        }
        .onChange(of: showingTrailer) { newValue in
            print("🎬 MovieDetailView: showingTrailer changed to: \(newValue)")
            print("🎬 MovieDetailView: selectedTrailer is: \(selectedTrailer?.name ?? "nil")")
        }
        .task {
            await loadTrailers()
            await loadWatchProviders()
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
                            .fill(Color(white: 0.15))
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: 300)
                    .clipped()

                // Gradient overlay for readability
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.2),
                        Color.clear,
                        Color.clear,
                        Color.black.opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geometry.size.width, height: 300)

                // Close button - properly positioned below status bar
                Button(action: {
                    Haptics.shared.lightImpact()
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                        )
                }
                .padding(.top, 60) // Account for status bar + safe area
                .padding(.leading, 20)
            }
        }
        .frame(height: 300)
    }
    
    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(movie.title)
                .font(.title.bold())
                .foregroundColor(.white)
                .lineLimit(3)
                .truncationMode(.tail)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 16) {
                // Rating
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(movie.formattedRating)
                        .font(.headline)
                        .foregroundColor(.white)
                }

                // Vote count
                Text("(\(movie.voteCount) reviews)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Quick Info

    private var quickInfoSection: some View {
        HStack(spacing: 20) {
            if let year = movie.releaseYear {
                Label(year, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }

            Label(movie.originalLanguage.uppercased(), systemImage: "globe")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    // MARK: - Overview

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.title3.bold())
                .foregroundColor(.white)

            Text(movie.overview)
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(showingFullOverview ? nil : 4)

            if movie.overview.count > 200 {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingFullOverview.toggle()
                    }
                } label: {
                    Text(showingFullOverview ? "Show Less" : "Show More")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
    }
    
    // MARK: - Genres

    private var genresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Genres")
                .font(.title3.bold())
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Genre.names(for: movie.genreIds), id: \.self) { genreName in
                        Text(genreName)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
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
            Button(action: {
                Haptics.shared.mediumImpact()
                onWatchlistToggle()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: isInWatchlist ? "checkmark" : "plus")
                        .font(.system(size: 16, weight: .bold))

                    Text(isInWatchlist ? "In Watchlist" : "Add to Watchlist")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isInWatchlist ? Color.white.opacity(0.15) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(isInWatchlist ? 0.3 : 0), lineWidth: 1)
                )
                .foregroundColor(isInWatchlist ? .white : .black)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.top, 8)
    }
    
    // MARK: - Trailer Section

    private var trailerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trailers")
                .font(.title3.bold())
                .foregroundColor(.white)
            
            if trailers.count == 1 {
                // Single trailer - large button
                Button {
                    print("🎬 MovieDetailView: User tapped single trailer button")
                    print("   Trailer: \(trailers[0].name)")
                    print("   Video key: \(trailers[0].key)")
                    selectedTrailer = trailers[0]
                    showingTrailer = true
                    print("   showingTrailer set to: \(showingTrailer)")
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
                                    print("🎬 MovieDetailView: User tapped trailer card")
                                    print("   Trailer: \(trailer.name)")
                                    print("   Video key: \(trailer.key)")
                                    selectedTrailer = trailer
                                    showingTrailer = true
                                    print("   showingTrailer set to: \(showingTrailer)")
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
        print("🎬 MovieDetailView: Starting to load trailers for movie ID: \(movie.id)")
        isLoadingTrailers = true
        defer { isLoadingTrailers = false }

        do {
            let videoResponse = try await tmdbService.fetchVideos(for: movie.id)
            await MainActor.run {
                trailers = videoResponse.allTrailers
                print("🎬 MovieDetailView: Successfully loaded \(trailers.count) trailers")
                for (index, trailer) in trailers.enumerated() {
                    print("   Trailer \(index + 1): \(trailer.name) - Key: \(trailer.key) - Site: \(trailer.site)")
                }
            }
        } catch {
            print("⚠️ MovieDetailView: Failed to load trailers: \(error)")
            // Silently fail - trailers are optional
        }
    }

    private func loadWatchProviders() async {
        isLoadingProviders = true
        defer { isLoadingProviders = false }

        do {
            let providers = try await tmdbService.fetchWatchProviders(for: movie.id)
            await MainActor.run {
                watchProviders = providers
            }
        } catch {
            // Silently fail - watch providers are optional
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
            onClose: {},
            tmdbService: .shared
        )
    }
}
#endif
