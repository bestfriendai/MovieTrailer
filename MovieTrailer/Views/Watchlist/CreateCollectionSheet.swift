//
//  CreateCollectionSheet.swift
//  MovieTrailer
//

import SwiftUI

struct CreateCollectionSheet: View {
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor: Color = .blue
    let onCreate: (String, String, Color) -> Void

    private let iconOptions = [
        "folder.fill", "heart.fill", "star.fill", "moon.stars.fill",
        "film.fill", "popcorn.fill", "tv.fill", "play.circle.fill",
        "flame.fill", "sparkles", "bolt.fill", "crown.fill"
    ]

    private let colorOptions: [Color] = [
        .blue, .purple, .pink, .red, .orange, .yellow, .green, .cyan
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Collection Name", text: $name)
                        .font(.system(size: 17))
                } header: {
                    Text("Name")
                }

                Section {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                                Haptics.shared.selectionChanged()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(
                                            selectedIcon == icon
                                            ? selectedColor.opacity(0.2)
                                            : Color.white.opacity(0.1)
                                        )
                                        .frame(width: 44, height: 44)

                                    Image(systemName: icon)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(
                                            selectedIcon == icon ? selectedColor : .white.opacity(0.6)
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Icon")
                }

                Section {
                    HStack(spacing: 12) {
                        ForEach(colorOptions, id: \.self) { color in
                            Button {
                                selectedColor = color
                                Haptics.shared.selectionChanged()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 36, height: 36)

                                    if selectedColor == color {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 3)
                                            .frame(width: 36, height: 36)

                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Color")
                }

                Section {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedColor.opacity(0.2))
                                .frame(width: 60, height: 60)

                            Image(systemName: selectedIcon)
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(selectedColor)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(name.isEmpty ? "New Collection" : name)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)

                            Text("0 movies")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.leading, 12)

                        Spacer()
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Preview")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Haptics.shared.success()
                        onCreate(name, selectedIcon, selectedColor)
                        isPresented = false
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Collection Model

struct WatchlistCollection: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var movieIds: [Int]
    var createdAt: Date

    init(name: String, icon: String, color: Color) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = color.toHex() ?? "#0A84FF"
        self.movieIds = []
        self.createdAt = Date()
    }

    var color: Color {
        Color(hex: colorHex)
    }
}
