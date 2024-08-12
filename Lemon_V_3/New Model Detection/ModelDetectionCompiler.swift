//
//  NewDetectionCompiler.swift
//  Lemon_V_3
//
//  Created by Mohamed Asjad on 24/7/2024.
//

import Foundation

class ModelDetectionCompiler {

    typealias HeldModel = (
        held: [ModelClassification],     // Model being held
        maybeHeld: [ModelClassification], // Model maybe being held (close proximity to a hand)
        handsUsed: Int                    // Number of hands used to hold unique tagmata
    )

    private static let DETECTION_BATCH_SIZE = 30
    private static let DETECTION_THRESHOLD = 12
    private static let COMPLETION_THRESHOLD = 15

    private var compiledModelOutcomes = [NewModelDetectionOutcome]()
    private var compiledHandOutcomes = [HandDetectionOutcome]()
    private var results = ModelCompiledResults()
    private(set) var newResultsReady = false

    func clearOutcomes() {
        self.compiledModelOutcomes.removeAll()
        self.compiledHandOutcomes.removeAll()
    }

    func addOutcome(_ modelOutcome: NewModelDetectionOutcome, handOutcome: HandDetectionOutcome) {
        self.compiledModelOutcomes.append(modelOutcome)
        self.compiledHandOutcomes.append(handOutcome)
        let results = self.compileResults(detectionThreshold: Self.DETECTION_THRESHOLD)
        let detectionsFound = !results.hasNoDetections
        let unsureAboutCompletion = (!results.modelIsComplete && isGreaterZero(results.completionConfidence))
        let resultsAreReady = detectionsFound && !unsureAboutCompletion
        let thresholdReached = self.compiledModelOutcomes.count >= Self.DETECTION_BATCH_SIZE
        if resultsAreReady || thresholdReached {
            self.publishResults(results)
        } else if self.compiledModelOutcomes.count > Self.DETECTION_BATCH_SIZE - Self.DETECTION_THRESHOLD {
            let earlyThreshold = self.compiledModelOutcomes.count + Self.DETECTION_THRESHOLD - Self.DETECTION_BATCH_SIZE
            let earlyResults = self.compileResults(detectionThreshold: earlyThreshold)
            if earlyResults.hasNoDetections {
                self.publishResults(earlyResults)
            }
        }
    }

    func retrieveResults() -> ModelCompiledResults {
        self.newResultsReady = false
        return self.results
    }

    private func publishResults(_ results: ModelCompiledResults) {
        self.compiledModelOutcomes.removeAll()
        self.compiledHandOutcomes.removeAll()
        self.results = results
        self.newResultsReady = true
    }

    private func compileResults(detectionThreshold: Int) -> ModelCompiledResults {
        var tally = [String: Int]() // Use `name` for tallying
        for outcome in self.compiledModelOutcomes {
            for detection in outcome.modelDetections {
                tally[detection.classification.name, default: 0] += 1
            }
        }

        var results = [ModelClassification]()
        for (name, total) in tally {
            if total >= detectionThreshold {
                // Retrieve the classification from a local store or database
                if let classification = self.getClassificationByName(name: name) {
                    results.append(classification)
                }
            }
        }

        var heldResults = [ModelClassification]()
        var maybeHeldResults = [ModelClassification]()
        var handsUsedResults = [Int]()
        for index in 0..<self.compiledModelOutcomes.count {
            let tagmataOutcome = self.compiledModelOutcomes[index]
            let handOutcome = self.compiledHandOutcomes[index]
            let beingHeld = self.findModelBeingHeld(
                modelDetectionOutcome: tagmataOutcome,
                handDetectionOutcome: handOutcome
            )
            heldResults.append(contentsOf: beingHeld.held)
            maybeHeldResults.append(contentsOf: beingHeld.maybeHeld)
            handsUsedResults.append(beingHeld.handsUsed)
        }

        var filteredHeldResults = [ModelClassification]()
        for heldResult in heldResults {
            if results.contains(where: { $0.name == heldResult.name }) {
                filteredHeldResults.append(heldResult)
            }
        }

        var filteredMaybeHeldResults = [ModelClassification]()
        for maybeHeldResult in maybeHeldResults {
            if results.contains(where: { $0.name == maybeHeldResult.name }) {
                filteredMaybeHeldResults.append(maybeHeldResult)
            }
        }

        let sortedHandsUsed = handsUsedResults.groupAndSort(reverseOrder: true)
        var handsUsed = sortedHandsUsed.first?.first ?? 0
        for group in sortedHandsUsed {
            assert(group.count > 0, "Every group generated should have more than 0 elements")
            if group.count >= detectionThreshold {
                handsUsed = group.first ?? handsUsed
                break
            }
        }

        let compiledHeldModel = filteredHeldResults.filterDuplicates()
        let compiledMaybeHeldModel = filteredMaybeHeldResults.filterDuplicates()
        let compiledHandsUsed = min(handsUsed, compiledHeldModel.count)
        return ModelCompiledResults(
            detectedModel: results,
            heldModel: compiledHeldModel,
            maybeHeldModel: compiledMaybeHeldModel,
            handsUsed: compiledHandsUsed,
            modelIsComplete: results.isEmpty,
            completionConfidence: 0.0 // Since `detectInsectCompletion` is not used
        )
    }

