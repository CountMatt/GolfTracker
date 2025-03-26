//
//  StatisticsCalculator.swift
//  GolfTracker
//
//  Created by Matteo Keller on 25.03.2025.
//


// File: Sources/Controllers/StatisticsCalculator.swift
import Foundation

class StatisticsCalculator {
    func calculateStatistics(from rounds: [Round]) -> Statistics {
        guard !rounds.isEmpty else {
            return Statistics()
        }
        
        var statistics = Statistics()
        statistics.totalRounds = rounds.count
        
        // Calculate scoring statistics
        let totalHoles = rounds.reduce(0) { $0 + $1.holes.count }
        let totalScore = rounds.reduce(0) { $0 + $1.totalScore }
        statistics.averageScore = totalHoles > 0 ? Double(totalScore) / Double(totalRounds(forHoleCount: 18, from: rounds)) : 0
        
        // Calculate fairway statistics
        var totalFairwayOpportunities = 0
        var totalFairwaysHit = 0
        
        // Calculate GIR statistics
        var totalGIROpportunities = 0
        var totalGIRHit = 0
        
        // Calculate putting statistics
        var totalPutts = 0
        
        // Process hole by hole statistics
        for round in rounds {
            for hole in round.holes {
                // Only count fairway stats on non-par-3 holes
                if !hole.isPar3 {
                    if let fairwayHit = hole.fairwayHit {
                        totalFairwayOpportunities += 1
                        if fairwayHit {
                            totalFairwaysHit += 1
                        }
                    }
                }
                
                // GIR stats
                totalGIROpportunities += 1
                if hole.isGIR {
                    totalGIRHit += 1
                }
                
                // Putting stats
                totalPutts += hole.putts
            }
            
            // Store round data for trends
            statistics.roundsWithScoreByDate.append(DateScorePair(date: round.date, score: round.totalScore))
            
            let totalPuttsInRound = round.holes.reduce(0) { $0 + $1.putts }
            statistics.roundsWithPuttsByDate.append(DatePuttsPair(date: round.date, putts: totalPuttsInRound))
        }
        
        // Calculate percentages
        statistics.fairwayHitPercentage = totalFairwayOpportunities > 0 ? Double(totalFairwaysHit) / Double(totalFairwayOpportunities) * 100 : 0
        statistics.girPercentage = totalGIROpportunities > 0 ? Double(totalGIRHit) / Double(totalGIROpportunities) * 100 : 0
        statistics.averagePuttsPerHole = totalHoles > 0 ? Double(totalPutts) / Double(totalHoles) : 0
        statistics.averagePuttsPerRound = statistics.totalRounds > 0 ? Double(totalPutts) / Double(statistics.totalRounds) : 0
        
        // Sort date-based arrays chronologically
        statistics.roundsWithScoreByDate.sort { $0.date < $1.date }
        statistics.roundsWithPuttsByDate.sort { $0.date < $1.date }
        
        return statistics
    }
    
    // Helper method to convert 9-hole rounds to equivalent 18-hole rounds
    private func totalRounds(forHoleCount standardCount: Int, from rounds: [Round]) -> Double {
        var equivalentRounds = 0.0
        
        for round in rounds {
            if round.holes.count == standardCount {
                equivalentRounds += 1.0
            } else {
                equivalentRounds += Double(round.holes.count) / Double(standardCount)
            }
        }
        
        return equivalentRounds
    }
}
