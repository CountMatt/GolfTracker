// --- START OF FILE GolfTracker.swiftpm/Sources/Views/StatsView.swift ---

import SwiftUI
import Charts
import OSLog

struct StatsView: View {
    let statistics: Statistics // Passed in from HomeView
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "StatsView")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.spacingL) { // Use Theme spacing
                // --- Trend Charts Section ---
                VStack(alignment: .leading, spacing: Theme.spacingS) { // Added spacing
                     Text("Performance Trends")
                         .font(Theme.fontTitle2) // Use Theme font
                         .padding(.horizontal, Theme.spacingM) // Use Theme spacing
                    trendChartSection // Extracted chart section view
                }
                 .padding(.bottom, Theme.spacingM) // Padding after charts

                // --- Detailed Stat Sections Header ---
                Text("Detailed Statistics")
                    .font(Theme.fontTitle2) // Use Theme font
                    .padding(.horizontal, Theme.spacingM) // Use Theme spacing

                // --- Reusable Stat Sections ---
                // Pass Theme.surface for the card background color
                StatSectionView(title: "Overall Averages", backgroundColor: Theme.surface) {
                    StatItemView(label: "Avg Score (18 holes)", value: formatStatValue(statistics.averageScore, format: "%.1f"))
                    StatItemView(label: "GIR %", value: formatStatValue(statistics.girPercentage, format: "%.1f%%"))
                    StatItemView(label: "Fairways Hit %", value: formatStatValue(statistics.fairwayHitPercentage, format: "%.1f%%"))
                    StatItemView(label: "Avg Putts / Hole", value: formatStatValue(statistics.averagePuttsPerHole, format: "%.2f"))
                    StatItemView(label: "Avg Putts / Round", value: formatStatValue(statistics.averagePuttsPerRound, format: "%.1f"))
                     Theme.divider.padding(.vertical, Theme.spacingXXS) // Add divider within section
                     StatItemView(label: "Total Rounds", value: "\(statistics.totalRounds)")
                     StatItemView(label: "Total Holes", value: "\(statistics.totalHolesPlayed)")
                }

                StatSectionView(title: "Performance by Par", backgroundColor: Theme.surface) {
                    StatItemView(label: "Avg Score Par 3", value: formatStatValue(statistics.avgScorePar3, format: "%.2f"))
                    StatItemView(label: "Avg Score Par 4", value: formatStatValue(statistics.avgScorePar4, format: "%.2f"))
                    StatItemView(label: "Avg Score Par 5", value: formatStatValue(statistics.avgScorePar5, format: "%.2f"))
                    Theme.divider.padding(.vertical, Theme.spacingXXS)
                    StatItemView(label: "Avg Putts Par 3", value: formatStatValue(statistics.avgPuttsPar3, format: "%.2f"))
                    StatItemView(label: "Avg Putts Par 4", value: formatStatValue(statistics.avgPuttsPar4, format: "%.2f"))
                    StatItemView(label: "Avg Putts Par 5", value: formatStatValue(statistics.avgPuttsPar5, format: "%.2f"))
                    Theme.divider.padding(.vertical, Theme.spacingXXS)
                     StatItemView(label: "GIR % Par 3", value: formatStatValue(statistics.girPercentagePar3, format: "%.1f%%"))
                }

                StatSectionView(title: "Putting Breakdown", backgroundColor: Theme.surface) {
                    StatItemView(label: "Avg Putts on GIR", value: formatStatValue(statistics.avgPuttsOnGIR, format: "%.2f"))
                    StatItemView(label: "Avg Putts Off GIR", value: formatStatValue(statistics.avgPuttsOffGIR, format: "%.2f"))
                    Theme.divider.padding(.vertical, Theme.spacingXXS)
                    StatItemView(label: "1-Putt %", value: formatStatValue(statistics.onePuttPercentage, format: "%.1f%%"))
                    StatItemView(label: "3-Putt+ %", value: formatStatValue(statistics.threePuttPercentage, format: "%.1f%%"))
                }

                StatSectionView(title: "Driving Accuracy", backgroundColor: Theme.surface) {
                    StatItemView(label: "Fairways Hit %", value: formatStatValue(statistics.fairwaysHitPercentageTotal, format: "%.1f%%"))
                     StatItemView(label: "Missed Left %", value: formatStatValue(statistics.fairwaysMissedLeftPercentage, format: "%.1f%%"))
                     StatItemView(label: "Missed Right %", value: formatStatValue(statistics.fairwaysMissedRightPercentage, format: "%.1f%%"))
                     Theme.divider.padding(.vertical, Theme.spacingXXS)
                     StatItemView(label: "Total Opportunities", value: "\(statistics.totalFairwayOpportunities)")
                }

                StatSectionView(title: "Strokes Gained (vs Benchmark)", backgroundColor: Theme.surface) {
                    StatItemView(label: "Total", value: formatStrokesGained(statistics.strokesGainedTotal))
                    StatItemView(label: "Off The Tee", value: formatStrokesGained(statistics.strokesGainedOffTheTee))
                    StatItemView(label: "Approach", value: formatStrokesGained(statistics.strokesGainedApproach))
                    StatItemView(label: "Around Green", value: formatStrokesGained(statistics.strokesGainedAroundGreen))
                    StatItemView(label: "Putting", value: formatStrokesGained(statistics.strokesGainedPutting))
                    Text("Note: Strokes Gained requires benchmark data and detailed shot tracking for accurate calculation.")
                         .font(Theme.fontCaption) // Use Theme font
                         .foregroundColor(Theme.textSecondary) // Use Theme color
                         .padding(.top, Theme.spacingXS) // Use Theme spacing
                         .fixedSize(horizontal: false, vertical: true) // Allow text wrap
                }

            } // End Main VStack
            .padding(.vertical) // Overall vertical padding for scroll content
        } // End ScrollView
        .background(Theme.background.ignoresSafeArea()) // Apply Theme background to ScrollView
        .navigationTitle("Statistics")
        .onAppear {
             logger.info("StatsView appeared.")
        }
    }

    // MARK: - Extracted Chart Section
    // ... (trendChartSection remains unchanged from the previous themed version) ...
    private var trendChartSection: some View {
         VStack(spacing: Theme.spacingM) { // Use Theme spacing between charts
             // Pass data and accessors to the generic chart function
             trendChart(
                 title: "Score Trend (vs Par)",
                 data: statistics.roundsWithScoreByDate,
                 dateProvider: { $0.date },
                 valueProvider: { Double($0.scoreRelativeToPar) }, // Use relative score
                 lineColor: Theme.accentSecondary // Use Blue for score trend
             )
             .frame(height: 200) // Keep fixed height
             .chartYAxisLabel("Score vs Par", alignment: .center) // Add Y axis label

             trendChart(
                 title: "Putts per Round Trend",
                 data: statistics.roundsWithPuttsByDate,
                 dateProvider: { $0.date },
                 valueProvider: { Double($0.putts) },
                 lineColor: Theme.negative // Use Red for putts (lower is better)
             )
             .frame(height: 200)
             .chartYAxisLabel("Total Putts", alignment: .center)

             trendChart(
                 title: "GIR % Trend",
                 data: statistics.roundsWithGIRByDate,
                 dateProvider: { $0.date },
                 valueProvider: { $0.percentage },
                 lineColor: Theme.positive // Use Green for GIR (higher is better)
             )
             .frame(height: 200)
             .chartYScale(domain: 0...100) // Keep scale 0-100 for percentages
             .chartYAxisLabel("GIR %", alignment: .center)

             trendChart(
                 title: "Fairway % Trend",
                 data: statistics.roundsWithFairwaysByDate,
                 dateProvider: { $0.date },
                 valueProvider: { $0.percentage },
                 lineColor: Theme.warning // Use Orange for Fairways
             )
             .frame(height: 200)
              .chartYScale(domain: 0...100)
              .chartYAxisLabel("Fairway %", alignment: .center)
         }
         .padding(.horizontal, Theme.spacingM) // Padding around the chart group
    }

    // MARK: - Reusable Trend Chart Component
    // ... (trendChart function remains unchanged from the previous themed version) ...
    private func trendChart<T: Identifiable>(
        title: String,
        data: [T],
        dateProvider: @escaping (T) -> Date,
        valueProvider: @escaping (T) -> Double,
        lineColor: Color // Pass in line color
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) { // Add spacing
            Text(title).font(Theme.fontHeadline) // Use Theme font

            // Handle empty data case
            if data.isEmpty {
                 Text("No data available for this chart.")
                     .font(Theme.fontCaption) // Use Theme font
                     .foregroundColor(Theme.textSecondary) // Use Theme color
                     .frame(height: 200, alignment: .center) // Match chart height and center text
                     .frame(maxWidth: .infinity)
                     .background(Theme.surface) // Use Theme surface
                     .cornerRadius(Theme.cornerRadiusM) // Use Theme radius
            } else {
                Chart {
                    ForEach(data) { item in
                        let date = dateProvider(item)
                        let value = valueProvider(item)

                        // Line Mark - Use specified line color
                        LineMark(
                            x: .value("Date", date),
                            y: .value("Value", value)
                        )
                        .foregroundStyle(lineColor) // Apply Theme color
                        .interpolationMethod(.catmullRom) // Smooth line

                        // Point Mark - Use specified line color
                        PointMark(
                            x: .value("Date", date),
                            y: .value("Value", value)
                        )
                        .foregroundStyle(lineColor) // Apply Theme color
                        .symbolSize(CGSize(width: 6, height: 6)) // Slightly larger points
                    }
                }
                // Customize X Axis (Date)
                .chartXAxis {
                     AxisMarks(values: .automatic(desiredCount: data.count > 10 ? 8 : 5)) { value in
                         AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 3])) // Dashed grid line
                            .foregroundStyle(Theme.divider.opacity(0.5))
                         AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Theme.divider)
                         AxisValueLabel(format: .dateTime.month(.abbreviated).day(), // Concise date format
                                        orientation: .vertical, // Orient labels vertically if needed
                                        verticalSpacing: Theme.spacingXS)
                            .font(Theme.fontCaption2) // Use Theme font
                            .foregroundStyle(Theme.textSecondary) // Use Theme color
                     }
                 }
                 // Customize Y Axis (Value)
                 .chartYAxis {
                     AxisMarks { value in
                         AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 3]))
                            .foregroundStyle(Theme.divider.opacity(0.5))
                         AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Theme.divider)
                         AxisValueLabel() // Default formatting for value
                            .font(Theme.fontCaption2) // Use Theme font
                            .foregroundStyle(Theme.textSecondary) // Use Theme color
                     }
                 }
                 // Add horizontal scroll for dense data
                 .chartScrollableAxes(.horizontal)
                 .chartXVisibleDomain(length: calculateXDomainLength(dataCount: data.count)) // Show recent N items initially
                 .frame(minWidth: 300) // Ensure minimum width if not scrollable
            }
        }
        .padding(Theme.spacingM) // Padding inside the card
        .background(Theme.surface) // Use Theme surface
        .cornerRadius(Theme.cornerRadiusM) // Use Theme radius
        .modifier(Theme.subtleShadow) // Use Theme shadow
    }


    private func calculateXDomainLength(dataCount: Int) -> Int {
        let desiredVisibleCount = 12
        return min(dataCount, desiredVisibleCount)
    }

    // MARK: - Helper Functions for Formatting (Ensure returns exist)

    // Helper to format optional Strokes Gained values
    private func formatStrokesGained(_ value: Double?) -> String {
        guard let value = value, value.isFinite else { return "N/A" }
        // --- FIXED: Added return ---
        return String(format: "%+.2f", value)
    }

    // Helper to format regular stat values, handling potential NaN/Infinite
     private func formatStatValue(_ value: Double, format: String) -> String {
         guard value.isFinite else { return "N/A" }
         // --- FIXED: Added return ---
         return String(format: format, value)
     }
}


