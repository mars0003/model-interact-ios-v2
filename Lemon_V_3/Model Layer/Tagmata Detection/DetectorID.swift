//
//  DetectorID.swift
//  Lemon
//
//  Created by Andre Pham on 29/6/2023.
//

import Foundation

struct DetectorID {
    
    private let id = UUID()
    public var idString: String {
        return self.id.uuidString
    }
    
    func matches(_ other: DetectorID) -> Bool {
        return self.id == other.id
    }
    
}
