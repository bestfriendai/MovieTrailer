# Gemini 3 Flash Movie Recommendation Chatbot - Implementation Guide

## Overview

This document outlines the implementation of an AI-powered movie recommendation chatbot using **Google Gemini 3 Flash** integrated with Firebase AI Logic SDK. The chatbot will learn from user preferences stored in Firestore and provide personalized movie recommendations through a premium chat interface.

---

## Table of Contents

1. [Gemini 3 Flash Overview](#gemini-3-flash-overview)
2. [Architecture](#architecture)
3. [Firebase AI Logic SDK Setup](#firebase-ai-logic-sdk-setup)
4. [Chat Service Implementation](#chat-service-implementation)
5. [Chat UI/UX Design](#chat-uiux-design)
6. [Keyboard Handling](#keyboard-handling)
7. [Message Components](#message-components)
8. [Streaming Responses](#streaming-responses)
9. [Context & Memory](#context--memory)
10. [Complete Implementation](#complete-implementation)

---

## Gemini 3 Flash Overview

### Model Specifications

| Feature | Specification |
|---------|---------------|
| **Model ID** | `gemini-3-flash-preview` |
| **Context Window** | 1 million tokens input |
| **Max Output** | 64,000 tokens |
| **Pricing** | $0.50/1M input, $3/1M output |
| **Free Tier** | Available via Gemini API |
| **Thinking Levels** | minimal, low, medium, high |
| **Knowledge Cutoff** | January 2025 |

### Key Capabilities

- **Frontier Intelligence**: Outperforms Gemini 2.5 Pro while being 3x faster
- **Multimodal**: Supports text, images, audio, video, and PDFs
- **Agentic Workflows**: Designed for complex multi-step reasoning
- **Configurable Reasoning**: `thinking_level` parameter for quality/speed tradeoff
- **Automatic Context Caching**: Reduces costs for repeated context

### Sources
- [Introducing Gemini 3 Flash](https://blog.google/products/gemini/gemini-3-flash/)
- [Build with Gemini 3 Flash](https://blog.google/technology/developers/build-with-gemini-3-flash/)
- [Gemini 3 Developer Guide](https://ai.google.dev/gemini-api/docs/gemini-3)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        MovieTrailer App                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐ │
│  │   ChatView      │───▶│  ChatViewModel  │───▶│ GeminiService│ │
│  │   (SwiftUI)     │    │  (ObservableObj)│    │              │ │
│  └─────────────────┘    └─────────────────┘    └──────┬───────┘ │
│          │                       │                     │        │
│          ▼                       ▼                     ▼        │
│  ┌─────────────────┐    ┌─────────────────┐    ┌──────────────┐ │
│  │ MessageBubble   │    │ UserPreferences │    │ Firebase AI  │ │
│  │ TypingIndicator │    │ WatchlistMgr    │    │ Logic SDK    │ │
│  │ InputBar        │    │ FirestoreService│    │              │ │
│  └─────────────────┘    └─────────────────┘    └──────┬───────┘ │
│                                                        │        │
└────────────────────────────────────────────────────────┼────────┘
                                                         │
                                                         ▼
                                              ┌──────────────────┐
                                              │  Gemini 3 Flash  │
                                              │  (Google Cloud)  │
                                              └──────────────────┘
```

---

## Firebase AI Logic SDK Setup

### Step 1: Add Firebase AI Logic to Package Dependencies

In Xcode, add Firebase AI Logic to your project:

```swift
// In Package.swift or via Xcode > File > Add Package Dependencies
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.5.0")
]

// Select FirebaseAILogic product
```

### Step 2: Update project.pbxproj

Add to your build files and frameworks:

```
FirebaseAILogic in Frameworks
```

### Step 3: Enable in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (movietrailer-1767069717)
3. Navigate to **AI Logic** in the sidebar
4. Enable the Gemini API
5. Set up Firebase App Check (recommended for production)

### Sources
- [Firebase AI Logic Getting Started](https://firebase.google.com/docs/ai-logic/get-started)
- [Firebase AI Logic Models](https://firebase.google.com/docs/ai-logic/models)

---

## Chat Service Implementation

### GeminiChatService.swift

```swift
//
//  GeminiChatService.swift
//  MovieTrailer
//
//  Handles Gemini 3 Flash API communication with streaming support
//

import Foundation
import FirebaseCore
import FirebaseAILogic

// MARK: - Chat Message Model

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: MessageRole
    var content: String
    let timestamp: Date
    var isStreaming: Bool

    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        isStreaming: Bool = false
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
    }
}

// MARK: - Gemini Chat Service

@MainActor
final class GeminiChatService: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isStreaming = false
    @Published var error: Error?

    // MARK: - Private Properties

    private var chat: Chat?
    private var model: GenerativeModel?
    private let userPreferences: UserPreferences
    private let firestoreService: FirestoreService

    // MARK: - Configuration

    private let modelName = "gemini-3-flash-preview"

    private var systemPrompt: String {
        """
        You are a friendly and knowledgeable movie recommendation assistant for the MovieTrailer app.
        Your personality is enthusiastic about cinema but not overwhelming.

        USER PREFERENCES:
        - Liked movies: \(userPreferences.getLikedMovieIds().prefix(20).map(String.init).joined(separator: ", "))
        - Disliked movies: \(userPreferences.getDislikedMovieIds().prefix(10).map(String.init).joined(separator: ", "))
        - Preferred genres: \(userPreferences.selectedGenreIds.map { GenreHelper.name(for: $0) ?? "Unknown" }.joined(separator: ", "))
        - Streaming services: \(userPreferences.selectedStreamingServices.map(\.displayName).joined(separator: ", "))

        GUIDELINES:
        1. Recommend movies based on the user's preferences shown above
        2. Consider their liked/disliked movies to understand their taste
        3. Prioritize movies available on their streaming services when possible
        4. Be conversational but concise - mobile users prefer shorter responses
        5. Use movie titles in **bold** for emphasis
        6. If asked about a specific movie, provide rating, year, and brief synopsis
        7. Suggest 2-3 movies at a time, not overwhelming lists
        8. Ask follow-up questions to refine recommendations
        9. Remember context from earlier in the conversation

        Keep responses under 200 words unless the user asks for detailed information.
        """
    }

    // MARK: - Initialization

    init(
        userPreferences: UserPreferences = .shared,
        firestoreService: FirestoreService = .shared
    ) {
        self.userPreferences = userPreferences
        self.firestoreService = firestoreService

        setupModel()
        addWelcomeMessage()
    }

    // MARK: - Setup

    private func setupModel() {
        guard FirebaseApp.app() != nil else {
            print("⚠️ Firebase not configured - Gemini chat unavailable")
            return
        }

        let ai = FirebaseAI.firebaseAI(backend: .googleAI())

        // Configure generation settings
        let config = GenerationConfig(
            temperature: 0.8,
            topP: 0.95,
            topK: 40,
            maxOutputTokens: 1024
        )

        // Create model with system instruction
        model = ai.generativeModel(
            modelName: modelName,
            generationConfig: config,
            systemInstruction: ModelContent(role: "system", parts: systemPrompt)
        )
    }

    private func addWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            role: .assistant,
            content: "Hey! I'm your movie buddy. I've seen your taste in films, and I've got some great recommendations ready. What are you in the mood for tonight? Action, comedy, something mind-bending, or should I surprise you?"
        )
        messages.append(welcomeMessage)
    }

    // MARK: - Public Methods

    /// Send a message and stream the response
    func sendMessage(_ text: String) async {
        guard let model = model else {
            error = NSError(domain: "GeminiChat", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Gemini model not initialized"])
            return
        }

        // Add user message
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)

        // Create placeholder for assistant response
        let assistantMessage = ChatMessage(
            role: .assistant,
            content: "",
            isStreaming: true
        )
        messages.append(assistantMessage)

        isLoading = true
        isStreaming = true

        do {
            // Initialize chat if needed
            if chat == nil {
                let history = messages.dropLast(2).compactMap { message -> ModelContent? in
                    guard message.role != .system else { return nil }
                    return ModelContent(
                        role: message.role == .user ? "user" : "model",
                        parts: message.content
                    )
                }
                chat = model.startChat(history: history)
            }

            // Stream the response
            let contentStream = try chat!.sendMessageStream(text)

            var fullResponse = ""

            for try await chunk in contentStream {
                if let text = chunk.text {
                    fullResponse += text

                    // Update the last message with streamed content
                    if let lastIndex = messages.indices.last {
                        messages[lastIndex].content = fullResponse
                    }
                }
            }

            // Mark streaming complete
            if let lastIndex = messages.indices.last {
                messages[lastIndex].isStreaming = false
            }

        } catch {
            self.error = error
            // Remove failed assistant message
            messages.removeLast()
            print("❌ Gemini error: \(error.localizedDescription)")
        }

        isLoading = false
        isStreaming = false
    }

    /// Clear chat history and start fresh
    func clearChat() {
        messages.removeAll()
        chat = nil
        addWelcomeMessage()
    }

    /// Refresh system prompt with latest preferences
    func refreshContext() {
        setupModel()
        chat = nil // Force new chat with updated context
    }
}
```

---

## Chat UI/UX Design

### Design Principles (Based on Industry Best Practices)

| Principle | Implementation |
|-----------|----------------|
| **Visual Hierarchy** | User messages right-aligned (blue), AI left-aligned (gray) |
| **Real-time Feedback** | Typing indicator, streaming text, timestamps |
| **Platform Conventions** | Follow iOS design patterns, safe areas |
| **Accessibility** | VoiceOver support, dynamic type, high contrast |
| **Dark Mode** | Full support with proper contrast ratios |

### Sources
- [Chat UI Design Patterns 2025](https://bricxlabs.com/blogs/message-screen-ui-deisgn)
- [UI/UX Best Practices for Chat Apps](https://www.cometchat.com/blog/chat-app-design-best-practices)
- [Sendbird Chat UI Resources](https://sendbird.com/blog/resources-for-modern-chat-app-ui)

---

## Keyboard Handling

### Key Implementation Points

1. **Automatic Keyboard Avoidance** (iOS 14+): SwiftUI handles this by default
2. **Scroll Dismiss**: Use `.scrollDismissesKeyboard(.interactively)` for natural dismissal
3. **Focus Management**: Use `@FocusState` for programmatic control
4. **Safe Area Handling**: Proper safe area management for input bar

### Sources
- [SwiftUI Keyboard Avoidance](https://www.fivestars.blog/articles/swiftui-keyboard/)
- [Keyboard Avoidance Best Practices](https://www.vadimbulavin.com/how-to-move-swiftui-view-when-keyboard-covers-text-field/)
- [Dismiss Keyboard on Scroll](https://www.kodeco.com/books/swiftui-cookbook/v1.0/chapters/10-dismiss-keyboard-on-scroll-in-swiftui)

---

## Message Components

### ChatView.swift

```swift
//
//  ChatView.swift
//  MovieTrailer
//
//  Premium chat interface with Gemini 3 Flash integration
//

import SwiftUI

struct ChatView: View {

    // MARK: - Properties

    @StateObject private var viewModel = ChatViewModel()
    @FocusState private var isInputFocused: Bool
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundGradient

                VStack(spacing: 0) {
                    // Header
                    chatHeader

                    // Messages
                    messagesScrollView

                    // Input Bar
                    inputBar
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
            isInputFocused = false
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 0.05, green: 0.05, blue: 0.1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var chatHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.cyan)
                    Text("Movie Assistant")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                if viewModel.isStreaming {
                    Text("typing...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: { viewModel.clearChat() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    // MARK: - Messages ScrollView

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }

                    // Typing indicator
                    if viewModel.isLoading && !viewModel.isStreaming {
                        TypingIndicator()
                            .id("typing")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 100) // Space for input bar
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear { scrollProxy = proxy }
            .onChange(of: viewModel.messages.count) { _, _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.messages.last?.content) { _, _ in
                scrollToBottom(proxy: proxy)
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.1))

            HStack(spacing: 12) {
                // Text Field
                HStack {
                    TextField("Ask about movies...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .foregroundStyle(.white)
                        .focused($isInputFocused)
                        .lineLimit(1...5)
                        .submitLabel(.send)
                        .onSubmit(sendMessage)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                )

                // Send Button
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(messageText.isEmpty ? Color.gray.opacity(0.3) : Color.cyan)
                            .frame(width: 36, height: 36)

                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .disabled(messageText.isEmpty || viewModel.isLoading)
                .animation(.easeInOut(duration: 0.2), value: messageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Actions

    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messageText = ""
        isInputFocused = false

        Haptics.shared.lightImpact()

        Task {
            await viewModel.sendMessage(text)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.3)) {
            if let lastMessage = viewModel.messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            } else if viewModel.isLoading {
                proxy.scrollTo("typing", anchor: .bottom)
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(LocalizedStringKey(message.content))
                    .font(.body)
                    .foregroundStyle(isUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isUser ? Color.cyan : Color.white.opacity(0.1))
                    )
                    .overlay(alignment: isUser ? .bottomTrailing : .bottomLeading) {
                        if message.isStreaming {
                            StreamingCursor()
                                .padding(isUser ? .trailing : .leading, 12)
                                .padding(.bottom, 8)
                        }
                    }

                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if !isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Streaming Cursor

struct StreamingCursor: View {
    @State private var isVisible = true

    var body: some View {
        Rectangle()
            .fill(Color.cyan)
            .frame(width: 2, height: 16)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    isVisible.toggle()
                }
            }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset(for: index))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )

            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                animationOffset = 1
            }
        }
    }

    private func animationOffset(for index: Int) -> CGFloat {
        let delay = Double(index) * 0.15
        let progress = (animationOffset + CGFloat(delay)).truncatingRemainder(dividingBy: 1)
        return sin(progress * .pi * 2) * 4
    }
}

// MARK: - Preview

#Preview {
    ChatView()
        .preferredColorScheme(.dark)
}
```

---

## Streaming Responses

### Implementation Details

The Firebase AI Logic SDK supports streaming via `sendMessageStream()`:

```swift
let contentStream = try chat.sendMessageStream(userMessage)

for try await chunk in contentStream {
    if let text = chunk.text {
        // Append to current response
        currentResponse += text

        // Update UI immediately
        updateMessage(with: currentResponse)
    }
}
```

### Benefits of Streaming

| Benefit | Description |
|---------|-------------|
| **Perceived Speed** | User sees response immediately instead of waiting |
| **Better UX** | Mimics human typing behavior |
| **Early Abort** | User can cancel if response is going wrong direction |
| **Engagement** | Keeps user engaged during generation |

### Sources
- [Firebase AI Logic Chat Documentation](https://firebase.google.com/docs/ai-logic/chat)

---

## Context & Memory

### Building Personalized Context

The system prompt is dynamically built using the user's stored preferences:

```swift
private var systemPrompt: String {
    """
    USER PREFERENCES:
    - Liked movies: \(userPreferences.getLikedMovieIds())
    - Disliked movies: \(userPreferences.getDislikedMovieIds())
    - Preferred genres: \(userPreferences.selectedGenreIds)
    - Streaming services: \(userPreferences.selectedStreamingServices)

    Use these preferences to personalize recommendations...
    """
}
```

### Conversation History Management

The SDK automatically manages conversation history:

```swift
// History is automatically maintained by the Chat object
let chat = model.startChat(history: existingHistory)

// Each sendMessage call adds to history automatically
let response = try await chat.sendMessage(newMessage)
// History now includes: existingHistory + newMessage + response
```

### Cost Optimization

With Gemini's 1M token context window, be mindful of costs:

1. **Limit History**: Keep only recent 20-30 messages
2. **Summarize**: Periodically summarize older context
3. **Context Caching**: Gemini 3 Flash supports automatic caching
4. **Thinking Level**: Use `minimal` for simple queries, `high` for complex ones

---

## Complete Implementation

### Files to Create

```
MovieTrailer/
├── Services/
│   └── GeminiChatService.swift
├── ViewModels/
│   └── ChatViewModel.swift
├── Views/
│   └── Chat/
│       ├── ChatView.swift
│       ├── MessageBubble.swift
│       ├── TypingIndicator.swift
│       ├── ChatInputBar.swift
│       └── StreamingCursor.swift
└── Models/
    └── ChatMessage.swift
```

### ChatViewModel.swift

```swift
//
//  ChatViewModel.swift
//  MovieTrailer
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

    init(chatService: GeminiChatService = GeminiChatService()) {
        self.chatService = chatService

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
    }

    func refreshContext() {
        chatService.refreshContext()
    }
}
```

### Integration with Main App

```swift
// In MainTabView or navigation:
NavigationLink(destination: ChatView()) {
    Label("Movie Assistant", systemImage: "sparkles")
}

// Or as a floating button:
Button(action: { showChat = true }) {
    Image(systemName: "message.fill")
        .font(.title2)
        .foregroundStyle(.white)
        .frame(width: 56, height: 56)
        .background(
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: .cyan.opacity(0.5), radius: 10)
}
.fullScreenCover(isPresented: $showChat) {
    ChatView()
}
```

---

## Package Dependencies to Add

Add Firebase AI Logic to your Xcode project:

```swift
// In project.pbxproj, add:
FIREBASEAI_PKGREF /* XCRemoteSwiftPackageReference "firebase-ios-sdk" */ = {
    isa = XCRemoteSwiftPackageReference;
    repositoryURL = "https://github.com/firebase/firebase-ios-sdk";
    requirement = {
        kind = upToNextMajorVersion;
        minimumVersion = 12.5.0;
    };
};

// Add FirebaseAILogic to package product dependencies
```

---

## Best Practices Summary

### UI/UX
- Use `.scrollDismissesKeyboard(.interactively)` for natural keyboard dismissal
- Implement streaming with visual cursor for real-time feedback
- Group consecutive messages from same sender
- Show timestamps sparingly (every few minutes)
- Add haptic feedback on send

### Performance
- Stream responses instead of waiting for complete response
- Limit conversation history to manage token costs
- Use appropriate thinking_level based on query complexity
- Implement proper error handling with retry logic

### Accessibility
- Support VoiceOver for all elements
- Use Dynamic Type for text sizing
- Ensure sufficient color contrast
- Provide haptic feedback for interactions

---

## Next Steps

1. **Add Firebase AI Logic package** to Xcode project
2. **Enable AI Logic** in Firebase Console
3. **Create the service and view files** as outlined above
4. **Test with streaming** to ensure smooth UX
5. **Iterate on system prompt** based on user feedback

---

## Sources

- [Gemini 3 Flash Announcement](https://blog.google/products/gemini/gemini-3-flash/)
- [Firebase AI Logic Documentation](https://firebase.google.com/docs/ai-logic)
- [Firebase AI Logic Chat](https://firebase.google.com/docs/ai-logic/chat)
- [Gemini 3 Developer Guide](https://ai.google.dev/gemini-api/docs/gemini-3)
- [SwiftUI Keyboard Avoidance](https://www.fivestars.blog/articles/swiftui-keyboard/)
- [Chat UI Design Patterns](https://bricxlabs.com/blogs/message-screen-ui-deisgn)
- [Sendbird Typing Indicator](https://sendbird.com/docs/chat/uikit/v3/ios-uikit/features/typing-indicator)
