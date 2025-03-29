// File: Sources/Controllers/StatisticsCalculator.swift
import Foundation

class StatisticsCalculator {

    func calculateStatistics(from rounds: [Round]) -> Statistics {
        guard !rounds.isEmpty else { return Statistics() }

        var statistics = Statistics()
        statistics.totalRounds = rounds.count

        // --- Initialize Counters ---
        var totalScoreOverall: Int = 0
        var totalHolesOverall: Int = 0
        var totalPuttsOverall: Int = 0

        var totalFairwayOpportunitiesOverall: Int = 0
        var totalFairwaysHitOverall: Int = 0
        var totalFairwaysMissedLeft: Int = 0
        var totalFairwaysMissedRight: Int = 0

        var totalGIROpportunitiesOverall: Int = 0
        var totalGIRsHitOverall: Int = 0

        // Par 3 Stats
        var scoreSumPar3: Int = 0
        var puttsSumPar3: Int = 0
        var girSumPar3: Int = 0
        var holeCountPar3: Int = 0

        // Par 4 Stats
        var scoreSumPar4: Int = 0
        var puttsSumPar4: Int = 0
        var girSumPar4: Int = 0
        var holeCountPar4: Int = 0

        // Par 5 Stats
        var scoreSumPar5: Int = 0
        var puttsSumPar5: Int = 0
        var girSumPar5: Int = 0
        var holeCountPar5: Int = 0

        // Putting Breakdown Stats
        var puttSumOnGIR: Int = 0
        var holeCountOnGIR: Int = 0
        var puttSumOffGIR: Int = 0
        var holeCountOffGIR: Int = 0
        var onePuttCount: Int = 0
        var threePuttPlusCount: Int = 0


        // --- Process Rounds and Holes ---
        for round in rounds {
            // Accumulate per-round stats for trends
            statistics.roundsWithScoreByDate.append(DateScorePair(date: round.date, score: round.totalScore))
            statistics.roundsWithPuttsByDate.append(DatePuttsPair(date: round.date, putts: round.totalPutts))
            statistics.roundsWithGIRByDate.append(DatePercentPair(date: round.date, percentage: round.girPercentage))
            statistics.roundsWithFairwaysByDate.append(DatePercentPair(date: round.date, percentage: round.fairwayPercentage))

            for hole in round.holes {
                totalHolesOverall += 1
                totalScoreOverall += hole.score
                totalPuttsOverall += hole.putts

                // Overall GIR
                totalGIROpportunitiesOverall += 1 // Every hole is an opportunity
                if hole.isGIR {
                    totalGIRsHitOverall += 1
                }

                // Overall Fairway & Driving Breakdown (Only Par 4s/5s)
                if !hole.isPar3 {
                    totalFairwayOpportunitiesOverall += 1
                    if let hit = hole.fairwayHit {
                        if hit {
                            totalFairwaysHitOverall += 1
                        } else {
                            if hole.fairwayMissDirection == .left {
                                totalFairwaysMissedLeft += 1
                            } else if hole.fairwayMissDirection == .right {
                                totalFairwaysMissedRight += 1
                            }
                            // Ignore .none misses if fairwayHit is explicitly false
                        }
                    }
                }

                // Stats by Par Type
                switch hole.par {
                case 3:
                    holeCountPar3 += 1
                    scoreSumPar3 += hole.score
                    puttsSumPar3 += hole.putts
                    if hole.isGIR { girSumPar3 += 1 } // GIR on Par 3 is hitting green
                case 4:
                    holeCountPar4 += 1
                    scoreSumPar4 += hole.score
                    puttsSumPar4 += hole.putts
                    if hole.isGIR { girSumPar4 += 1 }
                case 5:
                    holeCountPar5 += 1
                    scoreSumPar5 += hole.score
                    puttsSumPar5 += hole.putts
                    if hole.isGIR { girSumPar5 += 1 }
                default:
                    break // Ignore invalid par numbers
                }

                // Putting Breakdown
                if hole.isGIR {
                    holeCountOnGIR += 1
                    puttSumOnGIR += hole.putts
                } else {
                    holeCountOffGIR += 1
                    puttSumOffGIR += hole.putts
                }

                if hole.putts == 1 {
                    onePuttCount += 1
                } else if hole.putts >= 3 {
                    threePuttPlusCount += 1
                }
            } // End hole loop
        } // End round loop


        // --- Calculate Averages and Percentages ---

        // Overall Stats
        statistics.averageScore = totalHolesOverall > 0 ? Double(totalScoreOverall) / totalRounds(forHoleCount: 18, from: rounds) : 0 // Per 18 equiv
        statistics.girPercentage = totalGIROpportunitiesOverall > 0 ? (Double(totalGIRsHitOverall) / Double(totalGIROpportunitiesOverall) * 100.0) : 0
        statistics.fairwayHitPercentage = totalFairwayOpportunitiesOverall > 0 ? (Double(totalFairwaysHitOverall) / Double(totalFairwayOpportunitiesOverall) * 100.0) : 0
        statistics.averagePuttsPerHole = totalHolesOverall > 0 ? Double(totalPuttsOverall) / Double(totalHolesOverall) : 0
        statistics.averagePuttsPerRound = statistics.totalRounds > 0 ? Double(totalPuttsOverall) / Double(statistics.totalRounds) : 0


        // Performance by Par
        statistics.avgScorePar3 = holeCountPar3 > 0 ? Double(scoreSumPar3) / Double(holeCountPar3) : 0
        statistics.avgScorePar4 = holeCountPar4 > 0 ? Double(scoreSumPar4) / Double(holeCountPar4) : 0
        statistics.avgScorePar5 = holeCountPar5 > 0 ? Double(scoreSumPar5) / Double(holeCountPar5) : 0
        statistics.avgPuttsPar3 = holeCountPar3 > 0 ? Double(puttsSumPar3) / Double(holeCountPar3) : 0
        statistics.avgPuttsPar4 = holeCountPar4 > 0 ? Double(puttsSumPar4) / Double(holeCountPar4) : 0
        statistics.avgPuttsPar5 = holeCountPar5 > 0 ? Double(puttsSumPar5) / Double(holeCountPar5) : 0
        statistics.girPercentagePar3 = holeCountPar3 > 0 ? (Double(girSumPar3) / Double(holeCountPar3) * 100.0) : 0
        // Note: GIR for Par 4/5 is handled by the overall GIR calculation if needed elsewhere


        // Putting Breakdown
        statistics.avgPuttsOnGIR = holeCountOnGIR > 0 ? Double(puttSumOnGIR) / Double(holeCountOnGIR) : 0
        statistics.avgPuttsOffGIR = holeCountOffGIR > 0 ? Double(puttSumOffGIR) / Double(holeCountOffGIR) : 0
        if totalHolesOverall > 0 {
            statistics.onePuttPercentage = (Double(onePuttCount) / Double(totalHolesOverall)) * 100.0
            statistics.threePuttPercentage = (Double(threePuttPlusCount) / Double(totalHolesOverall)) * 100.0
        } else {
            statistics.onePuttPercentage = 0
            statistics.threePuttPercentage = 0
        }

        // Driving Accuracy Breakdown
        if totalFairwayOpportunitiesOverall > 0 {
            statistics.fairwaysMissedLeftPercentage = (Double(totalFairwaysMissedLeft) / Double(totalFairwayOpportunitiesOverall)) * 100.0
            statistics.fairwaysMissedRightPercentage = (Double(totalFairwaysMissedRight) / Double(totalFairwayOpportunitiesOverall)) * 100.0
        } else {
             statistics.fairwaysMissedLeftPercentage = 0
             statistics.fairwaysMissedRightPercentage = 0
         }

        // Strokes Gained - Placeholders: Calculation requires external benchmarks
        // statistics.strokesGainedTotal = calculateStrokesGained(...)

        // Add total counts for potential display
        statistics.totalHolesPlayed = totalHolesOverall
        statistics.totalPar3sPlayed = holeCountPar3
        statistics.totalPar4sPlayed = holeCountPar4
        statistics.totalPar5sPlayed = holeCountPar5
        statistics.totalFairwayOpportunities = totalFairwayOpportunitiesOverall


        // Sort date-based arrays chronologically
        statistics.roundsWithScoreByDate.sort { $0.date < $1.date }
        statistics.roundsWithPuttsByDate.sort { $0.date < $1.date }
        statistics.roundsWithGIRByDate.sort { $0.date < $1.date }
        statistics.roundsWithFairwaysByDate.sort { $0.date < $1.date }

        return statistics
    }

    // Helper method to convert 9-hole rounds to equivalent 18-hole rounds for scoring avg
    private func totalRounds(forHoleCount standardCount: Int, from rounds: [Round]) -> Double {
        var equivalentRounds = 0.0
        for round in rounds {
            equivalentRounds += Double(round.holes.count) / Double(standardCount)
        }
        return equivalentRounds > 0 ? equivalentRounds : 1.0 // Avoid division by zero if only partial rounds exist
    }
}
