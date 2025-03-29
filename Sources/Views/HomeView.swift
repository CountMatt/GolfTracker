// File: Sources/Views/HomeView.swift
import SwiftUI
import OSLog // Import OSLog for logging

struct HomeView: View {
    // State variables
    @State private var rounds: [Round] = []
    @State private var statistics: Statistics = Statistics()
    @State private var showingNewRoundOptions = false
    @State private var selectedTab = 0 // Default to Home tab (index 0)
    @State private var selectedRound: Round? = nil
    @State private var showRoundView = false // Controls navigation to RoundView

    // Logger instance
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "HomeView")

    // Access DataManager for loading/deleting
    private let dataManager = DataManager.shared

    // Color Palette
    let backgroundColor = Color(hex: "F8F9FA") // Light grey background
    let primaryColor = Color(hex: "18A558")    // Golf green
    let cardColor = Color.white               // White cards
    let textColor = Color(hex: "252C34")      // Dark text
    let secondaryTextColor = Color(hex: "5F6B7A") // Greyish text

    var body: some View {
        // Use NavigationStack for programmatic navigation outside the TabView
        NavigationStack {
            // --- TabView with 3 Tabs ---
            TabView(selection: $selectedTab) {
                // HOME TAB
                homeTabContent
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0) // Tag for home tab

                // ROUND HISTORY TAB (NEW)
                // Pass the necessary bindings and colors
                RoundHistoryView(
                    rounds: $rounds,
                    selectedRound: $selectedRound,
                    showRoundView: $showRoundView,
                    cardColor: cardColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    primaryColor: primaryColor,
                    backgroundColor: backgroundColor
                )
                .tabItem { Label("History", systemImage: "list.bullet") }
                .tag(2) // Tag for history tab

                // STATS TAB
                StatsView(statistics: statistics)
                    .tabItem { Label("Statistics", systemImage: "chart.bar.fill") }
                    .tag(1) // Tag for stats tab
            }
            .accentColor(primaryColor) // Set accent color for selected tab item
            .onAppear {
                 // Load data when the root view appears
                 loadData()
                 configureAppearance()
                 logger.info("HomeView appeared. Data loaded.")
            }
            // Navigation Destination applies to the whole NavigationStack
            .navigationDestination(isPresented: $showRoundView) {
                 if let roundToEdit = selectedRound {
                    // Safely find the index for the binding
                    if let index = rounds.firstIndex(where: { $0.id == roundToEdit.id }) {
                        RoundView(round: $rounds[index]) // Pass the binding
                             // Save logic is now handled within RoundView/DataManager interaction
                    } else {
                        // Fallback view if index isn't found
                        Text("Error: Round not found.")
                            .onAppear { logger.error("Error: Could not find index for round ID \(roundToEdit.id) in navigationDestination.") }
                    }
                 } else {
                     // Fallback view if selectedRound is nil
                     Text("Error: No round selected.")
                         .onAppear{ logger.error("Error: navigationDestination triggered but selectedRound was nil.") }
                 }
            }
            // Confirmation dialog for starting a new round
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
            backgroundColor.ignoresSafeArea() // Apply background

            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    startNewRoundButton
                    StatSummaryView(statistics: statistics) // Use existing StatSummaryView
                        .padding(.horizontal) // Add padding to constrain cards
                    recentRoundsSection // Shows only top 3 recent rounds
                    Spacer(minLength: 80) // Space for tab bar
                }
            }
        }
        .navigationBarHidden(true) // Typically hide nav bar for top-level tab views
    }

    // MARK: - Subviews for Home Tab

     private var headerView: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E2EADF"), backgroundColor], // Gradient to background
                startPoint: .top, endPoint: .bottom
            )
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
            .padding().background(primaryColor) // Use primary color
            .cornerRadius(16).shadow(color: primaryColor.opacity(0.4), radius: 10, x: 0, y: 5)
            .padding(.horizontal)
        }
        .buttonStyle(PressableButtonStyle())
    }

    // Recent Rounds Section (Shows only a few recent rounds on Home)
    private var recentRoundsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Rounds").font(.title3).fontWeight(.semibold).foregroundColor(textColor)
                Spacer()
                 // Button to switch to the History Tab
                 Button("View All") {
                     selectedTab = 2 // Switch TabView to index 2 (History)
                 }
                 .font(.callout)
                 .foregroundColor(primaryColor)
            }
            .padding(.horizontal)

            if rounds.isEmpty {
                 emptyStateView.padding(.horizontal) // Add horizontal padding to empty state too
            } else {
                 // Card containing the top 3 recent rounds
                 VStack(spacing: 0) { // No spacing between rows inside the card
                     // Sort rounds by date descending and take the top 3
                     ForEach(rounds.sorted(by: { $0.date > $1.date }).prefix(3)) { round in
                         RoundSummaryRow(
                             round: round,
                             cardColor: cardColor,
                             textColor: textColor,
                             secondaryTextColor: secondaryTextColor,
                             primaryColor: primaryColor
                         )
                         .padding(.horizontal) // Padding inside the row
                         .padding(.vertical, 12)
                         .background(cardColor) // Row background
                         .contentShape(Rectangle()) // Make entire row tappable
                         .onTapGesture { navigateToRound(round) } // Navigate on tap
                          .contextMenu { deleteButton(for: round) } // Add context menu

                         // Add divider conditionally, except for the last item in the preview list
                         if round.id != rounds.sorted(by: { $0.date > $1.date }).prefix(3).last?.id {
                             Divider().padding(.leading) // Indent divider slightly
                         }
                     }
                 }
                 .background(cardColor) // Background for the card containing rows
                 .cornerRadius(16)
                 .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                 .padding(.horizontal) // Padding around the card
            }
        }
    }

    // Empty state view
    private var emptyStateView: some View {
         VStack(spacing: 16) {
            Image(systemName: "figure.golf").font(.system(size: 60)).foregroundColor(secondaryTextColor.opacity(0.5))
            Text("No rounds recorded yet").font(.headline).foregroundColor(secondaryTextColor)
            Text("Tap 'Start New Round' to begin!").font(.subheadline).foregroundColor(secondaryTextColor).multilineTextAlignment(.center).padding(.horizontal)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40).background(cardColor).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(backgroundColor, lineWidth: 1)) // Use background color for subtle border
    }

    // MARK: - Data Management Methods

    private func startNewRound(holeCount: Int) {
        let newRound = Round.createNew(holeCount: holeCount)
        rounds.append(newRound)
        saveData() // Save immediately after adding
        logger.info("Created new \(holeCount)-hole round with ID: \(newRound.id). Saved initial structure.")

        selectedRound = newRound // Set for navigation
        DispatchQueue.main.async { // Ensure state update before navigation
            showRoundView = true
            logger.info("Navigating to RoundView for new round.")
        }
    }

    private func loadData() {
        rounds = dataManager.loadRounds()
        updateStatistics()
        logger.info("Loaded \(rounds.count) rounds.")
    }

    // Saves the current state of the 'rounds' array
    private func saveData() {
        dataManager.saveRounds(rounds)
        updateStatistics() // Recalculate stats after saving potentially changed data
        logger.info("HomeView explicit saveData called. Saved \(rounds.count) rounds.")
    }

    // Calculates overall statistics
    private func updateStatistics() {
        let calculator = StatisticsCalculator()
        statistics = calculator.calculateStatistics(from: rounds)
        logger.info("Statistics updated.")
    }

    // Deletes a round using the DataManager and reloads the local array
    private func deleteRound(_ roundToDelete: Round) {
         dataManager.deleteRound(with: roundToDelete.id)
         loadData() // Reload data to update the UI across all views using the 'rounds' state
         logger.info("Deleted round requested for ID: \(roundToDelete.id). Reloaded data.")
    }

    // Sets the selected round and triggers navigation
    private func navigateToRound(_ round: Round) {
         selectedRound = round
         showRoundView = true
         logger.info("Navigating to round: \(round.id)")
    }

    // Helper for delete button in context menus/swipe actions
    @ViewBuilder private func deleteButton(for round: Round) -> some View {
        Button(role: .destructive) {
            deleteRound(round)
        } label: {
            Label("Delete Round", systemImage: "trash")
        }
        .tint(.red)
    }

    // MARK: - Appearance Configuration
     private func configureAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(cardColor) // Use card color for tab bar background
         // Set selected/unselected colors (optional, uses accentColor by default)
         let itemAppearance = UITabBarItemAppearance()
         itemAppearance.normal.iconColor = UIColor(secondaryTextColor)
         itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(secondaryTextColor)]
         itemAppearance.selected.iconColor = UIColor(primaryColor)
         itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(primaryColor)]
         tabBarAppearance.stackedLayoutAppearance = itemAppearance
         tabBarAppearance.inlineLayoutAppearance = itemAppearance // For wider screens if applicable
         tabBarAppearance.compactInlineLayoutAppearance = itemAppearance // For compact widths

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Configure Navigation Bar Appearance (Applied if using NavigationView within tabs)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(cardColor) // Match tab bar
        navigationBarAppearance.shadowColor = .clear // No shadow line under nav bar
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(textColor), .font: UIFont.systemFont(ofSize: 18, weight: .semibold)]
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}

