//
//  HandDetector.swift
//  Lemon
//
//  Created by Andre Pham on 7/7/2023.
//

import Foundation
import UIKit
import Vision

class HandDetector {
    
    private static let MAX_THREADS = 3
    
    private typealias HandDetectorModel = HandDetector2_70
    private var activeThreads = 0
    
    private var model: HandDetectorModel? = nil
    public weak var handDetectionDelegate: HandDetectionDelegate?
    
    init() {
        self.setupModel()
    }
    
    private func setupModel() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            self.model = try? HandDetectorModel(configuration: MLModelConfiguration())
        }
    }
    
    func makePrediction(on frame: CGImage) {
        guard self.activeThreads < Self.MAX_THREADS else {
            return
        }
        self.activeThreads += 1
        // Run on non-UI related background thread
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            self.process(frame: frame)
        }
    }
    
    private func process(frame: CGImage) {
        assert(!Thread.isMainThread, "Predictions should be made off the main thread")
        
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 2
        handPoseRequest.revision = VNDetectHumanHandPoseRequestRevision1
        
        let handler = VNImageRequestHandler(cgImage: frame, orientation: .up)
        do {
            try handler.perform([handPoseRequest])
        } catch {
            assertionFailure("Handler failed with error: \(error)")
        }
        
        let handDetectionOutcome = HandDetectionOutcome()
        guard let handPoses = handPoseRequest.results, !handPoses.isEmpty else {
            self.delegateOutcome(handDetectionOutcome)
            return
        }
        for handPose in handPoses {
            let handDetection = self.getHandDetection(from: handPose)
            handDetectionOutcome.addHandDetection(handDetection)
        }
        self.delegateOutcome(handDetectionOutcome)
    }
    
    func getHandDetection(from observation: VNHumanHandPoseObservation) -> HandDetection {
        assert(!Thread.isMainThread, "Recognition should be made off the main thread")
        let handDetection = HandDetection()
        // 1. Chirality
        handDetection.setChirality(to: observation.chirality)
        // 2. Classification
        if let classification = self.getHandClassification(handPose: observation) {
            handDetection.setHandClassification(to: classification)
        }
        // 3. Joint positions
        guard let recognisedPoints = try? observation.recognizedPoints(.all) else {
            return handDetection
        }
        for point in recognisedPoints {
            let jointPosition = handDetection.retrievePosition(from: point.key)
            jointPosition.position = CGPoint(x: point.value.location.x, y: point.value.location.y)
            jointPosition.confidence = point.value.confidence.magnitude
        }
        return handDetection
    }
    
    func getHandClassification(handPose: VNHumanHandPoseObservation) -> HandClassification? {
        guard let keyPointsMultiArray = try? handPose.keypointsMultiArray() else {
            return nil
        }
        guard let model = self.model else {
            self.setupModel()
            return nil
        }
        let prediction = try? model.prediction(poses: keyPointsMultiArray)
        if let label = prediction?.label, let confidence = prediction?.labelProbabilities[label] {
            return HandClassification(label: label, confidence: confidence)
        }
        return nil
    }
    
    private func delegateOutcome(_ outcome: HandDetectionOutcome) {
        // Jump back to main thread
        DispatchQueue.main.async {
            self.activeThreads -= 1
            self.handDetectionDelegate?.onHandDetection(outcome: outcome)
        }
    }
    
}