// MARK: - Reusable Stat Section View Component
// ... (StatSectionView remains unchanged from the previous themed version) ...
struct StatSectionView<Content: View>: View {
    let title: String
    let backgroundColor: Color // Passed in (e.g., Theme.surface)
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) { // Use Theme spacing
            Text(title)
                .font(Theme.fontHeadline) // Use Theme font
                .foregroundColor(Theme.textPrimary) // Use Theme color
                .padding(.horizontal, Theme.spacingM) // Use Theme spacing
                .padding(.top, Theme.spacingS) // Use Theme spacing

             VStack(alignment: .leading, spacing: 0) { // No spacing between items in the list
                 content
             }
             .padding(.horizontal, Theme.spacingM) // Horizontal padding for content
             .padding(.bottom, Theme.spacingS) // Bottom padding for content
        }
        .background(backgroundColor) // Use passed background color
        .cornerRadius(Theme.cornerRadiusM) // Use Theme radius
        .modifier(Theme.subtleShadow) // Use Theme shadow
        .padding(.horizontal, Theme.spacingM) // Padding outside the section card
    }
}

// MARK: - Reusable Stat Item View Component
// ... (StatItemView remains unchanged from the previous themed version) ...
struct StatItemView: View {
    let label: String
    let value: String

    var body: some View {
         HStack {
            Text(label)
                .font(Theme.fontSubheadline) // Use Theme font
                .foregroundColor(Theme.textSecondary) // Use Theme color
                .lineLimit(1)
            Spacer()
            Text(value)
                .font(Theme.fontBodySemibold) // Use Theme font (slightly bolder value)
                .foregroundColor(Theme.textPrimary) // Use Theme color
        }
        .padding(.vertical, Theme.spacingXS) // Use Theme spacing for vertical padding
    }
}


// MARK: - Previews
#if DEBUG
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStats = StatisticsCalculator().calculateStatistics(from: SampleData.sampleRounds)
        NavigationView {
            StatsView(statistics: sampleStats)
        }
    }
}
#endif
// --- END OF FILE GolfTracker.swiftpm/Sources/Views/StatsView.swift ---
