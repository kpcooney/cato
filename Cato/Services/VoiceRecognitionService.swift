//
//  VoiceRecognitionService.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import Speech

protocol VoiceRecognitionServiceProtocol {
    func requestAuthorization() async -> Bool
    func startListening(onResult: @escaping (String) -> Void) throws
    func stopListening()
}

/// Wraps SFSpeechRecognizer for on-device voice command recognition during sessions.
///
/// On-device recognition (`requiresOnDeviceRecognition = true`) is required for
/// privacy — no audio leaves the device. The trade-off is slightly lower accuracy
/// than server-side recognition, which is acceptable for the simple numeric and
/// keyword commands Cato uses ("5", "got 3", "skip", "next", etc.).
///
/// Apple limits recognition tasks to ~60 seconds before they time out. In Phase 3,
/// SessionViewModel will restart the recognition task every 55 seconds to stay
/// within this limit without dropping any commands.
///
/// This service is fully stubbed for Phase 1–2. Implementation lands in Phase 3.
class VoiceRecognitionService: VoiceRecognitionServiceProtocol {

    /// en-US locale is hardcoded for v1. Multi-language support is a future consideration.
    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        // .dictation hint improves recognition of short numeric utterances.
        self.speechRecognizer?.defaultTaskHint = .dictation
    }

    /// Requests system authorization for speech recognition. Must be called before
    /// startListening(). The system sheet appears only on the first call per app install.
    /// Returns true if granted, false if denied or restricted.
    func requestAuthorization() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    /// Starts a new recognition task and streams transcriptions to the callback.
    /// The callback is called with partial results as the user speaks.
    /// TODO (Phase 3): Set up AVAudioEngine, SFSpeechAudioBufferRecognitionRequest,
    ///                  and session-aware start/stop logic with the rest timer.
    func startListening(onResult: @escaping (String) -> Void) throws {
        // Stub — implemented in Phase 3.
    }

    /// Stops the current recognition task. Safe to call even if not listening.
    func stopListening() {
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }
}
