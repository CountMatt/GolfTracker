//
//  Round.swift
//  GolfTracker
//
//  Created by Matteo Keller on 25.03.2025.
//


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
    
    static func createNew(holeCount: Int) -> Round {
        var holes: [Hole] = []
        
        for i in 1...holeCount {
            // Default most holes to par 4, with a few par 3s and 5s
            var par = 4
            if [3, 6, 11, 16].contains(i) {
                par = 3
            } else if [4, 8, 13, 18].contains(i) {
                par = 5
            }
            
            holes.append(Hole(number: i, par: par))
        }
        
        return Round(date: Date(), holes: holes)
    }
}