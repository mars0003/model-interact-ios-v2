//
//  CGFloat.swift
//  Lemon
//
//  Created by Andre Pham on 30/6/2023.
//

import Foundation

extension CGFloat {
    
    func toString(decimalPlaces: Int = 2) -> String {
        return NSString(format: "%.\(decimalPlaces)f" as NSString, self) as String
    }
    
}
