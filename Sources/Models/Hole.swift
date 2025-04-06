// --- START OF FILE GolfTracker.swiftpm/Sources/Models/Hole.swift ---
// No changes needed in Hole.swift as it's a data model (Wind logic was already removed).
// Keep the existing Hole.swift code.

import Foundation

// Enum representing the result location relative to the green center
enum GreenHitLocation: Int, Codable, Equatable, CaseIterable { // Added CaseIterable
    case center = 0    // Green in regulation
    case longLeft = 1
    case long = 2
    case longRight = 3
    case left = 4
    case right = 5
    case shortLeft = 6
    case short = 7
    case shortRight = 8

    // Computed property to check if it's a Green in Regulation
    var isGIR: Bool {
        return self == .center
    }

    // Provide descriptive text for each location
    var description: String {
        switch self {
            case .center: return "Green in Reg"
            case .longLeft: return "Missed Long Left"
            case .long: return "Missed Long"
            case .longRight: return "Missed Long Right"
            case .left: return "Missed Left"
            case .right: return "Missed Right"
            case .shortLeft: return "Missed Short Left"
            case .short: return "Missed Short"
            case .shortRight: return "Missed Short Right"
        }
    }

     // Provide short text for grid display
     var shortDescription: String {
         switch self {
             case .center: return "GIR"
             case .longLeft: return "L/L"
             case .long: return "Long"
             case .longRight: return "L/R"
             case .left: return "Left"
             case .right: return "Right"
             case .shortLeft: return "S/L"
             case .short: return "Short"
             case .shortRight: return "S/R"
         }
     }
}

// Enum representing the direction of a missed fairway
enum FairwayMissDirection: String, Codable, Equatable, CaseIterable { // Added CaseIterable
    case left
    case right
    case none // Used when fairway was hit or for Par 3s

     var description: String {
         switch self {
         case .left: return "Missed Left"
         case .right: return "Missed Right"
         case .none: return "Hit Fairway" // Or N/A for Par 3
         }
     }
}

// Represents data for a single hole within a round
struct Hole: Identifiable, Codable, Equatable {
    var id = UUID()
    var number: Int // Hole number (1-18)
    var par: Int    // Par for the hole (3, 4, or 5)
    var score: Int = 0 // Player's score for the hole

    // --- Tee shot details ---
    var teeClub: Club?       // Club used for the tee shot
    var fairwayHit: Bool? = nil // true = hit, false = miss, nil = N/A (Par 3)
    var fairwayMissDirection: FairwayMissDirection = .none // Direction if fairwayHit is false

    // --- Approach shot details ---
    var approachDistance: Int? = nil // Distance to the hole for the approach shot (e.g., in meters/yards)
    var approachClub: Club?       // Club used for the approach shot
    var greenHitLocation: GreenHitLocation = .center // Where the ball landed relative to the green

    // --- Putting details ---
    var putts: Int = 0 // Number of putts taken on the green
    var firstPuttDistance: Int? = nil // Distance of the first putt (e.g., in feet)

    // --- Weather/Conditions (Manual Input) ---
    var windSpeed: Double = 0.0 // Wind speed (e.g., m/s)
    var windDirection: Int = 0  // Wind direction in degrees (0-360, 0 = North)

    // --- Computed Properties ---
    var isPar3: Bool {
        return par == 3
    }

    // Check if the green was hit in regulation based on the location
    var isGIR: Bool {
        return greenHitLocation.isGIR
    }
}
// --- END OF FILE GolfTracker.swiftpm/Sources/Models/Hole.swift ---
