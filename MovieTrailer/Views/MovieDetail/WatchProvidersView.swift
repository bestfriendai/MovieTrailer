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
    let movieTitle: String?
    let releaseDate: String?
    let onProviderTap: ((String?) -> Void)?

    init(
        providers: WatchProviderInfo,
        movieTitle: String? = nil,
        releaseDate: String? = nil,
        onProviderTap: ((String?) -> Void)? = nil
    ) {
        self.providers = providers
        self.movieTitle = movieTitle
        self.releaseDate = releaseDate
        self.onProviderTap = onProviderTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 8) {
                Image(systemName: "play.tv.fill")
                    .font(.title2)
                    .foregroundColor(.white)

                Text("Where to Watch")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                Spacer()

                if providers.link != nil {
                    Button {
                        onProviderTap?(providers.link)
                    } label: {
                        Text("See All")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }

            if isInTheaters {
                theaterSection
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
                            color: .cyan,
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

    private var theaterSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "popcorn.fill")
                    .font(.caption)
                    .foregroundColor(.accentOrange)

                Text("In Theaters")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }

            if let url = fandangoURL {
                if let onProviderTap = onProviderTap {
                    Button {
                        onProviderTap(url.absoluteString)
                    } label: {
                        ticketButtonLabel
                    }
                } else {
                    Link(destination: url) {
                        ticketButtonLabel
                    }
                }
            } else {
                Text("Check local listings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var ticketButtonLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 14, weight: .semibold))

            Text("Get Tickets on Fandango")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundColor(.textInverted)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.accentPrimary)
        .clipShape(Capsule())
    }

    private var fandangoURL: URL? {
        guard let title = movieTitle,
              let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://www.fandango.com/search?q=\(encoded)")
    }

    private var isInTheaters: Bool {
        guard let releaseDate else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: releaseDate) else { return false }

        let now = Date()
        let pastWindow = Calendar.current.date(byAdding: .day, value: -90, to: now) ?? now
        let futureWindow = Calendar.current.date(byAdding: .day, value: 30, to: now) ?? now
        return date >= pastWindow && date <= futureWindow
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
