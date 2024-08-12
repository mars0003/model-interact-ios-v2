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
    var objectDetectionDelegate: ModelDetectionDeletegate? { get set }
    
    func makePrediction(on frame: CGImage)
    
}

