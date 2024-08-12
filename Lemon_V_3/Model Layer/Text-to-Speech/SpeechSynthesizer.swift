//
//  SpeechSynthesizer.swift
//  Lemon
//
//  Created by Andre Pham on 11/6/2023.
//

import Foundation
import AVFoundation

class SpeechSynthesizer: NSObject, AVSpeechSynthesizerDelegate {
    
    enum Accent: String {
        case american = "en-US"
        case australian = "en-AU"
        // Add more if desired, e.g. en-GB, en-IE
    }
    
    private let synthesiser = AVSpeechSynthesizer()
    private var rate: Float = 0.50
    private var pitchMultiplier: Float = 0.9
    private var postUtteranceDelay: TimeInterval = 0.0
    private var volume: Float = 1.0 // [0.0, 1.0]
    private var voice: AVSpeechSynthesisVoice
    private var lastSpoken: String? = nil
    public var isSpeaking: Bool {
        return self.synthesiser.isSpeaking
    }
    public var isPaused: Bool {
        return self.synthesiser.isPaused
    }
    /// Called when the speech synthesizer finishes the utterance - provided as per call to `speak`
    private var speakDidFinishDelegate: (() -> Void)? = nil
    /// Called when the speech synthesizer finishes the utterance
    public var didFinishDelegate: (() -> Void)? = nil
    /// Called when the speech synthesizer starts an utterance
    public var didStartDelegate: (() -> Void)? = nil
    /// Called when the speech synthesizer pauses an utterance
    public var didPauseDelegate: (() -> Void)? = nil
    /// Called when the speech synthesizer cancels an utterance
    public var didCancelDelegate: (() -> Void)? = nil
    /// Called when the speech synthesizer continues an utterance after a pause
    public var didContinueDelegate: (() -> Void)? = nil
    
    override init() {
        self.voice = AVSpeechSynthesisVoice(language: Accent.american.rawValue)!
        super.init()
        self.synthesiser.delegate = self
    }
    
    private func buildUtterance(speech: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: speech)
        utterance.rate = self.rate
        utterance.pitchMultiplier = self.pitchMultiplier
        utterance.postUtteranceDelay = self.postUtteranceDelay
        utterance.volume = self.volume
        utterance.voice = self.voice
        return utterance
    }
    
    func speak(_ speech: String, onCompletion: (() -> Void)? = nil) {
        self.speakDidFinishDelegate = onCompletion
        let utterance = self.buildUtterance(speech: speech)
        // AudioSessionManager.inst.setToPlaybackMode() // Unnecessary with VOIP mode or speaker mode
        self.synthesiser.speak(utterance)
    }
    
    func stopSpeaking() {
        guard self.synthesiser.isSpeaking else {
            return
        }
        self.synthesiser.stopSpeaking(at: .immediate)
    }
    
    func repeatLastSpoken() {
        if let lastSpoken {
            self.speak(lastSpoken)
        }
    }
    
}
extension SpeechSynthesizer {
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    /// Called when the speech synthesizer finishes the utterance.
    /// - Parameters:
    ///   - synthesizer: The speech synthesizer that has finished the utterance
    ///   - utterance: The speech utterance that was completed
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.speakDidFinishDelegate?()
        self.didFinishDelegate?()
        self.speakDidFinishDelegate = nil
    }
    
    /// Called when the speech synthesizer starts an utterance.
    /// - Parameters:
    ///   - synthesizer: The speech synthesizer that has started the utterance
    ///   - utterance: The speech utterance that was started
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.didStartDelegate?()
    }
    
    /// Called when the speech synthesizer pauses an utterance.
    /// - Parameters:
    ///   - synthesizer: The speech synthesizer that has paused the utterance
    ///   - utterance: The speech utterance that was paused
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        self.didPauseDelegate?()
    }
    
    /// Called when the speech synthesizer cancels an utterance.
    /// - Parameters:
    ///   - synthesizer: The speech synthesizer that has canceled the utterance
    ///   - utterance: The speech utterance that was canceled
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.didCancelDelegate?()
    }
    
    /// Called when the speech synthesizer continues an utterance after a pause.
    /// - Parameters:
    ///   - synthesizer: The speech synthesizer that has continued the utterance
    ///   - utterance: The speech utterance that was continued
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        self.didContinueDelegate?()
    }
    
}
