//
//  StatSummaryView.swift
//  GolfTracker
//
//  Created by Matteo Keller on 25.03.2025.
//


// File: Sources/Views/Components/StatSummaryView.swift
import SwiftUI

struct StatSummaryView: View {
    let statistics: Statistics
    
    // Target values for stats
    private let targetScore: Double = 78.0
    private let bestPuttsPerHole: Double = 1.5  // Best realistic putts per hole
    private let worstPuttsPerHole: Double = 3.0 // Worst expected putts per hole
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Key Statistics")
                .font(.headline)
                .padding(.bottom, 2)
            
            HStack(spacing: 20) {
                // Average Score
                CircularStatView(
                    value: getScoreProgress(),
                    label: "Avg Score",
                    valueText: String(format: "%.1f", statistics.averageScore),
                    color: getScoreColor()
                )
                
                // GIR
                CircularStatView(
                    value: min(statistics.girPercentage / 100.0, 1.0),
                    label: "GIR",
                    valueText: String(format: "%.0f%%", statistics.girPercentage),
                    color: Color.green
                )
            }
            
            HStack(spacing: 20) {
                // Fairways
                CircularStatView(
                    value: min(statistics.fairwayHitPercentage / 100.0, 1.0),
                    label: "Fairways",
                    valueText: String(format: "%.0f%%", statistics.fairwayHitPercentage),
                    color: Color.blue
                )
                
                // Putts/Hole
                CircularStatView(
                    value: getPuttsProgress(),
                    label: "Putts/Hole",
                    valueText: String(format: "%.1f", statistics.averagePuttsPerHole),
                    color: getPuttsColor()
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    // Calculate score progress (lower is better, so we invert)
    private func getScoreProgress() -> Double {
        if statistics.averageScore <= targetScore {
            // If better than target, fill completely
            return 1.0
        } else if statistics.averageScore >= 100 {
            // If over 100, minimum fill
            return 0.1
        } else {
            // Linear scale from target to 100
            let range = 100.0 - targetScore
            let overTarget = statistics.averageScore - targetScore
            return max(0.1, min(1.0, 1.0 - (overTarget / range)))
        }
    }
    
    // Calculate putts progress (lower is better)
    private func getPuttsProgress() -> Double {
        if statistics.averagePuttsPerHole <= bestPuttsPerHole {
            return 1.0
        } else if statistics.averagePuttsPerHole >= worstPuttsPerHole {
            return 0.1
        } else {
            let range = worstPuttsPerHole - bestPuttsPerHole
            let value = worstPuttsPerHole - statistics.averagePuttsPerHole
            return max(0.1, min(1.0, value / range))
        }
    }
    
    // Get color for score
    private func getScoreColor() -> Color {
        if statistics.averageScore <= targetScore - 5 {
            return Color.purple  // Exceptional
        } else if statistics.averageScore <= targetScore {
            return Color.green   // At or below target
        } else if statistics.averageScore <= targetScore + 5 {
            return Color.orange  // Slightly above target
        } else {
            return Color.red     // Well above target
        }
    }
    
    // Get color for putts
    private func getPuttsColor() -> Color {
        if statistics.averagePuttsPerHole <= 1.8 {
            return Color.purple  // Exceptional
        } else if statistics.averagePuttsPerHole <= 2.0 {
            return Color.green   // Good
        } else if statistics.averagePuttsPerHole <= 2.5 {
            return Color.orange  // Average
        } else {
            return Color.red     // Needs improvement
        }
    }
}

struct CircularStatView: View {
    let value: Double        // Progress value (0.0 to 1.0)
    let label: String        // Label text
    let valueText: String    // Value to display
    let color: Color         // Color of progress
    
    var body: some View {
        VStack {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: CGFloat(value))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: value)
                
                // Value text
                Text(valueText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
    }
}
