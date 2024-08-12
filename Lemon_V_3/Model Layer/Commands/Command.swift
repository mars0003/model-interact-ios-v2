//
//  Commands.swift
//  Lemon
//
//  Created by Andre Pham on 21/7/2023.
//

import Foundation

/// The various commands the user can speak to perform.
/// These enum values directly represent the command to speak. `case name` responds to the user saying the word "name".
/// If you want your command to be different from the enum name, add a string value. For instance, `case name = "say name"` for the command "say name".
enum Command: CaseIterable {
    
    /// Speak the name of the held insect tagma
    case name
    /// Speak the information of the held insect tagma
    case information
    /// Check if the insect is completed
    case completed
    /// Ask for a description of what a piece connects to
    case connect
    /// Add a custom label to a piece
    case addLabel
    /// Listen to a custom label assigned to a piece
    case listenLabel
    /// A test command (for development purposes)
    case test
    /// No command
    case switchToTagmata
    case switchToWaterCycle
    case none
    
    /// The strings to look for in the speech-to-text transcription to activate this command
    public var strings: [String] {
        switch self {
        case .name:
            return [Strings("command.name").local]
        case .information:
            return [Strings("command.information").local]
        case .completed:
            return [Strings("command.complete").local, Strings("command.complete1").local]
        case .connect:
            return [Strings("command.connect").local, Strings("command.connect1").local]
        case .addLabel:
            return [Strings("command.addLabel").local, Strings("command.addLabel1").local]
        case .listenLabel:
            return [Strings("command.listenLabel").local, Strings("command.listenLabel1").local]
        case .test:
            return [Strings("command.test").local]
        case .switchToTagmata:
            return[Strings("command.switchToTagmata").local]
        case .switchToWaterCycle:
            return[Strings("command.switchToWaterCycle").local]
        case .none:
            return []
        }
    }
    
}
