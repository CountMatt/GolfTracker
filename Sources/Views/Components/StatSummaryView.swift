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
    
    var body: some View {
        VStack(spacing: 16) {
            HStack{
                Spacer().frame(width: 16)
                Text("Performance Overview")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "252C34"))
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Spacer().frame(width:0)
                // Average Score
                StatisticCard(
                    title: "Avg Score",
                    value: String(format: "%.1f", statistics.averageScore),
                    icon: "number.circle.fill",
                    color: Color(hex: "2D7D46")
                )
                
                // GIR
               
                StatisticCard(
                    title: "GIR",
                    value: String(format: "%.0f%%", statistics.girPercentage),
                    icon: "target",
                    color: Color(hex: "18A558")
                    
                )
                Spacer().frame(width: 0)
            }
            
            HStack(spacing: 12) {
                Spacer().frame(width: 0)
                // Fairways hit
                StatisticCard(
                    title: "Fairways",
                    value: String(format: "%.0f%%", statistics.fairwayHitPercentage),
                    icon: "arrow.up.forward",
                    color: Color(hex: "E67E22")
                )
                
                // Putts per hole
                StatisticCard(
                    title: "Putts/Hole",
                    value: String(format: "%.1f", statistics.averagePuttsPerHole),
                    icon: "flag.fill",
                    color: Color(hex: "5F6B7A")
                )
                Spacer().frame(width: 0)
            }
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card header
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "5F6B7A"))
            }
            
            // Value display
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "252C34"))
            
            // Progress indicator at bottom
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color(hex: "E2EADF"))
                        .frame(height: 4)
                    
                    // Progress fill
                    Capsule()
                        .fill(color)
                        .frame(width: min(CGFloat(valuePercentage) * geometry.size.width, geometry.size.width), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .frame(maxWidth: .infinity)
    }
    
    // Helper to approximate percentage for progress bar
    var valuePercentage: Double {
        // Convert string value to percentage for progress bar
        if let numValue = Double(value.replacingOccurrences(of: "%", with: "")) {
            if value.contains("%") {
                return numValue / 100.0
            } else if title == "Avg Score" {
                // Assuming good score is around 72, bad is 100+
                return max(0.0, min(1.0, (100.0 - numValue) / 28.0))
            } else if title == "Putts/Hole" {
                // Assuming 1.0 putts is perfect, 3.0 is poor
                return max(0.0, min(1.0, (3.0 - numValue) / 2.0))
            }
        }
        return 0.5 // Default fallback
    }
}


//MARK Circular Stats View

struct CircularStatView: View {
    let value: Double        // Progress value (0.0 to 1.0)
    let label: String        // Label text
    let valueText: String    // Value to display
    let color: Color         // Color of progress
    @State private var animatedValue: Double = 0
    
    var body: some View {
        VStack {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(hex: "E2EADF"), lineWidth: 10)
                    .frame(width: 90, height: 90)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: CGFloat(animatedValue))
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                
                // Center content
                VStack(spacing: 2) {
                    Text(valueText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "252C34"))
                    
                    Text(label)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "5F6B7A"))
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                animatedValue = newValue
            }
        }
    }
}
