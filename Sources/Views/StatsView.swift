
// File: Sources/Views/StatsView.swift
import SwiftUI
import Charts // Import Charts
import OSLog // Assuming you might want logging here too

struct StatsView: View {
    let statistics: Statistics

    // Define colors for charts and UI elements
    let primaryColor = Color.green // Or Color(hex:"18A558")
    let secondaryColor = Color.blue
    let tertiaryColor = Color.orange
    let quaternaryColor = Color(hex: "5F6B7A") // Greyish blue
    let backgroundColor = Color(.systemGroupedBackground) // Standard grouped background
    let cardBackgroundColor = Color(.secondarySystemGroupedBackground) // Background for cards

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "StatsView")

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) { // Increased spacing

                    // --- Trend Charts ---
                    VStack(alignment: .leading) {
                         Text("Performance Trends")
                             .font(.title2).bold()
                             .padding(.horizontal)
                        trendChartSection // Extracted chart section
                    }
                     .padding(.bottom) // Add padding after charts

                    // --- Detailed Stat Sections ---
                    Text("Detailed Statistics")
                        .font(.title2).bold()
                        .padding(.horizontal)

                    StatSectionView(title: "Overall Averages", backgroundColor: cardBackgroundColor) {
                        StatItemView(label: "Avg Score (18 holes)", value: formatStatValue(statistics.averageScore, format: "%.1f"))
                        StatItemView(label: "GIR %", value: formatStatValue(statistics.girPercentage, format: "%.1f%%"))
                        StatItemView(label: "Fairways Hit %", value: formatStatValue(statistics.fairwayHitPercentage, format: "%.1f%%"))
                        StatItemView(label: "Avg Putts / Hole", value: formatStatValue(statistics.averagePuttsPerHole, format: "%.2f"))
                        StatItemView(label: "Avg Putts / Round", value: formatStatValue(statistics.averagePuttsPerRound, format: "%.1f"))
                         StatItemView(label: "Total Rounds", value: "\(statistics.totalRounds)")
                         StatItemView(label: "Total Holes", value: "\(statistics.totalHolesPlayed)")
                    }

                    StatSectionView(title: "Performance by Par", backgroundColor: cardBackgroundColor) {
                        StatItemView(label: "Avg Score Par 3", value: formatStatValue(statistics.avgScorePar3, format: "%.2f"))
                        StatItemView(label: "Avg Score Par 4", value: formatStatValue(statistics.avgScorePar4, format: "%.2f"))
                        StatItemView(label: "Avg Score Par 5", value: formatStatValue(statistics.avgScorePar5, format: "%.2f"))
                        Divider().padding(.vertical, 4)
                        StatItemView(label: "Avg Putts Par 3", value: formatStatValue(statistics.avgPuttsPar3, format: "%.2f"))
                        StatItemView(label: "Avg Putts Par 4", value: formatStatValue(statistics.avgPuttsPar4, format: "%.2f"))
                        StatItemView(label: "Avg Putts Par 5", value: formatStatValue(statistics.avgPuttsPar5, format: "%.2f"))
                        Divider().padding(.vertical, 4)
                         StatItemView(label: "GIR % Par 3", value: formatStatValue(statistics.girPercentagePar3, format: "%.1f%%"))
                    }

                    StatSectionView(title: "Putting Breakdown", backgroundColor: cardBackgroundColor) {
                        StatItemView(label: "Avg Putts on GIR", value: formatStatValue(statistics.avgPuttsOnGIR, format: "%.2f"))
                        StatItemView(label: "Avg Putts Off GIR", value: formatStatValue(statistics.avgPuttsOffGIR, format: "%.2f"))
                        Divider().padding(.vertical, 4)
                        StatItemView(label: "1-Putt %", value: formatStatValue(statistics.onePuttPercentage, format: "%.1f%%"))
                        StatItemView(label: "3-Putt+ %", value: formatStatValue(statistics.threePuttPercentage, format: "%.1f%%"))
                    }

                    StatSectionView(title: "Driving Accuracy", backgroundColor: cardBackgroundColor) {
                        StatItemView(label: "Fairways Hit %", value: formatStatValue(statistics.fairwaysHitPercentageTotal, format: "%.1f%%"))
                         StatItemView(label: "Missed Left %", value: formatStatValue(statistics.fairwaysMissedLeftPercentage, format: "%.1f%%"))
                         StatItemView(label: "Missed Right %", value: formatStatValue(statistics.fairwaysMissedRightPercentage, format: "%.1f%%"))
                         StatItemView(label: "Total Opportunities", value: "\(statistics.totalFairwayOpportunities)")
                    }

                    StatSectionView(title: "Strokes Gained (vs Benchmark)", backgroundColor: cardBackgroundColor) {
                        StatItemView(label: "Total", value: formatStrokesGained(statistics.strokesGainedTotal))
                        StatItemView(label: "Off The Tee", value: formatStrokesGained(statistics.strokesGainedOffTheTee))
                        StatItemView(label: "Approach", value: formatStrokesGained(statistics.strokesGainedApproach))
                        StatItemView(label: "Around Green", value: formatStrokesGained(statistics.strokesGainedAroundGreen))
                        StatItemView(label: "Putting", value: formatStrokesGained(statistics.strokesGainedPutting))
                        Text("Note: Strokes Gained requires benchmark data and detailed shot tracking for accurate calculation.")
                             .font(.caption)
                             .foregroundColor(.secondary)
                             .padding(.top, 5)
                             .fixedSize(horizontal: false, vertical: true) // Allow text wrap
                    }

                } // End Main VStack
                .padding(.vertical)
            } // End ScrollView
            .background(backgroundColor.ignoresSafeArea()) // Apply background to ScrollView
            .navigationTitle("Statistics")
            .onAppear {
                 logger.info("StatsView appeared.")
                 // Statistics are passed in, no need to load here
            }
        }
        .navigationViewStyle(.stack) // Use stack style for standard behavior
    }

    // MARK: - Extracted Chart Section
    private var trendChartSection: some View {
         VStack(spacing: 20) {
             // Pass the correct data and closures to the generic chart function
             trendChart(
                 title: "Score Trend (vs Par)",
                 data: statistics.roundsWithScoreByDate, // Use data with relative score
                 dateProvider: { $0.date },
                 valueProvider: { Double($0.scoreRelativeToPar) } // Access the relative score
             )
             .frame(height: 200)
             .chartYAxisLabel("Score vs Par")

             trendChart(
                 title: "Putts per Round Trend",
                 data: statistics.roundsWithPuttsByDate,
                 dateProvider: { $0.date },
                 valueProvider: { Double($0.putts) }
             )
             .frame(height: 200)
             .chartYAxisLabel("Total Putts")

             trendChart(
                 title: "GIR % Trend",
                 data: statistics.roundsWithGIRByDate,
                 dateProvider: { $0.date },
                 valueProvider: { $0.percentage }
             )
             .frame(height: 200)
             .chartYScale(domain: 0...100)
             .chartYAxisLabel("GIR %")

             trendChart(
                 title: "Fairway % Trend",
                 data: statistics.roundsWithFairwaysByDate,
                 dateProvider: { $0.date },
                 valueProvider: { $0.percentage }
             )
             .frame(height: 200)
              .chartYScale(domain: 0...100)
              .chartYAxisLabel("Fairway %")
         }
         .padding(.horizontal) // Apply padding around the VStack containing charts
    }


    // MARK: - Reusable Trend Chart Component
    private func trendChart<T: Identifiable>(
        title: String,
        data: [T],
        dateProvider: @escaping (T) -> Date, // Closure to get Date for X-axis
        valueProvider: @escaping (T) -> Double // Closure to get Double for Y-axis
    ) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)

            // Handle empty data case for charts
            if data.isEmpty {
                 Text("No data available for this chart.")
                     .font(.caption)
                     .foregroundColor(.secondary)
                     .frame(height: 200) // Match chart height
                     .frame(maxWidth: .infinity)
                     .background(cardBackgroundColor)
                     .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    Chart {
                        ForEach(data) { item in
                            let date = dateProvider(item)
                            let value = valueProvider(item)

                            LineMark(x: .value("Date", date), y: .value("Value", value))
                                .foregroundStyle(primaryColor)
                                .interpolationMethod(.catmullRom)

                            PointMark(x: .value("Date", date), y: .value("Value", value))
                                .foregroundStyle(primaryColor)
                                .symbolSize(CGSize(width: 5, height: 5))
                        }
                    }
                    .chartXAxis {
                         AxisMarks(values: .automatic(desiredCount: data.count > 10 ? 10 : 5)) { value in
                             AxisGridLine()
                             AxisTick()
                             AxisValueLabel(format: .dateTime.month().day())
                         }
                     }
                     .chartYAxis {
                         AxisMarks { value in
                             AxisGridLine()
                             AxisTick()
                             AxisValueLabel() // Default formatting
                         }
                     }
                    .frame(minWidth: max(300, CGFloat(data.count * 30))) // Ensure minimum scrollable width
                } // End ScrollView
            }
        }
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }

    // MARK: - Helper Functions for Formatting

    // Helper to format optional Strokes Gained values
    private func formatStrokesGained(_ value: Double?) -> String {
        guard let value = value, value.isFinite else { return "N/A" }
        return String(format: "%+.2f", value)
    }

    // Helper to format regular stat values, handling potential NaN/Infinite
     private func formatStatValue(_ value: Double, format: String) -> String {
         guard value.isFinite else { return "N/A" }
         return String(format: format, value)
     }
}


