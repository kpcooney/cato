//
//  WeightRounding.swift
//  Cato
//
//  Created by Claude Code on 2026-02-17.
//

import Foundation

enum WeightRounding {

    /// Rounds a weight to the nearest valid plate increment.
    /// - Parameters:
    ///   - weight: The raw calculated weight.
    ///   - unit: .lbs → nearest 2.5; .kg → nearest 1.25
    /// - Returns: Rounded weight.
    static func round(_ weight: Double, unit: TargetUnit) -> Double {
        let increment: Double = unit == .kg ? 1.25 : 2.5
        return (weight / increment).rounded() * increment
    }

    /// Rounds up to the nearest valid plate increment.
    static func roundUp(_ weight: Double, unit: TargetUnit) -> Double {
        let increment: Double = unit == .kg ? 1.25 : 2.5
        return ceil(weight / increment) * increment
    }

    /// Rounds down to the nearest valid plate increment.
    static func roundDown(_ weight: Double, unit: TargetUnit) -> Double {
        let increment: Double = unit == .kg ? 1.25 : 2.5
        return floor(weight / increment) * increment
    }

    /// Converts lbs to kg, rounded to nearest plate increment.
    static func lbsToKg(_ lbs: Double) -> Double {
        round(lbs * 0.453592, unit: .kg)
    }

    /// Converts kg to lbs, rounded to nearest plate increment.
    static func kgToLbs(_ kg: Double) -> Double {
        round(kg * 2.20462, unit: .lbs)
    }

    /// Formats a weight for display.
    static func format(_ weight: Double, unit: TargetUnit) -> String {
        let label = unit == .kg ? "kg" : "lbs"
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(weight)) \(label)"
        } else {
            return String(format: "%.1f %@", weight, label)
        }
    }
}
