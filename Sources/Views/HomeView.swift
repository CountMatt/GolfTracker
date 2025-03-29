
// File: Sources/Views/HomeView.swift
import SwiftUI
import OSLog // Import OSLog for logging

struct HomeView: View {
    // Use DataManager as the source of truth via @StateObject
    @StateObject private var dataManager = DataManager.shared

    // State for UI presentation
    @State private var showingNewRoundOptions = false
    @State private var selectedTab = 0 // Default to Home tab (index 0)

    // State for triggering navigation using the Round's ID
    @State private var selectedRoundID: Round.ID? = nil
    // isPresented derived from selectedRoundID != nil
    @State private var showRoundView = false

    // Logger instance
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "HomeView")

    // Color Palette
    let backgroundColor = Color(hex: "F8F9FA") // Light grey background
    let primaryColor = Color(hex: "18A558")    // Golf green
    let cardColor = Color.white               // White cards
    let textColor = Color(hex: "252C34")      // Dark text
    let secondaryTextColor = Color(hex: "5F6B7A") // Greyish text

    // State for calculated statistics
    @State private var statistics: Statistics = Statistics()

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // HOME TAB
                homeTabContent
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                // ROUND HISTORY TAB
                RoundHistoryView(
                    rounds: dataManager.rounds, // Pass non-binding for display
                    selectedRoundID: $selectedRoundID, // Pass binding for navigation trigger
                    // Pass colors
                    cardColor: cardColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    primaryColor: primaryColor,
                    backgroundColor: backgroundColor
                )
                .tabItem { Label("History", systemImage: "list.bullet") }
                .tag(2)

                // STATS TAB
                StatsView(statistics: statistics) // Pass calculated stats
                    .tabItem { Label("Statistics", systemImage: "chart.bar.fill") }
                    .tag(1)
            }
            .accentColor(primaryColor)
            .onAppear {
                 // DataManager loads automatically on init via Task
                 configureAppearance()
                 logger.info("HomeView appeared. DataManager should handle loading.")
                 // Initial stats calculation
                 updateStatistics()
            }
            // Listen for changes in DataManager's rounds to recalculate stats
             .onChange(of: dataManager.rounds) { _, _ in
                 logger.info("DataManager rounds changed, updating statistics.")
                 updateStatistics()
             }
            // Update showRoundView binding based on selectedRoundID state
             .onChange(of: selectedRoundID) { _, newID in
                showRoundView = (newID != nil)
                logger.debug("selectedRoundID changed to \(newID?.uuidString ?? "nil"). showRoundView is now \(showRoundView)")
             }
            // Navigation Destination triggered by showRoundView binding
            .navigationDestination(isPresented: $showRoundView) {
                 // Find the binding using the ID
                 if let id = selectedRoundID,
                    // Find index in the data manager's array
                    let index = dataManager.rounds.firstIndex(where: { $0.id == id }) {
                     // Create binding TO the DataManager's array element
                      let roundBinding = Binding<Round>(
                          get: {
                              // Ensure index is still valid before accessing
                              guard index < dataManager.rounds.count, dataManager.rounds[index].id == id else {
                                   logger.error("Binding GET: Index out of bounds or ID mismatch for \(id). Returning default.")
                                   // Return a dummy/default Round to prevent crash, though this indicates a state issue
                                   return Round.createNew(holeCount: 18) // Or handle differently
                              }
                               return dataManager.rounds[index]
                          },
                          set: { updatedRound in
                              // Update through DataManager to trigger save
                               logger.debug("Binding SET: Updating round \(updatedRound.id)")
                              dataManager.updateRound(updatedRound)
                          }
                      )
                      RoundView(round: roundBinding)
                           .onDisappear {
                                logger.debug("RoundView disappeared. Setting selectedRoundID to nil.")
                                // Reset the ID when the view is dismissed, allowing re-navigation
                                selectedRoundID = nil
                           }
                 } else {
                     Text("Error: Round data not available for navigation.")
                         .onAppear { logger.error("Error: Could not find index for round ID \(selectedRoundID?.uuidString ?? "nil") in navigationDestination build.") }
                 }
            }
            .confirmationDialog(
                "Choose number of holes",
                isPresented: $showingNewRoundOptions,
                titleVisibility: .visible
            ) {
                Button("9 Holes") { startNewRound(holeCount: 9) }
                Button("18 Holes") { startNewRound(holeCount: 18) }
                Button("Cancel", role: .cancel) { }
            }
        } // End NavigationStack
    } // End body

    // --- Home Tab Content ---
    private var homeTabContent: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    startNewRoundButton
                    StatSummaryView(statistics: statistics) // Display current stats
                        .padding(.horizontal)
                    recentRoundsSection
                    Spacer(minLength: 80)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Subviews for Home Tab
     private var headerView: some View {
        ZStack {
            LinearGradient( colors: [Color(hex: "E2EADF"), backgroundColor], startPoint: .top, endPoint: .bottom)
            .frame(height: 120).clipShape(RoundedRectangle(cornerRadius: 16)).padding(.horizontal)
            VStack(spacing: 8) {
                Text("Golf Tracker").font(.largeTitle).fontWeight(.heavy).foregroundColor(textColor)
                Text("\(statistics.totalRounds) rounds recorded").font(.headline).foregroundColor(secondaryTextColor)
            }
        }
        .padding(.top)
    }

    private var startNewRoundButton: some View {
        Button { showingNewRoundOptions = true } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start New Round").font(.title2).fontWeight(.semibold).foregroundColor(.white)
                    Text("Record your next golf adventure").font(.body).foregroundColor(Color.white.opacity(0.9))
                }
                Spacer()
                Image(systemName: "plus.circle.fill").font(.system(size: 40)).foregroundColor(.white)
            }
            .padding().background(primaryColor)
            .cornerRadius(16).shadow(color: primaryColor.opacity(0.4), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // Recent Rounds Section uses dataManager.rounds
    private var recentRoundsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Rounds").font(.title3).fontWeight(.semibold).foregroundColor(textColor)
                Spacer()
                 Button("View All") { selectedTab = 2 }
                 .font(.callout).foregroundColor(primaryColor)
            }
            .padding(.horizontal)

            if dataManager.rounds.isEmpty { // Check dataManager
                 emptyStateView.padding(.horizontal)
            } else {
                 VStack(spacing: 0) {
                     ForEach(dataManager.rounds.sorted(by: { $0.date > $1.date }).prefix(3)) { round in
                         RoundSummaryRow(
                             round: round, // Pass the round data directly
                             cardColor: cardColor, textColor: textColor, secondaryTextColor: secondaryTextColor, primaryColor: primaryColor
                         )
                         .padding(.horizontal).padding(.vertical, 12).background(cardColor)
                         .contentShape(Rectangle())
                         .onTapGesture { navigateToRound(id: round.id) } // Navigate using ID
                          .contextMenu { deleteButton(for: round) }

                         if round.id != dataManager.rounds.sorted(by: { $0.date > $1.date }).prefix(3).last?.id {
                             Divider().padding(.leading)
                         }
                     }
                 }
                 .background(cardColor).cornerRadius(16)
                 .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                 .padding(.horizontal)
            }
        }
    }

    private var emptyStateView: some View {
         VStack(spacing: 16) {
            Image(systemName: "figure.golf").font(.system(size: 60)).foregroundColor(secondaryTextColor.opacity(0.5))
            Text("No rounds recorded yet").font(.headline).foregroundColor(secondaryTextColor)
            Text("Tap 'Start New Round' to begin!").font(.subheadline).foregroundColor(secondaryTextColor).multilineTextAlignment(.center).padding(.horizontal)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40).background(cardColor).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(backgroundColor, lineWidth: 1))
    }

    // MARK: - Data Management Methods (Updated for DataManager)

    private func startNewRound(holeCount: Int) {
        let newRound = Round.createNew(holeCount: holeCount)
        dataManager.addRound(newRound) // Add via DataManager (triggers save)
        logger.info("Created new \(holeCount)-hole round with ID: \(newRound.id).")
        // Set the ID to trigger navigation AFTER the rounds array likely updates
        DispatchQueue.main.async {
            self.navigateToRound(id: newRound.id)
        }
    }

    // Calculates overall statistics from DataManager's rounds
    private func updateStatistics() {
        // Perform calculation directly if not too complex, or use Task if needed
        let calculator = StatisticsCalculator()
        let newStats = calculator.calculateStatistics(from: dataManager.rounds)
        self.statistics = newStats // Update @State property
        logger.info("Statistics updated.")
    }

    // Deletes a round using the DataManager
    private func deleteRound(_ roundToDelete: Round) {
         dataManager.deleteRound(withId: roundToDelete.id) // Delete via DataManager
         logger.info("Deleted round requested for ID: \(roundToDelete.id).")
         // UI updates automatically via @StateObject observing @Published rounds
    }

    // Sets the selected round ID to trigger navigation
    private func navigateToRound(id: Round.ID) {
         selectedRoundID = id
         logger.info("Setting selectedRoundID to trigger navigation: \(id)")
    }

    @ViewBuilder private func deleteButton(for round: Round) -> some View {
        Button(role: .destructive) { deleteRound(round) }
        label: { Label("Delete Round", systemImage: "trash") }
        .tint(.red)
    }

    private func configureAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(cardColor)
         let itemAppearance = UITabBarItemAppearance()
         itemAppearance.normal.iconColor = UIColor(secondaryTextColor)
         itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(secondaryTextColor)]
         itemAppearance.selected.iconColor = UIColor(primaryColor)
         itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(primaryColor)]
         tabBarAppearance.stackedLayoutAppearance = itemAppearance
         tabBarAppearance.inlineLayoutAppearance = itemAppearance
         tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(cardColor)
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(textColor), .font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}

