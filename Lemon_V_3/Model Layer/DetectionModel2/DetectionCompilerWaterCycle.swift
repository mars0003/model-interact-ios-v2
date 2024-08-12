////
////  DetectionCompilerWaterCycle.swift
////  Lemon
////
////  Created by Ishrat Kaur on 11/5/2024.
////
//
//import Foundation
//
//
///// This is used to compile multiple model outputs into a single validated output.
///// For instance, if a tagma is partially visible and hence is flickering, we may not be sure if it's a random misidentification or not.
///// It's unsafe to assume that if a tagma is detected by the model within a single frame, it's 100% there and valid. We want to be more sure that it is indeed there.
///// Hence we compile many detections together (`DETECTION_BATCH_SIZE`). If a certain number (`DETECTION_THRESHOLD`) indicate they do indeed see something, we can be more confident that the something is indeed there and not an outlier misidentification.
///// This also means we don't instantly react to detections. If there's only one frame where a tagma is detected, we don't want to jump the gun and assume that we want to react to it.
//class DetectionCompilerWaterCycle {
//    
//    typealias HeldWaterCycle = (
//        // Water Cycle being held
//        held: [WaterCycleClassification],
//        // Tagmata maybe being held (close proximity to a hand)
//        maybeHeld: [WaterCycleClassification],
//        // The number of hands used to hold unique tagmata (two hands holding one or a hand holding none don't count)
//        handsUsed: Int
//    )
//    
//    /// How many detections (model outputs) until we compile results (whether there was something detected)
//    private static let DETECTION_BATCH_SIZE = 10
//    /// How many of the detections (model outputs) are needed to indicate that something indeed was detected
//    private static let DETECTION_THRESHOLD = 3
//    /// How many of the detections (where the model is complete) are needed to indicate that the model is indeed complete
//    private static let COMPLETION_THRESHOLD = 4
//    
//    /// All the water cycle detections to be used to produce the results
//    private var compiledWaterCycleOutcomes = [ModelDetectionOutcome]()
//    /// All the hand detections to be used to produce the results
//    private var compiledHandOutcomes = [HandDetectionOutcome]()
//    /// The results to be retrieved
//    private var results = CompiledResultsWaterCycle()
//    /// If new results are ready to be read (once retrieved, is toggled to false again)
//    private(set) var newResultsReady = false
//    
//    func clearOutcomes() {
//        self.compiledWaterCycleOutcomes.removeAll()
//        self.compiledHandOutcomes.removeAll()
//    }
//
//    func addOutcome(_ WaterCycleOutcome: ModelDetectionOutcome, handOutcome: HandDetectionOutcome) {
//        self.compiledWaterCycleOutcomes.append(WaterCycleOutcome)
//        self.compiledHandOutcomes.append(handOutcome)
//        let results = self.compileResults(detectionThreshold: Self.DETECTION_THRESHOLD)
//        let detectionsFound = !results.hasNoDetections
//        let unsureAboutCompletion = (
//            // The insect isn't yet registered as complete but there's a chance it becomes detected as complete
//            !results.WaterCycleIsComplete && isGreaterZero(results.completionConfidence)
//        )
//        let resultsAreReady = detectionsFound && !unsureAboutCompletion
//        let thresholdReached = self.compiledWaterCycleOutcomes.count >= Self.DETECTION_BATCH_SIZE
//        if resultsAreReady || thresholdReached {
//            self.publishResults(results)
//        } else if self.compiledWaterCycleOutcomes.count > Self.DETECTION_BATCH_SIZE - Self.DETECTION_THRESHOLD {
//            // Let's say you need to detect a tagma at least 4 times for it
//            // to be part of the results and our batch size is 10. If we've
//            // compiled 7 results then with a detection threshold of 1 if
//            // there are no results, we know for sure the final results
//            // will be empty, so we may as well abandon this compilation
//            // and restart early.
//            let earlyThreshold = self.compiledWaterCycleOutcomes.count + Self.DETECTION_THRESHOLD - Self.DETECTION_BATCH_SIZE
//            let earlyResults = self.compileResults(detectionThreshold: earlyThreshold)
//            if earlyResults.hasNoDetections {
//                self.publishResults(earlyResults)
//            }
//        }
//    }
//    
//    func retrieveResults() -> CompiledResultsWaterCycle {
//        self.newResultsReady = false
//        return self.results
//    }
//    
//    private func publishResults(_ results: CompiledResultsWaterCycle) {
//        self.compiledWaterCycleOutcomes.removeAll()
//        self.compiledHandOutcomes.removeAll()
//        self.results = results
//        self.newResultsReady = true
//    }
//    
//    private func compileResults(detectionThreshold: Int) -> CompiledResultsWaterCycle {
//        var tally = [WaterCycleClassification: Int]()
//        WaterCycleClassification.allCases.forEach({ tally[$0] = 0 })
//        
//        for outcome in self.compiledWaterCycleOutcomes {
//            for detection in outcome.modelDetections {
//                tally[detection.classification]! += 1
//            }
//        }
//        
//        var results = [WaterCycleClassification]()
//        for (classification, total) in tally {
//            if total >= detectionThreshold {
//                results.append(classification)
//            }
//        }
//        
//        var heldResults = [WaterCycleClassification]()
//        var maybeHeldResults = [WaterCycleClassification]()
//        var handsUsedResults = [Int]()
//        for index in 0..<self.compiledWaterCycleOutcomes.count {
//            let WaterCycleOutcome = self.compiledWaterCycleOutcomes[index]
//            let handOutcome = self.compiledHandOutcomes[index]
//            let beingHeld = self.findWaterCycleBeingHeld(
//                WaterCycleDetectionOutcome: WaterCycleOutcome,
//                handDetectionOutcome: handOutcome
//            )
//
//            heldResults.append(contentsOf: beingHeld.held)
//            maybeHeldResults.append(contentsOf: beingHeld.maybeHeld)
//            handsUsedResults.append(beingHeld.handsUsed)
//        }
//        var filteredHeldResults = [WaterCycleClassification]()
//        for heldResult in heldResults {
//            if results.contains(heldResult) {
//                filteredHeldResults.append(heldResult)
//            }
//        }
//        var filteredMaybeHeldResults = [WaterCycleClassification]()
//        for maybeHeldResult in maybeHeldResults {
//            if results.contains(maybeHeldResult) {
//                filteredMaybeHeldResults.append(maybeHeldResult)
//            }
//        }
//        // Here, we're validating the number of hands used
//        // If the number of hands used for each outcome goes [0, 1, 1, 1, 1, 1, 2] we don't want to just take the largest number
//        // We want to take the largest number (because detecting fake hands is very rare) that passes the threshold
//        // [0, 1, 1, 1, 1, 1, 2] -> We'd say 1 hand is used here
//        // [0, 1, 1, 1, 2, 2, 2] -> Okay, now we'd say 2 hands were used here
//        let sortedHandsUsed = handsUsedResults.groupAndSort(reverseOrder: true)
//        // We set the default to the first result, in case none pass the threshold
//        // [1, 2, 2] -> None pass the threshold, so we'd say 2 hands were used
//        // [0, 0, 0, 2, 2] -> Okay now that 0 passes the threshold, we can use 0
//        // Next line should never fail (self.compiledTagmataOutcomes.count would need to be 0), but just in case we default to 0
//        var handsUsed = sortedHandsUsed.first?.first ?? 0
//        for group in sortedHandsUsed {
//            assert(group.count > 0, "Every group generated should have more than 0 elements")
//            if group.count >= detectionThreshold {
//                handsUsed = group.first ?? handsUsed // Every element in every group should be the same
//                break
//            }
//        }
//        
//        var completionDetectionsCount = 0
//        for outcome in self.compiledWaterCycleOutcomes {
//            if self.detectInsectCompletion(for: outcome) {
//                completionDetectionsCount += 1
//            }
//        }
//        let insectIsComplete = completionDetectionsCount >= Self.COMPLETION_THRESHOLD
//        let completionConfidence = Double(completionDetectionsCount)/Double(self.compiledWaterCycleOutcomes.count)
//        
//        let compiledHeldTagmata = filteredHeldResults.filterDuplicates()
//        let compiledMaybeHeldTagmata = filteredMaybeHeldResults.filterDuplicates()
//        // Number of hands used can't be more than the actual amount of held tagmata
//        let compiledHandsUsed = min(handsUsed, compiledHeldTagmata.count)
//        return CompiledResultsWaterCycle(
//            detectedTagmata: results,
//            heldTagmata: compiledHeldTagmata,
//            maybeHeldTagmata: compiledMaybeHeldTagmata,
//            handsUsed: compiledHandsUsed,
//            insectIsComplete: insectIsComplete,
//            completionConfidence: completionConfidence
//        )
//    }
//    
//    private func findWaterCycleBeingHeld(
//        WaterCycleDetectionOutcome: ModelDetectionOutcome,
//        handDetectionOutcome: HandDetectionOutcome
//    ) -> HeldWaterCycle {
//        if WaterCycleDetectionOutcome.modelDetections.isEmpty {
//            return HeldWaterCycle(held: [], maybeHeld: [], handsUsed: 0)
//        }
//        let frameWidth = tagmataDetectionOutcome.frameSize.width
//        let frameHeight = tagmataDetectionOutcome.frameSize.height
//        let tagmataClassifications = tagmataDetectionOutcome.tagmataDetections.map({ $0.classification })
//        let tagmataPositions = tagmataDetectionOutcome.tagmataDetections.map({
//            $0.getDenormalisedCenter(boundsWidth: frameWidth, boundsHeight: frameHeight)
//        })
//        var result = HeldTagmata(held: [], maybeHeld: [], handsUsed: 0)
//        // Initially the distance threshold was empirically measured using a width/height of 504x896 and was found to be 80
//        // This converts the distance threshold to match the frame's width and height
//        let distanceThreshold = self.equivalentDistance(
//            oldWidth: 504, oldHeight: 896, oldDistance: 80,
//            newWidth: frameWidth, newHeight: frameHeight
//        )
//        for handDetection in handDetectionOutcome.handDetections {
//            var heldTagmata = [WaterCycleClassification]()
//            let jointPositions = handDetection.holdingPositions
//            for jointPosition in jointPositions {
//                for tagmataIndex in 0..<tagmataClassifications.count {
//                    let tagmataPosition = tagmataPositions[tagmataIndex]
//                    let tagmataClassification = tagmataClassifications[tagmataIndex]
//                    if let distance = jointPosition.getDenormalisedPosition(viewWidth: frameWidth, viewHeight: frameHeight)?.length(to: tagmataPosition),
//                       isLess(distance, distanceThreshold) {
//                        heldTagmata.append(tagmataClassification)
//                    }
//                }
//            }
//            if let mostCommon = heldTagmata.mostCommonElement() {
//                // To qualify for being held, you need to be within the threshold distance to the most joints
//                result.held.append(mostCommon)
//            }
//            // To qualify for being maybe held, you need to be within the threshold distance to at least one joint
//            result.maybeHeld.append(contentsOf: heldTagmata)
//        }
//        result.held = result.held.filterDuplicates()
//        result.maybeHeld = result.maybeHeld.filterDuplicates()
//        result.handsUsed = result.held.count
//        return result
//    }
//    
//    /// Converts a distance in a given frame to the equivalent distance in a new frame.
//    /// Example:
//    /// ``` equivalentDistance(
//    ///         oldWidth: 1000, oldHeight: 1000, oldDistance: 100,
//    ///         newWidth: 100, newHeight: 100
//    ///     ) -> 10.0
//    /// ```
//    /// - Parameters:
//    ///   - oldWidth: Old frame's width
//    ///   - oldHeight: Old frame's height
//    ///   - oldDistance: Distance to be converted
//    ///   - newWidth: The new width as reference for the new distance
//    ///   - newHeight: The new height as reference for the new distance
//    /// - Returns: `oldDistance` equivalent to to new width and height
//    private func equivalentDistance(
//        oldWidth: Double,
//        oldHeight: Double,
//        oldDistance: Double,
//        newWidth: Double,
//        newHeight: Double
//    ) -> Double {
//        let oldDiagonal = sqrt(pow(oldWidth, 2) + pow(oldHeight, 2))
//        let proportion = oldDistance / oldDiagonal
//        let newDiagonal = sqrt(pow(newWidth, 2) + pow(newHeight, 2))
//        let newDistance = proportion * newDiagonal
//        return newDistance
//    }
//    
//    private func detectInsectCompletion(for waterCycleDetectionOutcome: ModelDetectionOutcome) -> Bool {
//        var predictions = [WaterCycleClassification: ModelDetection]()
//        for prediction in waterCycleDetectionOutcome.modelDetections {
//            predictions[prediction.classification] = prediction
//        }
//        let A = predictions[.head]
//        let B = predictions[.leftWing]
//        let C = predictions[.thorax]
//        let D = predictions[.rightWing]
//        let E = predictions[.abdomen]
//        
//        let frameWidth = tagmataDetectionOutcome.frameSize.width
//        let frameHeight = tagmataDetectionOutcome.frameSize.height
//        let angle1 = self.angleBetweenDetections(A, C, D, frameWidth: frameWidth, frameHeight: frameHeight)
//        let angle2 = self.angleBetweenDetections(B, C, A, frameWidth: frameWidth, frameHeight: frameHeight)
//        let angle3 = self.angleBetweenDetections(E, C, B, frameWidth: frameWidth, frameHeight: frameHeight)
//        let angle4 = self.angleBetweenDetections(D, C, E, frameWidth: frameWidth, frameHeight: frameHeight)
//        
//        if let angle1, let angle2, let angle3, let angle4, let A, let B, let C, let D, let E {
//            // I apply * -1 below for readability (easier to compare positives)
//            let sum = -(angle1.degrees + angle2.degrees + angle3.degrees + angle4.degrees)
//            let sumInRange = sum >= 350 && sum <= 370
//            let validAngles = [angle1, angle2, angle3, angle4].allSatisfy({ -$0.degrees >= 50 && -$0.degrees <= 130 })
//            let abdomenIntersects = C.boundingBox.intersects(E.boundingBox)
//            let leftWingIntersects = C.boundingBox.intersects(B.boundingBox)
//            let rightWingIntersects = C.boundingBox.intersects(D.boundingBox)
//            let headIntersects = C.boundingBox.intersects(A.boundingBox)
//            let validIntersects = abdomenIntersects && leftWingIntersects && rightWingIntersects && headIntersects
//            return sumInRange && validAngles && validIntersects
//        }
//        return false
//    }
//    
//    private func angleBetweenDetections(
//        _ detection1: TagmataDetection?,
//        _ detection2: TagmataDetection?,
//        _ detection3: TagmataDetection?,
//        frameWidth: Double,
//        frameHeight: Double
//    ) -> Angle? {
//        guard let detection1, let detection2, let detection3 else {
//            return nil
//        }
//        let point1 = detection1.getDenormalisedCenter(boundsWidth: frameWidth, boundsHeight: frameHeight)
//        let point2 = detection2.getDenormalisedCenter(boundsWidth: frameWidth, boundsHeight: frameHeight)
//        let point3 = detection3.getDenormalisedCenter(boundsWidth: frameWidth, boundsHeight: frameHeight)
//        return self.angleBetweenPoints(point1: point1, point2: point2, point3: point3)
//    }
//    
//    /// Calculates the angle formed by three points.
//    /// Example:
//    /// ``` angleBetweenPoints(
//    ///         point1: CGPoint(x: 0, y: 1),
//    ///         point2: CGPoint(x: 0, y: 0),
//    ///         point3: CGPoint(x: 1, y: 0)
//    ///     ) -> 90
//    /// ```
//    /// - Parameters:
//    ///   - point1: The first point
//    ///   - point2: The second point, serves as the vertex of the angle
//    ///   - point3: The third point
//    /// - Returns: The signed angle between `point1` and `point3` with `point2` as the vertex
//    private func angleBetweenPoints(point1: CGPoint, point2: CGPoint, point3: CGPoint) -> Angle {
//        let vector1 = CGPoint(x: point2.x - point1.x, y: point2.y - point1.y)
//        let vector2 = CGPoint(x: point3.x - point2.x, y: point3.y - point2.y)
//        
//        let dotProduct = vector1.x * vector2.x + vector1.y * vector2.y
//        let magnitude1 = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
//        let magnitude2 = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)
//        
//        let cosAngle = dotProduct / (magnitude1 * magnitude2)
//        let angle = acos(cosAngle)
//        
//        let crossProduct = vector1.x * vector2.y - vector1.y * vector2.x
//        let signedAngle = crossProduct >= 0 ? angle : -angle
//        return Angle(radians: signedAngle)
//    }
//    
//}
