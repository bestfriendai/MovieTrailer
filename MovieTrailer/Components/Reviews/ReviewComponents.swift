//
//  ReviewComponents.swift
//  MovieTrailer
//
//  Apple 2025 Premium Review Components
//  User reviews with expandable content
//

import SwiftUI
import Kingfisher

// MARK: - Review Card

/// Individual review card with author and content
struct ReviewCard: View {

    let review: Review
    let onTap: (() -> Void)?

    @State private var isExpanded = false

    init(review: Review, onTap: (() -> Void)? = nil) {
        self.review = review
        self.onTap = onTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            header

            // Content
            content

            // Footer
            if review.isLongReview || review.reviewURL != nil {
                footer
            }
        }
        .padding(Spacing.md)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large, style: .continuous)
                .stroke(Color.glassBorder, lineWidth: 0.5)
        )
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Spacing.sm) {
            // Avatar
            avatar

            // Author info
            VStack(alignment: .leading, spacing: 2) {
                Text(review.authorDetails?.displayName ?? review.author)
                    .font(.labelLarge)
                    .foregroundColor(.textPrimary)

                if let timeAgo = review.timeAgo {
                    Text(timeAgo)
                        .font(.captionSmall)
                        .foregroundColor(.textTertiary)
                }
            }

            Spacer()

            // Rating
            if let rating = review.rating {
                ratingBadge(rating: rating)
            }
        }
    }

    private var avatar: some View {
        Group {
            if let avatarURL = review.avatarURL {
                KFImage(avatarURL)
                    .placeholder {
                        initialsAvatar
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                initialsAvatar
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    private var initialsAvatar: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.accentPrimary.opacity(0.6), .accentSecondary.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Text(review.authorDetails?.initials ?? "??")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
    }

    private func ratingBadge(rating: Double) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(.ratingStar)

            Text(String(format: "%.0f", rating))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    // MARK: - Content

    private var content: some View {
        Text(isExpanded ? review.content : review.truncatedContent)
            .font(.bodySmall)
            .foregroundColor(.textSecondary)
            .lineLimit(isExpanded ? nil : 4)
            .animation(AppTheme.Animation.smooth, value: isExpanded)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            // Expand/Collapse button
            if review.isLongReview {
                Button {
                    withAnimation(AppTheme.Animation.smooth) {
                        isExpanded.toggle()
                    }
                    Haptics.shared.selectionChanged()
                } label: {
                    Text(isExpanded ? "Show Less" : "Read More")
                        .font(.labelMedium)
                        .foregroundColor(.accentPrimary)
                }
            }

            Spacer()

            // External link
            if let url = review.reviewURL {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Text("Full Review")
                            .font(.labelSmall)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(.textTertiary)
                }
            }
        }
    }
}

// MARK: - Reviews Section

/// Section showing featured reviews with see all option
struct ReviewsSection: View {

    let reviews: [Review]
    let totalCount: Int
    let onReviewTap: ((Review) -> Void)?
    let onSeeAllTap: (() -> Void)?

    init(
        reviews: [Review],
        totalCount: Int = 0,
        onReviewTap: ((Review) -> Void)? = nil,
        onSeeAllTap: (() -> Void)? = nil
    ) {
        self.reviews = reviews
        self.totalCount = totalCount > 0 ? totalCount : reviews.count
        self.onReviewTap = onReviewTap
        self.onSeeAllTap = onSeeAllTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Section header
            sectionHeader

            // Reviews
            if reviews.isEmpty {
                emptyState
            } else {
                reviewsList
            }
        }
    }

    private var sectionHeader: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                Text("Reviews")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                if totalCount > 0 {
                    Text("(\(totalCount))")
                        .font(.labelMedium)
                        .foregroundColor(.textTertiary)
                }
            }

            Spacer()

            if let onSeeAllTap = onSeeAllTap, totalCount > 3 {
                Button {
                    Haptics.shared.buttonTapped()
                    onSeeAllTap()
                } label: {
                    Text("See All")
                        .font(.labelMedium)
                        .foregroundColor(.accentPrimary)
                }
            }
        }
        .padding(.horizontal, Spacing.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "text.bubble")
                .font(.system(size: 40))
                .foregroundColor(.textTertiary)

            Text("No reviews yet")
                .font(.labelLarge)
                .foregroundColor(.textSecondary)

            Text("Be the first to share your thoughts")
                .font(.captionRegular)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .padding(.horizontal, Spacing.horizontal)
    }

    private var reviewsList: some View {
        VStack(spacing: Spacing.md) {
            ForEach(Array(reviews.prefix(3).enumerated()), id: \.element.id) { index, review in
                ReviewCard(review: review) {
                    onReviewTap?(review)
                }
                .slideInStaggered(index: index)
            }
        }
        .padding(.horizontal, Spacing.horizontal)
    }
}

