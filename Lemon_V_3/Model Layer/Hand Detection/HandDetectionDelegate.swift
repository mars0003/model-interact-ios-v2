//
//  HandDetectionDelegate.swift
//  Lemon
//
//  Created by Andre Pham on 7/7/2023.
//

import Foundation

protocol HandDetectionDelegate: AnyObject {
    
    func onHandDetection(outcome: HandDetectionOutcome?)
    
}
