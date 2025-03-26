//
//  Statistics.swift
//  GolfTracker
//
//  Created by Matteo Keller on 25.03.2025.
//


// File: Sources/Models/Statistics.swift
import Foundation

// Create a codable wrapper for our tuples
struct DateScorePair: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var score: Int
}

struct DatePuttsPair: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var putts: Int
}

struct Statistics: Codable {
    var totalRounds: Int = 0
    var averageScore: Double = 0.0
    var fairwayHitPercentage: Double = 0.0
    var girPercentage: Double = 0.0
    var averagePuttsPerHole: Double = 0.0
    var averagePuttsPerRound: Double = 0.0
    var roundsWithScoreByDate: [DateScorePair] = []
    var roundsWithPuttsByDate: [DatePuttsPair] = []
    
    // Other stat tracking metrics can be added here
}
