// --- START OF FILE GolfTracker.swiftpm/Sources/Models/ClubType.swift ---
// No changes needed in ClubType.swift as it's a data model.
// Keep the existing ClubType.swift code.

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
    var name: String // Keep simple name for now

    // Predefined set of clubs for quick selection
    // Consider making this editable by the user in the future
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
        Club(type: .wedge, name: "PW"), // Pitching Wedge
        Club(type: .wedge, name: "GW"), // Gap Wedge
        Club(type: .wedge, name: "SW"), // Sand Wedge
        Club(type: .wedge, name: "LW"), // Lob Wedge
        Club(type: .putter, name: "Putter")
    ]

   // Add convenience computed properties if needed, e.g., abbreviation
   var shortName: String {
       switch type {
           case .driver: return "Dr"
           case .wood: return name.replacingOccurrences(of: " Wood", with: "W") // "3W", "5W"
           case .hybrid: return name.replacingOccurrences(of: " Hybrid", with: "H") // "3H", "4H"
           case .iron: return name.replacingOccurrences(of: " Iron", with: "i") // "4i", "5i"
           case .wedge: return name // PW, GW, SW, LW are already short
           case .putter: return "Pt"
       }
   }
}
// --- END OF FILE GolfTracker.swiftpm/Sources/Models/ClubType.swift ---
