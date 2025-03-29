//
//  WindCalculator.swift
//  GolfTracker
//
//  Created by Matteo Keller on 28.03.2025.
//


// Create a new file called WindCalculator.swift
import Foundation

struct WindCalculator {
    static func calculateImpact(distance: Int, windSpeed: Double, windDirection: Double) -> Int {
        let radians = (windDirection * .pi) / 180.0
        
        let headwindComponent = cos(radians) * windSpeed
        let crosswindComponent = sin(radians) * windSpeed
        
        let headwindImpact = -headwindComponent * 2.5
        let crosswindImpact = abs(crosswindComponent) * 0.8
        
        return Int(headwindImpact - crosswindImpact)
    }
}