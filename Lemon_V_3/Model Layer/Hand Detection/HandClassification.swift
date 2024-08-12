//
//  HandClassification.swift
//  Lemon
//
//  Created by Andre Pham on 14/7/2023.
//

import Foundation

class HandClassification {
    
    enum Label: String {
        case stop
        case background
    }
    
    public let label: Label
    public let confidence: Double
    
    init(label: String, confidence: Double) {
        guard let label = Label(rawValue: label) else {
            fatalError("String classification has no corresponding defined Label value")
        }
        self.label = label
        self.confidence = confidence
    }
    
    func toString() -> String {
        return "\(self.label.rawValue) \((self.confidence * 100.0).toString(decimalPlaces: 0))%"
    }
    
}
