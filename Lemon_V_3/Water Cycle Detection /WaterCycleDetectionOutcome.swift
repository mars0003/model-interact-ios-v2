////
////  WaterCycleDetectionOutcome.swift
////  Lemon
////
////  Created by Mohamed Asjad on 1/5/2024.
////
//import Foundation
//import CoreGraphics
//
//class WaterCycleDetectionOutcome {
//    
//    public let detectorID: DetectorID
//    public let frameSize: CGSize
//    private var waterCycleDetectionStore = [WaterCycleClassification: [WaterCycleDetection]]()
//    /// Keep track of weights so if a merge occurs twice the confidences don't become skewed towards latest additions
//    private var classificationWeights = [WaterCycleClassification: Int]()
//    public var waterCycleDetections: [WaterCycleDetection] {
//        var result = [WaterCycleDetection]()
//        for waterCycleDetectionArray in waterCycleDetectionStore.values {
//            result.append(contentsOf: waterCycleDetectionArray)
//        }
//        return result
//    }
//    
//    init(detectorID: DetectorID, frameSize: CGSize) {
//        self.detectorID = detectorID
//        self.frameSize = frameSize
//        for classification in WaterCycleClassification.allCases {
//            self.waterCycleDetectionStore[classification] = [WaterCycleDetection]()
//            self.classificationWeights[classification] = 0
//        }
//    }
//    
//    convenience init(detectorID: DetectorID, frameSize: CGSize, detections: [WaterCycleDetection]) {
//        self.init(detectorID: detectorID, frameSize: frameSize)
//        for detection in detections {
//            self.addDetection(detection)
//        }
//    }
//    
//    func addDetection(_ detection: WaterCycleDetection) {
//        self.waterCycleDetectionStore[detection.classification]!.append(detection)
//        self.classificationWeights[detection.classification]! += 1
//    }
//    
//    func merge() {
//        for detectionsToMerge in self.waterCycleDetectionStore.values {
//            guard !detectionsToMerge.isEmpty else {
//                continue
//            }
//            let boundingBoxesToMerge = detectionsToMerge.map({ $0.boundingBox })
//            let confidencesToMerge = detectionsToMerge.map({ $0.confidence })
//            let boundingBox = boundingBoxesToMerge.unionAll()
//            let classification = detectionsToMerge.first!.classification
//            let label = detectionsToMerge.first!.label
//            let confidence = confidencesToMerge.reduce(0, +) / Float(self.classificationWeights[classification]!)
//            let mergedDetection = WaterCycleDetection(
//                boundingBox: boundingBox,
//                label: label,
//                classification: classification,
//                confidence: confidence
//            )
//            // Replace entire array with array with just the merged detection
//            self.waterCycleDetectionStore[mergedDetection.classification]! = [mergedDetection]
//        }
//    }
//    
//    func merged(with other: WaterCycleDetectionOutcome, newID: DetectorID, frameSize: CGSize) -> WaterCycleDetectionOutcome {
//        let new = WaterCycleDetectionOutcome(detectorID: newID, frameSize: frameSize)
//        self.waterCycleDetections.forEach({ new.addDetection($0) })
//        other.waterCycleDetections.forEach({ new.addDetection($0) })
//        new.merge()
//        return new
//    }
//    
//}
//
