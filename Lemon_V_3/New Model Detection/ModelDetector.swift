//
//  ModelDetector.swift
//  Lemon
//
//  Created by Mohamed Asjad on 7/5/2024.
//

import Foundation
import Vision

class ModelDetector: DetectsModel {
    
    private static let MAX_THREADS = 3
    
    public let id = DetectorID()
    private var visionModel: VNCoreMLModel? = nil
    private var request: VNCoreMLRequest? = nil
    var objectDetectionDelegate: ModelDetectionDelegate?
    private var activeThreads = 0
    private let firebaseManager = FirebaseManager.shared // Use the shared instance

    // Updated init to take modelFile and modelName
    init(mlModelFile: URL, modelName: String) {
        self.setupModel(from: mlModelFile)
        firebaseManager.modelName = modelName
    }
    
    func makePrediction(on frame: CGImage) {
        guard self.activeThreads < Self.MAX_THREADS else {
            return
        }
        self.activeThreads += 1
        fetchClassificationsAndPredict(frame: frame)
    }
    
    private func fetchClassificationsAndPredict(frame: CGImage) {
        firebaseManager.fetchParts { [weak self] parts in
            guard let self = self else { return }
            self.process(frame: frame, classifications: parts)
        }
    }
    
    private func process(frame: CGImage, classifications: [ModelClassification]) {
//        assert(!Thread.isMainThread, "Predictions should be made off the main thread")
        guard let request = self.createRequest() else {
            self.delegateOutcome(nil)
            return
        }
        
        let handler = VNImageRequestHandler(cgImage: frame)
        do {
            try handler.perform([request])
        } catch {
            assertionFailure("Handler failed with error: \(error)")
        }
        
        if let predictions = request.results as? [VNRecognizedObjectObservation] {
            let detection = NewModelDetectionOutcome(
                detectorID: self.id,
                frameSize: CGSize(width: frame.width, height: frame.height),
                detections: predictions.map({ NewModelDetection(observation: $0, parts: classifications) }),
                classifications: classifications
            )
            detection.merge()
            self.delegateOutcome(detection)
        } else {
            self.delegateOutcome(nil)
        }
    }
    
    private func setupModel(from mlModelFile: URL) {
        do {
            let model = try MLModel(contentsOf: mlModelFile)
            self.visionModel = try VNCoreMLModel(for: model)
        } catch {
            print("Error loading ML model:", error)
        }
    }
    
    private func createRequest() -> VNCoreMLRequest? {
        guard let visionModel = self.visionModel else {
            print("Vision model is not set up.")
            return nil
        }
        let request = VNCoreMLRequest(model: visionModel)
        request.imageCropAndScaleOption = .scaleFit
        return request
    }
    
    private func delegateOutcome(_ outcome: NewModelDetectionOutcome?) {
        DispatchQueue.main.async {
            self.activeThreads -= 1
            self.objectDetectionDelegate?.onModelDetection(outcome: outcome)
        }
    }
}
