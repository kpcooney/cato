//
//  CatoSpeechService.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation
import AVFoundation

protocol CatoSpeechServiceProtocol {
    func speak(_ text: String)
    func stop()
    func setRate(_ rate: Float)
}

/// Wraps AVSpeechSynthesizer to give Cato a voice.
///
/// All text spoken through this service must originate from CatoPersona.swift —
/// never pass raw strings from views or ViewModels to keep the persona consistent.
///
/// Audio session configuration (.playback + .duckOthers) is handled in Phase 3
/// when speech is wired to active sessions. For now, this uses default audio routing
/// so it doesn't interfere with music during Phase 2 (program management) testing.
class CatoSpeechService: CatoSpeechServiceProtocol {

    private let synthesizer: AVSpeechSynthesizer

    /// User-adjustable speech rate. Exposed via SettingsView (0.3 = slow, 0.7 = fast).
    /// AVSpeechUtteranceDefaultSpeechRate is ~0.5.
    private var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate

    init() {
        self.synthesizer = AVSpeechSynthesizer()
    }

    /// Speaks the given text using Cato's voice settings.
    /// If the synthesizer is already speaking, the new utterance is queued after the current one.
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = speechRate
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    /// Stops speech immediately (e.g. when the user pauses a session or taps Skip).
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    /// Called from SettingsView when the user adjusts the speech rate slider.
    /// Takes effect on the next call to speak() — does not affect in-progress utterances.
    func setRate(_ rate: Float) {
        self.speechRate = rate
    }
}
