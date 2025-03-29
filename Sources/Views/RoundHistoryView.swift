// File: Sources/Views/RoundHistoryView.swift
import SwiftUI
import OSLog

struct RoundHistoryView: View {
    // --- Bindings ---
    @Binding var rounds: [Round]
    @Binding var selectedRound: Round? // To potentially navigate from here too
    @Binding var showRoundView: Bool   // To trigger navigation

    // --- Passed Properties (NEW: Added properties to accept colors) ---
    let cardColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let primaryColor: Color
    let backgroundColor: Color

    // --- Internal State/Helpers ---
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "RoundHistoryView")
    private let dataManager = DataManager.shared // For deletion

    // Computed property for sorted rounds (keeps view body cleaner)
    private var sortedRounds: [Round] {
        rounds.sorted { $0.date > $1.date }
    }

    var body: some View {
        // Use NavigationView for title and potential toolbar items within this tab
        NavigationView {
            List {
                // Use the computed property for iteration
                ForEach(sortedRounds) { round in
                    // ZStack makes the entire row area linkable, overlaying the invisible NavigationLink
                    ZStack {
                        // Invisible NavigationLink - triggered by the tap gesture on the ZStack content
                        NavigationLink(destination: roundDetailView(for: round)) {
                             EmptyView()
                         }
                         .opacity(0) // Make the default chevron/arrow invisible

                        // The visible content of the row
                        RoundSummaryRow(
                            round: round,
                            cardColor: cardColor,
                            textColor: textColor,
                            secondaryTextColor: secondaryTextColor,
                            primaryColor: primaryColor
                        )
                    }
                    // Make the entire row tappable (redundant with ZStack but safe)
                    // .contentShape(Rectangle()) // Can often omit this when using ZStack approach
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) // Standard list padding
                    .listRowBackground(backgroundColor) // Set row background explicitly
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) { // Swipe action
                         deleteButton(for: round)
                    }
                    .contextMenu { // Context menu (long press)
                         deleteButton(for: round)
                    }
                }
                 // Use onDelete modifier directly on ForEach for standard swipe-delete behavior
                 .onDelete(perform: deleteItems)

            }
            .listStyle(.plain) // Use plain style
            .navigationTitle("Round History")
            .background(backgroundColor.ignoresSafeArea()) // Set overall background
             .onAppear {
                 logger.info("RoundHistoryView appeared.")
             }
        }
        .navigationViewStyle(.stack) // Use stack style
    }

     // Function to handle List's onDelete modifier
     private func deleteItems(at offsets: IndexSet) {
         // The offsets are relative to the *current* state of the ForEach (which uses sortedRounds)
         offsets.map { sortedRounds[$0] }.forEach { round in
             dataManager.deleteRound(with: round.id)
         }
         // Reload data in HomeView by modifying the source binding
         // This assumes HomeView will react correctly. For more complex apps, consider EnvironmentObject.
         rounds = dataManager.loadRounds() // Reload the binding source
         logger.info("Deleted items at offsets \(offsets). Reloaded rounds.")
     }

     // Helper for delete button in swipe actions/context menus
     @ViewBuilder private func deleteButton(for round: Round) -> some View {
         Button(role: .destructive) {
             dataManager.deleteRound(with: round.id)
             rounds = dataManager.loadRounds() // Reload the binding source
             logger.info("Deleted round \(round.id) via context/swipe.")
         } label: {
             Label("Delete", systemImage: "trash")
         }
         .tint(.red)
     }

     // Generates the destination view for navigation
     @ViewBuilder private func roundDetailView(for round: Round) -> some View {
         // Find the index in the original binding to pass to RoundView
         if let index = rounds.firstIndex(where: { $0.id == round.id }) {
             RoundView(round: $rounds[index])
         } else {
             // Fallback if index not found
             Text("Error: Could not load round details.")
                 .onAppear { logger.error("Error finding index for round \(round.id) in RoundHistoryView navigation.") }
         }
     }
}

#if DEBUG
struct RoundHistoryView_Previews: PreviewProvider {
    @State static var previewRounds = SampleData.sampleRounds
    @State static var previewSelectedRound: Round? = nil
    @State static var previewShowRoundView = false

    static var previews: some View {
        RoundHistoryView(
            rounds: $previewRounds,
            selectedRound: $previewSelectedRound,
            showRoundView: $previewShowRoundView,
            // Provide default colors for preview
            cardColor: .white,
            textColor: .black,
            secondaryTextColor: .gray,
            primaryColor: .green,
            backgroundColor: Color(.systemGroupedBackground)
        )
    }
}
#endif

// --- DUMMY DEFINITIONS FOR PREVIEW (If needed and not elsewhere) ---
// Ensure RoundSummaryRow, RoundView, DataManager, Models are accessible
// struct RoundSummaryRow: View { ... }
// struct RoundView: View { ... }
// class DataManager { ... }
// struct Round { ... }
// struct SampleData { ... }
// --- END DUMMY DEFINITIONS ---
