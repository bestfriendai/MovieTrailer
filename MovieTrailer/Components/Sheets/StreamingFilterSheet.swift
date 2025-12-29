//
//  StreamingFilterSheet.swift
//  MovieTrailer
//
//  Created by Claude Code on 28/12/2025.
//  Streaming service selection sheet
//

import SwiftUI

struct StreamingFilterSheet: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var preferences: UserPreferences
    @State private var searchText = ""

    private var filteredServices: [StreamingService] {
        if searchText.isEmpty {
            return StreamingService.allCases
        }
        return StreamingService.allCases.filter {
            $0.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var subscriptionServices: [StreamingService] {
        filteredServices.filter { !$0.isFree }
    }

    private var freeServices: [StreamingService] {
        filteredServices.filter { $0.isFree }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Search bar
                    searchBar

                    // Selected services summary
                    if !preferences.selectedStreamingServices.isEmpty {
                        selectedServicesSummary
                    }

                    // Subscription services section
                    if !subscriptionServices.isEmpty {
                        serviceSection(
                            title: "Subscription Services",
                            services: subscriptionServices
                        )
                    }

                    // Free services section
                    if !freeServices.isEmpty {
                        serviceSection(
                            title: "Free with Ads",
                            services: freeServices
                        )
                    }
                }
                .padding(.horizontal, Spacing.horizontal)
                .padding(.bottom, Spacing.xxxl)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Your Services")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear All") {
                        Haptics.shared.lightImpact()
                        preferences.clearStreamingServices()
                    }
                    .foregroundColor(.red)
                    .opacity(preferences.selectedStreamingServices.isEmpty ? 0.5 : 1)
                    .disabled(preferences.selectedStreamingServices.isEmpty)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        Haptics.shared.selectionChanged()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search services...", text: $searchText)
                .textFieldStyle(.plain)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(Spacing.sm)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }

    // MARK: - Selected Services Summary

    private var selectedServicesSummary: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Selected")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(preferences.selectedStreamingServices.count) services")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(Array(preferences.selectedStreamingServices).sorted(by: { $0.rawValue < $1.rawValue })) { service in
                        StreamingBadge(
                            service: service,
                            style: .standard,
                            isSelected: true
                        ) {
                            preferences.toggleStreamingService(service)
                        }
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
    }

    // MARK: - Service Section

    private func serviceSection(title: String, services: [StreamingService]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.leading, Spacing.xs)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: Spacing.md
            ) {
                ForEach(services) { service in
                    StreamingBadge(
                        service: service,
                        style: .large,
                        isSelected: preferences.isServiceSelected(service)
                    ) {
                        preferences.toggleStreamingService(service)
                    }
                }
            }
        }
    }
}

// MARK: - Streaming Filter Button

struct StreamingFilterButton: View {

    @ObservedObject var preferences: UserPreferences
    @State private var showingSheet = false

    var body: some View {
        Button(action: {
            Haptics.shared.lightImpact()
            showingSheet = true
        }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "slider.horizontal.3")
                    .font(.body.weight(.medium))

                if preferences.selectedStreamingServices.isEmpty {
                    Text("Services")
                        .font(.subheadline.weight(.medium))
                } else {
                    Text("\(preferences.selectedStreamingServices.count)")
                        .font(.subheadline.weight(.bold))
                }
            }
            .foregroundColor(preferences.selectedStreamingServices.isEmpty ? .primary : .white)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(preferences.selectedStreamingServices.isEmpty ? Color(.systemGray6) : Color.accentStart)
            )
            .overlay(
                Capsule()
                    .stroke(preferences.selectedStreamingServices.isEmpty ? Color(.systemGray4) : Color.clear, lineWidth: 0.5)
            )
        }
        .buttonStyle(PillButtonStyle())
        .sheet(isPresented: $showingSheet) {
            StreamingFilterSheet(preferences: preferences)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct StreamingFilterSheet_Previews: PreviewProvider {
    static var previews: some View {
        StreamingFilterSheet(preferences: UserPreferences.shared)
    }
}
#endif
