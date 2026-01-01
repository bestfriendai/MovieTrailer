//
//  MovieDetailView.swift
//  MovieTrailer
//
//  Complete Movie Details with Cast, Reviews, Similar & More
//

import SwiftUI
import Kingfisher

struct MovieDetailView: View {

    let movie: Movie
    let isInWatchlist: Bool
    let onWatchlistToggle: () -> Void
    let onClose: () -> Void
    let tmdbService: TMDBService
    var onMovieTap: ((Movie) -> Void)?
    var onPersonTap: ((Int) -> Void)?

    // MARK: - State

    @State private var showingFullOverview = false
    @State private var trailers: [Video] = []
    @State private var selectedTrailer: Video?
    @State private var showingTrailer = false
    @State private var watchProviders: WatchProviderInfo = .empty
    @State private var credits: Credits = .empty
    @State private var similarMovies: [Movie] = []
    @State private var recommendedMovies: [Movie] = []
    @State private var reviews: [Review] = []
    @State private var certification: String?
    @State private var collection: MovieCollection?
    @State private var keywords: [Keyword] = []

    @State private var isLoading = true

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                backdropHeader

                VStack(alignment: .leading, spacing: 28) {
                    titleSection
                    quickInfoSection
                    overviewSection

                    if !trailers.isEmpty {
                        trailerSection
                    }

                    if !watchProviders.isEmpty {
                        WatchProvidersView(
                            providers: watchProviders,
                            movieTitle: movie.title,
                            releaseDate: movie.releaseDate
                        ) { link in
                            if let link = link, let url = URL(string: link) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .padding(.horizontal, -20)
                    }

                    if !credits.cast.isEmpty {
                        castSection
                    }

                    if !credits.directors.isEmpty || !credits.writers.isEmpty {
                        crewSection
                    }

                    genresSection

                    if !keywords.isEmpty {
                        keywordsSection
                    }

                    if collection != nil {
                        collectionSection
                    }

                    if !reviews.isEmpty {
                        reviewsSection
                    }

                    if !similarMovies.isEmpty {
                        similarMoviesSection
                    }

                    if !recommendedMovies.isEmpty {
                        recommendedMoviesSection
                    }

                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .background(Color.black)
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $showingTrailer) {
            if let trailer = selectedTrailer {
                TrailerPlayerView(video: trailer, onClose: {
                    showingTrailer = false
                    selectedTrailer = nil
                })
            }
        }
        .task {
            await loadAllContent()
        }
    }

    // MARK: - Load Content

    private func loadAllContent() async {
        isLoading = true

        async let trailersTask: () = loadTrailers()
        async let providersTask: () = loadWatchProviders()
        async let creditsTask: () = loadCredits()
        async let similarTask: () = loadSimilarMovies()
        async let recommendedTask: () = loadRecommendedMovies()
        async let reviewsTask: () = loadReviews()
        async let detailsTask: () = loadFullDetails()

        _ = await (trailersTask, providersTask, creditsTask, similarTask, recommendedTask, reviewsTask, detailsTask)

        isLoading = false
    }

    private func loadTrailers() async {
        do {
            let response = try await tmdbService.fetchVideos(for: movie.id)
            await MainActor.run { trailers = response.allTrailers }
        } catch {}
    }

    private func loadWatchProviders() async {
        do {
            let providers = try await tmdbService.fetchWatchProviders(for: movie.id)
            await MainActor.run { watchProviders = providers }
        } catch {}
    }

    private func loadCredits() async {
        do {
            let creds = try await tmdbService.fetchCredits(for: movie.id)
            await MainActor.run { credits = creds }
        } catch {}
    }

    private func loadSimilarMovies() async {
        do {
            let response = try await tmdbService.fetchSimilarMovies(for: movie.id)
            await MainActor.run { similarMovies = Array(response.results.prefix(10)) }
        } catch {}
    }

    private func loadRecommendedMovies() async {
        do {
            let response = try await tmdbService.fetchRecommendations(for: movie.id)
            await MainActor.run { recommendedMovies = Array(response.results.prefix(10)) }
        } catch {}
    }

    private func loadReviews() async {
        do {
            let response = try await tmdbService.fetchReviews(for: movie.id)
            await MainActor.run { reviews = Array(response.results.prefix(5)) }
        } catch {}
    }

    private func loadFullDetails() async {
        do {
            let details = try await tmdbService.fetchMovieDetailsFull(id: movie.id)
            await MainActor.run {
                certification = details.certification
                if let col = details.belongsToCollection {
                    // Fetch full collection
                    Task {
                        if let fullCollection = try? await tmdbService.fetchCollection(id: col.id) {
                            collection = fullCollection
                        }
                    }
                }
                if let kw = details.keywords?.keywords {
                    keywords = Array(kw.prefix(8))
                }
            }
        } catch {}
    }

    // MARK: - Backdrop Header

    private var backdropHeader: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                KFImage(movie.backdropURL)
                    .placeholder {
                        Rectangle().fill(Color(white: 0.15))
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: 320)
                    .clipped()

