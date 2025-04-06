// --- START OF FILE GolfTracker.swiftpm/Sources/Views/HoleView.swift ---

import SwiftUI
import OSLog

// MARK: - Simple wind display view (Used by Wind Button)
struct WindIndicatorView: View {
    let speed: Double
    let direction: Int // Degrees

    var body: some View {
        HStack(spacing: Theme.spacingXXS) { // Use Theme spacing
            Image(systemName: "arrow.up")
                .rotationEffect(.degrees(Double(direction)))
                .frame(width: 20, height: 20)
                .foregroundColor(speed > 0 ? Theme.accentSecondary : Theme.textSecondary) // Use Theme colors

            Text(speed > 0 ? "\(Int(speed.rounded())) m/s" : "Calm")
                .font(Theme.fontCaption) // Use Theme font
                .foregroundColor(speed > 0 ? Theme.textPrimary : Theme.textSecondary) // Use Theme colors
        }
        .padding(.horizontal, Theme.spacingS).padding(.vertical, Theme.spacingXXS) // Use Theme spacing
        .background(Theme.surface) // Use Theme surface for background
        .cornerRadius(Theme.cornerRadiusS) // Use Theme radius
        .overlay( // Add a subtle border
            RoundedRectangle(cornerRadius: Theme.cornerRadiusS)
                .stroke(Theme.divider.opacity(0.5), lineWidth: 0.5)
        )
    }
}


// MARK: - Main Hole View
struct HoleView: View {
    @Binding var hole: Hole
    @FocusState private var isApproachDistanceFocused: Bool
    @FocusState private var isFirstPuttDistanceFocused: Bool
    @State private var showWindSettings = false

