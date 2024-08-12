//
//  NewCompiledResults.swift
//  Lemon_V_3
//
//  Created by Mohamed Asjad on 24/7/2024.
//test string
//

import Foundation

class ModelCompiledResults {
    
    /// All detected tagmata within frame
    private(set) var detectedModel: [ModelClassification]
    /// All detected tagmata that are currently being held within frame
    private(set) var heldModel: [ModelClassification]
    /// All detected tagmata that are currently maybe held within frame (close to a hand)
    private(set) var maybeHeldModel: [ModelClassification]
    /// If the insect is complete (all pieces are correctly attached)
    public let modelIsComplete: Bool
    /// The confidence that the insect is complete (the proportion of outcomes analysed that said it was complete), range [0, 1]
    public let completionConfidence: Double
    /// The number of hands used to hold unique tagmata (two hands holding one or a hand holding none don't count)
    public let handsUsed: Int
    /// True if there were no detected tagmata within frame
    public var hasNoDetections: Bool {
        return self.detectedModel.isEmpty
    }
    /// True if there were no detected tagmata being held within frame
    public var hasNoHeldDetections: Bool {
        return self.heldModel.isEmpty
    }
    /// True if there were no detected tagmata close to any hands within frame
    public var hasNoMaybeHeldDetections: Bool {
        return self.maybeHeldModel.isEmpty
    }
    
    init(
        detectedModel: [ModelClassification] = [],
        heldModel: [ModelClassification] = [],
        maybeHeldModel: [ModelClassification] = [],
        handsUsed: Int = 0,
        modelIsComplete: Bool = false,
        completionConfidence: Double = 0.0
    ) {
        self.detectedModel = detectedModel
        self.heldModel = heldModel
        self.maybeHeldModel = maybeHeldModel
        self.handsUsed = handsUsed
        self.modelIsComplete = modelIsComplete
        self.completionConfidence = completionConfidence
    }
    
    func modelStillHeld(original: ModelClassification) -> Bool {
        // We assume we 100% know they were previously holding the original since it triggered a command
        // Hence if we believe they were already holding it, we don't want to accidentally think they've stopped holding it if we're unsure
        // That can trigger it to stop speaking, which is really annoying if they just took a finger off or something
        // Hence we just look through everything that's currently MAYBE being held
        // If they were holding a piece, and their fingers are still close to it, we say they're still holding it
        for part in self.maybeHeldModel {
            if part == original {
                return true
            }
        }
        return false
    }
    
}
