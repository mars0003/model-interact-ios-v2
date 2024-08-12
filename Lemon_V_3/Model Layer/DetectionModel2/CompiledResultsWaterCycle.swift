////
////  CompiledResultsWaterCycle.swift
////  Lemon
////
////  Created by Ishrat Kaur on 11/5/2024.
////
//
//import Foundation
//
//class CompiledResultsWaterCycle {
//    
//    /// All detected tagmata within frame
//    private(set) var detectedWaterCycle: [WaterCycleClassification]
//    /// All detected tagmata that are currently being held within frame
//    private(set) var heldWaterCycle: [WaterCycleClassification]
//    /// All detected tagmata that are currently maybe held within frame (close to a hand)
//    private(set) var maybeHeldWaterCycle: [WaterCycleClassification]
//    /// If the insect is complete (all pieces are correctly attached)
//    public let WaterCycleIsComplete: Bool
//    /// The confidence that the insect is complete (the proportion of outcomes analysed that said it was complete), range [0, 1]
//    public let completionConfidence: Double
//    /// The number of hands used to hold unique tagmata (two hands holding one or a hand holding none don't count)
//    public let handsUsed: Int
//    /// True if there were no detected tagmata within frame
//    public var hasNoDetections: Bool {
//        return self.detectedWaterCycle.isEmpty
//    }
//    /// True if there were no detected tagmata being held within frame
//    public var hasNoHeldDetections: Bool {
//        return self.heldWaterCycle.isEmpty
//    }
//    /// True if there were no detected tagmata close to any hands within frame
//    public var hasNoMaybeHeldDetections: Bool {
//        return self.maybeHeldWaterCycle.isEmpty
//    }
//    
//    init(
//        detectedWaterCycle: [WaterCycleClassification] = [],
//        heldWaterCycle: [WaterCycleClassification] = [],
//        maybeHeldWaterCycle: [WaterCycleClassification] = [],
//        handsUsed: Int = 0,
//        WaterCycleIsComplete: Bool = false,
//        completionConfidence: Double = 0.0
//    ) {
//        self.detectedWaterCycle = detectedWaterCycle
//        self.heldWaterCycle = heldWaterCycle
//        self.maybeHeldWaterCycle = maybeHeldWaterCycle
//        self.handsUsed = handsUsed
//        self.WaterCycleIsComplete = WaterCycleIsComplete
//        self.completionConfidence = completionConfidence
//    }
//    
//    func WaterCycleStillHeld(original: WaterCycleClassification) -> Bool {
//        // We assume we 100% know they were previously holding the original since it triggered a command
//        // Hence if we believe they were already holding it, we don't want to accidentally think they've stopped holding it if we're unsure
//        // That can trigger it to stop speaking, which is really annoying if they just took a finger off or something
//        // Hence we just look through everything that's currently MAYBE being held
//        // If they were holding a piece, and their fingers are still close to it, we say they're still holding it
//        for waterCycle in self.maybeHeldWaterCycle {
//            if waterCycle == original {
//                return true
//            }
//        }
//        return false
//    }
//    
//}
