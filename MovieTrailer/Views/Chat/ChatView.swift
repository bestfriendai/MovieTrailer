//
//  ChatView.swift
//  MovieTrailer
//
//  AI Chat with TMDB Movie Cards
//

import SwiftUI
import Kingfisher

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var messageText = ""
    @State private var selectedMovie: Movie?

    var onMovieTap: ((Movie) -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageView(message: message, onMovieTap: { movie in
                                onMovieTap?(movie)
                            })
                            .id(message.id)
                        }

                        if viewModel.isLoading && !viewModel.isStreaming {
                            TypingView()
                                .id("typing")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: viewModel.messages.count) { _, _ in
                    scroll(proxy)
                }
                .onChange(of: viewModel.messages.last?.content) { _, _ in
                    scroll(proxy)
                }
                .onChange(of: viewModel.messages.last?.movies.count) { _, _ in
                    scroll(proxy)
                }
            }

            inputBar
        }
        .background(Color.black)
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError() } }
        )) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Movie AI")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)

                Text(viewModel.isStreaming ? "thinking..." : "powered by Gemini")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            Button {
                viewModel.clearChat()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(white: 0.06))
    }

    // MARK: - Input

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask for movie recommendations...", text: $messageText, axis: .vertical)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .focused($isInputFocused)
                .lineLimit(1...4)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(white: 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 22))

            Button {
                send()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(messageText.isEmpty ? Color(white: 0.25) : .blue)
            }
            .disabled(messageText.isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(white: 0.04))
    }

    private func send() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        Task { await viewModel.sendMessage(text) }
    }

    private func scroll(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            if let last = viewModel.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - Message View

struct MessageView: View {
    let message: ChatMessage
    let onMovieTap: (Movie) -> Void

    private var isUser: Bool { message.role == .user }

    var body: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
            // Text bubble
            HStack {
                if isUser { Spacer(minLength: 50) }

                Text(cleanedContent)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isUser ? Color.blue : Color(white: 0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                if !isUser { Spacer(minLength: 50) }
            }

            // Movie cards
            if !message.movies.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(message.movies) { movie in
                            ChatMovieCard(movie: movie) {
                                onMovieTap(movie)
                            }
                        }
                    }
                }
            }
        }
    }

    // Remove [[Movie Title]] brackets from display
    private var cleanedContent: String {
        message.content.replacingOccurrences(of: #"\[\[([^\]]+)\]\]"#, with: "$1", options: .regularExpression)
    }
}

// MARK: - Chat Movie Card

struct ChatMovieCard: View {
    let movie: Movie
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Poster
                KFImage(movie.posterURL)
                    .placeholder {
                        Rectangle()
                            .fill(Color(white: 0.15))
                            .overlay(
                                Image(systemName: "film")
                                    .foregroundColor(.gray)
                            )
                    }
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fill)
                    .frame(width: 120, height: 180)
                    .clipped()

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)

                        Text(String(format: "%.1f", movie.voteAverage))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)

                        if let year = movie.releaseYear {
                            Text("• \(year)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .frame(width: 120, alignment: .leading)
                .background(Color(white: 0.12))
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(white: 0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Typing View

struct TypingView: View {
    @State private var dot = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .opacity(dot == i ? 1 : 0.3)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(white: 0.16))
            .clipShape(RoundedRectangle(cornerRadius: 18))

            Spacer()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                dot = (dot + 1) % 3
            }
        }
    }
}

#Preview {
    ChatView()
}
