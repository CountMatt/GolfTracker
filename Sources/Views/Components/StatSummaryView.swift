// --- START OF FILE GolfTracker.swiftpm/Sources/Views/Components/StatSummaryView.swift ---

import SwiftUI

// Overview Section for HomeView
struct StatSummaryView: View {
    let statistics: Statistics

    var body: some View {
        VStack(spacing: Theme.spacingM) { // Use Theme spacing
            // Section Header
            HStack {
                Text("Performance Overview")
                    .font(Theme.fontTitle3) // Use Theme font
                    .foregroundColor(Theme.textPrimary) // Use Theme color
                Spacer()
            }
            // Grid of Stat Cards
            VStack(spacing: Theme.spacingS) { // Use Theme spacing between rows
                // Row 1: Avg Score, GIR
                HStack(spacing: Theme.spacingS) { // Use Theme spacing between cards
                    StatisticCard(
                        title: "Avg Score",
                        value: String(format: "%.1f", statistics.averageScore),
                        icon: "number.circle.fill",
                        color: Theme.accentSecondary // Use Blue for Score
                    )
                    StatisticCard(
                        title: "GIR %",
                        value: String(format: "%.0f%%", statistics.girPercentage),
                        icon: "target",
                        color: Theme.positive // Use Green (positive) for GIR
                    )
                }
                // Row 2: Fairways, Putts/Hole
                HStack(spacing: Theme.spacingS) { // Use Theme spacing between cards
                    StatisticCard(
                        title: "Fairways",
                        value: String(format: "%.0f%%", statistics.fairwayHitPercentage),
                        icon: "arrow.up.forward.circle.fill", // Filled icon
                        color: Theme.warning // Use Orange (warning/neutral) for Fairways
                    )
                    StatisticCard(
                        title: "Putts/Hole",
                        value: String(format: "%.1f", statistics.averagePuttsPerHole),
                        icon: "flag.circle.fill", // Filled icon
                        color: Theme.neutral // Use Gray (neutral) for Putts
                    )
                }
            }
        }
        // No horizontal padding here - applied by HomeView where StatSummaryView is used
    }
}

// Reusable Card for displaying a single statistic
struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color // Color passed from StatSummaryView (using Theme colors)

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) { // Use Theme spacing
            // Card header: Icon and Title
            HStack {
                Image(systemName: icon)
                    .font(Theme.fontHeadline) // Use Theme font for icon
                    .foregroundColor(color) // Use passed Theme color
                Text(title)
                    .font(Theme.fontSubheadline) // Use Theme font
                    .foregroundColor(Theme.textSecondary) // Use Theme color
            }

            // Value display
            Text(value)
                .font(Theme.fontTitle2) // Use Theme font for value
                .foregroundColor(Theme.textPrimary) // Use Theme color

            // Progress indicator (optional, keep simple)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Theme.neutral.opacity(0.1)) // Use Theme neutral faded
                        .frame(height: 4)
                    // Progress fill
                    Capsule()
                        .fill(color) // Use passed Theme color
                        // Calculate width based on approximated percentage
                        .frame(width: min(CGFloat(valuePercentage) * geometry.size.width, geometry.size.width), height: 4)
                        .animation(.easeOut, value: valuePercentage) // Animate progress change
                }
            }
            .frame(height: 4) // Fixed height for progress bar
        }
        .padding(Theme.spacingM) // Use Theme spacing for padding inside card
        .background(Theme.surface) // Use Theme surface for card background
        .cornerRadius(Theme.cornerRadiusM) // Use Theme radius
        .modifier(Theme.subtleShadow) // Use Theme shadow
        .frame(maxWidth: .infinity) // Ensure cards take available horizontal space
    }

    // Helper to approximate percentage for progress bar (keep simple logic)
    var valuePercentage: Double {
        guard let numValue = Double(value.replacingOccurrences(of: "%", with: "")) else {
            return 0.3 // Default fallback if parsing fails
        }
        if value.contains("%") {
            // Percentage values (GIR, Fairways)
            return max(0.0, min(1.0, numValue / 100.0))
        } else if title == "Avg Score" {
            // Score: Lower is better. Map 72 (good) to 1.0, 100 (poor) to 0.0
            let score = numValue
            let goodScore = 72.0
            let poorScore = 100.0
            let percentage = (poorScore - score) / (poorScore - goodScore)
            return max(0.0, min(1.0, percentage))
        } else if title == "Putts/Hole" {
            // Putts: Lower is better. Map 1.5 (good) to 1.0, 2.5 (poor) to 0.0
            let putts = numValue
            let goodPutts = 1.5
            let poorPutts = 2.5
            let percentage = (poorPutts - putts) / (poorPutts - goodPutts)
            return max(0.0, min(1.0, percentage))
        }
        return 0.5 // Default fallback for unknown titles
    }
}


// Circular Stat View (If used elsewhere - currently not used in provided code)
// Apply Theme if you decide to use this component
struct CircularStatView: View {
    let value: Double        // Progress value (0.0 to 1.0)
    let label: String        // Label text
    let valueText: String    // Value to display
    let color: Color         // Color of progress (pass Theme color)
    @State private var animatedValue: Double = 0

    var body: some View {
        VStack(spacing: Theme.spacingXS) { // Use Theme spacing
            ZStack {
                // Background circle
                Circle()
                    .stroke(Theme.neutral.opacity(0.15), lineWidth: 10) // Use Theme neutral faded

                // Progress circle
                Circle()
                    .trim(from: 0, to: CGFloat(animatedValue))
                    .stroke(
                        color, // Use passed Theme color
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90)) // Start from top
                    .animation(.easeOut(duration: 1.0), value: animatedValue) // Animate progress

                // Center content
                VStack(spacing: 2) { // Tight spacing for center text
                    Text(valueText)
                        .font(Theme.fontTitle2) // Use Theme font
                        .foregroundColor(Theme.textPrimary) // Use Theme color
                    Text(label)
                        .font(Theme.fontCaption) // Use Theme font
                        .foregroundColor(Theme.textSecondary) // Use Theme color
                }
            }
            .frame(width: 100, height: 100) // Adjust size as needed
        }
        .onAppear { animatedValue = value } // Initial animation
        .onChange(of: value) { oldValue, newValue in animatedValue = newValue } // Animate updates (iOS 17+)
    }
}

// Preview for StatSummaryView
#if DEBUG
struct StatSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStats = StatisticsCalculator().calculateStatistics(from: SampleData.sampleRounds)
        StatSummaryView(statistics: sampleStats)
            .padding()
            .background(Theme.background) // Add background for context
            // .preferredColorScheme(.dark)
    }
}
#endif
// --- END OF FILE GolfTracker.swiftpm/Sources/Views/Components/StatSummaryView.swift ---
