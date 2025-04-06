// --- START OF FILE GolfTracker.swiftpm/Sources/Views/RoundView.swift ---

import SwiftUI
import OSLog

struct RoundView: View {
    @Binding var round: Round
    @State private var currentHoleIndex = 0
    @Environment(\.presentationMode) var presentationMode

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "RoundView")

    // Safely get binding to the current hole
    private var currentHoleBinding: Binding<Hole> {
        guard round.holes.indices.contains(currentHoleIndex) else {
            logger.error("Invalid currentHoleIndex (\(currentHoleIndex)) accessed in RoundView. Round has \(round.holes.count) holes.")
            // Return a dummy binding to prevent crashes
            return .constant(Hole(number: -1, par: 0))
        }
        return $round.holes[currentHoleIndex]
    }

    var body: some View {
        VStack(spacing: 0) { // No spacing between header, hole view, nav controls
            roundHeader
            // HoleView manages its own padding and background
            HoleView(hole: currentHoleBinding)
            navigationControls
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
             logger.info("RoundView appeared for round ID: \(round.id), Hole: \(currentHoleIndex + 1)")
         }
        .onDisappear {
            logger.info("RoundView disappearing for round ID: \(round.id). State saved via binding.")
        }
    }

    // MARK: - Subviews

    // Custom Header Bar
    private var roundHeader: some View {
        HStack {
            // Back Button
            Button { presentationMode.wrappedValue.dismiss() } label: {
                HStack(spacing: Theme.spacingXXS) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(Theme.fontBody)
                .foregroundColor(Theme.accentSecondary)
            }
            .padding(.leading, Theme.spacingM)

            Spacer()

            // Course Name / Date
            VStack(spacing: 0) {
                Text(round.courseName.isEmpty ? "Golf Round" : round.courseName)
                    .font(Theme.fontHeadline)
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                Text(formattedDate)
                     .font(Theme.fontCaption)
                     .foregroundColor(Theme.textSecondary)
            }
            .padding(.horizontal, Theme.spacingXS)

            Spacer()

            // Hole Indicator
            Text("Hole \(currentHoleIndex + 1)/\(round.holes.count)")
                .font(Theme.fontSubheadline)
                .foregroundColor(Theme.textSecondary)
                .padding(.trailing, Theme.spacingM)
        }
        .padding(.vertical, Theme.spacingS)
        .background(Theme.surface.ignoresSafeArea(edges: .top)) // Use Theme surface, extend to top
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Theme.divider), alignment: .bottom) // Bottom border
    }

    // Bottom Navigation Bar (Previous/Next/Finish)
    private var navigationControls: some View {
        HStack(spacing: Theme.spacingM) {
            // Previous Button
            Button {
                if currentHoleIndex > 0 { currentHoleIndex -= 1; logger.debug("Prev hole: \(currentHoleIndex + 1).") }
            } label: {
                HStack { Image(systemName: "chevron.left"); Text("Previous") }
                    .font(Theme.fontBodySemibold)
                    .frame(maxWidth: .infinity)
                    .padding(Theme.spacingM) // Consistent padding
                    .background(Theme.surface)
                    .foregroundColor(currentHoleIndex == 0 ? Theme.textDisabled : Theme.accentSecondary)
                    .cornerRadius(Theme.cornerRadiusM)
                    .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadiusM).stroke(currentHoleIndex == 0 ? Theme.divider.opacity(0.5) : Theme.divider))
            }
             .disabled(currentHoleIndex == 0)
             .buttonStyle(.plain) // Use plain style

            // Next / Finish Button
            Button {
                if currentHoleIndex < round.holes.count - 1 { currentHoleIndex += 1; logger.debug("Next hole: \(currentHoleIndex + 1).") }
                else { presentationMode.wrappedValue.dismiss(); logger.info("Finish Round.") }
            } label: {
                let isLastHole = currentHoleIndex == round.holes.count - 1
                HStack {
                    Text(isLastHole ? "Finish Round" : "Next")
                    Image(systemName: "chevron.right")
                }
                .font(Theme.fontBodySemibold)
                .frame(maxWidth: .infinity)
                .padding(Theme.spacingM) // Consistent padding
                .background(isLastHole ? Theme.positive : Theme.accentSecondary)
                .foregroundColor(Theme.textOnAccent)
                .cornerRadius(Theme.cornerRadiusM)
                .shadow(color: Theme.neutral.opacity(0.2), radius: 5, y: 2) // Add shadow
            }
             .buttonStyle(.plain) // Use plain style
        }
        .padding(Theme.spacingM)
        .background(Theme.surface.ignoresSafeArea(edges: .bottom)) // Use Theme surface, extend to bottom
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Theme.divider), alignment: .top) // Top border
    }

    // MARK: - Helpers
    private var formattedDate: String {
        let f = DateFormatter(); f.dateStyle = .short; f.timeStyle = .none
        return f.string(from: round.date)
    }
}

// MARK: - Preview Provider
#if DEBUG
struct RoundView_Previews: PreviewProvider {
    @State static var previewRound = SampleData.sampleRounds.first ?? Round.createNew(holeCount: 18)
    static var previews: some View {
        // Preview within a NavigationView context
        NavigationView {
            RoundView(round: $previewRound)
        }
        // Optional: Preview in dark mode
        // .preferredColorScheme(.dark)
    }
}
#endif
// --- END OF FILE GolfTracker.swiftpm/Sources/Views/RoundView.swift ---
