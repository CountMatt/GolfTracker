// --- START OF FILE GolfTracker.swiftpm/Resources/SampleData.swift ---
// No changes needed in SampleData.swift as it deals with data, not UI presentation.
// Keep the existing SampleData.swift code.

// File: Resources/SampleData.swift
import Foundation

struct SampleData {
    static var sampleRounds: [Round] {
        let calendar = Calendar.current
        let today = Date()

        // Create dates for sample rounds
        let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)!
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: today)!
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today)!

        // Sample 9-hole round from two weeks ago
        var nineHoleRound = Round(
            date: twoWeeksAgo,
            courseName: "Local Course",
            holes: []
        )

        for i in 1...9 {
            var par = 4
            if [3, 6].contains(i) {
                par = 3
            } else if [4, 8].contains(i) {
                par = 5
            }

            var hole = Hole(number: i, par: par)
            hole.score = par + ([-1, 0, 0, 1].randomElement() ?? 0)
            hole.teeClub = Club.allClubs.first(where: { $0.name == "Driver" })
            hole.fairwayHit = Bool.random()
            hole.approachDistance = (100...180).randomElement()
            hole.approachClub = Club.allClubs.first(where: { $0.name == "7 Iron" })
            hole.greenHitLocation = [GreenHitLocation.center, GreenHitLocation.center, GreenHitLocation.short, GreenHitLocation.longRight].randomElement()!
            hole.putts = (1...3).randomElement()!
            hole.firstPuttDistance = (3...30).randomElement()

            nineHoleRound.holes.append(hole)
        }

        // Sample 18-hole round from last week
        var eighteenHoleRound = Round(
            date: lastWeek,
            courseName: "Championship Course",
            holes: []
        )

        for i in 1...18 {
            var par = 4
            if [3, 6, 11, 16].contains(i) {
                par = 3
            } else if [4, 8, 13, 18].contains(i) {
                par = 5
            }

            var hole = Hole(number: i, par: par)
            hole.score = par + ([-1, 0, 0, 1, 2].randomElement() ?? 0)

            let randomClub = Club.allClubs.randomElement()!
            hole.teeClub = randomClub

            if par != 3 {
                hole.fairwayHit = Bool.random()
            }

            hole.approachDistance = (80...200).randomElement()
            hole.approachClub = Club.allClubs.first(where: { $0.name == "8 Iron" })

            // Weighted randomization favoring GIR
            let locations: [GreenHitLocation] = [.center, .center, .center, .long, .short, .left, .right]
            hole.greenHitLocation = locations.randomElement()!

            hole.putts = (1...3).randomElement()!
            hole.firstPuttDistance = (2...25).randomElement()

            eighteenHoleRound.holes.append(hole)
        }

        // Sample recent round from day before yesterday
        var recentRound = Round(
            date: dayBeforeYesterday,
            courseName: "City Links",
            holes: []
        )

        for i in 1...18 {
            var par = 4
            if [3, 6, 11, 16].contains(i) {
                par = 3
            } else if [4, 8, 13, 18].contains(i) {
                par = 5
            }

            var hole = Hole(number: i, par: par)
            hole.score = par + ([-2, -1, 0, 0, 0, 1].randomElement() ?? 0)

            hole.teeClub = Club.allClubs.first(where: { $0.type == .driver })

            if par != 3 {
                hole.fairwayHit = [true, true, false].randomElement()
            }

            hole.approachDistance = (90...180).randomElement()
            hole.approachClub = Club.allClubs.first(where: { $0.name == "9 Iron" }) ?? Club.allClubs.randomElement()

            // Better play in recent round
            let betterLocations: [GreenHitLocation] = [.center, .center, .center, .center, .long, .short]
            hole.greenHitLocation = betterLocations.randomElement()!

            // Better putting
            hole.putts = [1, 2, 2].randomElement()!
            hole.firstPuttDistance = (3...20).randomElement()

            recentRound.holes.append(hole)
        }

        return [nineHoleRound, eighteenHoleRound, recentRound]
    }
}
// --- END OF FILE GolfTracker.swiftpm/Resources/SampleData.swift ---
