//
//  ChatViewModel.swift
//  MovieTrailer
//
//  Created by Claude Code on 01/01/2026.
//  ViewModel for chat interface with Gemini AI
//

import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isStreaming = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let chatService: GeminiChatService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        self.chatService = GeminiChatService()

        // Bind to service
        chatService.$messages
            .assign(to: &$messages)

        chatService.$isLoading
            .assign(to: &$isLoading)

        chatService.$isStreaming
            .assign(to: &$isStreaming)

        chatService.$error
            .compactMap { $0?.localizedDescription }
            .assign(to: &$errorMessage)
    }

    // MARK: - Public Methods

    func sendMessage(_ text: String) async {
        await chatService.sendMessage(text)
    }

    func clearChat() {
        chatService.clearChat()
        errorMessage = nil
    }

    func dismissError() {
        errorMessage = nil
    }
}