// MARK: - Updated RoundSummaryRow (No functional change needed from previous)
struct RoundSummaryRow: View {
    let round: Round
    let cardColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let primaryColor: Color

    var scoreString: String { let rel = round.scoreRelativeToPar; if rel == 0 { return "E" } else if rel > 0 { return "+\(rel)" } else { return "\(rel)" } }
    var scoreColor: Color { let rel = round.scoreRelativeToPar; if rel < 0 { return .red } else if rel == 0 { return primaryColor } else { return secondaryTextColor } }

    var body: some View {
        HStack(spacing: 12) {
             Text(round.isNineHoles ? "9" : "18")
                 .font(.caption.weight(.bold)).frame(width: 24, height: 24)
                 .background(secondaryTextColor.opacity(0.1)).foregroundColor(secondaryTextColor).clipShape(Circle())
             VStack(alignment: .leading, spacing: 2) {
                 Text(round.courseName.isEmpty ? "Unknown Course" : round.courseName).font(.headline).foregroundColor(textColor).lineLimit(1)
                 Text(formattedDate).font(.subheadline).foregroundColor(secondaryTextColor)
                 HStack(spacing: 10) {
                     if !round.isNineHoles || round.fairwayOpportunities > 0 { statIconText(icon: "arrow.up.forward.circle", value: round.fairwayPercentage, format: "%.0f%%") }
                     statIconText(icon: "target", value: round.girPercentage, format: "%.0f%%")
                     statIconText(icon: "flag.fill", value: Double(round.totalPutts), format: "%.0f P")
                 }
                 .padding(.top, 4)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                 Text("\(round.totalScore)").font(.title2.weight(.bold)).foregroundColor(textColor)
                 Text(scoreString).font(.headline).foregroundColor(scoreColor)
                     .padding(.vertical, 2).padding(.horizontal, 5).background(scoreColor.opacity(0.15)).cornerRadius(6)
            }
            Image(systemName: "chevron.right").foregroundColor(secondaryTextColor.opacity(0.5))
        }
        .padding(.vertical, 8)
    }

