// --- START OF FILE GolfTracker.swiftpm/Sources/Models/Round.swift ---
// No changes needed in Round.swift as it's a data model.
// Keep the existing Round.swift code.

// File: Sources/Models/Round.swift
import Foundation

// Added Equatable conformance
struct Round: Identifiable, Codable, Equatable {
    var id = UUID()
    var date: Date
    var courseName: String = "My Course"
    var holes: [Hole] // Assumes Hole is already Equatable
    var notes: String = ""

    // --- Computed Properties (Keep as before) ---
    var isNineHoles: Bool { holes.count <= 9 }
    var totalScore: Int { holes.reduce(0) { $0 + $1.score } }
    var totalPar: Int { holes.reduce(0) { $0 + $1.par } }
    var scoreRelativeToPar: Int { totalScore - totalPar }
    var totalPutts: Int { holes.reduce(0) { $0 + $1.putts } }
    var greensInRegulation: Int { holes.reduce(0) { $0 + ($1.isGIR ? 1 : 0) } }
    var girOpportunities: Int { holes.count }
    var girPercentage: Double { guard girOpportunities > 0 else { return 0.0 }; return (Double(greensInRegulation) / Double(girOpportunities)) * 100.0 }
    var fairwaysHit: Int { holes.reduce(0) { $0 + ($1.fairwayHit == true ? 1 : 0) } }
    var fairwayOpportunities: Int { holes.reduce(0) { $0 + (!$1.isPar3 ? 1 : 0) } }
    var fairwayPercentage: Double { guard fairwayOpportunities > 0 else { return 0.0 }; return (Double(fairwaysHit) / Double(fairwayOpportunities)) * 100.0 }

    // --- Static Factory Method (Keep as before) ---
    static func createNew(holeCount: Int) -> Round {
        var newHoles: [Hole] = []
        for i in 1...holeCount {
            var par = 4
            // Default Par Logic (adjust if course specific pars needed later)
            if holeCount == 9 {
                if [3, 6].contains(i) { par = 3 }
                else if [4, 8].contains(i) { par = 5 }
            } else { // Assume 18 holes
                if [3, 6, 11, 16].contains(i) { par = 3 }
                else if [4, 8, 13, 18].contains(i) { par = 5 }
            }
            newHoles.append(Hole(number: i, par: par))
        }
        return Round(date: Date(), holes: newHoles)
    }

    // Note: Because all stored properties (UUID, Date, String, [Hole])
    // are Equatable, Swift synthesizes the == operator automatically.
    // No need to write static func == (lhs: Round, rhs: Round) -> Bool
}
// --- END OF FILE GolfTracker.swiftpm/Sources/Models/Round.swift ---
