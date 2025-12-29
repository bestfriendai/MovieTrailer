//
//  ShareableWatchlist.swift
//  MovieTrailer
//
//  Created by Claude Code on 29/12/2025.
//  Shareable watchlist with deep links and social features
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Shareable Watchlist

struct ShareableWatchlist: Codable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    let createdBy: String
    var movieIds: [Int]
    let createdAt: Date
    var updatedAt: Date
    var isPublic: Bool
    var coverImageMovieId: Int?

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        createdBy: String = "Movie Fan",
        movieIds: [Int] = [],
        isPublic: Bool = true
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.createdBy = createdBy
        self.movieIds = movieIds
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isPublic = isPublic
        self.coverImageMovieId = movieIds.first
    }

    // MARK: - URLs

    var shareURL: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "movietrailer.app"
        components.path = "/list/\(id.uuidString)"
        return components.url
    }

    var deepLinkURL: URL? {
        URL(string: "movietrailer://list/\(id.uuidString)")
    }

    var qrCodeData: Data? {
        shareURL?.absoluteString.data(using: .utf8)
    }

    // MARK: - Share Text

    var shareText: String {
        var text = "\(name)"

        if !description.isEmpty {
            text += "\n\(description)"
        }

        text += "\n\n\(movieIds.count) movies"

        if let url = shareURL {
            text += "\n\n\(url.absoluteString)"
        }

        return text
    }
}

// MARK: - Watchlist Share Manager

@MainActor
final class WatchlistShareManager: ObservableObject {

    // MARK: - Published Properties

    @Published var sharedLists: [ShareableWatchlist] = []
    @Published var isGeneratingShare = false
    @Published var generatedShareURL: URL?
    @Published var error: String?

    // MARK: - File Storage

    private var storageURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("shared_lists.json")
    }

    // MARK: - Initialization

    init() {
        loadSharedLists()
    }

    // MARK: - Create Shareable List

    func createShareableList(
        from items: [WatchlistItem],
        name: String,
        description: String = ""
    ) -> ShareableWatchlist {
        let list = ShareableWatchlist(
            name: name,
            description: description,
            movieIds: items.map(\.id)
        )

        sharedLists.append(list)
        saveSharedLists()

        return list
    }

    func createShareableList(
        from watchlistManager: WatchlistManager,
        name: String? = nil
    ) -> ShareableWatchlist {
        let items = watchlistManager.items
        let listName = name ?? "My Watchlist (\(items.count) movies)"

        return createShareableList(from: items, name: listName)
    }

    // MARK: - Update List

    func updateList(_ list: ShareableWatchlist) {
        if let index = sharedLists.firstIndex(where: { $0.id == list.id }) {
            var updated = list
            updated.updatedAt = Date()
            sharedLists[index] = updated
            saveSharedLists()
        }
    }

    func deleteList(_ list: ShareableWatchlist) {
        sharedLists.removeAll { $0.id == list.id }
        saveSharedLists()
    }

    // MARK: - Import List

    func importList(from url: URL) async throws -> ShareableWatchlist? {
        // Extract list ID from URL
        let pathComponents = url.pathComponents
        guard let idString = pathComponents.last,
              let id = UUID(uuidString: idString) else {
            throw ShareError.invalidURL
        }

        // In a real app, this would fetch from a server
        // For now, check if we have it locally
        if let existing = sharedLists.first(where: { $0.id == id }) {
            return existing
        }

        throw ShareError.listNotFound
    }

    func importFromClipboard() async throws -> ShareableWatchlist? {
        guard let string = UIPasteboard.general.string,
              let url = URL(string: string) else {
            throw ShareError.invalidClipboard
        }

        return try await importList(from: url)
    }

    // MARK: - Storage

    private func loadSharedLists() {
        guard let url = storageURL,
              FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let data = try Data(contentsOf: url)
            sharedLists = try JSONDecoder().decode([ShareableWatchlist].self, from: data)
        } catch {
            print("Failed to load shared lists: \(error)")
        }
    }

    private func saveSharedLists() {
        guard let url = storageURL else { return }

        do {
            let data = try JSONEncoder().encode(sharedLists)
            try data.write(to: url)
        } catch {
            print("Failed to save shared lists: \(error)")
        }
    }

    // MARK: - Errors

    enum ShareError: LocalizedError {
        case invalidURL
        case listNotFound
        case invalidClipboard
        case networkError

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid share URL"
            case .listNotFound: return "List not found"
            case .invalidClipboard: return "No valid URL in clipboard"
            case .networkError: return "Network error"
            }
        }
    }
}

