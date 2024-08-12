//
//  Angle.swift
//  Lemon
//
//  Created by Andre Pham on 17/7/2023.
//

import Foundation

struct Angle {
    
    public let radians: Float
    public var degrees: Float {
        return self.radians * 180.0 / .pi
    }
    
    init(radians: Float) {
        self.radians = radians
    }
    
    init(degrees: Float) {
        self.radians = degrees * .pi / 180.0
    }
    
    init(radians: Double) {
        self.radians = Float(radians)
    }
    
    init(degrees: Double) {
        self.radians = Float(degrees) * .pi / 180.0
    }
    
}
