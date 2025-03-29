// File: Sources/Models/Round.swift
import Foundation

struct Round: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var courseName: String = "My Course"
    var holes: [Hole]
    var notes: String = ""

    var isNineHoles: Bool {
        return holes.count <= 9
    }

    var totalScore: Int {
        return holes.reduce(0) { $0 + $1.score }
    }

    var totalPar: Int {
        return holes.reduce(0) { $0 + $1.par }
    }

    var scoreRelativeToPar: Int {
        return totalScore - totalPar
    }

    // --- NEW: Computed Properties for Round-Specific Stats ---

    var totalPutts: Int {
        holes.reduce(0) { $0 + $1.putts }
    }

    var greensInRegulation: Int {
        holes.reduce(0) { $0 + ($1.isGIR ? 1 : 0) }
    }

    var girOpportunities: Int {
        holes.count // Every hole is a GIR opportunity
    }

    var girPercentage: Double {
        guard girOpportunities > 0 else { return 0.0 }
        return (Double(greensInRegulation) / Double(girOpportunities)) * 100.0
    }

    var fairwaysHit: Int {
        holes.reduce(0) { $0 + ($1.fairwayHit == true ? 1 : 0) }
    }

    var fairwayOpportunities: Int {
        // Only count Par 4s and Par 5s as fairway opportunities
        holes.reduce(0) { $0 + (!$1.isPar3 ? 1 : 0) }
    }

    var fairwayPercentage: Double {
        guard fairwayOpportunities > 0 else { return 0.0 } // Avoid division by zero
        return (Double(fairwaysHit) / Double(fairwayOpportunities)) * 100.0
    }

    // --- End New Properties ---


    static func createNew(holeCount: Int) -> Round {
        var newHoles: [Hole] = []
        for i in 1...holeCount {
            var par = 4
            if [3, 6, 11, 16].contains(i) { par = 3 }
            else if [4, 8, 13, 18].contains(i) { par = 5 }
            newHoles.append(Hole(number: i, par: par))
        }
        return Round(date: Date(), holes: newHoles)
    }
}
