// --- START OF FILE GolfTracker.swiftpm/Sources/Views/Components/ClubSelectionView.swift ---

import SwiftUI

struct ClubSelectionView: View {
    @Binding var selectedClub: Club?
    let title: String
    private let clubs = Club.allClubs

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) { // Increased spacing
            Text(title)
                .font(Theme.fontHeadline)
                .foregroundColor(Theme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                // Increased spacing between club buttons
                HStack(spacing: Theme.spacingS) {
                    ForEach(clubs) { club in
                        Button(action: {
                            if selectedClub?.id == club.id { selectedClub = nil }
                            else { selectedClub = club }
                        }) {
                            Text(club.name)
                                .font(Theme.fontCaptionBold) // Slightly bolder text
                                // Ensure sufficient padding for touch targets
                                .padding(.horizontal, Theme.spacingM)
                                .padding(.vertical, Theme.spacingXS)
                                .background(selectedClub?.id == club.id ? Theme.accentSecondary : Theme.surface)
                                .foregroundColor(selectedClub?.id == club.id ? Theme.textOnAccent : Theme.textPrimary)
                                .cornerRadius(Theme.cornerRadiusM) // Slightly larger radius
                                // Always show border for better definition
                                .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadiusM).stroke(Theme.divider))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, Theme.spacingXXS) // Padding for scroll clearance
            }

            Text(selectedClub == nil ? "No club selected" : "Selected: \(selectedClub!.name)")
                .font(Theme.fontCaption)
                .foregroundColor(Theme.textSecondary)
                // Add padding below selection text for spacing
                .padding(.bottom, Theme.spacingXXS)
        }
        // Removed vertical padding from VStack - apply where component is used if needed
    }
}

// MARK: - Preview
#if DEBUG
struct ClubSelectionView_Previews: PreviewProvider {
    @State static private var previewSelectedClub: Club? = Club.allClubs[6]
    static var previews: some View {
        ClubSelectionView(selectedClub: $previewSelectedClub, title: "Approach Club")
            .padding()
            .background(Theme.background)
    }
}
#endif
// --- END OF FILE GolfTracker.swiftpm/Sources/Views/Components/ClubSelectionView.swift ---
