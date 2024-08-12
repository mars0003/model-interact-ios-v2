////
////  WaterCycleQuadrantDetector.swift
////  Lemon
////
////  Created by Mohamed Asjad on 1/5/2024.
////
//
//import Foundation
//import CoreGraphics
//
//class WaterCycleQuadrantDetector: DetectsWaterCycle, WaterCycleDetectionDelegate {
//    
//    var objectDetectionDelegate: WaterCycleDetectionDelegate?
//    
//    private static let QUARTILE_PROPORTION = 0.6
//    
//    public let id = DetectorID()
//    private let waterCycleDetectorFull = WaterCycleDetector()
//    // Below follow the cartesian plane quadrants
//    private let waterCycleDetectorQ1 = WaterCycleDetector() // Top-right
//    private let waterCycleDetectorQ2 = WaterCycleDetector() // Top-left
//    private let waterCycleDetectorQ3 = WaterCycleDetector() // Bottom-left
//    private let waterCycleDetectorQ4 = WaterCycleDetector() // Bottom-right
//    private lazy var allDetectors: [WaterCycleDetector] = {
//        return [self.waterCycleDetectorFull, self.waterCycleDetectorQ1, self.waterCycleDetectorQ2, self.waterCycleDetectorQ3, self.waterCycleDetectorQ4]
//    }()
//    // Represent detector completions
//    private var quadrantProcessingCompletions = 0 {
//        didSet {
//            if self.quadrantProcessingCompletions >= self.allDetectors.count, let outcome = self.outcome {
//                self.objectDetectionDelegate?.onWaterCycleDetection(outcome: outcome)
//                self.quadrantProcessingCompletions = 0
//                self.outcome = nil
//            }
//        }
//    }
//    private var outcome: WaterCycleDetectionOutcome? = nil
//    
//    init() {
//        self.allDetectors.forEach({ $0.objectDetectionDelegate = self })
//    }
//    
//    func makePrediction(on frame: CGImage) {
//        guard self.quadrantProcessingCompletions == 0 else {
//            return
//        }
//        self.waterCycleDetectorFull.makePrediction(on: frame)
//        let width = CGFloat(frame.width)
//        let height = CGFloat(frame.height)
//        let quadrantWidth = width * Self.QUARTILE_PROPORTION
//        let quadrantHeight = height * Self.QUARTILE_PROPORTION
//        
//        if let q1Frame = frame.cropping(to: CGRect(x: width * (1.0 - Self.QUARTILE_PROPORTION), y: 0.0, width: quadrantWidth, height: quadrantHeight)) {
//            self.waterCycleDetectorQ1.makePrediction(on: q1Frame)
//        } else {
//            self.quadrantProcessingCompletions += 1
//            assertionFailure("Q1 Quadrant couldn't be cropped")
//        }
//        
//        if let q2Frame = frame.cropping(to: CGRect(x: 0.0, y: 0.0, width: quadrantWidth, height: quadrantHeight)) {
//            self.waterCycleDetectorQ2.makePrediction(on: q2Frame)
//        } else {
//            self.quadrantProcessingCompletions += 1
//            assertionFailure("Q2 Quadrant couldn't be cropped")
//        }
//        
//        if let q3Frame = frame.cropping(to: CGRect(x: 0.0, y: height * (1.0 - Self.QUARTILE_PROPORTION), width: quadrantWidth, height: quadrantHeight)) {
//            self.waterCycleDetectorQ3.makePrediction(on: q3Frame)
//        } else {
//            self.quadrantProcessingCompletions += 1
//            assertionFailure("Q3 Quadrant couldn't be cropped")
//        }
//        
//        if let q4Frame = frame.cropping(to: CGRect(x: width * (1.0 - Self.QUARTILE_PROPORTION), y: height * (1.0 - Self.QUARTILE_PROPORTION), width: quadrantWidth, height: quadrantHeight)) {
//            self.waterCycleDetectorQ4.makePrediction(on: q4Frame)
//        } else {
//            self.quadrantProcessingCompletions += 1
//            assertionFailure("Q4 Quadrant couldn't be cropped")
//        }
//    }
//    
//    func onWaterCycleDetection(outcome: WaterCycleDetectionOutcome?) {
//        guard let outcome = outcome else {
//            self.quadrantProcessingCompletions += 1
//            return
//        }
//        
//        if outcome.detectorID.matches(self.waterCycleDetectorFull.id) {
//            self.onFullDetection(outcome)
//        } else if outcome.detectorID.matches(self.waterCycleDetectorQ1.id) {
//            self.onQ1Detection(outcome)
//        } else if outcome.detectorID.matches(self.waterCycleDetectorQ2.id) {
//            self.onQ2Detection(outcome)
//        } else if outcome.detectorID.matches(self.waterCycleDetectorQ3.id) {
//            self.onQ3Detection(outcome)
//        } else if outcome.detectorID.matches(self.waterCycleDetectorQ4.id) {
//            self.onQ4Detection(outcome)
//        } else {
//            fatalError("Outcome was received from an unknown detector")
//        }
//    }
//    
//    private func onFullDetection(_ outcome: WaterCycleDetectionOutcome) {
//        self.completeOutcome(outcome)
//    }
//    
//    private func onQ1Detection(_ outcome: WaterCycleDetectionOutcome) {
//        for detection in outcome.waterCycleDetections {
//            detection.resizeBoundingBox(minX: 0.4, minY: 0.4, maxX: 1.0, maxY: 1.0)
//        }
//        self.completeOutcome(outcome)
//    }
//    
//    private func onQ2Detection(_ outcome: WaterCycleDetectionOutcome) {
//        for detection in outcome.waterCycleDetections {
//            detection.resizeBoundingBox(minX: 0.0, minY: 0.4, maxX: 0.6, maxY: 1.0)
//        }
//        self.completeOutcome(outcome)
//    }
//    
//    private func onQ3Detection(_ outcome: WaterCycleDetectionOutcome) {
//        for detection in outcome.waterCycleDetections {
//            detection.resizeBoundingBox(minX: 0.0, minY: 0.0, maxX: 0.6, maxY: 0.6)
//        }
//        self.completeOutcome(outcome)
//    }
//    
//    private func onQ4Detection(_ outcome: WaterCycleDetectionOutcome) {
//        for detection in outcome.waterCycleDetections {
//            detection.resizeBoundingBox(minX: 0.4, minY: 0.0, maxX: 1.0, maxY: 0.6)
//        }
//        self.completeOutcome(outcome)
//    }
//    
//    private func completeOutcome(_ outcome: WaterCycleDetectionOutcome) {
//        if let currentOutcome = self.outcome {
//            let frameSize = outcome.detectorID.matches(self.waterCycleDetectorFull.id) ? outcome.frameSize : currentOutcome.frameSize
//            self.outcome = currentOutcome.merged(with: outcome, newID: self.id, frameSize: frameSize)
//        } else {
//            self.outcome = outcome
//        }
//        self.quadrantProcessingCompletions += 1
//    }
//    
//}
