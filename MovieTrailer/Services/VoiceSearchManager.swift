//
//  VoiceSearchManager.swift
//  MovieTrailer
//
//  Phase 3: Voice Search Feature
//  Speech recognition for hands-free movie search
//

import Foundation
import Speech
import AVFoundation

// MARK: - Voice Search State

enum VoiceSearchState: Equatable {
    case idle
    case requesting
    case listening
    case processing
    case error(String)

    var isActive: Bool {
        switch self {
        case .listening, .processing:
            return true
        default:
            return false
        }
    }
}

// MARK: - Voice Search Manager

@MainActor
final class VoiceSearchManager: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var state: VoiceSearchState = .idle
    @Published private(set) var transcript: String = ""
    @Published private(set) var isAuthorized = false

    // MARK: - Callback

    var onTranscriptFinalized: ((String) -> Void)?

    // MARK: - Private Properties

    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // MARK: - Initialization

    init(locale: Locale = .current) {
        speechRecognizer = SFSpeechRecognizer(locale: locale)
        checkAuthorization()
    }

    // MARK: - Authorization

    private func checkAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor [weak self] in
                switch status {
                case .authorized:
                    self?.isAuthorized = true
                case .denied, .restricted, .notDetermined:
                    self?.isAuthorized = false
                @unknown default:
                    self?.isAuthorized = false
                }
            }
        }
    }

    /// Request microphone and speech authorization
    func requestAuthorization() async -> Bool {
        state = .requesting

        // Request microphone permission
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            state = .error("Microphone access denied")
            return false
        }

        // Request speech recognition permission
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                Task { @MainActor [weak self] in
                    switch status {
                    case .authorized:
                        self?.isAuthorized = true
                        self?.state = .idle
                        continuation.resume(returning: true)
                    default:
                        self?.isAuthorized = false
                        self?.state = .error("Speech recognition not authorized")
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }

    // MARK: - Voice Search

    /// Start listening for voice input
    func startListening() {
        guard isAuthorized else {
            Task {
                let authorized = await requestAuthorization()
                if authorized {
                    startListening()
                }
            }
            return
        }

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            state = .error("Speech recognition unavailable")
            return
        }

        // Stop any existing task
        stopListening()

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            state = .error("Audio session error")
            return
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            state = .error("Unable to create request")
            return
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.taskHint = .search

        // Get audio input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                if let result = result {
                    self.transcript = result.bestTranscription.formattedString

                    if result.isFinal {
                        self.state = .processing
                        let finalTranscript = result.bestTranscription.formattedString
                        self.stopListening()

                        // Notify callback with final transcript
                        if !finalTranscript.isEmpty {
                            self.onTranscriptFinalized?(finalTranscript)
                        }
                    }
                }

                if let error = error {
                    // Ignore cancellation errors
                    let nsError = error as NSError
                    if nsError.domain != "kAFAssistantErrorDomain" {
                        self.state = .error("Recognition error")
                    }
                    self.stopListening()
                }
            }
        }

        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            state = .listening
            transcript = ""

            // Auto-stop after 10 seconds
            Task {
                try? await Task.sleep(for: .seconds(10))
                if self.state == .listening {
                    self.stopListening()
                }
            }
        } catch {
            state = .error("Audio engine error")
            stopListening()
        }
    }

    /// Stop listening and process results
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil

        if state == .listening {
            // If we have a transcript, trigger the callback
            if !transcript.isEmpty {
                onTranscriptFinalized?(transcript)
            }
            state = .idle
        } else if state != .error("") {
            state = .idle
        }
    }

    /// Toggle listening state
    func toggle() {
        if state.isActive {
            stopListening()
        } else {
            startListening()
        }
    }
}