// MARK: - Updated RoundSummaryRow (with Stats & Style Parameters)
struct RoundSummaryRow: View {
    let round: Round
    // Pass colors for better styling control
    let cardColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let primaryColor: Color


    var scoreString: String {
        let relativeToPar = round.scoreRelativeToPar
        if relativeToPar == 0 { return "E" }
        else if relativeToPar > 0 { return "+\(relativeToPar)" }
        else { return "\(relativeToPar)" }
    }

    var scoreColor: Color {
        let relativeToPar = round.scoreRelativeToPar
        if relativeToPar < 0 { return .red } // Under par
        else if relativeToPar == 0 { return primaryColor } // Even par (use app's primary green)
        else { return secondaryTextColor } // Over par
    }

    var body: some View {
        HStack(spacing: 12) {
            // Hole Count Indicator
             Text(round.isNineHoles ? "9" : "18")
                 .font(.caption.weight(.bold))
                 .frame(width: 24, height: 24)
                 .background(secondaryTextColor.opacity(0.1))
                 .foregroundColor(secondaryTextColor)
                 .clipShape(Circle())


            VStack(alignment: .leading, spacing: 2) { // Reduced spacing
                Text(round.courseName.isEmpty ? "Unknown Course" : round.courseName)
                    .font(.headline).foregroundColor(textColor).lineLimit(1)
                Text(formattedDate).font(.subheadline).foregroundColor(secondaryTextColor)

                 // --- NEW: Inline Stats ---
                 HStack(spacing: 10) {
                     // Only show Fairway % if it was an 18-hole round (or has par 4/5s)
                     if !round.isNineHoles || round.fairwayOpportunities > 0 {
                          statIconText(icon: "arrow.up.forward.circle", value: round.fairwayPercentage, format: "%.0f%%")
                     }
                     statIconText(icon: "target", value: round.girPercentage, format: "%.0f%%") // GIR %
                     statIconText(icon: "flag.fill", value: Double(round.totalPutts), format: "%.0f P") // Putts
                 }
                 .padding(.top, 4)
            }

            Spacer()

            // Score display remains similar
            VStack(alignment: .trailing, spacing: 2) { // Reduced spacing
                 Text("\(round.totalScore)")
                     .font(.title2.weight(.bold)) // Larger score
                     .foregroundColor(textColor)
                 Text(scoreString)
                     .font(.headline).foregroundColor(scoreColor)
                     .padding(.vertical, 2).padding(.horizontal, 5)
                     .background(scoreColor.opacity(0.15)).cornerRadius(6)
            }

            Image(systemName: "chevron.right").foregroundColor(secondaryTextColor.opacity(0.5))
        }
        .padding(.vertical, 8) // Adjust overall vertical padding if needed
    }

