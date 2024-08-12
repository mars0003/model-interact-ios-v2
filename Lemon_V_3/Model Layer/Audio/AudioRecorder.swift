//
//  AudioRecorder.swift
//  Lemon
//
//  Created by Andre Pham on 26/7/2023.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var onPlaybackCompletion: (() -> Void)? = nil
    private(set) var recordingSessionID = UUID()
    public var isRecording: Bool {
        return self.audioRecorder?.isRecording ?? false
    }
    public var isPlaying: Bool {
        return self.audioPlayer?.isPlaying ?? false
    }
    
    /// Start recording audio to write to file.
    /// - Parameters:
    ///   - audioFileName: The filename of the audio file, with extension included (e.g. "test.m4a")
    func startRecording(audioFileName: String) {
        self.recordingSessionID = UUID()
        let audioFilename = self.getDocumentsDirectory().appendingPathComponent(audioFileName)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC), // AAC is a good choice for lossy compression
            AVSampleRateKey: 44100, // 44.1 kHz is standard for audio CD quality
            AVNumberOfChannelsKey: 2, // 2 signifies stereo recording
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue // High quality recording
        ]

        do {
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder.delegate = self
            self.audioRecorder.record()
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        self.audioRecorder.stop()
        self.audioRecorder = nil
    }
    
    /// Start playback of a written audio file.
    /// - Parameters:
    ///   - audioFileName: The filename of the audio file, with extension included (e.g. "test.m4a")
    func startPlayback(audioFileName: String, onCompletion: (() -> Void)? = nil) {
        self.onPlaybackCompletion = onCompletion
        let audioFilename = self.getDocumentsDirectory().appendingPathComponent(audioFileName)
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            self.audioPlayer.delegate = self
            self.audioPlayer.play()
        } catch {
            onCompletion?()
            print("Could not start playback: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.onPlaybackCompletion?()
    }
    
    func stopPlayback() {
        self.audioPlayer.stop()
        self.audioPlayer = nil
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
