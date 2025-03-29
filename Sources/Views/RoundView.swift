
// File: Sources/Views/RoundView.swift
import SwiftUI
import OSLog

struct RoundView: View {
    // Binding received from HomeView's manual binding creation
    // This binding's 'set' block now calls dataManager.updateRound implicitly
    @Binding var round: Round

    @State private var currentHoleIndex = 0
    @Environment(\.presentationMode) var presentationMode

    // No longer need direct access to DataManager here for saving
    // private let dataManager = DataManager.shared

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "RoundView")

    var body: some View {
        VStack(spacing: 0) {
            roundHeader
            if round.holes.indices.contains(currentHoleIndex) {
                HoleView(hole: $round.holes[currentHoleIndex]) // Pass binding down
                    .padding(.horizontal)
                    .padding(.bottom)
                    // onChange on the hole struct itself is less reliable than letting the binding handle updates
                    // The binding created in HomeView now handles the update propagation to DataManager
                    // .onChange(of: round.holes[currentHoleIndex]) { _, _ in
                    //     logger.debug("Hole \(currentHoleIndex + 1) data changed (onChange detected). Update should occur via binding.")
                    // }
            } else {
                 Spacer(); Text("Error: Invalid hole index.").foregroundColor(.red); Spacer()
            }
            navigationControls
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
             logger.info("RoundView appeared for round ID: \(round.id), Hole: \(currentHoleIndex + 1)")
             // Data should be up-to-date via the binding
         }
        .onDisappear {
            logger.info("RoundView disappearing for round ID: \(round.id). Final state saved via binding.")
            // Explicit save on disappear is likely redundant now due to binding update
        }
    }

    // MARK: - Subviews
    private var roundHeader: some View {
        HStack {
            Button {
                // Update is handled by the binding when HoleView changes data before dismissal
                presentationMode.wrappedValue.dismiss()
                logger.info("Back button tapped. Dismissing RoundView.")
            } label: { Image(systemName: "chevron.left"); Text("Back") }
            .padding(.leading)
            Spacer()
            Text("\(round.courseName.isEmpty ? "Round" : round.courseName) - \(formattedDate)")
                .font(.headline).lineLimit(1)
            Spacer()
            Text("Hole \(currentHoleIndex + 1)/\(round.holes.count)")
                .font(.subheadline).foregroundColor(.secondary).padding(.trailing)
        }
        .padding(.vertical, 12).background(Color(.secondarySystemGroupedBackground)).border(Color(.separator), width: 0.5)
    }

    private var navigationControls: some View {
        HStack {
            // Previous Button
            Button {
                if currentHoleIndex > 0 {
                    // State changes propagate via binding before index changes
                    currentHoleIndex -= 1
                    logger.debug("Navigated to previous hole: \(currentHoleIndex + 1).")
                }
            } label: { HStack { Image(systemName: "chevron.left"); Text("Previous") }.padding().frame(maxWidth: .infinity) }
             .disabled(currentHoleIndex == 0).foregroundColor(currentHoleIndex == 0 ? .gray : .blue)
             .background(Color(.secondarySystemGroupedBackground)).cornerRadius(10)

            // Next / Finish Button
            Button {
                // State changes propagate via binding before index/view changes
                if currentHoleIndex < round.holes.count - 1 {
                    currentHoleIndex += 1
                    logger.debug("Navigated to next hole: \(currentHoleIndex + 1).")
                } else {
                    presentationMode.wrappedValue.dismiss()
                    logger.info("Finish Round button tapped. Dismissing RoundView.")
                }
            } label: { HStack { Text(currentHoleIndex < round.holes.count - 1 ? "Next" : "Finish Round").fontWeight(.semibold); Image(systemName: "chevron.right") }.padding().frame(maxWidth: .infinity) }
              .foregroundColor(.white).background(currentHoleIndex < round.holes.count - 1 ? Color.blue : Color.green)
              .cornerRadius(10)
        }
        .padding().background(Color(.secondarySystemGroupedBackground).ignoresSafeArea(.container, edges: .bottom))
    }

    // MARK: - Helpers
    private var formattedDate: String { let f = DateFormatter(); f.dateStyle = .short; f.timeStyle = .none; return f.string(from: round.date) }

    // MARK: - Save Function (REMOVED - Handled by binding update)
}

// MARK: - Preview Provider
#if DEBUG
struct RoundView_Previews: PreviewProvider {
    // Provide a simple @State wrapper for previewing the binding
    @State static var previewRound = SampleData.sampleRounds.first ?? Round.createNew(holeCount: 18)

    static var previews: some View {
        RoundView(round: $previewRound)
    }
}
#endif

// --- DUMMY DEFINITIONS FOR PREVIEW ---
// Ensure necessary views/models are accessible
// struct HoleView: View { ... }
// struct Round: Identifiable, Codable { ... }
// struct SampleData { ... }
