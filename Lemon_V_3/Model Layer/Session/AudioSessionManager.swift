//
//  AudioSessionManager.swift
//  Lemon
//
//  Created by Andre Pham on 11/6/2023.
//

import Foundation
import AVFoundation

class AudioSessionManager {
    
    enum Mode {
        case VOIP
        case speaker
        case playback
        case record
    }
    
    public static let inst = AudioSessionManager()
    private var audioSession: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    private var modeHistory = [Mode]()
    public var activeMode: Mode {
        assert(!self.modeHistory.isEmpty, "Mode history should never be empty - did you forget to setup?")
        return self.modeHistory.last ?? .speaker
    }
    
    private init() { }
    
    func setup() {
        self.setToSpeakerMode()
    }
    
    func setPreviousMode() {
        guard self.modeHistory.count > 1 else {
            // No previous mode to return to
            return
        }
        self.modeHistory.removeLast()
        let previousMode = self.modeHistory.popLast()!
        switch previousMode {
        case .VOIP:
            self.setToVOIPMode()
        case .speaker:
            self.setToSpeakerMode()
        case .playback:
            self.setToPlaybackMode()
        case .record:
            self.setToRecordMode()
        }
    }
    
    /// This mode is the default mode used for stuff like voice calls, and allows the processing of both input and output text simultaneously. It works great if you're using a bluetooth headset or are holding a phone to your ear, but not if you want to have the main speaker producing the audio. Note: it also has sidetone.
    func setToVOIPMode() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try self.audioSession.setActive(true)
            self.modeHistory.append(.VOIP)
        } catch {
            assertionFailure("Failed to set audio session to universal mode: \(error)")
        }
    }
    
    /// This mode is just for audio playback.
    func setToPlaybackMode() {
        do {
            try self.audioSession.setCategory(.playback, mode: .default, options: [])
            try self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            self.modeHistory.append(.playback)
        } catch {
            assertionFailure("Failed to set audio session to playback mode: \(error)")
        }
    }
    
    /// This mode is just for audio recording.
    func setToRecordMode() {
        do {
            try self.audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .mixWithOthers, .allowBluetoothA2DP])
            try self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            self.modeHistory.append(.record)
        } catch {
            assertionFailure("Failed to set audio session to record mode: \(error)")
        }
    }
    
    /// This is the "speaker mode" in voice calls. This mode allows the processing of both input and output text simultaneously. However, it is bound to the device's peripherals (no headset/speakers allowed).
    func setToSpeakerMode() {
        do {
            try self.audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try self.audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            self.modeHistory.append(.speaker)
        } catch {
            assertionFailure("Failed to set audio session to speaker mode: \(error)")
        }
    }
    
}