// MARK: - Share Sheet

struct WatchlistShareSheet: View {
    let watchlist: ShareableWatchlist
    let onDismiss: () -> Void

    @State private var showCopiedToast = false
    @State private var qrCodeImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // QR Code
                    qrCodeSection

                    // Share URL
                    urlSection

                    // Share Options
                    shareOptionsSection

                    // List Preview
                    listPreviewSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Share List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
        .onAppear {
            generateQRCode()
        }
        .overlay {
            if showCopiedToast {
                ToastView(
                    message: "Copied to clipboard",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 50)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }

    // MARK: - QR Code Section

    private var qrCodeSection: some View {
        VStack(spacing: 12) {
            if let image = qrCodeImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceSecondary)
                    .frame(width: 200, height: 200)
                    .overlay(
                        ProgressView()
                    )
            }

            Text("Scan to view list")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surfaceElevated)
        )
    }

    // MARK: - URL Section

    private var urlSection: some View {
        VStack(spacing: 8) {
            Text("Share Link")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                Text(watchlist.shareURL?.absoluteString ?? "")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                Button {
                    copyToClipboard()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.accentPrimary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surfaceSecondary)
            )
        }
    }

    // MARK: - Share Options

    private var shareOptionsSection: some View {
        VStack(spacing: 12) {
            Text("Share via")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                ShareOptionButton(
                    icon: "message.fill",
                    label: "Messages",
                    color: .green
                ) {
                    shareViaMessages()
                }

                ShareOptionButton(
                    icon: "envelope.fill",
                    label: "Email",
                    color: .blue
                ) {
                    shareViaEmail()
                }

                ShareOptionButton(
                    icon: "square.and.arrow.up",
                    label: "More",
                    color: .gray
                ) {
                    shareViaSystem()
                }
            }
        }
    }

    // MARK: - List Preview

    private var listPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("List Preview")
                .font(.headline)
                .foregroundColor(.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                Text(watchlist.name)
                    .font(.title3.bold())
                    .foregroundColor(.textPrimary)

                if !watchlist.description.isEmpty {
                    Text(watchlist.description)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }

                HStack {
                    Label("\(watchlist.movieIds.count) movies", systemImage: "film")
                    Spacer()
                    Text("by \(watchlist.createdBy)")
                }
                .font(.caption)
                .foregroundColor(.textTertiary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceSecondary)
            )
        }
    }

    // MARK: - Actions

    private func generateQRCode() {
        guard let data = watchlist.qrCodeData else { return }

        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")

        guard let ciImage = filter?.outputImage else { return }

        let scale = 200 / ciImage.extent.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = ciImage.transformed(by: transform)

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return }

        qrCodeImage = UIImage(cgImage: cgImage)
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = watchlist.shareURL?.absoluteString
        Haptics.shared.success()

        withAnimation {
            showCopiedToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedToast = false
            }
        }
    }

    private func shareViaMessages() {
        // Would open Messages with pre-filled content
        Haptics.shared.lightImpact()
    }

    private func shareViaEmail() {
        // Would open Mail with pre-filled content
        Haptics.shared.lightImpact()
    }

    private func shareViaSystem() {
        // Would open system share sheet
        Haptics.shared.lightImpact()
    }
}

// MARK: - Share Option Button

struct ShareOptionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(color)
                    .clipShape(Circle())

                Text(label)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Transferable Conformance

extension ShareableWatchlist: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)

        ProxyRepresentation(exporting: \.shareText)
    }
}

// MARK: - Preview

#if DEBUG
struct ShareableWatchlist_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistShareSheet(
            watchlist: ShareableWatchlist(
                name: "My Weekend Movies",
                description: "A collection of great films to watch this weekend",
                movieIds: [550, 551, 552, 553, 554]
            ),
            onDismiss: {}
        )
        .preferredColorScheme(.dark)
    }
}
#endif
