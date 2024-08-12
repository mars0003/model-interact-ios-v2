//
//  TagmataDetection.swift
//  Lemon
//
//  Created by Andre Pham on 14/6/2023.
//

import Foundation
import Vision
import UIKit

class TagmataDetection {
    
    private(set) var boundingBox: CGRect
    public let label: String
    public let classification: TagmataClassification
    public let confidence: Float
    
    init(observation: VNRecognizedObjectObservation) {
        self.boundingBox = observation.boundingBox
        self.label = observation.labels.first!.identifier
        guard let classification = TagmataClassification(rawValue: self.label) else {
            fatalError("Classification found has no corresponding enum case")
        }
        self.classification = classification
        self.confidence = observation.confidence.magnitude
    }
    
    init(boundingBox: CGRect, label: String, classification: TagmataClassification, confidence: Float) {
        self.boundingBox = boundingBox
        self.label = label
        self.classification = classification
        self.confidence = confidence
    }
    
    func getDenormalisedBoundingBox(boundsWidth: Double, boundsHeight: Double) -> CGRect {
        let scale = CGAffineTransform.identity.scaledBy(x: boundsWidth, y: boundsHeight)
        let reflection = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
        let rect = self.boundingBox.applying(reflection).applying(scale)
        return rect
    }
    
    func getDenormalisedBoundingBox(for view: UIView) -> CGRect {
        return self.getDenormalisedBoundingBox(boundsWidth: view.bounds.width, boundsHeight: view.bounds.height)
    }
    
    func getDenormalisedCenter(boundsWidth: Double, boundsHeight: Double) -> CGPoint {
        return self.getDenormalisedBoundingBox(boundsWidth: boundsWidth, boundsHeight: boundsHeight).center
    }
    
    func getDenormalisedCenter(for view: UIView) -> CGPoint {
        return self.getDenormalisedBoundingBox(for: view).center
    }
    
    /// Resize the bounding box relative to new bounds.
    /// - Parameters:
    ///   - minX: The normalised minimum x, e.g. 0.5 is half way through the bounds
    ///   - minY: The normalised minimum y, e.g. 0.5 is half way through the bounds
    ///   - maxX: The normalised maximum x, e.g. 1.0 is the end of the bounds
    ///   - maxY: The normalised maximum y, e.g. 1.0 is the end of the bounds
    func resizeBoundingBox(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        self.boundingBox = CGRect(
            x: minX + self.boundingBox.origin.x*(maxX - minX),
            y: minY + self.boundingBox.origin.y*(maxY - minY),
            width: (maxX - minX)*self.boundingBox.width,
            height: (maxY - minY)*self.boundingBox.height
        )
    }
    
}
