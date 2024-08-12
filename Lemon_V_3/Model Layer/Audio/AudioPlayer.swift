//
//  AudioManager.swift
//  Lemon
//
//  Created by Andre Pham on 26/7/2023.
//

import Foundation
import AVFoundation

class AudioPlayer {
    
    public static let inst = AudioPlayer()
    private var audioPlayer: AVAudioPlayer?
    public var isPlaying: Bool {
        return self.audioPlayer?.isPlaying ?? false
    }

    private init() { }

    /// Play the audio from a local file.
    /// Remember to add all files to project build (Project/TARGET/Build Phases/Copy Bundle Resources).
    /// Example: `AudioPlayer.inst.playAudio(file: "myAudioFile", type: "m4a")`
    /// - Parameters:
    ///   - file: The filename
    ///   - type: The file extension
    func playAudio(file: String, type: String, volume: Float = 1.0) {
        guard let path = Bundle.main.path(forResource: file, ofType: type) else {
            assertionFailure("Unable to find audio file \(file). Have you added it to bundle resources? (Project -> select target -> open Build Phases -> add to Copy Bundle Resources)")
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer?.volume = volume
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
        } catch {
            assertionFailure("Unable to play audio file: \(error)")
        }
    }

    func stopAudio() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
    }
    
}
