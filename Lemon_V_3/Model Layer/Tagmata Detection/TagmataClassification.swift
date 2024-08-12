//
//  TagmataClassification.swift
//  Lemon
//
//  Created by Andre Pham on 20/6/2023.
//

import Foundation
import UIKit


//enum WaterCycleModelClassification: String, CaseIterable {
//    case sun = "The Sun"
//    case rain = "Rain"
//    case infiltration = "Infiltration"
//    case plantUptake = "Plant uptake"
//    case runOff = "Run Off"
//    case snow = "Snow"
//    case mountain = "Mountain"
//    case precipitation = "Precipitation"
//    case river = "River"
//    case condensation = "Condensation"
//    case groundWater = "Groundwater"
//    case cloud = "Cloud"
//    case ocean = "Ocean"
//    case transpiration = "Transpiration"
//    case evaporation = "Evaporation"
//    case arrow = "Arrow"
//    
//    public var name: String {
//        switch self {
//        case .sun: return Strings("watercycle.sun").local
//
//        }
//    }
//}

/// For the sake of syntax, we're pretending the wings are part of the tagmata of an insect.
enum TagmataClassification: String, CaseIterable {
    
    case head = "head-yellow"
    case thorax = "thorax-blue"
    case abdomen = "abdomen-magenta"
    case leftWing = "wing-red"
    case rightWing = "wing-green"
    
    public var name: String {
        switch self {
        case .head: return Strings("tagma.head").local
        case .thorax: return Strings("tagma.thorax").local
        case .abdomen: return Strings("tagma.abdomen").local
        case .leftWing: return Strings("tagma.leftWing").local
        case .rightWing: return Strings("tamga.rightWing").local
        }
    }
    
    public var description: String {
        switch self {
        case .head: return Strings("description.head").local
        case .thorax: return Strings("description.thorax").local
        case .abdomen: return Strings("description.abdomen").local
        case .leftWing: return Strings("description.leftWing").local
        case .rightWing: return Strings("description.rightWing").local
        }
    }
    
    public var connection: String {
        switch self {
        case .head: return Strings("connection.head").local
        case .thorax: return Strings("connection.thorax").local
        case .abdomen: return Strings("connection.abdomen").local
        case .leftWing: return Strings("connection.leftWing").local
        case .rightWing: return Strings("connection.rightWing").local
        }
    }
    
    public var audioAction: AudioAction {
        switch self {
        case .head: return .head
        case .thorax: return .thorax
        case .abdomen: return .abdomen
        case .leftWing, .rightWing: return .wings
        }
    }
    
    public var colorDescription: String {
        switch self {
        case .head: return "Yellow"
        case .thorax: return "Blue"
        case .abdomen: return "Magenta"
        case .leftWing: return "Red"
        case .rightWing: return "Green"
        }
    }
    
    public var color: UIColor {
        switch self {
        case .head: return UIColor.yellow
        case .thorax: return UIColor.blue
        case .abdomen: return UIColor.magenta
        case .leftWing: return UIColor.red
        case .rightWing: return UIColor.green
        }
    }
    
}
