//
//  CGRect.swift
//  Lemon
//
//  Created by Andre Pham on 14/6/2023.
//

import Foundation

extension CGRect {
    
    var center: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
    
    var area: CGFloat {
        return self.width*self.height
    }
    
    func scale(toAspectFillSize size: CGSize) -> CGRect {
        let aspectRatio = size.width / size.height
        let rectRatio = self.width / self.height
        
        var scale: CGFloat = 1.0
        
        if aspectRatio > rectRatio {
            // Scale based on width
            scale = size.width / self.width
        } else {
            // Scale based on height
            scale = size.height / self.height
        }
        
        let scaledWidth = self.width * scale
        let scaledHeight = self.height * scale
        
        let x = self.origin.x - (scaledWidth - self.width) / 2
        let y = self.origin.y - (scaledHeight - self.height) / 2
        
        return CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
    }
    
}

extension Array where Element == CGRect {
    
    func unionAll() -> CGRect {
        guard !self.isEmpty else {
            return CGRect()
        }
        var result = self.first!
        for element in self { // Faster to merge first with first than to do other calculations e.g. drop first
            result = result.union(element)
        }
        return result
    }
    
}
