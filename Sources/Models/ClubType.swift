import Foundation

enum ClubType: String, CaseIterable, Identifiable, Codable, Equatable {
    case driver = "Driver"
    case wood = "Wood"
    case hybrid = "Hybrid"
    case iron = "Iron"
    case wedge = "Wedge"
    case putter = "Putter"
    
    var id: String { self.rawValue }
}

struct Club: Identifiable, Codable, Hashable, Equatable {
    var id = UUID()
    var type: ClubType
    var name: String
    
    // Predefined set of clubs for quick selection
    static let allClubs: [Club] = [
        Club(type: .driver, name: "Driver"),
        Club(type: .wood, name: "3 Wood"),
        Club(type: .wood, name: "5 Wood"),
        Club(type: .hybrid, name: "3 Hybrid"),
        Club(type: .hybrid, name: "4 Hybrid"),
        Club(type: .iron, name: "4 Iron"),
        Club(type: .iron, name: "5 Iron"),
        Club(type: .iron, name: "6 Iron"),
        Club(type: .iron, name: "7 Iron"),
        Club(type: .iron, name: "8 Iron"),
        Club(type: .iron, name: "9 Iron"),
        Club(type: .wedge, name: "PW"),
        Club(type: .wedge, name: "GW"),
        Club(type: .wedge, name: "SW"),
        Club(type: .wedge, name: "LW"),
        Club(type: .putter, name: "Putter")
    ]
    
  
}
