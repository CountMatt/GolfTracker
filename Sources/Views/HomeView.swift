// --- START OF FILE GolfTracker.swiftpm/Sources/Views/HomeView.swift ---

import SwiftUI
import OSLog

struct HomeView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingNewRoundOptions = false
    @State private var selectedTab = 0 // Default to Home tab (index 0)
    @State private var selectedRoundID: Round.ID? = nil
    @State private var showRoundView = false // Derived from selectedRoundID
    @State private var statistics: Statistics = Statistics() // Calculated stats

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "HomeView")

    var body: some View {
        NavigationStack {
            // Main TabView Structure
            TabView(selection: $selectedTab) {
                homeTab
                    .tag(0) // Tag for Home tab

                historyTab
                    .tag(2) // Tag for History tab

                statsTab
                    .tag(1) // Tag for Stats tab
            }
            .accentColor(Theme.accentPrimary) // Use Theme accent
            .onAppear {
                 configureAppearance()
                 logger.info("HomeView appeared. DataManager should handle loading.")
                 updateStatistics()
            }
            .onChange(of: dataManager.rounds) {
                 logger.info("DataManager rounds changed, updating statistics.")
                 updateStatistics()
            }
            .onChange(of: selectedRoundID) {
                showRoundView = (selectedRoundID != nil)
                logger.debug("selectedRoundID changed. showRoundView is now \(showRoundView)")
            }
            // Navigation Destination for RoundView
            .navigationDestination(isPresented: $showRoundView) {
                roundDestinationView // Extracted destination view builder
            }
            // Confirmation Dialog for New Round
            .confirmationDialog(
                "Choose number of holes",
                isPresented: $showingNewRoundOptions,
                titleVisibility: .visible
            ) {
                Button("9 Holes") { startNewRound(holeCount: 9) }
                Button("18 Holes") { startNewRound(holeCount: 18) }
                // Cancel button is implicit
            }
        } // End NavigationStack
    } // End body

    // MARK: - Tab Content Views

    // Home Tab Content
    private var homeTab: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: Theme.spacingL) {
                    headerView
                    startNewRoundButton
                    StatSummaryView(statistics: statistics)
                        .padding(.horizontal, Theme.spacingM)
                    recentRoundsSection
                    Spacer(minLength: 80)
                }
                .padding(.top)
            }
        }
        .navigationBarHidden(true)
        .tabItem { Label("Home", systemImage: "house.fill") }
    }

    // History Tab Content
    private var historyTab: some View {
        // Note: RoundHistoryView needs the refined RoundSummaryRow defined below
        RoundHistoryView(
            rounds: dataManager.rounds,
            selectedRoundID: $selectedRoundID
        )
        .tabItem { Label("History", systemImage: "list.bullet") }
    }

    // Statistics Tab Content
    private var statsTab: some View {
        StatsView(statistics: statistics)
        .tabItem { Label("Statistics", systemImage: "chart.bar.fill") }
    }


    // MARK: - Subviews for Home Tab

     private var headerView: some View {
        ZStack {
             LinearGradient(
                 colors: [Theme.surface, Theme.background],
                 startPoint: .top,
                 endPoint: .bottom
             )
            .frame(height: 120)
            .cornerRadius(Theme.cornerRadiusL)
            .padding(.horizontal, Theme.spacingM)

            VStack(spacing: Theme.spacingXS) {
                Text("Golf Tracker")
                    .font(Theme.fontDisplayLarge)
                    .foregroundColor(Theme.textPrimary)
                Text("\(statistics.totalRounds) rounds recorded")
                    .font(Theme.fontHeadline)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(.top, Theme.spacingS)
    }

    private var startNewRoundButton: some View {
        Button { showingNewRoundOptions = true } label: {
            HStack {
                VStack(alignment: .leading, spacing: Theme.spacingXXS) {
                    Text("Start New Round")
                        .font(Theme.fontTitle2)
                        .foregroundColor(Theme.textOnAccent)
                    Text("Record your next golf adventure")
                        .font(Theme.fontBody)
                        .foregroundColor(Theme.textOnAccent.opacity(0.9))
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.textOnAccent)
            }
            .padding(Theme.spacingM)
            .background(Theme.accentPrimary)
            .cornerRadius(Theme.cornerRadiusL)
            .modifier(Theme.standardShadow)
            .padding(.horizontal, Theme.spacingM)
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var recentRoundsSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            HStack {
                Text("Recent Rounds")
                    .font(Theme.fontTitle3)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                 Button("View All") { selectedTab = 2 }
                    .font(Theme.fontCallout)
                    .foregroundColor(Theme.accentPrimary)
            }
            .padding(.horizontal, Theme.spacingM)

            if dataManager.rounds.isEmpty {
                 emptyStateView
                    .padding(.horizontal, Theme.spacingM)
            } else {
                 VStack(spacing: 0) {
                     ForEach(dataManager.rounds.sorted(by: { $0.date > $1.date }).prefix(3)) { round in
                         // Use the refined RoundSummaryRow defined below
                         RoundSummaryRow(round: round)
                         .padding(.horizontal, Theme.spacingM)
                         .padding(.vertical, Theme.spacingS) // Padding handled by listRowInsets in HistoryView, add here for Home
                         .contentShape(Rectangle())
                         .onTapGesture { navigateToRound(id: round.id) }
                          .contextMenu { deleteButton(for: round) }

                         if round.id != dataManager.rounds.sorted(by: { $0.date > $1.date }).prefix(3).last?.id {
                             Theme.divider
                                .padding(.leading, Theme.spacingM)
                         }
                     }
                 }
                 .background(Theme.surface)
                 .cornerRadius(Theme.cornerRadiusL)
                 .modifier(Theme.standardShadow)
                 .padding(.horizontal, Theme.spacingM)
            }
        }
    }

    private var emptyStateView: some View {
         VStack(spacing: Theme.spacingM) {
            Image(systemName: "figure.golf")
                .font(.system(size: 60))
                .foregroundColor(Theme.textSecondary.opacity(0.5))
            Text("No rounds recorded yet")
                .font(Theme.fontHeadline)
                .foregroundColor(Theme.textSecondary)
            Text("Tap 'Start New Round' to begin!")
                .font(Theme.fontSubheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.spacingM)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.spacingXL)
        .background(Theme.surface)
        .cornerRadius(Theme.cornerRadiusL)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusL)
                .stroke(Theme.background, lineWidth: 1)
        )
    }

    // MARK: - Navigation Destination Builder
    @ViewBuilder private var roundDestinationView: some View {
        if let id = selectedRoundID,
           let index = dataManager.rounds.firstIndex(where: { $0.id == id }) {
             let roundBinding = Binding<Round>(
                 get: {
                     guard index < dataManager.rounds.count, dataManager.rounds[index].id == id else {
                          logger.error("Binding GET: Index out of bounds or ID mismatch for \(id). Returning default.")
                          return Round.createNew(holeCount: 18)
                     }
                      return dataManager.rounds[index]
                 },
                 set: { updatedRound in
                      logger.debug("Binding SET: Updating round \(updatedRound.id)")
                     dataManager.updateRound(updatedRound)
                 }
             )
             RoundView(round: roundBinding)
                  .onDisappear {
                       logger.debug("RoundView disappeared. Setting selectedRoundID to nil.")
                       selectedRoundID = nil
                  }
        } else {
            Text("Error: Round data not available for navigation.")
                .font(Theme.fontBody)
                .foregroundColor(Theme.negative)
                .onAppear { logger.error("Error: Could not find index for round ID \(selectedRoundID?.uuidString ?? "nil") in navigationDestination build.") }
        }
   }


    // MARK: - Data Management Methods
    private func startNewRound(holeCount: Int) {
        let newRound = Round.createNew(holeCount: holeCount)
        dataManager.addRound(newRound)
        logger.info("Created new \(holeCount)-hole round with ID: \(newRound.id).")
        DispatchQueue.main.async {
            self.navigateToRound(id: newRound.id)
        }
    }

    private func updateStatistics() {
        let calculator = StatisticsCalculator()
        let newStats = calculator.calculateStatistics(from: dataManager.rounds)
        self.statistics = newStats
        logger.info("Statistics updated.")
    }

    private func deleteRound(_ roundToDelete: Round) {
         dataManager.deleteRound(withId: roundToDelete.id)
         logger.info("Deleted round requested for ID: \(roundToDelete.id).")
    }

    private func navigateToRound(id: Round.ID) {
         selectedRoundID = id
         logger.info("Setting selectedRoundID to trigger navigation: \(id)")
    }

    // MARK: - Helper Views & Configuration

    @ViewBuilder private func deleteButton(for round: Round) -> some View {
        Button(role: .destructive) { deleteRound(round) } label: {
            Label("Delete Round", systemImage: "trash")
        }
        .tint(Theme.negative)
    }

    // Configure TabBar and NavigationBar appearance
    private func configureAppearance() {
        // Tab Bar Appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Theme.surface)

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor(Theme.textSecondary)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.textSecondary)]
        itemAppearance.selected.iconColor = UIColor(Theme.accentPrimary)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.accentPrimary)]

        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        tabBarAppearance.inlineLayoutAppearance = itemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Navigation Bar Appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(Theme.surface)
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.textPrimary),
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}

