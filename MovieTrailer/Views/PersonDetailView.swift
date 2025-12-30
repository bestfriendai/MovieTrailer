//
//  PersonDetailView.swift
//  MovieTrailer
//
//  Apple 2025 Premium Person Detail Screen
//  Actor/Crew member profile with filmography
//

import SwiftUI
import Kingfisher

struct PersonDetailView: View {

    @StateObject private var viewModel: PersonDetailViewModel
    @Environment(\.dismiss) private var dismiss

    let onMovieTap: (Movie) -> Void

    @State private var showFullBio = false

    init(personId: Int, onMovieTap: @escaping (Movie) -> Void) {
        _viewModel = StateObject(wrappedValue: PersonDetailViewModel(personId: personId))
        self.onMovieTap = onMovieTap
    }

    var body: some View {
        ZStack {
            // Background
            Color.appBackground.ignoresSafeArea()

            if viewModel.isLoading && !viewModel.hasContent {
                loadingView
            } else if let error = viewModel.error, !viewModel.hasContent {
                errorView(error: error)
            } else {
                contentView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewModel.displayName)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
        }
        .task {
            await viewModel.loadPersonDetails()
        }
    }

    // MARK: - Content View

    private var contentView: some View {
        ScrollView {
            VStack(spacing: Spacing.section) {
                // Header
                headerSection

                // Bio
                if let bio = viewModel.biography {
                    biographySection(bio: bio)
                }

                // Known For
                if !viewModel.knownForMovies.isEmpty {
                    knownForSection
                }

                // Filmography
                if !viewModel.filmography.isEmpty {
                    filmographySection
                }

                // Social Links
                if !viewModel.socialLinks.isEmpty {
                    socialLinksSection
                }

                Spacer(minLength: Spacing.tabBarSafeArea)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: Spacing.lg) {
            // Profile Image
            Group {
                if let url = viewModel.profileURL {
                    KFImage(url)
                        .placeholder {
                            profilePlaceholder
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    profilePlaceholder
                }
            }
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.3), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
            .scaleIn(delay: 0.1)

            // Name
            Text(viewModel.displayName)
                .font(.displaySmall)
                .foregroundColor(.textPrimary)
                .fadeIn(delay: 0.15)

            // Details
            VStack(spacing: Spacing.xs) {
                // Department
                if let department = viewModel.department {
                    Text(department)
                        .font(.labelLarge)
                        .foregroundColor(.accentPrimary)
                }

                // Birth info
                if let birthInfo = viewModel.birthInfo {
                    Text(birthInfo)
                        .font(.labelMedium)
                        .foregroundColor(.textSecondary)
                }

                // Place of birth
                if let place = viewModel.placeOfBirth {
                    Text(place)
                        .font(.labelSmall)
                        .foregroundColor(.textTertiary)
                }

                // Movie count
                if viewModel.movieCount > 0 {
                    Text("\(viewModel.movieCount) movies")
                        .font(.labelMedium)
                        .foregroundColor(.textTertiary)
                        .padding(.top, Spacing.xs)
                }
            }
            .fadeIn(delay: 0.2)
        }
        .padding(.top, Spacing.lg)
    }

    private var profilePlaceholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color.surfaceSecondary, Color.surfaceTertiary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.textTertiary)
            }
    }

    // MARK: - Biography Section

    private func biographySection(bio: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Biography")
                .font(.headline2)
                .foregroundColor(.textPrimary)

            Text(bio)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .lineLimit(showFullBio ? nil : 6)

            if bio.count > 300 {
                Button {
                    withAnimation(AppTheme.Animation.smooth) {
                        showFullBio.toggle()
                    }
                    Haptics.shared.selectionChanged()
                } label: {
                    Text(showFullBio ? "Show Less" : "Read More")
                        .font(.labelMedium)
                        .foregroundColor(.accentPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.horizontal)
        .slideIn(delay: 0.25, from: .bottom)
    }

    // MARK: - Known For Section

    private var knownForSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Known For")
                .font(.headline2)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Spacing.md) {
                    ForEach(viewModel.knownForMovies) { credit in
                        knownForCard(credit: credit)
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
        .slideIn(delay: 0.3, from: .bottom)
    }

    private func knownForCard(credit: PersonCastCredit) -> some View {
        Button {
            Haptics.shared.cardTapped()
            onMovieTap(credit.toMovie())
        } label: {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                // Poster
                KFImage(credit.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color.surfaceSecondary)
                            .overlay {
                                Image(systemName: "film")
                                    .foregroundColor(.textTertiary)
                            }
                    }
                    .resizable()
                    .aspectRatio(AspectRatio.poster, contentMode: .fill)
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
                    .mediumShadow()

                // Title
                Text(credit.title)
                    .font(.labelMedium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)

                // Character
                if let character = credit.character {
                    Text(character)
                        .font(.captionSmall)
                        .foregroundColor(.textTertiary)
                        .lineLimit(1)
                }
            }
            .frame(width: 120)
        }
        .buttonStyle(CardButtonStyle())
    }

    // MARK: - Filmography Section

    private var filmographySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Filmography")
                    .font(.headline2)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(viewModel.filmography.count) movies")
                    .font(.labelSmall)
                    .foregroundColor(.textTertiary)
            }
            .padding(.horizontal, Spacing.horizontal)

            // Recent filmography (first 10)
            VStack(spacing: Spacing.sm) {
                ForEach(viewModel.filmography.prefix(10)) { credit in
                    filmographyRow(credit: credit)
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
        .slideIn(delay: 0.35, from: .bottom)
    }

    private func filmographyRow(credit: PersonCastCredit) -> some View {
        Button {
            Haptics.shared.cardTapped()
            onMovieTap(credit.toMovie())
        } label: {
            HStack(spacing: Spacing.sm) {
                // Poster
                KFImage(credit.posterURL)
                    .placeholder {
                        Rectangle().fill(Color.surfaceSecondary)
                    }
                    .resizable()
                    .aspectRatio(AspectRatio.poster, contentMode: .fill)
                    .frame(width: 50, height: 75)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small, style: .continuous))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(credit.title)
                        .font(.labelMedium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    if let character = credit.character {
                        Text("as \(character)")
                            .font(.captionSmall)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }

                    HStack(spacing: Spacing.xs) {
                        if let year = credit.releaseYear {
                            Text(year)
                                .font(.captionSmall)
                                .foregroundColor(.textTertiary)
                        }

                        if credit.voteAverage > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.ratingStar)
                                Text(credit.formattedRating)
                                    .font(.captionSmall)
                            }
                            .foregroundColor(.textTertiary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textTertiary)
            }
            .padding(Spacing.sm)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
        }
        .buttonStyle(CardButtonStyle())
    }

    // MARK: - Social Links Section

    private var socialLinksSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("External Links")
                .font(.headline2)
                .foregroundColor(.textPrimary)

            HStack(spacing: Spacing.md) {
                ForEach(viewModel.socialLinks) { link in
                    Link(destination: link.url) {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: link.type.icon)
                                .font(.system(size: 20))
                                .foregroundColor(.textPrimary)
                                .frame(width: 50, height: 50)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())

                            Text(link.type.name)
                                .font(.captionSmall)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.horizontal)
        .slideIn(delay: 0.4, from: .bottom)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.accentPrimary)

            Text("Loading...")
                .font(.labelMedium)
                .foregroundColor(.textSecondary)
        }
    }

    // MARK: - Error View

    private func errorView(error: NetworkError) -> some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)

            Text("Something went wrong")
                .font(.headline2)
                .foregroundColor(.textPrimary)

            Text(error.localizedDescription)
                .font(.bodySmall)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await viewModel.retry()
                }
            } label: {
                Text("Try Again")
                    .font(.buttonMedium)
                    .foregroundColor(.white)
                    .padding(.horizontal, Spacing.xl)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.accentPrimary)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PersonDetailView(personId: 287) { _ in }
        }
        .preferredColorScheme(.dark)
    }
}
#endif
