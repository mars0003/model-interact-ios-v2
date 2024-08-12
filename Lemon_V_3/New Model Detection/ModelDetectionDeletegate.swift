//
//  ModelDetectionDeletegate.swift
//  Lemon
//
//  Created by Mohamed Asjad on 7/5/2024.
//



import Foundation
import Vision

protocol ModelDetectionDeletegate: AnyObject {
    
    func onModelDetection(outcome: NewModelDetectionOutcome?)
    
}
