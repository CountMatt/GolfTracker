import Foundation

enum GreenHitLocation: Int, Codable, Equatable {
    case center = 0    // Green in regulation
    case longLeft = 1
    case long = 2
    case longRight = 3
    case left = 4
    case right = 5
    case shortLeft = 6
    case short = 7
    case shortRight = 8
    
    var isGIR: Bool {
        return self == .center
    }
}

enum FairwayMissDirection: String, Codable, Equatable {
    case left
    case right
    case none
}

struct Hole: Identifiable, Codable, Equatable {
    var id = UUID()
    var number: Int
    var par: Int
    var score: Int = 0
    
    // Tee shot
    var teeClub: Club?
    var fairwayHit: Bool? = nil  // nil for par 3s
    var fairwayMissDirection: FairwayMissDirection = .none
    
    // Approach shot
    var approachDistance: Int? = nil
    var approachClub: Club?
    var greenHitLocation: GreenHitLocation = .center
    
    // Putting
    var putts: Int = 0
    var firstPuttDistance: Int? = nil  // In feet
    
    var isPar3: Bool {
        return par == 3
    }
    
    var isGIR: Bool {
        return greenHitLocation.isGIR
    }
    
   
}
