//
//  CaptureDelegate.swift
//  Lemon
//
//  Created by Andre Pham on 14/6/2023.
//

import Foundation
import CoreVideo

protocol CaptureDelegate: AnyObject {
    
    func onCapture(session: CaptureSession, frame: CGImage?)
    
}
