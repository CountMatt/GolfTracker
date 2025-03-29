// File: Sources/Models/Statistics.swift
import Foundation

// --- Helper Structs for Trend Data (Must be defined BEFORE Statistics struct) ---
// Ensure these are Codable

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

struct DatePercentPair: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var percentage: Double // For GIR%, Fairway% etc.
}

// --- Main Statistics Struct ---

struct Statistics: Codable { // Codable conformance should now work
    // Existing Stats
    var totalRounds: Int = 0
    var averageScore: Double = 0.0 // Per 18 holes equivalent
    var fairwayHitPercentage: Double = 0.0 // Overall
    var girPercentage: Double = 0.0 // Overall
    var averagePuttsPerHole: Double = 0.0 // Overall
    var averagePuttsPerRound: Double = 0.0 // Overall (per actual rounds played)

    // Trend Data (Using the structs defined above)
    var roundsWithScoreByDate: [DateScorePair] = []
    var roundsWithPuttsByDate: [DatePuttsPair] = []
    var roundsWithGIRByDate: [DatePercentPair] = []
    var roundsWithFairwaysByDate: [DatePercentPair] = []

    // Performance by Par
    var avgScorePar3: Double = 0.0
    var avgScorePar4: Double = 0.0
    var avgScorePar5: Double = 0.0
    var avgPuttsPar3: Double = 0.0
    var avgPuttsPar4: Double = 0.0
    var avgPuttsPar5: Double = 0.0
    var girPercentagePar3: Double = 0.0

    // Putting Breakdown
    var avgPuttsOnGIR: Double = 0.0
    var avgPuttsOffGIR: Double = 0.0
    var onePuttPercentage: Double = 0.0
    var threePuttPercentage: Double = 0.0

    // Driving Accuracy Breakdown
    var fairwaysHitPercentageTotal: Double { fairwayHitPercentage } // Use computed property for alias
    var fairwaysMissedLeftPercentage: Double = 0.0
    var fairwaysMissedRightPercentage: Double = 0.0

    // Strokes Gained (Placeholders)
    var strokesGainedTotal: Double? = nil
    var strokesGainedPutting: Double? = nil
    var strokesGainedApproach: Double? = nil
    var strokesGainedOffTheTee: Double? = nil
    var strokesGainedAroundGreen: Double? = nil

    // Helper counts
    var totalHolesPlayed: Int = 0
    var totalPar3sPlayed: Int = 0
    var totalPar4sPlayed: Int = 0
    var totalPar5sPlayed: Int = 0
    var totalFairwayOpportunities: Int = 0
}
