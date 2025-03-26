//
//  StatsView.swift
//  GolfTracker
//
//  Created by Matteo Keller on 25.03.2025.
//


// File: Sources/Views/StatsView.swift
import SwiftUI

struct StatsView: View {
    let statistics: Statistics
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Performance Summary")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Scoring stats
                    StatSection(title: "Scoring", stats: [
                        StatItem(label: "Average Score", value: String(format: "%.1f", statistics.averageScore)),
                        StatItem(label: "Rounds Played", value: "\(statistics.totalRounds)")
                    ])
                    
                    // Approach stats
                    StatSection(title: "Approach", stats: [
                        StatItem(label: "GIR Percentage", value: String(format: "%.1f%%", statistics.girPercentage)),
                        StatItem(label: "Fairways Hit", value: String(format: "%.1f%%", statistics.fairwayHitPercentage))
                    ])
                    
                    // Putting stats
                    StatSection(title: "Putting", stats: [
                        StatItem(label: "Putts per Hole", value: String(format: "%.2f", statistics.averagePuttsPerHole)),
                        StatItem(label: "Putts per Round", value: String(format: "%.1f", statistics.averagePuttsPerRound))
                    ])
                    
                    // Simplified trend chart placeholder
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Score Trend")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                Text("Score chart would appear here")
                                    .foregroundColor(.secondary)
                            )
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatSection: View {
    let title: String
    let stats: [StatItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 2) {
                ForEach(stats, id: \.label) { stat in
                    HStack {
                        Text(stat.label)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(stat.value)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color(.systemBackground))
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}

struct StatItem {
    let label: String
    let value: String
}