//
//  ModelQuadrantDetection.swift
//  Lemon
//
//  Created by Mohamed Asjad on 7/5/2024.
//

import Foundation
import CoreGraphics

class ModelQuadrantDetection: DetectsModel, ModelDetectionDeletegate {
    
    var objectDetectionDelegate: ModelDetectionDeletegate?
    
    func onModelDetection(outcome: NewModelDetectionOutcome?) {
        guard let outcome = outcome else {
            self.quadrantProcessingCompletions += 1
            return
        }
        
        if outcome.detectorID.matches(self.modelDetectorFull.id) {
            self.onFullDetection(outcome)
        } else if outcome.detectorID.matches(self.modelDetectorQ1.id) {
            self.onQ1Detection(outcome)
        } else if outcome.detectorID.matches(self.modelDetectorQ2.id) {
            self.onQ2Detection(outcome)
        } else if outcome.detectorID.matches(self.modelDetectorQ3.id) {
            self.onQ3Detection(outcome)
        } else if outcome.detectorID.matches(self.modelDetectorQ4.id) {
            self.onQ4Detection(outcome)
        } else {
            fatalError("Outcome was received from an unknown detector")
        }
        
    }
    
    private static let QUARTILE_PROPORTION = 0.6
    
    public let id = DetectorID()
    private let modelDetectorFull: ModelDetector
    // Below follow the cartesian plane quadrants
    private let modelDetectorQ1: ModelDetector // Top-right
    private let modelDetectorQ2: ModelDetector // Top-left
    private let modelDetectorQ3: ModelDetector // Bottom-left
    private let modelDetectorQ4: ModelDetector // Bottom-right
    private lazy var allDetectors: [ModelDetector] = {
        return [self.modelDetectorFull, self.modelDetectorQ1, self.modelDetectorQ2, self.modelDetectorQ3, self.modelDetectorQ4]
    }()
    // Represent detector completions
    private var quadrantProcessingCompletions = 0 {
        didSet {
            if self.quadrantProcessingCompletions >= self.allDetectors.count, let outcome = self.outcome {
                self.objectDetectionDelegate?.onModelDetection(outcome: outcome)
                self.quadrantProcessingCompletions = 0
                self.outcome = nil
            }
        }
    }
    private var outcome: NewModelDetectionOutcome? = nil
    
    init(modelURL: URL) {
        self.modelDetectorFull = ModelDetector(mlModelFile: modelURL)
        self.modelDetectorQ1 = ModelDetector(mlModelFile: modelURL)
        self.modelDetectorQ2 = ModelDetector(mlModelFile: modelURL)
        self.modelDetectorQ3 = ModelDetector(mlModelFile: modelURL)
        self.modelDetectorQ4 = ModelDetector(mlModelFile: modelURL)
        
        self.allDetectors.forEach({ $0.objectDetectionDelegate = self })
    }
    
    func makePrediction(on frame: CGImage) {
        guard self.quadrantProcessingCompletions == 0 else {
            return
        }
        self.modelDetectorFull.makePrediction(on: frame)
        let width = CGFloat(frame.width)
        let height = CGFloat(frame.height)
        let quadrantWidth = width * Self.QUARTILE_PROPORTION
        let quadrantHeight = height * Self.QUARTILE_PROPORTION
        
        if let q1Frame = frame.cropping(to: CGRect(x: width * (1.0 - Self.QUARTILE_PROPORTION), y: 0.0, width: quadrantWidth, height: quadrantHeight)) {
            self.modelDetectorQ1.makePrediction(on: q1Frame)
        } else {
            self.quadrantProcessingCompletions += 1
            assertionFailure("Q1 Quadrant couldn't be cropped")
        }
        
        if let q2Frame = frame.cropping(to: CGRect(x: 0.0, y: 0.0, width: quadrantWidth, height: quadrantHeight)) {
            self.modelDetectorQ2.makePrediction(on: q2Frame)
        } else {
            self.quadrantProcessingCompletions += 1
            assertionFailure("Q2 Quadrant couldn't be cropped")
        }
        
        if let q3Frame = frame.cropping(to: CGRect(x: 0.0, y: height * (1.0 - Self.QUARTILE_PROPORTION), width: quadrantWidth, height: quadrantHeight)) {
            self.modelDetectorQ3.makePrediction(on: q3Frame)
        } else {
            self.quadrantProcessingCompletions += 1
            assertionFailure("Q3 Quadrant couldn't be cropped")
        }
        
        if let q4Frame = frame.cropping(to: CGRect(x: width * (1.0 - Self.QUARTILE_PROPORTION), y: height * (1.0 - Self.QUARTILE_PROPORTION), width: quadrantWidth, height: quadrantHeight)) {
            self.modelDetectorQ4.makePrediction(on: q4Frame)
        } else {
            self.quadrantProcessingCompletions += 1
            assertionFailure("Q4 Quadrant couldn't be cropped")
        }
    }
    
    private func onFullDetection(_ outcome: NewModelDetectionOutcome) {
        self.completeOutcome(outcome)
    }
    
    private func onQ1Detection(_ outcome: NewModelDetectionOutcome) {
        for detection in outcome.modelDetections {
            detection.resizeBoundingBox(minX: 0.4, minY: 0.4, maxX: 1.0, maxY: 1.0)
        }
        self.completeOutcome(outcome)
    }
    
    private func onQ2Detection(_ outcome: NewModelDetectionOutcome) {
        for detection in outcome.modelDetections {
            detection.resizeBoundingBox(minX: 0.0, minY: 0.4, maxX: 0.6, maxY: 1.0)
        }
        self.completeOutcome(outcome)
    }
    
    private func onQ3Detection(_ outcome: NewModelDetectionOutcome) {
        for detection in outcome.modelDetections {
            detection.resizeBoundingBox(minX: 0.0, minY: 0.0, maxX: 0.6, maxY: 0.6)
        }
        self.completeOutcome(outcome)
    }
    
    private func onQ4Detection(_ outcome: NewModelDetectionOutcome) {
        for detection in outcome.modelDetections {
            detection.resizeBoundingBox(minX: 0.4, minY: 0.0, maxX: 1.0, maxY: 0.6)
        }
        self.completeOutcome(outcome)
    }
    
    private func completeOutcome(_ outcome: NewModelDetectionOutcome) {
        if let currentOutcome = self.outcome {
            let frameSize = outcome.detectorID.matches(self.modelDetectorFull.id) ? outcome.frameSize : currentOutcome.frameSize
            self.outcome = currentOutcome.merged(with: outcome, newID: self.id, frameSize: frameSize)
        } else {
            self.outcome = outcome
        }
        self.quadrantProcessingCompletions += 1
    }
    
}