    private func findModelBeingHeld(
        modelDetectionOutcome: NewModelDetectionOutcome,
        handDetectionOutcome: HandDetectionOutcome
    ) -> HeldModel {
        if modelDetectionOutcome.modelDetections.isEmpty {
            return HeldModel(held: [], maybeHeld: [], handsUsed: 0)
        }
        let frameWidth = modelDetectionOutcome.frameSize.width
        let frameHeight = modelDetectionOutcome.frameSize.height
        let modelClassifications = modelDetectionOutcome.modelDetections.map { $0.classification }
        let modelPositions = modelDetectionOutcome.modelDetections.map {
            $0.getDenormalisedCenter(boundsWidth: frameWidth, boundsHeight: frameHeight)
        }
        var result = HeldModel(held: [], maybeHeld: [], handsUsed: 0)
        let distanceThreshold = self.equivalentDistance(
            oldWidth: 504, oldHeight: 896, oldDistance: 80,
            newWidth: frameWidth, newHeight: frameHeight
        )
        for handDetection in handDetectionOutcome.handDetections {
            var heldModel = [ModelClassification]()
            let jointPositions = handDetection.holdingPositions
            for jointPosition in jointPositions {
                for modelIndex in 0..<modelClassifications.count {
                    let modelPosition = modelPositions[modelIndex]
                    let modelClassification = modelClassifications[modelIndex]
                    if let distance = jointPosition.getDenormalisedPosition(viewWidth: frameWidth, viewHeight: frameHeight)?.length(to: modelPosition),
                       isLess(distance, distanceThreshold) {
                        heldModel.append(modelClassification)
                    }
                }
            }
            if let mostCommon = heldModel.mostCommonElement() {
                result.held.append(mostCommon)
            }
            result.maybeHeld.append(contentsOf: heldModel)
        }
        result.held = result.held.filterDuplicates()
        result.maybeHeld = result.maybeHeld.filterDuplicates()
        result.handsUsed = result.held.count
        return result
    }

    private func equivalentDistance(
        oldWidth: Double,
        oldHeight: Double,
        oldDistance: Double,
        newWidth: Double,
        newHeight: Double
    ) -> Double {
        let oldDiagonal = sqrt(pow(oldWidth, 2) + pow(oldHeight, 2))
        let proportion = oldDistance / oldDiagonal
        let newDiagonal = sqrt(pow(newWidth, 2) + pow(newHeight, 2))
        let newDistance = proportion * newDiagonal
        return newDistance
    }

    // Helper to get classification by name (Implement this based on your data store)
    private func getClassificationByName(name: String) -> ModelClassification? {
        // Implement logic to fetch ModelClassification from your data store or cache
        // Example:
        return FirebaseManager.shared.parts.first { $0.name == name }
    }
}
