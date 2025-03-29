//
//  HoleData.swift
//  GolfTracker
//
//  Created by Matteo Keller on 29.03.2025.
//

import Foundation
// Create a new file (e.g., Sources/Models/HoleData.swift) or add within ContentView for now
struct HoleData: Identifiable {
    let id = UUID() // Unique identifier for each entry
    let hole: Int
    let score: Int
    let putts: Int
    let fairway: Bool
}
