//
//  NewModelDetectionOutcome.swift
//  Lemon_V_3
//
//  Created by Mohamed Asjad on 24/7/2024.
//

import Foundation
import CoreGraphics

class NewModelDetectionOutcome {
    
    public let detectorID: DetectorID
    public let frameSize: CGSize
    private var modelDetectionStore = [ModelClassification: [NewModelDetection]]()
    private var classificationWeights = [ModelClassification: Int]()
    public var modelDetections: [NewModelDetection] {
        var result = [NewModelDetection]()
        for modelDetectionArray in modelDetectionStore.values {
            result.append(contentsOf: modelDetectionArray)
        }
        return result
    }
    
    init(detectorID: DetectorID, frameSize: CGSize, classifications: [ModelClassification]) {
        self.detectorID = detectorID
        self.frameSize = frameSize
        for classification in classifications {
            self.modelDetectionStore[classification] = [NewModelDetection]()
            self.classificationWeights[classification] = 0
        }
    }
    
    convenience init(detectorID: DetectorID, frameSize: CGSize, detections: [NewModelDetection], classifications: [ModelClassification]) {
        self.init(detectorID: detectorID, frameSize: frameSize, classifications: classifications)
        for detection in detections {
            self.addDetection(detection)
        }
    }
    
    func addDetection(_ detection: NewModelDetection) {
        guard let _ = self.modelDetectionStore[detection.classification] else {
            fatalError("Unknown classification")
        }
        self.modelDetectionStore[detection.classification]!.append(detection)
        self.classificationWeights[detection.classification]! += 1
    }
    
    func merge() {
        for detectionsToMerge in self.modelDetectionStore.values {
            guard !detectionsToMerge.isEmpty else {
                continue
            }
            let boundingBoxesToMerge = detectionsToMerge.map({ $0.boundingBox })
            let confidencesToMerge = detectionsToMerge.map({ $0.confidence })
            let boundingBox = boundingBoxesToMerge.unionAll()
            let classification = detectionsToMerge.first!.classification
            let label = detectionsToMerge.first!.label
            let confidence = confidencesToMerge.reduce(0, +) / Float(self.classificationWeights[classification]!)
            let mergedDetection = NewModelDetection(
                boundingBox: boundingBox,
                label: label,
                classification: classification,
                confidence: confidence
            )
            // Replace entire array with array with just the merged detection
            self.modelDetectionStore[mergedDetection.classification]! = [mergedDetection]
        }
    }
    
    func merged(with other: NewModelDetectionOutcome, newID: DetectorID, frameSize: CGSize) -> NewModelDetectionOutcome {
        let new = NewModelDetectionOutcome(detectorID: newID, frameSize: frameSize, classifications: Array(self.modelDetectionStore.keys))
        self.modelDetections.forEach({ new.addDetection($0) })
        other.modelDetections.forEach({ new.addDetection($0) })
        new.merge()
        return new
    }
    
}
