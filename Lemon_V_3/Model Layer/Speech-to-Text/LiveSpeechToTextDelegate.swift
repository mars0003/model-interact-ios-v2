//
//  LiveSpeechToTextDelegate.swift
//  Lemon
//
//  Created by Andre Pham on 23/6/2023.
//

import Foundation

protocol LiveSpeechToTextDelegate: AnyObject {
    
    func onWordRecognition(currentTranscription: SpeechText)
    
}
