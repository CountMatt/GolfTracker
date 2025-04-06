// --- START OF FILE GolfTracker.swiftpm/Sources/Views/RoundHistoryView.swift ---

import SwiftUI
import OSLog

struct RoundHistoryView: View {
    // Observe rounds from DataManager for deletion, but display sorted rounds
    @ObservedObject private var dataManager = DataManager.shared
    @Binding var selectedRoundID: Round.ID? // Used by HomeView for navigation

    // --- REMOVED Color properties - Use Theme directly ---
    // let cardColor: Color
    // ...

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "RoundHistoryView")

    // Computed property for sorted rounds from the DataManager
    private var sortedRounds: [Round] {
        dataManager.rounds.sorted { $0.date > $1.date }
    }

    var body: some View {
        // Note: NavigationView/NavigationStack is handled by the parent (HomeView)
        List {
            ForEach(sortedRounds) { round in
                // --- Use RoundSummaryRow defined in HomeView.swift ---
                RoundSummaryRow(round: round) // Row will use Theme internally
                    .contentShape(Rectangle()) // Ensure whole row is tappable
                    .onTapGesture {
                        selectedRoundID = round.id // Trigger navigation via ID in HomeView
                    }
                    .listRowInsets(EdgeInsets( // Custom insets for list rows
                        top: Theme.spacingXS,
                        leading: Theme.spacingM,
                        bottom: Theme.spacingXS,
                        trailing: Theme.spacingM
                    ))
                    .listRowBackground(Theme.surface) // Use Theme surface for row background
                    .listRowSeparatorTint(Theme.divider) // Use Theme divider color
                    // Swipe action for deletion
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                         deleteButton(for: round)
                    }
                    // Context menu for deletion
                    .contextMenu {
                         deleteButton(for: round)
                    }
            }
             // Use List's built-in onDelete modifier (alternative to swipe/context)
             // .onDelete(perform: deleteItems)
        }
        .listStyle(.plain) // Plain list style removes default inset grouping
        .navigationTitle("Round History")
        .background(Theme.background.ignoresSafeArea()) // Use Theme background
        .onAppear {
             logger.info("RoundHistoryView appeared with \(dataManager.rounds.count) rounds.")
        }
    }

     // Function to handle List's onDelete modifier (if used)
     private func deleteItems(at offsets: IndexSet) {
         // Map offsets to rounds based on the *sorted* array
         offsets.map { sortedRounds[$0] }.forEach { round in
             dataManager.deleteRound(withId: round.id) // Use DataManager to delete
         }
         logger.info("Deleted items at offsets \(offsets).")
         // UI updates automatically via HomeView observing DataManager
     }

     // Helper for delete button used in swipe/context menu
     @ViewBuilder private func deleteButton(for round: Round) -> some View {
         Button(role: .destructive) {
             dataManager.deleteRound(withId: round.id) // Use DataManager to delete
             logger.info("Deleted round \(round.id) via context/swipe.")
         } label: {
             Label("Delete", systemImage: "trash")
         }
         .tint(Theme.negative) // Use Theme negative color
     }

     // NavigationLink is handled by .navigationDestination in HomeView
}

#if DEBUG
struct RoundHistoryView_Previews: PreviewProvider {
    // Use a dummy State wrapper for the binding in preview
    @State static var previewSelectedRoundID: Round.ID? = nil

    static var previews: some View {
        // Wrap in NavigationView for preview context
        NavigationView {
            RoundHistoryView(selectedRoundID: $previewSelectedRoundID)
                 // Inject sample data into the shared DataManager for preview if needed
                 // .environmentObject(DataManager(sampleData: SampleData.sampleRounds))
        }
        // .preferredColorScheme(.dark)
    }
}
#endif
// --- END OF FILE GolfTracker.swiftpm/Sources/Views/RoundHistoryView.swift ---