     // Helper for inline stat display
     private func statIconText(icon: String, value: Double, format: String) -> some View {
         // Avoid displaying NaN or infinite values if data is weird
         guard value.isFinite else { return AnyView(EmptyView()) }

         return AnyView(
            HStack(spacing: 3) {
                 Image(systemName: icon)
                     .font(.caption) // Smaller icon
                     .foregroundColor(secondaryTextColor)
                 Text(String(format: format, value))
                     .font(.caption) // Smaller text
                     .foregroundColor(secondaryTextColor)
             }
         )
     }

    var formattedDate: String {
         let formatter = DateFormatter();
         formatter.dateStyle = .medium; // e.g., Sep 12, 2023
         formatter.timeStyle = .none
         return formatter.string(from: round.date)
    }
}


// MARK: - PressableButtonStyle & Color Extension (Keep as they are)
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted); var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0) // Default to black with alpha
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Preview Provider
#if DEBUG
struct HomeView_Previews: PreviewProvider { static var previews: some View { HomeView() } }
#endif

// --- DUMMY DEFINITIONS FOR COMPILATION (Ensure these match your actual models) ---
// Keep the dummy definitions from the previous response if needed for isolated testing,
// or ensure your actual Model files are correctly imported/accessible.
// struct Club: Identifiable... etc.
// enum ClubType: String... etc.
// ... other models ...
// struct Round: Identifiable... etc. (Make sure it has the computed properties added earlier)
// struct Hole: Identifiable... etc.
// struct SampleData { ... }
// struct Statistics: Codable { ... } (With added properties)
// class StatisticsCalculator { ... } (With updated calculations)
// struct StatSummaryView: View { ... } // Make sure this exists and takes Statistics
// struct RoundHistoryView: View { ... } // Make sure this exists
// struct StatsView: View { ... } // Make sure this exists
// struct RoundView: View { ... } // Make sure this exists
// class DataManager { ... } // Make sure this exists
// --------------------------------------------------------------------------
