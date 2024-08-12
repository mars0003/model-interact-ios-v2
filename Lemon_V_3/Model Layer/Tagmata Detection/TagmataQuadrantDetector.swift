//
//  TagmataQuadrantDetector.swift
//  Lemon
//
//  Created by Andre Pham on 29/6/2023.
//

import Foundation
import CoreGraphics

class TagmataQuadrantDetector: DetectsTagmata, TagmataDetectionDelegate {
    
    private static let QUARTILE_PROPORTION = 0.6
    
    public let id = DetectorID()
    private let tagmataDetectorFull = TagmataDetector()
    // Below follow the cartesian plane quadrants
    private let tagmataDetectorQ1 = TagmataDetector() // Top-right
    private let tagmataDetectorQ2 = TagmataDetector() // Top-left
    private let tagmataDetectorQ3 = TagmataDetector() // Bottom-left
    private let tagmataDetectorQ4 = TagmataDetector() // Bottom-right
    private var allDetectors: [TagmataDetector] {
        return [self.tagmataDetectorFull, self.tagmataDetectorQ1, self.tagmataDetectorQ2, self.tagmataDetectorQ3, self.tagmataDetectorQ4]
    }
    // Represent detector completions
    private var quadrantProcessingCompletions = 0 {
        didSet {
            if self.quadrantProcessingCompletions >= self.allDetectors.count, let outcome {
                self.objectDetectionDelegate?.onTagmataDetection(outcome: outcome)
                self.quadrantProcessingCompletions = 0
                self.outcome = nil
            }
        }
    }
    private var outcome: TagmataDetectionOutcome? = nil
    public weak var objectDetectionDelegate: TagmataDetectionDelegate?
    
    init() {
        self.allDetectors.forEach({ $0.objectDetectionDelegate = self })
    }
    
    func makePrediction(on frame: CGImage) {
        guard self.quadrantProcessingCompletions == 0 else {
            return
        }
        self.tagmataDetectorFull.makePrediction(on: frame)
        let width = CGFloat(frame.width)
        let height = CGFloat(frame.height)
        let quadrantWidth = width*Self.QUARTILE_PROPORTION
        let quadrantHeight = height*Self.QUARTILE_PROPORTION
        if let q1Frame = frame.cropping(to: CGRect(
            x: width*(1.0 - Self.QUARTILE_PROPORTION), y: 0.0, width: quadrantWidth, height: quadrantHeight
        )) {
            self.tagmataDetectorQ1.makePrediction(on: q1Frame)
        } else {
            self.quadrantProcessingCompletions += 1
            assertionFailure("Q1 Quadrant couldn't be cropped")
        }
        if let q2Frame = frame.cropping(to: CGRect(
            x: 0.0, y: 0.0, width: quadrantWidth, height: quadrantHeight
        )) {
            self.tagmataDetectorQ2.makePrediction(on: q2Frame)
        } else {
            self.quadrantProcessingCompletions += 1
            assertionFailure("Q2 Quadrant couldn't be cropped")
        }
        if let q3Frame = frame.cropping(to: CGRect(
            x: 0.0, y: height*(1.0 - Self.QUARTILE_PROPORTION), width: quadrantWidth, height: quadrantHeight
        )) {
            self.tagmataDetectorQ3.makePrediction(on: q3Frame)
        } else {
            self.quadrantProcessingCompletions += 1
            assertionFailure("Q3 Quadrant couldn't be cropped")
        }
        if let q4Frame = frame.cropping(to: CGRect(
            x: width*(1.0 - Self.QUARTILE_PROPORTION), y: height*(1.0 - Self.QUARTILE_PROPORTION), width: quadrantWidth, height: quadrantHeight
        )) {
            self.tagmataDetectorQ4.makePrediction(on: q4Frame)
        } else {
            self.quadrantProcessingCompletions += 1
            assertionFailure("Q4 Quadrant couldn't be cropped")
        }
    }
    
    func onTagmataDetection(outcome: TagmataDetectionOutcome?) {
        guard let outcome else {
            self.quadrantProcessingCompletions += 1
            return
        }
        if outcome.detectorID.matches(self.tagmataDetectorFull.id) {
            self.onFullDetection(outcome)
        } else if outcome.detectorID.matches(self.tagmataDetectorQ1.id) {
            self.onQ1Detection(outcome)
        } else if outcome.detectorID.matches(self.tagmataDetectorQ2.id) {
            self.onQ2Detection(outcome)
        } else if outcome.detectorID.matches(self.tagmataDetectorQ3.id) {
            self.onQ3Detection(outcome)
        } else if outcome.detectorID.matches(self.tagmataDetectorQ4.id) {
            self.onQ4Detection(outcome)
        } else {
            fatalError("Outcome was received from unknown detector")
        }
    }
    
    func onFullDetection(_ outcome: TagmataDetectionOutcome) {
        self.completeOutcome(outcome)
    }
    
    func onQ1Detection(_ outcome: TagmataDetectionOutcome) {
        for detection in outcome.tagmataDetections {
            detection.resizeBoundingBox(minX: 0.4, minY: 0.4, maxX: 1.0, maxY: 1.0)
        }
        self.completeOutcome(outcome)
    }
    
    func onQ2Detection(_ outcome: TagmataDetectionOutcome) {
        for detection in outcome.tagmataDetections {
            detection.resizeBoundingBox(minX: 0.0, minY: 0.4, maxX: 0.6, maxY: 1.0)
        }
        self.completeOutcome(outcome)
    }
    
    func onQ3Detection(_ outcome: TagmataDetectionOutcome) {
        for detection in outcome.tagmataDetections {
            detection.resizeBoundingBox(minX: 0.0, minY: 0.0, maxX: 0.6, maxY: 0.6)
        }
        self.completeOutcome(outcome)
    }
    
    func onQ4Detection(_ outcome: TagmataDetectionOutcome) {
        for detection in outcome.tagmataDetections {
            detection.resizeBoundingBox(minX: 0.4, minY: 0.0, maxX: 1.0, maxY: 0.6)
        }
        self.completeOutcome(outcome)
    }
    
    private func completeOutcome(_ outcome: TagmataDetectionOutcome) {
        if let currentOutcome = self.outcome {
            let frameSize = outcome.detectorID.matches(self.tagmataDetectorFull.id) ? outcome.frameSize : currentOutcome.frameSize
            self.outcome = currentOutcome.merged(with: outcome, newID: self.id, frameSize: frameSize)
        } else {
            self.outcome = outcome
        }
        self.quadrantProcessingCompletions += 1
    }
    
}
