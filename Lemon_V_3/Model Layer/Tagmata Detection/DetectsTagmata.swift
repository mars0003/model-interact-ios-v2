//
//  DetectsTagmata.swift
//  Lemon
//
//  Created by Andre Pham on 30/6/2023.
//

import Foundation
import CoreGraphics

protocol DetectsTagmata {
    
    var id: DetectorID { get }
    var objectDetectionDelegate: TagmataDetectionDelegate? { get set }
    
    func makePrediction(on frame: CGImage)
    
}
