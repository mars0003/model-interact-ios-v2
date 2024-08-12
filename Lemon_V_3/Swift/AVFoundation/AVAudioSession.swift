//
//  AVAudioSession.swift
//  Lemon
//
//  Created by Andre Pham on 11/6/2023.
//

import Foundation
import AVFoundation

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