// MARK: - Reusable Stat Section View Component
struct StatSectionView<Content: View>: View {
    let title: String
    let backgroundColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).padding(.horizontal).padding(.top, 8)
             VStack(alignment: .leading, spacing: 0) { content }
             .padding(.horizontal).padding(.bottom, 8)
        }
        .background(backgroundColor).cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Reusable Stat Item View Component
struct StatItemView: View {
    let label: String
    let value: String

    var body: some View {
         HStack {
            Text(label).font(.subheadline).foregroundColor(.secondary).lineLimit(1)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.semibold).foregroundColor(Color(hex:"252C34"))
        }
        .padding(.vertical, 6)
    }
}


// MARK: - Previews
#if DEBUG
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleStats: Statistics = {
            var stats = Statistics()
            let calc = StatisticsCalculator()
            stats = calc.calculateStatistics(from: SampleData.sampleRounds)
             let now = Date()
             // Ensure DateScorePair includes relative score for preview
             stats.roundsWithScoreByDate = [
                 DateScorePair(date: now.addingTimeInterval(-86400*14), score: 85, scoreRelativeToPar: 13),
                 DateScorePair(date: now.addingTimeInterval(-86400*10), score: 88, scoreRelativeToPar: 16),
                 DateScorePair(date: now.addingTimeInterval(-86400*7), score: 82, scoreRelativeToPar: 10),
                 DateScorePair(date: now.addingTimeInterval(-86400*3), score: 84, scoreRelativeToPar: 12),
                 DateScorePair(date: now.addingTimeInterval(-86400*1), score: 79, scoreRelativeToPar: 7)
             ]
             stats.roundsWithPuttsByDate = [ DatePuttsPair(date: now.addingTimeInterval(-86400*14), putts: 34), DatePuttsPair(date: now.addingTimeInterval(-86400*10), putts: 36), DatePuttsPair(date: now.addingTimeInterval(-86400*7), putts: 31), DatePuttsPair(date: now.addingTimeInterval(-86400*3), putts: 33), DatePuttsPair(date: now.addingTimeInterval(-86400*1), putts: 30) ]
             stats.roundsWithGIRByDate = [ DatePercentPair(date: now.addingTimeInterval(-86400*14), percentage: 50.0), DatePercentPair(date: now.addingTimeInterval(-86400*7), percentage: 61.1), DatePercentPair(date: now.addingTimeInterval(-86400*1), percentage: 72.2) ]
             stats.roundsWithFairwaysByDate = [ DatePercentPair(date: now.addingTimeInterval(-86400*14), percentage: 64.3), DatePercentPair(date: now.addingTimeInterval(-86400*7), percentage: 71.4), DatePercentPair(date: now.addingTimeInterval(-86400*1), percentage: 78.6) ]
            return stats
        }()
        StatsView(statistics: sampleStats)
    }
}
#endif

