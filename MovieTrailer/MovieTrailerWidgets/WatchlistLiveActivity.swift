//
//  WatchlistLiveActivity.swift
//  MovieTrailerWidgets
//
//  Created by Daniel Wijono on 10/12/2025.
//  Fixed: Proper integration with WatchlistActivityAttributes
//

import ActivityKit
import WidgetKit
import SwiftUI

/// Live Activity widget for watchlist notifications
/// Shows movie info in Dynamic Island and Lock Screen
struct WatchlistLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WatchlistActivityAttributes.self) { context in
            // Lock screen/banner UI
            LockScreenView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.8))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island UI
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(attributes: context.attributes)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(attributes: context.attributes)
                }
                DynamicIslandExpandedRegion(.center) {
                    ExpandedCenterView(attributes: context.attributes)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                // Compact leading (pill left)
                CompactLeadingView()
            } compactTrailing: {
                // Compact trailing (pill right)
                CompactTrailingView(state: context.state)
            } minimal: {
                // Minimal view (single icon)
                MinimalView()
            }
            .widgetURL(URL(string: "movietrailer://watchlist"))
            .keylineTint(Color.purple)
        }
    }
}

// MARK: - Lock Screen View

private struct LockScreenView: View {
    let context: ActivityViewContext<WatchlistActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // Movie poster placeholder with gradient
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 75)
                .overlay(
                    Image(systemName: "film")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                )

            VStack(alignment: .leading, spacing: 6) {
                // Movie title
                Text(context.attributes.movieTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)

                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)

                    Text(context.attributes.formattedRating)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }

                // Status message
                Text(context.state.message)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))

                // Time elapsed
                Text(context.state.formattedTimeElapsed)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Progress indicator
            VStack(spacing: 4) {
                CircularProgressView(progress: context.state.progressToTonight)
                    .frame(width: 44, height: 44)

                Text(context.state.timeUntilTonight)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(16)
    }
}

// MARK: - Circular Progress View

private struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)

            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Icon
            Image(systemName: "moon.stars.fill")
                .font(.caption)
                .foregroundColor(.purple)
        }
    }
}

// MARK: - Dynamic Island Expanded Views

private struct ExpandedLeadingView: View {
    let attributes: WatchlistActivityAttributes

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 40, height: 60)
            .overlay(
                Image(systemName: "film")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
            )
    }
}

private struct ExpandedTrailingView: View {
    let attributes: WatchlistActivityAttributes

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundColor(.yellow)
                Text(attributes.formattedRating)
                    .font(.caption)
                    .fontWeight(.bold)
            }

            Text("Rating")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

private struct ExpandedCenterView: View {
    let attributes: WatchlistActivityAttributes

    var body: some View {
        Text(attributes.movieTitle)
            .font(.headline)
            .fontWeight(.bold)
            .lineLimit(1)
    }
}

private struct ExpandedBottomView: View {
    let context: ActivityViewContext<WatchlistActivityAttributes>

    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)

                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * context.state.progressToTonight, height: 8)
                        .animation(.easeInOut(duration: 0.5), value: context.state.progressToTonight)
                }
            }
            .frame(height: 8)

            // Bottom info
            HStack {
                Text(context.state.message)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "moon.stars")
                        .font(.caption2)
                    Text(context.state.timeUntilTonight)
                        .font(.caption)
                }
                .foregroundColor(.purple)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Dynamic Island Compact Views

private struct CompactLeadingView: View {
    var body: some View {
        Image(systemName: "film.fill")
            .font(.caption)
            .foregroundColor(.purple)
    }
}

private struct CompactTrailingView: View {
    let state: WatchlistActivityAttributes.ContentState

    var body: some View {
        Text(state.timeUntilTonight)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.purple)
    }
}

private struct MinimalView: View {
    var body: some View {
        Image(systemName: "film.fill")
            .font(.caption2)
            .foregroundColor(.purple)
    }
}

// MARK: - Preview
// Live Activity previews are best viewed in Xcode canvas with simulator
