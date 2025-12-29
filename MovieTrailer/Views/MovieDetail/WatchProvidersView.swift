//
//  WatchProvidersView.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//

import SwiftUI
import Kingfisher

/// View displaying streaming platforms where a movie is available
struct WatchProvidersView: View {

    let providers: WatchProviderInfo
    let onProviderTap: ((String?) -> Void)?

    init(providers: WatchProviderInfo, onProviderTap: ((String?) -> Void)? = nil) {
        self.providers = providers
        self.onProviderTap = onProviderTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 8) {
                Image(systemName: "play.tv.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Where to Watch")
                    .font(.title2.bold())

                Spacer()

                if providers.link != nil {
                    Button {
                        onProviderTap?(providers.link)
                    } label: {
                        Text("See All")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }

            if providers.isEmpty {
                Text("Not available for streaming in your region")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    // Streaming section
                    if providers.hasStreaming {
                        ProviderSection(
                            title: "Stream",
                            icon: "play.circle.fill",
                            color: .green,
                            providers: providers.streaming
                        )
                    }

                    // Rent section
                    if providers.hasRent {
                        ProviderSection(
                            title: "Rent",
                            icon: "dollarsign.circle.fill",
                            color: .orange,
                            providers: providers.rent
                        )
                    }

                    // Buy section
                    if providers.hasBuy {
                        ProviderSection(
                            title: "Buy",
                            icon: "bag.fill",
                            color: .blue,
                            providers: providers.buy
                        )
                    }

                    // Free section
                    if providers.hasFree {
                        ProviderSection(
                            title: "Free",
                            icon: "gift.fill",
                            color: .purple,
                            providers: providers.free
                        )
                    }
                }
            }

            // Attribution
            Text("Data from JustWatch")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

// MARK: - Provider Section

struct ProviderSection: View {

    let title: String
    let icon: String
    let color: Color
    let providers: [WatchProvider]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Section label
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }

            // Provider logos
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(providers) { provider in
                        ProviderLogo(provider: provider)
                    }
                }
            }
        }
    }
}

// MARK: - Provider Logo

struct ProviderLogo: View {

    let provider: WatchProvider

    var body: some View {
        VStack(spacing: 6) {
            if let url = provider.logoURL {
                KFImage(url)
                    .placeholder {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Text(String(provider.providerName.prefix(2)))
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
            }

            Text(provider.providerName)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(width: 60)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(provider.providerName)")
    }
}

// MARK: - Preview

#if DEBUG
struct WatchProvidersView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            WatchProvidersView(providers: .sample)
        }
    }
}
#endif
