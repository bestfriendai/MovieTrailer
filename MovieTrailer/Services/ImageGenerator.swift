//
//  ImageGenerator.swift
//  MovieTrailer
//
//  Created by Daniel Wijono on 10/12/2025.
//

import SwiftUI
import UIKit

/// Generates shareable images from watchlist
@MainActor
struct ImageGenerator {
    
    // MARK: - Public Methods
    
    /// Generate a shareable image from watchlist items
    static func generateWatchlistImage(
        items: [WatchlistItem],
        maxItems: Int = 12
    ) async -> UIImage? {
        let limitedItems = Array(items.prefix(maxItems))
        
        let renderer = ImageRenderer(
            content: WatchlistShareView(items: limitedItems)
        )
        
        // Set scale for high quality
        renderer.scale = 3.0
        
        // Generate UIImage
        return renderer.uiImage
    }
    
    /// Generate image and return as Data (for sharing)
    static func generateWatchlistImageData(
        items: [WatchlistItem],
        maxItems: Int = 12,
        compressionQuality: CGFloat = 0.8
    ) async -> Data? {
        guard let image = await generateWatchlistImage(items: items, maxItems: maxItems) else {
            return nil
        }
        return image.jpegData(compressionQuality: compressionQuality)
    }
}

// MARK: - Watchlist Share View

private struct WatchlistShareView: View {
    let items: [WatchlistItem]
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("My Watchlist")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("\(items.count) Movies")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Movie Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    PosterThumbnail(item: item)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Footer
            HStack(spacing: 12) {
                Image(systemName: "film.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                
                Text("MovieTrailer")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 40)
        }
        .frame(width: 1080, height: 1920) // Instagram story size
        .background(
            LinearGradient(
                colors: [
                    Color(white: 0.05),
                    Color(white: 0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Poster Thumbnail

private struct PosterThumbnail: View {
    let item: WatchlistItem
    
    var body: some View {
        VStack(spacing: 8) {
            // Poster placeholder with gradient
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .aspectRatio(2/3, contentMode: .fit)
                .overlay(
                    VStack {
                        Image(systemName: "film")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(item.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 8)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            // Rating
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
                
                Text(item.formattedRating)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Alternative: Compact List View

extension ImageGenerator {
    /// Generate a compact list-style image
    static func generateCompactListImage(
        items: [WatchlistItem],
        maxItems: Int = 10
    ) async -> UIImage? {
        let limitedItems = Array(items.prefix(maxItems))
        
        let renderer = ImageRenderer(
            content: CompactListShareView(items: limitedItems)
        )
        
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

private struct CompactListShareView: View {
    let items: [WatchlistItem]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Watchlist")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(items.count) movies to watch")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "film.stack.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.horizontal, 32)
            .padding(.top, 40)
            
            // Movie List
            VStack(spacing: 16) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 16) {
                        // Rank
                        Text("\(index + 1)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .frame(width: 40)
                        
                        // Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            HStack(spacing: 8) {
                                if let year = item.releaseYear {
                                    Text(year)
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.yellow)
                                    
                                    Text(item.formattedRating)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                }
            }
            
            Spacer()
            
            // Footer
            Text("Created with MovieTrailer")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
        }
        .frame(width: 1080, height: 1920)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Preview Helpers

#if DEBUG
struct ImageGenerator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WatchlistShareView(items: WatchlistItem.samples)
                .previewDisplayName("Grid Style")
            
            CompactListShareView(items: WatchlistItem.samples)
                .previewDisplayName("List Style")
        }
    }
}
#endif
