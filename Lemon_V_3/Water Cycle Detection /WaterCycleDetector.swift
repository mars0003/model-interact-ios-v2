////
////  WaterCycleDetector.swift
////  Lemon
////
////  Created by Mohamed Asjad on 1/5/2024.
////
//
//import Foundation
//import Vision
//
//class WaterCycleDetector: DetectsWaterCycle {
//    
//    
//    
//    
//    private static let MAX_THREADS = 3
//    
//    public let id = DetectorID()
//    private var visionModel: VNCoreMLModel? = nil
//    private var request: VNCoreMLRequest? = nil
//    var objectDetectionDelegate: WaterCycleDetectionDelegate?
//
//    private var activeThreads = 0
//    
//    init() {
//        self.setupModel()
//    }
//    
//    func makePrediction(on frame: CGImage) {
//        guard self.activeThreads < Self.MAX_THREADS else {
//            return
//        }
//        self.activeThreads += 1
//        // Run on non-UI related background thread
//        DispatchQueue.global(qos: .userInitiated).async { [self] in
//            self.process(frame: frame)
//        }
//    }
//    
//    private func process(frame: CGImage) {
//        assert(!Thread.isMainThread, "Predictions should be made off the main thread")
//        guard let request = self.createRequest() else {
//            self.delegateOutcome(nil)
//            return
//        }
//        
//        let handler = VNImageRequestHandler(cgImage: frame)
//        do {
//            try handler.perform([request])
//        } catch {
//            assertionFailure("Handler failed with error: \(error)")
//        }
//        
//        if let predictions = request.results as? [VNRecognizedObjectObservation] {
//            let detection = WaterCycleDetectionOutcome(
//                detectorID: self.id,
//                frameSize: CGSize(width: frame.width, height: frame.height),
//                detections: predictions.map({ WaterCycleDetection(observation: $0) })
//            )
//            detection.merge()
//            self.delegateOutcome(detection)
//        } else {
//            self.delegateOutcome(nil)
//        }
//    }
//    
//    private func setupModel() {
//        if let model = try? watercycle(configuration: MLModelConfiguration()).model {
//            self.visionModel = try? VNCoreMLModel(for: model)
//        }
//    }
//    
//    private func createRequest() -> VNCoreMLRequest? {
//        guard let visionModel else {
//            self.setupModel()
//            return nil
//        }
//        let request = VNCoreMLRequest(model: visionModel)
//        request.imageCropAndScaleOption = .scaleFit
//        return request
//    }
//    
//    private func delegateOutcome(_ outcome: WaterCycleDetectionOutcome?) {
//        // Jump back to main thread
//        DispatchQueue.main.async {
//            self.activeThreads -= 1
//            self.objectDetectionDelegate?.onWaterCycleDetection(outcome: outcome)
//        }
//    }
//    
//}
//
