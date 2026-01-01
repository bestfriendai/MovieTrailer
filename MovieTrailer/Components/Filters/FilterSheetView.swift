//
//  FilterSheetView.swift
//  MovieTrailer
//
//  Apple 2025 Premium Filter Sheet
//  Beautiful, comprehensive filtering UI
//

import SwiftUI

// MARK: - Filter Sheet View

struct FilterSheetView: View {

    @ObservedObject var viewModel: FilterViewModel
    @Binding var isPresented: Bool
    let onApply: () -> Void

    @State private var tempFilter: FilterState
    @State private var showPresetPicker = false

    init(viewModel: FilterViewModel, isPresented: Binding<Bool>, onApply: @escaping () -> Void) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.onApply = onApply
        self._tempFilter = State(initialValue: viewModel.filterState)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.section) {
                    // Presets
                    presetsSection

                    // Content type
                    contentTypeSection

                    // Streaming services
                    streamingServicesSection

                    // Genres
                    genresSection

                    // Rating
                    ratingSection

                    // Quality filter (vote count)
                    qualitySection

                    // Release year
                    releaseYearSection

                    // Runtime
                    runtimeSection

                    // Sort
                    sortSection

                    // Apply button
                    applyButton
                        .padding(.bottom, Spacing.xxxl)
                }
                .padding(.horizontal, Spacing.horizontal)
                .padding(.top, Spacing.md)
            }
            .background(Color.appBackground)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        Haptics.shared.buttonTapped()
                        tempFilter = FilterState()
                    }
                    .foregroundColor(.accentBlue)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.textTertiary)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(AppTheme.CornerRadius.sheet)
    }

    // MARK: - Presets Section

    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Presets")
                .font(.headline3)
                .foregroundColor(.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(viewModel.presets.prefix(6)) { preset in
                        presetButton(preset)
                    }
                }
            }
        }
    }

    private func presetButton(_ preset: FilterPreset) -> some View {
        Button {
            Haptics.shared.buttonTapped()
            tempFilter = preset.filter
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: preset.icon)
                    .font(.system(size: 14))
                Text(preset.name)
                    .font(.labelMedium)
            }
            .foregroundColor(tempFilter == preset.filter ? .textInverted : .textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(tempFilter == preset.filter ? Color.accentBlue : Color.surfaceElevated)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Content Type Section

    private var contentTypeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Content Type")

            HStack(spacing: Spacing.sm) {
                ForEach(ContentType.allCases) { type in
                    contentTypeButton(type)
                }
            }
        }
    }

    private func contentTypeButton(_ type: ContentType) -> some View {
        Button {
            Haptics.shared.selectionChanged()
            tempFilter.contentType = type
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: type.icon)
                Text(type.displayName)
            }
            .font(.labelMedium)
            .foregroundColor(tempFilter.contentType == type ? .textInverted : .textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.sm)
            .background(tempFilter.contentType == type ? Color.accentBlue : Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Streaming Services Section

    private var streamingServicesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Where to Watch")

            // Service grid
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: Spacing.sm) {
                ForEach(Array(FilterStreamingProvider.allCases.prefix(8)), id: \.id) { service in
                    streamingServiceButton(service)
                }
            }

            // Additional options
            VStack(spacing: Spacing.sm) {
                Toggle(isOn: $tempFilter.includeTheaters) {
                    HStack {
                        Image(systemName: "popcorn.fill")
                        Text("In Theaters")
                    }
                    .font(.labelMedium)
                }
                .tint(.accentBlue)

                Toggle(isOn: $tempFilter.includeRentBuy) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("Rent/Buy")
                    }
                    .font(.labelMedium)
                }
                .tint(.accentBlue)
            }
            .padding(Spacing.md)
            .background(Color.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        }
    }

    private func streamingServiceButton(_ service: FilterStreamingProvider) -> some View {
        let isSelected = tempFilter.selectedServices.contains(service)

        return Button {
            Haptics.shared.selectionChanged()
            if isSelected {
                tempFilter.selectedServices.remove(service)
            } else {
                tempFilter.selectedServices.insert(service)
            }
        } label: {
            VStack(spacing: Spacing.xs) {
                Circle()
                    .fill(isSelected ? service.color : Color.surfaceSecondary)
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text(service.shortName.prefix(1))
                            .font(.labelLarge)
                            .foregroundColor(isSelected ? .white : .textSecondary)
                    }
                    .overlay {
                        if isSelected {
                            Circle()
                                .stroke(service.color, lineWidth: 2)
                                .frame(width: 50, height: 50)
                        }
                    }

                Text(service.shortName)
                    .font(.captionSmall)
                    .foregroundColor(isSelected ? .textPrimary : .textTertiary)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Genres Section

    private var genresSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Genres")

            Text("Include")
                .font(.labelMedium)
                .foregroundColor(.textSecondary)

            FlowLayout(spacing: Spacing.xs) {
                ForEach(FilterGenre.allCases) { genre in
                    genreChip(genre, isExcluded: false)
                }
            }

            Text("Exclude")
                .font(.labelMedium)
                .foregroundColor(.textSecondary)
                .padding(.top, Spacing.sm)

            FlowLayout(spacing: Spacing.xs) {
                ForEach(FilterGenre.allCases) { genre in
                    genreChip(genre, isExcluded: true)
                }
            }
        }
    }

    private func genreChip(_ genre: FilterGenre, isExcluded: Bool) -> some View {
        let isSelected = isExcluded ?
            tempFilter.excludedGenres.contains(genre) :
            tempFilter.includedGenres.contains(genre)

        return Button {
            Haptics.shared.selectionChanged()
            if isExcluded {
                if isSelected {
                    tempFilter.excludedGenres.remove(genre)
                } else {
                    tempFilter.excludedGenres.insert(genre)
                    tempFilter.includedGenres.remove(genre)
                }
            } else {
                if isSelected {
                    tempFilter.includedGenres.remove(genre)
                } else {
                    tempFilter.includedGenres.insert(genre)
                    tempFilter.excludedGenres.remove(genre)
                }
            }
        } label: {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: genre.icon)
                    .font(.system(size: 12))
                Text(genre.displayName)
                    .font(.pillSmall)
            }
            .foregroundColor(isSelected ? .white : .textSecondary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(
                isSelected ?
                    (isExcluded ? Color.accentRed : genre.color) :
                    Color.surfaceElevated
            )
            .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Rating Section

    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Minimum Rating")

            HStack(spacing: Spacing.md) {
                // Rating display
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.ratingStar)
                    Text(String(format: "%.1f+", tempFilter.minimumRating))
                        .font(.headline2)
                        .foregroundColor(.textPrimary)
                }
                .frame(width: 80)

                // Slider
                Slider(value: $tempFilter.minimumRating, in: 0...9, step: 0.5)
                    .tint(.accentBlue)
            }

            // Quick buttons
            HStack(spacing: Spacing.xs) {
                ForEach([0.0, 5.0, 6.0, 7.0, 8.0], id: \.self) { rating in
                    Button {
                        Haptics.shared.selectionChanged()
                        tempFilter.minimumRating = rating
                    } label: {
                        Text(rating == 0 ? "Any" : "\(Int(rating))+")
                            .font(.labelSmall)
                            .foregroundColor(tempFilter.minimumRating == rating ? .textInverted : .textSecondary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(tempFilter.minimumRating == rating ? Color.accentBlue : Color.surfaceElevated)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    // MARK: - Quality Section (Vote Count)

    private var qualitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Review Volume")

            Text("Filter by how many people have reviewed")
                .font(.caption)
                .foregroundColor(.textTertiary)

            HStack(spacing: Spacing.xs) {
                ForEach([
                    ("Any", 0),
                    ("50+", 50),
                    ("100+", 100),
                    ("500+", 500),
                    ("1000+", 1000)
                ], id: \.1) { label, count in
                    Button {
                        Haptics.shared.selectionChanged()
                        tempFilter.minimumVotes = count
                    } label: {
                        Text(label)
                            .font(.labelSmall)
                            .foregroundColor(tempFilter.minimumVotes == count ? .textInverted : .textSecondary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(tempFilter.minimumVotes == count ? Color.accentBlue : Color.surfaceElevated)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }

            // Explanation
            HStack(spacing: Spacing.xs) {
                Image(systemName: "info.circle")
                    .font(.caption)
                Text("Higher = more well-known films. Lower = hidden gems.")
                    .font(.caption)
            }
            .foregroundColor(.textTertiary)
            .padding(.top, Spacing.xs)
        }
    }

    // MARK: - Release Year Section

    private var releaseYearSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Release Year")

            // Range display
            HStack {
                Text("\(tempFilter.releaseYearStart)")
                    .font(.headline3)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("to")
                    .font(.labelMedium)
                    .foregroundColor(.textTertiary)

                Spacer()

                Text("\(tempFilter.releaseYearEnd)")
                    .font(.headline3)
                    .foregroundColor(.textPrimary)
            }

            // Quick buttons
            HStack(spacing: Spacing.xs) {
                ForEach([
                    ("This Year", Calendar.current.component(.year, from: Date()), Calendar.current.component(.year, from: Date())),
                    ("Last 5 Years", Calendar.current.component(.year, from: Date()) - 5, Calendar.current.component(.year, from: Date())),
                    ("2010s", 2010, 2019),
                    ("Classics", 1900, 1999)
                ], id: \.0) { label, start, end in
                    Button {
                        Haptics.shared.selectionChanged()
                        tempFilter.releaseYearStart = start
                        tempFilter.releaseYearEnd = end
                    } label: {
                        Text(label)
                            .font(.labelSmall)
                            .foregroundColor(
                                tempFilter.releaseYearStart == start && tempFilter.releaseYearEnd == end ?
                                    .textInverted : .textSecondary
                            )
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(
                                tempFilter.releaseYearStart == start && tempFilter.releaseYearEnd == end ?
                                    Color.accentBlue : Color.surfaceElevated
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    // MARK: - Runtime Section

    private var runtimeSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Runtime")

            HStack(spacing: Spacing.xs) {
                ForEach(RuntimeFilter.allCases) { filter in
                    Button {
                        Haptics.shared.selectionChanged()
                        tempFilter.runtimeFilter = filter
                    } label: {
                        Text(filter.displayName)
                            .font(.labelSmall)
                            .foregroundColor(tempFilter.runtimeFilter == filter ? .textInverted : .textSecondary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xs)
                            .background(tempFilter.runtimeFilter == filter ? Color.accentBlue : Color.surfaceElevated)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    // MARK: - Sort Section

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader("Sort By")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                ForEach(SortOption.allCases) { option in
                    Button {
                        Haptics.shared.selectionChanged()
                        tempFilter.sortBy = option
                    } label: {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: option.icon)
                            Text(option.displayName)
                        }
                        .font(.labelMedium)
                        .foregroundColor(tempFilter.sortBy == option ? .textInverted : .textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(tempFilter.sortBy == option ? Color.accentBlue : Color.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
        }
    }

    // MARK: - Apply Button

    private var applyButton: some View {
        Button {
            Haptics.shared.success()
            viewModel.filterState = tempFilter
            viewModel.save()
            onApply()
            isPresented = false
        } label: {
            Text("Apply Filters")
                .font(.buttonLarge)
                .foregroundColor(.textInverted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.md)
                .background(Color.accentBlue)
                .clipShape(Capsule())
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.top, Spacing.lg)
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline3)
            .foregroundColor(.textPrimary)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
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

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width && x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                maxHeight = max(maxHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: width, height: y + maxHeight)
        }
    }
}

// MARK: - Quick Filter Pills

struct FilterPillsView: View {

    @ObservedObject var viewModel: FilterViewModel
    let onShowFullFilters: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.xs) {
                // Show filters button
                Button {
                    Haptics.shared.buttonTapped()
                    onShowFullFilters()
                } label: {
                    HStack(spacing: Spacing.xxs) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Filters")
                        if viewModel.filterState.activeFilterCount > 0 {
                            Text("(\(viewModel.filterState.activeFilterCount))")
                                .foregroundColor(.accentBlue)
                        }
                    }
                    .font(.labelMedium)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.surfaceElevated)
                    .clipShape(Capsule())
                }

                // Active filters as removable pills
                if viewModel.filterState.contentType != .both {
                    removablePill(
                        label: viewModel.filterState.contentType.displayName,
                        onRemove: { viewModel.filterState.contentType = .both }
                    )
                }

                ForEach(Array(viewModel.filterState.selectedServices), id: \.id) { service in
                    removablePill(
                        label: service.shortName,
                        color: service.color,
                        onRemove: { viewModel.filterState.selectedServices.remove(service) }
                    )
                }

                ForEach(Array(viewModel.filterState.includedGenres), id: \.id) { genre in
                    removablePill(
                        label: genre.displayName,
                        color: genre.color,
                        onRemove: { viewModel.filterState.includedGenres.remove(genre) }
                    )
                }

                if viewModel.filterState.minimumRating > 0 {
                    removablePill(
                        label: "\(Int(viewModel.filterState.minimumRating))+",
                        icon: "star.fill",
                        onRemove: { viewModel.filterState.minimumRating = 0 }
                    )
                }

                if viewModel.filterState.runtimeFilter != .any {
                    removablePill(
                        label: viewModel.filterState.runtimeFilter.displayName,
                        icon: "clock",
                        onRemove: { viewModel.filterState.runtimeFilter = .any }
                    )
                }
            }
            .padding(.horizontal, Spacing.horizontal)
        }
    }

    private func removablePill(
        label: String,
        icon: String? = nil,
        color: Color = .accentBlue,
        onRemove: @escaping () -> Void
    ) -> some View {
        HStack(spacing: Spacing.xxs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }
            Text(label)
                .font(.labelSmall)

            Button {
                Haptics.shared.light()
                onRemove()
                viewModel.save()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(color)
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#if DEBUG
struct FilterSheetView_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetView(
            viewModel: FilterViewModel(),
            isPresented: .constant(true),
            onApply: {}
        )
        .preferredColorScheme(.dark)
    }
}
#endif
