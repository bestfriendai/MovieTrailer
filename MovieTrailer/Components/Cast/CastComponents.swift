//
//  CastComponents.swift
//  MovieTrailer
//
//  Apple 2025 Premium Cast & Crew Components
//  Beautiful cast cards with circular avatars
//

import SwiftUI
import Kingfisher

// MARK: - Cast Card

/// Individual cast member card with avatar and role
struct CastCard: View {

    let cast: CastMember
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.sm) {
                // Avatar
                avatar

                // Name
                Text(cast.name)
                    .font(.labelMedium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                // Character
                Text(cast.character)
                    .font(.captionSmall)
                    .foregroundColor(.textTertiary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(AppTheme.Animation.snappy, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(cast.name) as \(cast.character)")
        .accessibilityHint("Double tap to view profile")
    }

    private var avatar: some View {
        Group {
            if let url = cast.profileURL {
                KFImage(url)
                    .placeholder {
                        avatarPlaceholder
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.glassBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }

    private var avatarPlaceholder: some View {
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
                    .font(.system(size: 32))
                    .foregroundColor(.textTertiary)
            }
    }
}

// MARK: - Cast Row

/// Horizontal scrolling row of cast members
struct CastRow: View {

    let cast: [CastMember]
    let title: String
    let onCastTap: (CastMember) -> Void
    let onSeeAllTap: (() -> Void)?

    init(
        cast: [CastMember],
        title: String = "Top Billed Cast",
        onCastTap: @escaping (CastMember) -> Void,
        onSeeAllTap: (() -> Void)? = nil
    ) {
        self.cast = cast
        self.title = title
        self.onCastTap = onCastTap
        self.onSeeAllTap = onSeeAllTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Section header
            sectionHeader

            // Cast scroll
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Spacing.md) {
                    ForEach(cast) { member in
                        CastCard(cast: member) {
                            Haptics.shared.cardTapped()
                            onCastTap(member)
                        }
                        .slideInStaggered(index: cast.firstIndex(of: member) ?? 0)
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }

    private var sectionHeader: some View {
        HStack {
            Text(title)
                .font(.headline2)
                .foregroundColor(.textPrimary)

            Spacer()

            if let onSeeAllTap = onSeeAllTap, cast.count > 5 {
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
}

// MARK: - Compact Cast Card

/// Smaller cast card for grids or compact layouts
struct CompactCastCard: View {

    let cast: CastMember
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                // Avatar
                Group {
                    if let url = cast.profileURL {
                        KFImage(url)
                            .placeholder {
                                placeholderAvatar
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        placeholderAvatar
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(cast.name)
                        .font(.labelMedium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)

                    Text(cast.character)
                        .font(.captionSmall)
                        .foregroundColor(.textTertiary)
                        .lineLimit(1)
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

    private var placeholderAvatar: some View {
        Circle()
            .fill(Color.surfaceSecondary)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.textTertiary)
            }
    }
}

// MARK: - Crew Card

/// Card for crew members (director, writer, etc.)
struct CrewCard: View {

    let crew: CrewMember
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                // Avatar and name
                HStack(spacing: Spacing.sm) {
                    // Avatar
                    Group {
                        if let url = crew.profileURL {
                            KFImage(url)
                                .placeholder { placeholderAvatar }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            placeholderAvatar
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(crew.name)
                            .font(.labelMedium)
                            .foregroundColor(.textPrimary)

                        Text(crew.job)
                            .font(.captionSmall)
                            .foregroundColor(.accentPrimary)
                    }
                }
            }
            .padding(Spacing.sm)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(CardButtonStyle())
    }

    private var placeholderAvatar: some View {
        Circle()
            .fill(Color.surfaceSecondary)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.textTertiary)
            }
    }
}

// MARK: - Crew Row

/// Row showing key crew members (Director, Writers)
struct CrewRow: View {

    let director: CrewMember?
    let writers: [CrewMember]
    let onCrewTap: (CrewMember) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Crew")
                .font(.headline2)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, Spacing.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    // Director
                    if let director = director {
                        CrewCard(crew: director) {
                            onCrewTap(director)
                        }
                    }

                    // Writers
                    ForEach(writers.prefix(3)) { writer in
                        CrewCard(crew: writer) {
                            onCrewTap(writer)
                        }
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
            }
        }
    }
}

// MARK: - Full Cast List

/// Full cast list view for all cast members
struct FullCastList: View {

    let cast: [CastMember]
    let onCastTap: (CastMember) -> Void

    var body: some View {
        LazyVStack(spacing: Spacing.sm) {
            ForEach(cast) { member in
                CompactCastCard(cast: member) {
                    Haptics.shared.cardTapped()
                    onCastTap(member)
                }
            }
        }
        .padding(.horizontal, Spacing.horizontal)
    }
}

// MARK: - Preview

#if DEBUG
struct CastComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Cast Row
                CastRow(
                    cast: CastMember.samples,
                    onCastTap: { _ in },
                    onSeeAllTap: {}
                )

                // Crew Row
                CrewRow(
                    director: CrewMember.sample,
                    writers: CrewMember.samples.filter { $0.department == "Writing" },
                    onCrewTap: { _ in }
                )

                // Full Cast List
                Text("Full Cast")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                FullCastList(
                    cast: CastMember.samples,
                    onCastTap: { _ in }
                )
            }
            .padding(.vertical)
        }
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}
#endif