     private func statIconText(icon: String, value: Double, format: String) -> some View {
         guard value.isFinite else { return AnyView(EmptyView()) }
         return AnyView( HStack(spacing: 3) { Image(systemName: icon).font(.caption).foregroundColor(secondaryTextColor); Text(String(format: format, value)).font(.caption).foregroundColor(secondaryTextColor) } )
     }
    var formattedDate: String { let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none; return f.string(from: round.date) }
}


// MARK: - PressableButtonStyle & Color Extension (Keep as they are)
struct PressableButtonStyle: ButtonStyle { func makeBody(configuration: Configuration) -> some View { configuration.label.scaleEffect(configuration.isPressed ? 0.97 : 1).opacity(configuration.isPressed ? 0.9 : 1).animation(.easeOut(duration: 0.15), value: configuration.isPressed) } }
extension Color { init(hex: String) { let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted); var int: UInt64 = 0; Scanner(string: hex).scanHexInt64(&int); let a, r, g, b: UInt64; switch hex.count { case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17); case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF); case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF); default:(a, r, g, b) = (255, 0, 0, 0)}; self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)} }

// MARK: - Preview Provider
#if DEBUG
struct HomeView_Previews: PreviewProvider { static var previews: some View { HomeView() } }
#endif

// --- DUMMY DEFINITIONS FOR COMPILATION (Ensure real files exist) ---
// struct RoundHistoryView: View { /* Needs definition */ }
// struct StatsView: View { /* Needs definition */ }
// struct RoundView: View { /* Needs definition */ }
// struct StatSummaryView: View { /* Needs definition */ }
// class DataManager: ObservableObject { /* Needs definition */ }
// struct Round: Identifiable, Codable { /* Needs definition with computed props */ }
// struct Statistics: Codable { /* Needs definition */ }
// class StatisticsCalculator { /* Needs definition */ }
// ... other models ...
