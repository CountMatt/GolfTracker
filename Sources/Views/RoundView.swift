// File: Sources/Views/RoundView.swift
import SwiftUI
import OSLog // Import OSLog for logging

struct RoundView: View {
    // Use @Binding to receive and modify the round data directly from HomeView's @State array
    @Binding var round: Round

    // State for managing the currently displayed hole
    @State private var currentHoleIndex = 0

    // Environment variable to dismiss the view
    @Environment(\.presentationMode) var presentationMode

    // Access the shared DataManager to trigger saves
    // Note: We are saving the *entire* list via DataManager, triggered from here.
    private let dataManager = DataManager.shared

    // Logger instance
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "RoundView")

    var body: some View {
        VStack(spacing: 0) {
            // Header View
            roundHeader

            // Hole View Container
            if round.holes.indices.contains(currentHoleIndex) {
                // Pass the binding to the specific hole within the round's 'holes' array
                HoleView(hole: $round.holes[currentHoleIndex])
                    .padding(.horizontal) // Add padding around HoleView
                    .padding(.bottom)
                    // Detect changes to log them, but DON'T save here to avoid resource exhaustion
                    .onChange(of: round.holes[currentHoleIndex]) { _ in
                        logger.debug("Hole \(currentHoleIndex + 1) data changed (onChange detected).")
                        // saveAllRounds() // <-- REMOVED / COMMENTED OUT
                    }
            } else {
                 // Fallback view if index is out of bounds (should not happen in normal flow)
                 Spacer()
                 Text("Error: Invalid hole index.")
                     .foregroundColor(.red)
                 Spacer()
            }

            // Navigation Buttons (Previous/Next/Finish)
            navigationControls
        }
        .navigationBarHidden(true) // Hide the default navigation bar
        .navigationBarBackButtonHidden(true) // Hide the default back button if nested
        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Use a grouped background
        .onAppear {
             logger.info("RoundView appeared for round ID: \(round.id), Course: \(round.courseName). Starting at hole \(currentHoleIndex + 1)")
         }
        // Keep this final save as a safety net when the view disappears
        .onDisappear {
            logger.info("RoundView disappearing. Triggering final save.")
            saveAllRounds()
        }
    }

    // MARK: - Subviews

    private var roundHeader: some View {
        HStack {
            // Custom Back Button
            Button {
                // Save before dismissing
                saveAllRounds() // <-- KEEP SAVE HERE
                presentationMode.wrappedValue.dismiss()
                logger.info("Back button tapped. Saved and dismissing RoundView.")
            } label: {
                Image(systemName: "chevron.left")
                Text("Home") // Or "Rounds" if that's more accurate
            }
            .padding(.leading)

            Spacer()

            // Round Title/Date
            Text("\(round.courseName.isEmpty ? "Round" : round.courseName) - \(formattedDate)")
                .font(.headline)
                .lineLimit(1)

            Spacer()

            // Hole Indicator
            Text("Hole \(currentHoleIndex + 1)/\(round.holes.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.trailing)
        }
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground)) // A slightly different background for header
        .border(Color(.separator), width: 0.5) // Subtle bottom border
    }

    private var navigationControls: some View {
        HStack {
            // Previous Button
            Button {
                if currentHoleIndex > 0 {
                    // Save before navigating away from the current hole
                    saveAllRounds() // <-- KEEP SAVE HERE
                    currentHoleIndex -= 1
                    logger.debug("Navigated to previous hole: \(currentHoleIndex + 1). Saved.")
                }
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .padding()
                .frame(maxWidth: .infinity) // Make buttons equal width
            }
            .disabled(currentHoleIndex == 0)
            .foregroundColor(currentHoleIndex == 0 ? .gray : .blue) // Use standard disabled appearance
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)


            // Next / Finish Button
            Button {
                // Save before navigating or finishing
                saveAllRounds() // <-- KEEP SAVE HERE

                if currentHoleIndex < round.holes.count - 1 {
                    // Navigate to next hole
                    currentHoleIndex += 1
                    logger.debug("Navigated to next hole: \(currentHoleIndex + 1). Saved.")
                } else {
                    // Finish Round: Dismiss the view. Saving happened above.
                    presentationMode.wrappedValue.dismiss()
                    logger.info("Finish Round button tapped. Saved and dismissing RoundView.")
                }
            } label: {
                HStack {
                    Text(currentHoleIndex < round.holes.count - 1 ? "Next" : "Finish Round")
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                }
                .padding()
                .frame(maxWidth: .infinity) // Make buttons equal width
            }
             .foregroundColor(.white)
             .background(currentHoleIndex < round.holes.count - 1 ? Color.blue : Color.green) // Different color for Finish
             .cornerRadius(10)

        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground).ignoresSafeArea(.container, edges: .bottom)) // Extend background to bottom edge
    }

    // MARK: - Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short // e.g., 9/12/23
        formatter.timeStyle = .none
        return formatter.string(from: round.date)
    }

    // MARK: - Save Function

    // Ensures this runs on the main thread, especially important if loadRounds() is marked @MainActor
    @MainActor
    private func saveAllRounds() {
        // 1. Get the latest full list of rounds from DataManager
        var allRounds = dataManager.loadRounds()

        // 2. Find the index of the round currently being edited in the loaded list
        if let index = allRounds.firstIndex(where: { $0.id == round.id }) {
            // 3. Update the round in the loaded list with the current state from the binding
            //    The binding (@Binding var round) ensures 'round' reflects the latest UI changes
            allRounds[index] = round

            // 4. Tell DataManager to save the *entire updated list*
            dataManager.saveRounds(allRounds)
            logger.info("saveAllRounds: Successfully saved all \(allRounds.count) rounds (triggered from RoundView for round \(round.id)).")
            // Log specific data point for debugging if needed:
            // logger.debug("Score for hole 1 after save attempt: \(round.holes.first?.score ?? -99)")
        } else {
            // This case might happen if the round was deleted while this view was open, unlikely but good to log
            logger.warning("saveAllRounds: Could not find round with ID \(round.id) in loaded data. Save aborted for this round.")
        }
    }
}

// MARK: - Preview Provider (Optional)

#if DEBUG
struct RoundView_Previews: PreviewProvider {
    // Create a static State variable wrapper for the preview
    // Using SampleData assumes you have that file and it provides valid Round instances
    @State static var previewRound = SampleData.sampleRounds.indices.contains(1) ? SampleData.sampleRounds[1] : Round.createNew(holeCount: 18)

    static var previews: some View {
        // Pass the binding to the static state variable
        RoundView(round: $previewRound)
    }
}
#endif
