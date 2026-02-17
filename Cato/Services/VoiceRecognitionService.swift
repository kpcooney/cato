//
//  VoiceRecognitionService.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import Speech

protocol VoiceRecognitionServiceProtocol {
    func requestAuthorization() async -> Bool
    func startListening(onResult: @escaping (String) -> Void) throws
    func stopListening()
}

class VoiceRecognitionService: VoiceRecognitionServiceProtocol {

    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        self.speechRecognizer?.defaultTaskHint = .dictation
    }

    func requestAuthorization() async -> Bool {
        // Stub: Request speech recognition authorization
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startListening(onResult: @escaping (String) -> Void) throws {
        // Stub: Start on-device speech recognition
    }

    func stopListening() {
        // Stub: Stop speech recognition
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }
}
