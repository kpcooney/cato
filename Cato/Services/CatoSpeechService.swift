//
//  CatoSpeechService.swift
//  Cato
//
//  Created by Cato on 2026-02-17.
//

import Foundation
import AVFoundation

protocol CatoSpeechServiceProtocol {
    func speak(_ text: String)
    func stop()
    func setRate(_ rate: Float)
}

class CatoSpeechService: CatoSpeechServiceProtocol {

    private let synthesizer: AVSpeechSynthesizer
    private var speechRate: Float = AVSpeechUtteranceDefaultSpeechRate

    init() {
        self.synthesizer = AVSpeechSynthesizer()
    }

    func speak(_ text: String) {
        // Stub: Text-to-speech using AVSpeechSynthesizer
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = speechRate
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func stop() {
        // Stub: Stop current speech
        synthesizer.stopSpeaking(at: .immediate)
    }

    func setRate(_ rate: Float) {
        // Stub: Adjust speech rate
        self.speechRate = rate
    }
}
