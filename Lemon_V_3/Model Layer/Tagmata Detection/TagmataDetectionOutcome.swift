//
//  TagmataDetectionOutcome.swift
//  Lemon
//
//  Created by Andre Pham on 29/6/2023.
//

import Foundation
import CoreGraphics

class TagmataDetectionOutcome {
    
    public let detectorID: DetectorID
    public let frameSize: CGSize
    private var tagmataDetectionStore = [TagmataClassification: [TagmataDetection]]()
    /// Keep track of weights so if a merge occurs twice the confidences don't become skewed towards latest additions
    private var classificationWeights = [TagmataClassification: Int]()
    public var tagmataDetections: [TagmataDetection] {
        var result = [TagmataDetection]()
        for tagmataDetectionArray in tagmataDetectionStore.values {
            result.append(contentsOf: tagmataDetectionArray)
        }
        return result
    }
    
    init(detectorID: DetectorID, frameSize: CGSize) {
        self.detectorID = detectorID
        self.frameSize = frameSize
        for classification in TagmataClassification.allCases {
            self.tagmataDetectionStore[classification] = [TagmataDetection]()
            self.classificationWeights[classification] = 0
        }
    }
    
    convenience init(detectorID: DetectorID, frameSize: CGSize, detections: [TagmataDetection]) {
        self.init(detectorID: detectorID, frameSize: frameSize)
        for detection in detections {
            self.addDetection(detection)
        }
    }
    
    func addDetection(_ detection: TagmataDetection) {
        self.tagmataDetectionStore[detection.classification]!.append(detection)
        self.classificationWeights[detection.classification]! += 1
    }
    
    func merge() {
        for detectionsToMerge in self.tagmataDetectionStore.values {
            guard !detectionsToMerge.isEmpty else {
                continue
            }
            let boundingBoxesToMerge = detectionsToMerge.map({ $0.boundingBox })
            let confidencesToMerge = detectionsToMerge.map({ $0.confidence })
            let boundingBox = boundingBoxesToMerge.unionAll()
            let classification = detectionsToMerge.first!.classification
            let label = detectionsToMerge.first!.label
            let confidence = confidencesToMerge.reduce(0, +) / Float(self.classificationWeights[classification]!)
            let mergedDetection = TagmataDetection(
                boundingBox: boundingBox,
                label: label,
                classification: classification,
                confidence: confidence
            )
            // Replace entire array with array with just the merged detection
            self.tagmataDetectionStore[mergedDetection.classification]! = [mergedDetection]
        }
    }
    
    func merged(with other: TagmataDetectionOutcome, newID: DetectorID, frameSize: CGSize) -> TagmataDetectionOutcome {
        let new = TagmataDetectionOutcome(detectorID: newID, frameSize: frameSize)
        self.tagmataDetections.forEach({ new.addDetection($0) })
        other.tagmataDetections.forEach({ new.addDetection($0) })
        new.merge()
        return new
    }
    
}
