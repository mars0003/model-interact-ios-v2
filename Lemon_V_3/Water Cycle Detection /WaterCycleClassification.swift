////
////  WaterCycleClassification.swift
////  Lemon
////
////  Created by Mohamed Asjad on 1/5/2024.
////
//
//import Foundation
//import UIKit
//
///// WaterCycleClassification.swift
///// Enum to classify different stages of the water cycle.
//enum WaterCycleClassification: String, CaseIterable {
//    case sun = "Sun"
//    case rain = "Rain"
//    case infiltration = "Infiltration"
//    case plantUptake = "PlantUptake"
//    case runOff = "RunOff"
//    case snow = "Snow"
//    case snowMelt = "SnowMelt"
//    case mountain = "Mountain"
//    case precipitation = "Precipitation"
//    case river = "River"
//    case condensation = "Condensation"
//    case groundWater = "GroundWater"
//    case cloud = "Cloud"
//    case ocean = "Ocean"
//    case transpiration = "Transpiration"
//    case evaporation = "Evaporation"
//    case arrow = "BlackArrow"
//    case unidentified = "Undefined"
//    case head = "head-yellow"
//    case thorax = "thorax-blue"
//    case abdomen = "abdomen-magenta"
//    case leftWing = "wing-red"
//    case rightWing = "wing-green"
//    
//    public var name: String {
//        switch self {
//        case .sun: return Strings("watercycle.sun").local
//        case .rain: return Strings("watercycle.rain").local
//        case .infiltration: return Strings("watercycle.infiltration").local
//        case .plantUptake: return Strings("watercycle.plant_uptake").local
//        case .runOff: return Strings("watercycle.run_off").local
//        case .snow: return Strings("watercycle.snow").local
//        case .snowMelt: return Strings("watercycle.snow_melt").local
//        case .mountain: return Strings("watercycle.mountain").local
//        case .precipitation: return Strings("watercycle.precipitation").local
//        case .river: return Strings("watercycle.river").local
//        case .condensation: return Strings("watercycle.condensation").local
//        case .groundWater: return Strings("watercycle.ground_water").local
//        case .cloud: return Strings("watercycle.cloud").local
//        case .ocean: return Strings("watercycle.ocean").local
//        case .transpiration: return Strings("watercycle.transpiration").local
//        case .evaporation: return Strings("watercycle.evaporation").local
//        case .arrow: return Strings("watercycle.arrow").local
//        case .unidentified: return Strings("watercycle.unidentified").local
//        case .head: return Strings("tagma.head").local
//        case .thorax: return Strings("tagma.thorax").local
//        case .abdomen: return Strings("tagma.abdomen").local
//        case .leftWing: return Strings("tagma.leftWing").local
//        case .rightWing: return Strings("tamga.rightWing").local
//        }
//    }
//
//    public var description: String {
//        switch self {
//        case .sun: return Strings("description.sun").local
//        case .rain: return Strings("description.rain").local
//        case .infiltration: return Strings("description.infiltration").local
//        case .plantUptake: return Strings("description.plant_uptake").local
//        case .runOff: return Strings("description.run_off").local
//        case .snow: return Strings("description.snow").local
//        case .snowMelt: return Strings("description.snow_melt").local
//        case .mountain: return Strings("description.mountain").local
//        case .precipitation: return Strings("description.precipitation").local
//        case .river: return Strings("description.river").local
//        case .condensation: return Strings("description.condensation").local
//        case .groundWater: return Strings("description.ground_water").local
//        case .cloud: return Strings("description.cloud").local
//        case .ocean: return Strings("description.ocean").local
//        case .transpiration: return Strings("description.transpiration").local
//        case .evaporation: return Strings("description.evaporation").local
//        case .arrow: return Strings("description.arrow").local
//        case .unidentified: return Strings("description.unidentified").local
//        case .head: return Strings("description.head").local
//        case .thorax: return Strings("description.thorax").local
//        case .abdomen: return Strings("description.abdomen").local
//        case .leftWing: return Strings("description.leftWing").local
//        case .rightWing: return Strings("description.rightWing").local
//        }
//    }
//    
//    public var connection: String {
//        switch self {
//        case .sun:
//            return Strings("connection.sun").local
//        case .rain:
//            return Strings("connection.rain").local
//        case .infiltration:
//            return Strings("connection.infiltration").local
//        case .plantUptake:
//            return Strings("connection.plant_uptake").local
//        case .runOff:
//            return Strings("connection.run_off").local
//        case .snow:
//            return Strings("connection.snow").local
//        case .snowMelt:
//            return Strings("connection.snow_melt").local
//        case .mountain:
//            return Strings("connection.mountain").local
//        case .precipitation:
//            return Strings("connection.precipitation").local
//        case .river:
//            return Strings("connection.river").local
//        case .condensation:
//            return Strings("connection.condensation").local
//        case .groundWater:
//            return Strings("connection.ground_water").local
//        case .cloud:
//            return Strings("connection.cloud").local
//        case .ocean:
//            return Strings("connection.ocean").local
//        case .transpiration:
//            return Strings("connection.transpiration").local
//        case .evaporation:
//            return Strings("connection.evaporation").local
//        case .arrow:
//            return Strings("connection.arrow").local
//        case .unidentified:
//            return Strings("connection.unidentified").local
//        case .head: return Strings("connection.head").local
//        case .thorax: return Strings("connection.thorax").local
//        case .abdomen: return Strings("connection.abdomen").local
//        case .leftWing: return Strings("connection.leftWing").local
//        case .rightWing: return Strings("connection.rightWing").local
//        }
//    }
//
//
//}