// MARK: - Round Summary Row (Refined Spacing) - DEFINED HERE
struct RoundSummaryRow: View {
    let round: Round

    var scoreString: String {
        let rel = round.scoreRelativeToPar
        if rel == 0 { return "E" }
        else if rel > 0 { return "+\(rel)" }
        else { return "\(rel)" }
    }
    var scoreColor: Color {
        let rel = round.scoreRelativeToPar
        if rel < 0 { return Theme.negative }
        else if rel == 0 { return Theme.accentPrimary }
        else { return Theme.textSecondary }
    }
    var formattedDate: String {
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none
        return f.string(from: round.date)
    }

    var body: some View {
        HStack(spacing: Theme.spacingM) {
             Text(round.isNineHoles ? "9" : "18")
                 .font(Theme.fontCaptionBold)
                 .frame(width: 24, height: 24)
                 .background(Theme.textSecondary.opacity(0.1))
                 .foregroundColor(Theme.textSecondary)
                 .clipShape(Circle())

             VStack(alignment: .leading, spacing: Theme.spacingXXS) {
                 Text(round.courseName.isEmpty ? "Unknown Course" : round.courseName)
                    .font(Theme.fontHeadline)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                 Text(formattedDate)
                    .font(Theme.fontSubheadline)
                    .foregroundColor(Theme.textSecondary)

                 HStack(spacing: Theme.spacingM) { // Increased spacing between stats
                     if !round.isNineHoles || round.fairwayOpportunities > 0 {
                        statIconText(icon: "arrow.up.forward.circle", value: round.fairwayPercentage, format: "%.0f%%")
                     }
                     statIconText(icon: "target", value: round.girPercentage, format: "%.0f%%")
                     statIconText(icon: "flag.fill", value: Double(round.totalPutts), format: "%.0f P")
                 }
                 .padding(.top, Theme.spacingXS)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: Theme.spacingXXS) {
                 Text("\(round.totalScore)")
                    .font(Theme.fontTitle2)
                    .foregroundColor(Theme.textPrimary)
                 Text(scoreString)
                    .font(Theme.fontHeadline)
                    .foregroundColor(scoreColor)
                    .padding(.vertical, Theme.spacingXXS / 2)
                    .padding(.horizontal, Theme.spacingXS)
                    .background(scoreColor.opacity(0.15))
                    .cornerRadius(Theme.cornerRadiusS / 1.5)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(Theme.textSecondary.opacity(0.5))
        }
        // Row padding is handled by the container (List or VStack)
    }

     private func statIconText(icon: String, value: Double, format: String) -> some View {
         guard value.isFinite else { return AnyView(EmptyView()) }
         return AnyView(
            HStack(spacing: Theme.spacingXXS) { // Tight spacing for icon/text
                Image(systemName: icon)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textSecondary)
                Text(String(format: format, value))
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textSecondary)
            }
         )
     }
}

// MARK: - PressableButtonStyle
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview Provider
#if DEBUG
struct HomeView_Previews: PreviewProvider { static var previews: some View { HomeView() } }
#endif
// --- END OF FILE GolfTracker.swiftpm/Sources/Views/HomeView.swift ---