    // Explicitly defined club options
    private let teeClubOptions: [Club] = [
        Club(type: .driver, name: "Driver"), Club(type: .wood, name: "3W"), Club(type: .wood, name: "5W"),
        Club(type: .hybrid, name: "3H"), Club(type: .hybrid, name: "4H"),
        Club(type: .iron, name: "4i"), Club(type: .iron, name: "5i"), Club(type: .iron, name: "6i")
    ]
    private let approachClubOptions: [Club] = [
        Club(type: .wood, name: "5W"), Club(type: .hybrid, name: "4H"),
        Club(type: .iron, name: "4i"), Club(type: .iron, name: "5i"), Club(type: .iron, name: "6i"),
        Club(type: .iron, name: "7i"), Club(type: .iron, name: "8i"), Club(type: .iron, name: "9i"),
        Club(type: .wedge, name: "PW"), Club(type: .wedge, name: "GW"), Club(type: .wedge, name: "SW"),
        Club(type: .wedge, name: "LW")
    ]
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "HoleView")

    var body: some View {
        ScrollView {
            // Increased vertical spacing between major sections
            VStack(alignment: .leading, spacing: Theme.spacingL) {
                holeHeaderSection
                Theme.divider // Divider still useful for visual separation
                teeShotSection
                Theme.divider
                approachSection
                Theme.divider
                scoreSection
                    .padding(.bottom, Theme.spacingXS) // Add slight bottom padding to score section
            }
            .padding(Theme.spacingM)
            .onAppear { setDefaultScoreIfNeeded(); logger.info("HoleView appeared for hole \(hole.number).") }
            .onChange(of: hole.id) { logger.info("Hole changed to \(hole.number). Applying default."); setDefaultScoreIfNeeded() }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer(); Button("Done") { isApproachDistanceFocused = false; isFirstPuttDistanceFocused = false }
                        .font(Theme.fontBody)
                        .foregroundColor(Theme.accentSecondary)
                }
            }
            .sheet(isPresented: $showWindSettings) {
                 WindSettingsView(
                    windSpeed: $hole.windSpeed,
                    windDirection: $hole.windDirection,
                    approachDistance: hole.approachDistance
                 )
                 .presentationDetents([.medium, .large])
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Hole \(hole.number)")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Function to Set Default Score
    private func setDefaultScoreIfNeeded() {
        if hole.score == 0 && hole.par > 0 {
             hole.score = hole.par
             logger.debug("Hole \(hole.number): Default score set to par (\(hole.par)).")
         } else {
              logger.debug("Hole \(hole.number): Score (\(hole.score)) already set or par (\(hole.par)) invalid, not applying default.")
          }
    }

    // MARK: Hole Header Section
    private var holeHeaderSection: some View {
        // Adjusted spacing within header
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            parSelectionView
            windSection
            windImpactDisplayView
        }
    }

    // Par Selection Buttons
    private var parSelectionView: some View {
        HStack(spacing: Theme.spacingXS) {
            Text("Par:").font(Theme.fontHeadline).foregroundColor(Theme.textPrimary)
            ForEach([3, 4, 5], id: \.self) { parValue in
                Button {
                     hole.par = parValue
                     if hole.score == 0 { hole.score = parValue }
                } label: {
                    Text("\(parValue)")
                        .fontWeight(.medium).font(Theme.fontBody)
                        .padding(.horizontal, Theme.spacingS).padding(.vertical, Theme.spacingXXS)
                        .background(hole.par == parValue ? Theme.accentSecondary : Theme.surface)
                        .foregroundColor(hole.par == parValue ? Theme.textOnAccent : Theme.textPrimary)
                        .cornerRadius(Theme.cornerRadiusS)
                        .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadiusS).stroke(Theme.divider))
                }
            }
        }
    }

    // Wind Button/Indicator
    private var windSection: some View {
         HStack(alignment: .center) {
             Text("Wind:").font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
             Button { showWindSettings = true } label: {
                 WindIndicatorView(speed: hole.windSpeed, direction: hole.windDirection)
             }
             Spacer()
         }
    }

    // Wind Impact Display
     @ViewBuilder
     private var windImpactDisplayView: some View {
         if let distance = hole.approachDistance, distance > 0 {
             let impact = WindCalculator.calculateImpact(distance: distance, windSpeed: hole.windSpeed, windDirection: Double(hole.windDirection))
             if impact != 0 {
                 HStack(spacing: Theme.spacingXXS) {
                     Image(systemName: impact > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                         .foregroundColor(impact > 0 ? Theme.positive : Theme.negative)
                     Text("Wind \(impact > 0 ? "helps" : "hurts") by \(abs(impact))m.")
                         .font(Theme.fontCaption)
                         .foregroundColor(Theme.textSecondary)
                     Spacer()
                     Text("Plays like: \(distance + impact)m")
                         .font(Theme.fontCaptionBold)
                         .foregroundColor(Theme.textPrimary)
                 }
                 .padding(Theme.spacingXS)
                 .background(Theme.surface)
                 .cornerRadius(Theme.cornerRadiusS)
             }
         }
     }


    // MARK: Tee Shot Section
    private var teeShotSection: some View {
        // Adjusted spacing within section
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Text("Tee Shot").font(Theme.fontHeadline).foregroundColor(Theme.textPrimary)
            // Tee Club Menu
            HStack {
                Text("Club:").font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
                Spacer()
                Menu {
                    ForEach(teeClubOptions) { club in
                        Button(club.name) { hole.teeClub = club }
                    }
                    Button("Clear", role: .destructive) { hole.teeClub = nil }
                } label: {
                    HStack(spacing: Theme.spacingXXS) {
                        Text(hole.teeClub?.name ?? "Select")
                            .font(Theme.fontBody)
                            .foregroundColor(hole.teeClub == nil ? Theme.textSecondary : Theme.textPrimary)
                        Image(systemName: "chevron.down").font(Theme.fontCaption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.horizontal, Theme.spacingS).padding(.vertical, Theme.spacingXXS)
                    .background(Theme.surface)
                    .cornerRadius(Theme.cornerRadiusS)
                    .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadiusS).stroke(Theme.divider))
                }
            }
            // Fairway Hit/Miss (Par 4/5)
            if !hole.isPar3 {
                VStack(alignment: .leading, spacing: Theme.spacingXS) {
                    Text("Fairway:").font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
                    HStack(spacing: Theme.spacingXS) {
                        fairwayButton(label: "Left", hit: false, direction: .left)
                        fairwayButton(label: "Hit", hit: true, direction: .none)
                        fairwayButton(label: "Right", hit: false, direction: .right)
                    }
                }
            }
        }
    }

    // MARK: Approach Section
    private var approachSection: some View {
        // Adjusted spacing within section
        VStack(alignment: .leading, spacing: Theme.spacingM) {
            Text("Approach / Green").font(Theme.fontHeadline).foregroundColor(Theme.textPrimary)
            // Approach Distance
            HStack {
                Text("Approach Dist:").font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
                Spacer()
                distanceInput(value: $hole.approachDistance, placeholder: "meters", focusState: $isApproachDistanceFocused)
            }
            // Approach Club
            HStack {
                Text("Approach Club:").font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
                Spacer()
                Menu {
                    ForEach(approachClubOptions) { club in
                        Button(club.name) { hole.approachClub = club }
                    }
                    Button("Clear", role: .destructive) { hole.approachClub = nil }
                } label: {
                     HStack(spacing: Theme.spacingXXS) {
                        Text(hole.approachClub?.name ?? "Select")
                            .font(Theme.fontBody)
                            .foregroundColor(hole.approachClub == nil ? Theme.textSecondary : Theme.textPrimary)
                        Image(systemName: "chevron.down").font(Theme.fontCaption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .padding(.horizontal, Theme.spacingS).padding(.vertical, Theme.spacingXXS)
                    .background(Theme.surface)
                    .cornerRadius(Theme.cornerRadiusS)
                    .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadiusS).stroke(Theme.divider))
                }
            }
            // Green Target and Putting Area
            greenTargetAndPuttingSection // Spacing adjusted inside this view
        }
    }

    // Combined Green Target and Putting Inputs
    private var greenTargetAndPuttingSection: some View {
         // Adjusted spacing
         HStack(alignment: .top, spacing: Theme.spacingL) {
             // Green Target Area
             VStack(alignment: .center, spacing: Theme.spacingS) {
                 Text("Green Result").font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
                 ImprovedGreenTargetView(selectedLocation: $hole.greenHitLocation)
                     .frame(width: 150, height: 150)
                 Text(selectedLocationDescription)
                    .font(Theme.fontCaption)
                    .foregroundColor(Theme.textSecondary)
                    .frame(height: 30) // Keep height to prevent layout shifts
                    .multilineTextAlignment(.center)
             }
             .frame(maxWidth: .infinity)

             // Putting Area
             VStack(alignment: .leading, spacing: Theme.spacingL) {
                 Text("Putting").font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
                 // Number of Putts
                 VStack(alignment: .leading, spacing: Theme.spacingXS) {
                     Text("Number of Putts:").font(Theme.fontCaption).foregroundColor(Theme.textSecondary)
                     HStack(spacing: Theme.spacingXS) {
                         ForEach(0...4, id: \.self) { putts in
                             Button { hole.putts = putts } label: {
                                 Text("\(putts)")
                                    .font(Theme.fontBody)
                                    .frame(minWidth: 32, minHeight: 32)
                                    .padding(Theme.spacingXXS)
                                    .background(hole.putts == putts ? Theme.accentSecondary : Theme.surface)
                                    .foregroundColor(hole.putts == putts ? Theme.textOnAccent : Theme.textPrimary)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.divider))
                             }
                         }
                     }
                 }
                 // First Putt Distance
                 VStack(alignment: .leading, spacing: Theme.spacingXS) {
                     Text("First Putt Dist:").font(Theme.fontCaption).foregroundColor(Theme.textSecondary)
                     distanceInput(value: $hole.firstPuttDistance, placeholder: "feet", focusState: $isFirstPuttDistanceFocused)
                 }
             }
             .frame(maxWidth: .infinity)
         }
     }

    // Description for selected green location
    private var selectedLocationDescription: String {
        switch hole.greenHitLocation {
            case .center: return "Green in Reg"
            case .longLeft: return "Missed Long Left"
            case .long: return "Missed Long"
            case .longRight: return "Missed Long Right"
            case .left: return "Missed Left"
            case .right: return "Missed Right"
            case .shortLeft: return "Missed Short Left"
            case .short: return "Missed Short"
            case .shortRight: return "Missed Short Right"
        }
    }

    // MARK: Score Section
    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingS) {
            Text("Score").font(Theme.fontHeadline).foregroundColor(Theme.textPrimary)
            let scoreOptions = getScoreOptions(for: hole.par)
            HStack(spacing: Theme.spacingXS) {
                ForEach(scoreOptions, id: \.self) { scoreValue in
                    Button { hole.score = scoreValue } label: {
                        Text(scoreString(for: scoreValue, par: hole.par))
                            .fontWeight(hole.score == scoreValue ? .semibold : .medium)
                            .font(Theme.fontBody)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.spacingS)
                            .background(hole.score == scoreValue ? scoreColor(for: scoreValue, par: hole.par) : Theme.surface)
                            .foregroundColor(hole.score == scoreValue ? foregroundColorForScore(scoreValue, par: hole.par) : Theme.textPrimary)
                            .cornerRadius(Theme.cornerRadiusS)
                            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadiusS).stroke(Theme.divider))
                            .shadow(color: hole.score == scoreValue ? Theme.neutral.opacity(0.15) : .clear,
                                   radius: Theme.cornerRadiusS / 2, x: 0, y: 2)

                    }
                }
            }
        }
    }

    // MARK: - Helper Views/Functions

    // Reusable Distance Input TextField
    private func distanceInput(value: Binding<Int?>, placeholder: String, focusState: FocusState<Bool>.Binding) -> some View {
        TextField(placeholder, value: value, format: .number)
            .keyboardType(.numberPad)
            .font(Theme.fontBody)
            .padding(Theme.spacingXS)
            .background(Theme.surface)
            .cornerRadius(Theme.cornerRadiusS)
            .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadiusS).stroke(Theme.divider))
            .focused(focusState)
            .frame(width: 80)
            .multilineTextAlignment(.trailing)
    }

    // Reusable Fairway Button
    private func fairwayButton(label: String, hit: Bool?, direction: FairwayMissDirection) -> some View {
        let isSelected = (hole.fairwayHit == hit) && (hit == true || hole.fairwayMissDirection == direction)
        let bgColor = isSelected ? (hit == true ? Theme.positive : Theme.warning) : Theme.surface
        let fgColor = isSelected ? Theme.textOnAccent : Theme.textPrimary

        return Button {
            hole.fairwayHit = hit
            hole.fairwayMissDirection = (hit == false) ? direction : .none
        } label: {
            Text(label)
                .fontWeight(.medium).font(Theme.fontBody)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.spacingXS)
                .background(bgColor)
                .foregroundColor(fgColor)
                .cornerRadius(Theme.cornerRadiusS)
                .overlay(RoundedRectangle(cornerRadius: Theme.cornerRadiusS).stroke(Theme.divider))
        }
    }

    // MARK: Score Helpers

    // Generate score options around par
    private func getScoreOptions(for par: Int) -> [Int] {
        guard par >= 3 else { return [1, 2, 3, 4, 5] }
        let lowerBound = max(1, par - 3)
        let upperBound = par + 3
        return Array(lowerBound...upperBound)
    }

    // Get text label for score (e.g., "Birdie", "Par", "+2")
    private func scoreString(for score: Int, par: Int) -> String {
        guard par > 0 else { return "\(score)" }
        if score == 1 { return "Ace!" }
        let diff = score - par
        switch diff {
            case ..<(-2): return "\(diff)"
            case -2: return "Eagle"
            case -1: return "Birdie"
            case 0:  return "Par"
            case 1:  return "Bogey"
            case 2:  return "Double"
            default: return "+\(diff)"
        }
    }

    // Get background color for score button
    private func scoreColor(for score: Int, par: Int) -> Color {
        guard par > 0 else { return Theme.neutral }
        if score == 1 { return Theme.warning }
        let diff = score - par
        switch diff {
            case ..<(-1): return Theme.accentPrimary
            case -1: return Theme.negative
            case 0:  return Theme.accentSecondary
            case 1:  return Theme.neutral
            default: return Theme.textPrimary.opacity(0.7)
        }
    }

    // Get foreground color for score button text (for contrast)
    private func foregroundColorForScore(_ score: Int, par: Int) -> Color {
        let bgColor = scoreColor(for: score, par: par)
        if bgColor == Theme.neutral || bgColor == Theme.textPrimary.opacity(0.7) || bgColor == Theme.accentPrimary || bgColor == Theme.accentSecondary || bgColor == Theme.negative {
            return .white // Use white on darker/colored backgrounds
        } else {
            return Theme.textPrimary // Use primary text on lighter backgrounds (like Yellow/Warning)
        }
    }

} // End HoleView


