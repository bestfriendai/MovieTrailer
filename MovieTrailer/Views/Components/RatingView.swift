//
//  RatingView.swift
//  MovieTrailer
//
//  Created by Silverius Daniel Wijono on 09/12/25.
//  Implemented by Claude Code Audit on 28/12/2025.
//

import SwiftUI

/// Customizable rating display component with stars and score
struct RatingView: View {

    // MARK: - Properties

    let rating: Double
    let maxRating: Double
    let style: RatingStyle

    // MARK: - Initialization

    init(rating: Double, maxRating: Double = 10.0, style: RatingStyle = .compact) {
        self.rating = rating
        self.maxRating = maxRating
        self.style = style
    }

    // MARK: - Styles

    enum RatingStyle {
        case compact      // Star icon + number
        case stars        // 5 star icons
        case circular     // Circular progress
        case badge        // Badge style with background

        var starCount: Int { 5 }
    }

    // MARK: - Computed Properties

    private var normalizedRating: Double {
        (rating / maxRating) * 5.0
    }

    private var formattedRating: String {
        String(format: "%.1f", rating)
    }

    private var ratingColor: Color {
        switch rating {
        case 8.0...: return .green
        case 6.0..<8.0: return .yellow
        case 4.0..<6.0: return .orange
        default: return .red
        }
    }

    // MARK: - Body

    var body: some View {
        switch style {
        case .compact:
            compactView
        case .stars:
            starsView
        case .circular:
            circularView
        case .badge:
            badgeView
        }
    }

    // MARK: - Compact View

    private var compactView: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.yellow)

            Text(formattedRating)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating: \(formattedRating) out of \(Int(maxRating))")
    }

    // MARK: - Stars View

    private var starsView: some View {
        HStack(spacing: 2) {
            ForEach(0..<style.starCount, id: \.self) { index in
                starImage(for: index)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating: \(formattedRating) out of \(Int(maxRating))")
    }

    private func starImage(for index: Int) -> some View {
        let threshold = Double(index) + 0.5
        let imageName: String

        if normalizedRating >= Double(index + 1) {
            imageName = "star.fill"
        } else if normalizedRating >= threshold {
            imageName = "star.leadinghalf.filled"
        } else {
            imageName = "star"
        }

        return Image(systemName: imageName)
            .font(.caption)
            .foregroundColor(.yellow)
    }

    // MARK: - Circular View

    private var circularView: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)

            // Progress circle
            Circle()
                .trim(from: 0, to: rating / maxRating)
                .stroke(
                    ratingColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5), value: rating)

            // Rating text
            VStack(spacing: 0) {
                Text(formattedRating)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .frame(width: 44, height: 44)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating: \(formattedRating) out of \(Int(maxRating))")
    }

    // MARK: - Badge View

    private var badgeView: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
                .foregroundColor(.white)

            Text(formattedRating)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(ratingColor)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Rating: \(formattedRating) out of \(Int(maxRating))")
    }
}

// MARK: - Preview

#if DEBUG
struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Group {
                Text("Compact Style")
                    .font(.headline)
                HStack(spacing: 20) {
                    RatingView(rating: 8.5, style: .compact)
                    RatingView(rating: 6.5, style: .compact)
                    RatingView(rating: 4.0, style: .compact)
                }
            }

            Divider()

            Group {
                Text("Stars Style")
                    .font(.headline)
                VStack(spacing: 8) {
                    RatingView(rating: 10.0, style: .stars)
                    RatingView(rating: 7.5, style: .stars)
                    RatingView(rating: 5.0, style: .stars)
                }
            }

            Divider()

            Group {
                Text("Circular Style")
                    .font(.headline)
                HStack(spacing: 20) {
                    RatingView(rating: 8.5, style: .circular)
                    RatingView(rating: 6.5, style: .circular)
                    RatingView(rating: 4.0, style: .circular)
                }
            }

            Divider()

            Group {
                Text("Badge Style")
                    .font(.headline)
                HStack(spacing: 12) {
                    RatingView(rating: 8.5, style: .badge)
                    RatingView(rating: 6.5, style: .badge)
                    RatingView(rating: 4.0, style: .badge)
                }
            }
        }
        .padding()
    }
}
#endif
