//
//  SFSpeechRecognizer.swift
//  Lemon
//
//  Created by Andre Pham on 11/6/2023.
//

import Foundation
import Speech

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