// MARK: - Supporting Views Defined Locally (WindSettingsView, ImprovedGreenTargetView)

// Wind settings sheet View
struct WindSettingsView: View {
    @Binding var windSpeed: Double
    @Binding var windDirection: Int
    let approachDistance: Int?
    @Environment(\.dismiss) var dismiss

    private let vizSize: CGFloat = 120
    private let arrowSize: CGFloat = 20

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.spacingL) {
                    directionPickerSection
                    speedSliderSection
                    visualizerContainer
                        .padding(.vertical, Theme.spacingS)
                    windImpactPreview
                    Spacer(minLength: 20)
                }
                .padding(Theme.spacingM)
            }
            .navigationTitle("Wind Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(Theme.fontBodySemibold)
                        .foregroundColor(Theme.accentSecondary)
                }
            }
            .background(Theme.background.ignoresSafeArea())
        }
    }

    // Direction Picker
    private var directionPickerSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            Text("Wind Direction (Blowing From):")
                .font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
            Picker("Direction", selection: $windDirection) {
                Text("N").tag(0); Text("NE").tag(45); Text("E").tag(90); Text("SE").tag(135);
                Text("S").tag(180); Text("SW").tag(225); Text("W").tag(270); Text("NW").tag(315)
            }
            .pickerStyle(.segmented)
            .tint(Theme.accentSecondary)
        }
    }

    // Speed Slider
    private var speedSliderSection: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
            Text("Wind Speed: \(Int(windSpeed.rounded())) m/s")
                .font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
            Slider(value: $windSpeed, in: 0...25, step: 1)
                .tint(Theme.accentSecondary)
        }
    }

    // Wind Visualizer
    private var visualizerContainer: some View {
        ZStack {
            Circle().stroke(Theme.divider, lineWidth: 1)
                .frame(width: vizSize, height: vizSize)

            ForEach([("N", 0.0), ("E", 90.0), ("S", 180.0), ("W", 270.0)], id: \.0) { labelData in
                Text(labelData.0)
                    .font(Theme.fontCaption2).foregroundColor(Theme.textSecondary)
                    .offset(y: -(vizSize / 2 + 10))
                    .rotationEffect(.degrees(-labelData.1))
                    .rotationEffect(.degrees(labelData.1))
            }

            Image(systemName: "location.north.fill")
                .resizable().scaledToFit()
                .frame(width: arrowSize)
                .foregroundColor(Theme.accentSecondary)
                .rotationEffect(.degrees(Double(windDirection)))
                .offset(y: -(vizSize / 2 - arrowSize / 2 - 5))
                .rotationEffect(.degrees(Double(windDirection)))
        }
        .frame(height: vizSize + 30)
    }

    // Wind Impact Preview Text
    @ViewBuilder private var windImpactPreview: some View {
        VStack(alignment: .leading, spacing: Theme.spacingXS) {
             Text("Estimated Impact").font(Theme.fontHeadline).foregroundColor(Theme.textPrimary)
             if let distance = approachDistance, distance > 0 {
                 let impact = WindCalculator.calculateImpact(distance: distance, windSpeed: windSpeed, windDirection: Double(windDirection))
                 Text("On \(distance)m shot:").font(Theme.fontSubheadline).foregroundColor(Theme.textSecondary)
                 HStack {
                      Text("Plays like: \(distance + impact)m")
                           .font(Theme.fontBodySemibold)
                           .foregroundColor(impact > 0 ? Theme.positive : (impact < 0 ? Theme.negative : Theme.textPrimary))
                      Spacer()
                      Text(impactDescription(impact: impact))
                           .font(Theme.fontCaption).foregroundColor(Theme.textSecondary)
                 }

             } else {
                 Text("Enter approach distance in Hole view to see estimated impact.")
                    .font(Theme.fontCaption).foregroundColor(Theme.textSecondary)
             }
        }
         .padding(Theme.spacingM)
         .frame(maxWidth: .infinity, alignment: .leading)
         .background(Theme.surface)
         .cornerRadius(Theme.cornerRadiusM)
    }

    // Helper for impact description text
    private func impactDescription(impact: Int) -> String {
        let absImpact = abs(impact)
        if impact > 5 { return "Helping (\(absImpact)m+)" }
        else if impact > 0 { return "Helping (\(absImpact)m)" }
        else if impact < -5 { return "Hurting (\(absImpact)m+)" }
        else if impact < 0 { return "Hurting (\(absImpact)m)" }
        else { return "Minimal Wind Effect" }
    }
}