                LinearGradient(
                    colors: [.black.opacity(0.7), .clear, .black.opacity(0.9)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geometry.size.width, height: 320)

                // Close button
                Button(action: { onClose() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                .padding(.top, 60)
                .padding(.leading, 20)
            }
        }
        .frame(height: 320)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text(movie.title)
                    .font(.title.bold())
                    .foregroundColor(.white)

                if let cert = certification, !cert.isEmpty {
                    Text(cert)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .foregroundColor(.white)
                }
            }

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(movie.formattedRating)
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Text("(\(movie.voteCount.formatted()) reviews)")
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
                    withAnimation { showingFullOverview.toggle() }
                } label: {
                    Text(showingFullOverview ? "Show Less" : "Show More")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.blue)
                }
            }
        }
    }

    // MARK: - Trailers

    private var trailerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trailers")
                .font(.title3.bold())
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(trailers) { trailer in
                        Button {
                            selectedTrailer = trailer
                            showingTrailer = true
                        } label: {
                            ZStack {
                                AsyncImage(url: trailer.youtubeThumbnailURL) { image in
                                    image.resizable().aspectRatio(16/9, contentMode: .fill)
                                } placeholder: {
                                    Rectangle().fill(Color(white: 0.2))
                                }
                                .frame(width: 200, height: 112)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                Image(systemName: "play.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                    .shadow(radius: 4)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Cast Section

    private var castSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cast")
                .font(.title3.bold())
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(credits.topBilledCast) { cast in
                        Button {
                            onPersonTap?(cast.id)
                        } label: {
                            VStack(spacing: 8) {
                                KFImage(cast.profileURL)
                                    .placeholder {
                                        Circle()
                                            .fill(Color(white: 0.2))
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .foregroundColor(.gray)
                                            )
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())

                                VStack(spacing: 2) {
                                    Text(cast.name)
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    Text(cast.character)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                .frame(width: 80)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Crew Section

    private var crewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Crew")
                .font(.title3.bold())
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 8) {
                if !credits.directors.isEmpty {
                    HStack {
                        Text("Director")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: 80, alignment: .leading)
                        Text(credits.directors.map(\.name).joined(separator: ", "))
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white)
                    }
                }

                if !credits.writers.isEmpty {
                    HStack {
                        Text("Writers")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: 80, alignment: .leading)
                        Text(credits.writers.prefix(3).map(\.name).joined(separator: ", "))
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .background(Color(white: 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    ForEach(Genre.names(for: movie.genreIds), id: \.self) { name in
                        Text(name)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white.opacity(0.1)))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    // MARK: - Keywords

    private var keywordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keywords")
                .font(.title3.bold())
                .foregroundColor(.white)

            DetailFlowLayout(spacing: 8) {
                ForEach(keywords) { keyword in
                    Text(keyword.name)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Capsule())
                        .foregroundColor(.blue)
                }
            }
        }
    }

    // MARK: - Collection

    private var collectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let col = collection {
                Text("Part of \(col.name)")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(col.parts.sorted { ($0.releaseDate ?? "") < ($1.releaseDate ?? "") }) { part in
                            Button {
                                onMovieTap?(part.toMovie())
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    KFImage(part.posterURL)
                                        .placeholder {
                                            Rectangle().fill(Color(white: 0.15))
                                        }
                                        .resizable()
                                        .aspectRatio(2/3, contentMode: .fill)
                                        .frame(width: 100, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(part.id == movie.id ? Color.blue : Color.clear, lineWidth: 2)
                                        )

                                    Text(part.title)
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .lineLimit(2)
                                        .frame(width: 100, alignment: .leading)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Reviews

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews")
                .font(.title3.bold())
                .foregroundColor(.white)

            VStack(spacing: 12) {
                ForEach(reviews.prefix(3)) { review in
                    DetailReviewCard(review: review)
                }
            }
        }
    }

    // MARK: - Similar Movies

    private var similarMoviesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Similar Movies")
                .font(.title3.bold())
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(similarMovies) { similarMovie in
                        DetailMoviePosterCard(movie: similarMovie) {
                            onMovieTap?(similarMovie)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recommended Movies

    private var recommendedMoviesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended")
                .font(.title3.bold())
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recommendedMovies) { recMovie in
                        DetailMoviePosterCard(movie: recMovie) {
                            onMovieTap?(recMovie)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        Button(action: { onWatchlistToggle() }) {
            HStack(spacing: 12) {
                Image(systemName: isInWatchlist ? "checkmark" : "plus")
                    .font(.system(size: 16, weight: .bold))

                Text(isInWatchlist ? "In Watchlist" : "Add to Watchlist")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isInWatchlist ? Color.white.opacity(0.15) : Color.white)
            )
            .foregroundColor(isInWatchlist ? .white : .black)
        }
        .padding(.top, 8)
    }
}

// MARK: - Detail Movie Poster Card

struct DetailMoviePosterCard: View {
    let movie: Movie
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                KFImage(movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color(white: 0.15))
                            .overlay(Image(systemName: "film").foregroundColor(.gray))
                    }
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(movie.title)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text(movie.formattedRating)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 120, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Detail Review Card

struct DetailReviewCard: View {
    let review: Review
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                // Avatar
                if let url = review.avatarURL {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(review.authorDetails?.initials ?? "?")
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.author)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        if let rating = review.rating {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        if let time = review.timeAgo {
                            Text("• \(time)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }

                Spacer()
            }

            Text(expanded ? review.content : review.truncatedContent)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(expanded ? nil : 4)

            if review.isLongReview {
                Button {
                    withAnimation { expanded.toggle() }
                } label: {
                    Text(expanded ? "Show Less" : "Read More")
                        .font(.caption.bold())
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(white: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Detail Flow Layout for Keywords

struct DetailFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    MovieDetailView(
        movie: .sample,
        isInWatchlist: false,
        onWatchlistToggle: {},
        onClose: {},
        tmdbService: .shared
    )
}
