//
//  TagmataDetectionDelegate.swift
//  Lemon
//
//  Created by Andre Pham on 14/6/2023.
//

import Foundation
import Vision

protocol TagmataDetectionDelegate: AnyObject {
    
    func onTagmataDetection(outcome: TagmataDetectionOutcome?)
    
}
