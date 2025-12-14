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
    
    @State private var showingFullOverview = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Backdrop header
                backdropHeader
                
                // Content
                VStack(alignment: .leading, spacing: 24) {
                    // Title and rating
                    titleSection
                    
                    // Quick info
                    quickInfoSection
                    
                    // Overview
                    overviewSection
                    
                    // Genres
                    genresSection
                    
                    // Action buttons
                    actionButtons
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure full width
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(Color(uiColor: .systemBackground))
        // Removed .ignoresSafeArea to prevent scaling issues
    }
    
    // MARK: - Backdrop Header
    
    private var backdropHeader: some View {
        ZStack(alignment: .topLeading) {
            // Backdrop image
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
                .aspectRatio(16/9, contentMode: .fill)
                .frame(height: 280)
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
            .frame(height: 280)
            
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