// Improved Green Target View
struct ImprovedGreenTargetView: View {
    @Binding var selectedLocation: GreenHitLocation
    let locations: [[GreenHitLocation]] = [
        [.longLeft, .long, .longRight],
        [.left, .center, .right],
        [.shortLeft, .short, .shortRight]
    ]

    var body: some View {
        Grid(horizontalSpacing: 2, verticalSpacing: 2) {
            ForEach(0..<3, id: \.self) { row in
                GridRow {
                    ForEach(0..<3, id: \.self) { col in
                        let location = locations[row][col]
                        locationButton(for: location)
                    }
                }
            }
        }
        .background(Theme.divider.opacity(0.5))
        .cornerRadius(Theme.cornerRadiusS)
        .aspectRatio(1, contentMode: .fit)
    }

    private func locationButton(for location: GreenHitLocation) -> some View {
        Button { selectedLocation = location } label: {
            ZStack {
                Rectangle().fill(locationColor(location))
                    .aspectRatio(1, contentMode: .fit)
                if location == .center { centerMarkerView }
                Text(directionText(for: location))
                    .font(Theme.fontCaption2)
                    .foregroundColor(Theme.textOnAccent)
                    .fontWeight(selectedLocation == location ? .bold : .regular)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    private var centerMarkerView: some View {
        Circle()
            .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
            .padding(Theme.spacingXXS)
    }

    private func locationColor(_ location: GreenHitLocation) -> Color {
        guard selectedLocation == location else { return Theme.neutral.opacity(0.4) }
        return location == .center ? Theme.positive : Theme.warning
    }

    private func directionText(for location: GreenHitLocation) -> String {
        switch location {
            case .center: return "GIR"; case .longLeft: return "L/L"; case .long: return "Long"
            case .longRight: return "L/R"; case .left: return "Left"; case .right: return "Right"
            case .shortLeft: return "S/L"; case .short: return "Short"; case .shortRight: return "S/R"
        }
    }
}

// MARK: - Previews
#if DEBUG
struct HoleView_Previews: PreviewProvider {
     @State static var previewHole: Hole = {
        var hole = Hole(number: 7, par: 3)
        hole.approachDistance = 155
        hole.windSpeed = 8
        hole.windDirection = 45
        hole.score = 3
        hole.teeClub = Club.allClubs.first(where: {$0.name == "7 Iron"}) ?? Club(type: .iron, name: "7 Iron")
        hole.greenHitLocation = .center
        hole.putts = 2
        return hole
     }()

     static var previews: some View {
         NavigationView { HoleView(hole: $previewHole) }
     }
 }
#endif
// --- END OF FILE GolfTracker.swiftpm/Sources/Views/HoleView.swift ---
