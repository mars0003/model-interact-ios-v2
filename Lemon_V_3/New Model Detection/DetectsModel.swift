//
//  DetectsModel.swift
//  Lemon
//
//  Created by Mohamed Asjad on 7/5/2024.
//

import Foundation
import CoreGraphics

protocol DetectsModel {
    
    var id: DetectorID { get }
    var objectDetectionDelegate: ModelDetectionDelegate? { get set }
    
    func makePrediction(on frame: CGImage)
    
}