// MARK: - Compact Review Card

/// Smaller review card for horizontal scrolling
struct CompactReviewCard: View {

    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Header with rating
            HStack {
                // Author
                HStack(spacing: Spacing.xs) {
                    Circle()
                        .fill(Color.accentPrimary.opacity(0.3))
                        .frame(width: 24, height: 24)
                        .overlay {
                            Text(review.authorDetails?.initials.prefix(1) ?? "?")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.accentPrimary)
                        }

                    Text(review.authorDetails?.displayName ?? review.author)
                        .font(.labelSmall)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                }

                Spacer()

                // Rating
                if let rating = review.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.ratingStar)
                        Text(String(format: "%.0f", rating))
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.textPrimary)
                }
            }

            // Content
            Text(review.content)
                .font(.captionRegular)
                .foregroundColor(.textSecondary)
                .lineLimit(3)

            // Time
            if let timeAgo = review.timeAgo {
                Text(timeAgo)
                    .font(.captionSmall)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(Spacing.sm)
        .frame(width: 260)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
    }
}

// MARK: - Horizontal Reviews Row

/// Horizontal scrolling row of compact reviews
struct HorizontalReviewsRow: View {

    let reviews: [Review]
    let onSeeAllTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header
            HStack {
                Text("Reviews")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                Spacer()

                if let onSeeAllTap = onSeeAllTap {
                    Button {
                        onSeeAllTap()
                    } label: {
                        Text("See All")
                            .font(.labelMedium)
                            .foregroundColor(.accentPrimary)
                    }
                }
            }
            .padding(.horizontal, Spacing.horizontal)

            // Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(reviews.prefix(5)) { review in
                        CompactReviewCard(review: review)
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }
}

// MARK: - Star Rating View

/// Display star rating (1-5 stars)
struct StarRatingView: View {

    let rating: Double
    let maxRating: Int = 5
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starType(for: index))
                    .font(.system(size: size, weight: .semibold))
                    .foregroundColor(.ratingStar)
            }
        }
    }

    private func starType(for index: Int) -> String {
        let fullStars = Int(rating / 2)
        let hasHalfStar = (rating / 2) - Double(fullStars) >= 0.5

        if index <= fullStars {
            return "star.fill"
        } else if index == fullStars + 1 && hasHalfStar {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ReviewComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Full Reviews Section
                ReviewsSection(
                    reviews: Review.samples,
                    totalCount: 48,
                    onSeeAllTap: {}
                )

                Divider()
                    .padding(.horizontal)

                // Horizontal Reviews
                HorizontalReviewsRow(
                    reviews: Review.samples,
                    onSeeAllTap: {}
                )

                Divider()
                    .padding(.horizontal)

                // Star Rating
                VStack(spacing: 16) {
                    Text("Star Ratings")
                        .font(.headline)

                    StarRatingView(rating: 9.0)
                    StarRatingView(rating: 7.5)
                    StarRatingView(rating: 5.0)
                    StarRatingView(rating: 3.0)
                }
            }
            .padding(.vertical)
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
