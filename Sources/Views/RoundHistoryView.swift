
// File: Sources/Views/RoundHistoryView.swift
import SwiftUI
import OSLog

struct RoundHistoryView: View {
    // --- Bindings & Properties ---
    // Receive rounds directly for display (now read-only from DataManager)
    let rounds: [Round] // Changed from Binding to let
    @Binding var selectedRoundID: Round.ID? // Use ID for navigation trigger
    // Colors passed in
    let cardColor: Color
    let textColor: Color
    let secondaryTextColor: Color
    let primaryColor: Color
    let backgroundColor: Color

    // --- Internal State/Helpers ---
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "RoundHistoryView")
    // Access shared DataManager for deletion ONLY
    private let dataManager = DataManager.shared

    // Computed property for sorted rounds
    private var sortedRounds: [Round] {
        rounds.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(sortedRounds) { round in
                    // --- Row Content ---
                    RoundSummaryRow(
                        round: round,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        primaryColor: primaryColor
                    )
                    .contentShape(Rectangle()) // Make row tappable
                    .onTapGesture {
                        selectedRoundID = round.id // Trigger navigation via ID
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(backgroundColor)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                         deleteButton(for: round)
                    }
                    .contextMenu {
                         deleteButton(for: round)
                    }
                }
                 // Use onDelete modifier directly on ForEach
                 .onDelete(perform: deleteItems)
            }
            .listStyle(.plain)
            .navigationTitle("Round History")
            .background(backgroundColor.ignoresSafeArea())
             .onAppear {
                 logger.info("RoundHistoryView appeared with \(rounds.count) rounds.")
             }
        }
        .navigationViewStyle(.stack)
    }

     // Function to handle List's onDelete modifier
     private func deleteItems(at offsets: IndexSet) {
         // Map offsets to rounds based on the *sorted* array
         offsets.map { sortedRounds[$0] }.forEach { round in
             dataManager.deleteRound(withId: round.id) // Use DataManager to delete
         }
         // UI updates automatically via HomeView observing DataManager
         logger.info("Deleted items at offsets \(offsets).")
     }

     // Helper for delete button
     @ViewBuilder private func deleteButton(for round: Round) -> some View {
         Button(role: .destructive) {
             dataManager.deleteRound(withId: round.id) // Use DataManager to delete
             logger.info("Deleted round \(round.id) via context/swipe.")
             // UI updates automatically
         } label: {
             Label("Delete", systemImage: "trash")
         }
         .tint(.red)
     }

     // NavigationLink is now handled by .navigationDestination in HomeView using selectedRoundID
     // No roundDetailView needed here anymore.
}

#if DEBUG
struct RoundHistoryView_Previews: PreviewProvider {
    // Use non-binding rounds for preview display
    @State static var previewRounds = SampleData.sampleRounds
    @State static var previewSelectedRoundID: Round.ID? = nil

    static var previews: some View {
        RoundHistoryView(
            rounds: previewRounds, // Pass non-binding array
            selectedRoundID: $previewSelectedRoundID,
            // Provide default colors for preview
            cardColor: .white, textColor: .black, secondaryTextColor: .gray,
            primaryColor: .green, backgroundColor: Color(.systemGroupedBackground)
        )
    }
}
#endif

// --- DUMMY DEFINITIONS FOR PREVIEW ---
// Ensure necessary structs/classes are accessible
// struct RoundSummaryRow: View { ... }
// struct Round { ... }
// struct SampleData { ... }
// class DataManager { ... }
