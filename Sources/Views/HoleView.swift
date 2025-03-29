// File: Sources/Views/HoleView.swift
import SwiftUI
// import CoreLocation // No longer needed if LocationManager is removed
import OSLog       // Keep OSLog if you still want logging

// NOTE: LocationManager class is REMOVED from this file.

// MARK: - Simple wind display view
struct WindIndicatorView: View {
    let speed: Double
    let direction: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.up")
                .rotationEffect(.degrees(Double(direction)))
                .frame(width: 20, height: 20)
            Text("\(Int(speed.rounded())) m/s") // Rounded speed
                .font(.system(size: 14))
        }
        .padding(.horizontal, 10).padding(.vertical, 5)
        .background(speed > 0 ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(8)
    }
}


// MARK: - Main Hole View (Reverted State)
struct HoleView: View {
    // --- Properties ---
    @Binding var hole: Hole
    @FocusState private var isApproachDistanceFocused: Bool
    @FocusState private var isFirstPuttDistanceFocused: Bool
    // @StateObject private var locationManager = LocationManager() // REMOVED
    // @State private var isLoadingWeather = false // REMOVED
    // @State private var weatherError: String? = nil // REMOVED
    @State private var showWindSettings = false // Keep this for manual wind settings

    // Club options
    private let teeClubOptions = [
        Club(type: .driver, name: "Driver"), Club(type: .wood, name: "3W"), Club(type: .wood, name: "5W"),
        Club(type: .hybrid, name: "3H"), Club(type: .hybrid, name: "4H"),
        Club(type: .iron, name: "4i"), Club(type: .iron, name: "5i"), Club(type: .iron, name: "6i")
    ]
    private let approachClubOptions = [
        Club(type: .wood, name: "5W"), Club(type: .hybrid, name: "4H"),
        Club(type: .iron, name: "4i"), Club(type: .iron, name: "5i"), Club(type: .iron, name: "6i"),
        Club(type: .iron, name: "7i"), Club(type: .iron, name: "8i"), Club(type: .iron, name: "9i"),
        Club(type: .wedge, name: "PW"), Club(type: .wedge, name: "GW"), Club(type: .wedge, name: "SW"),
        Club(type: .wedge, name: "LW")
    ]
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "HoleView")

    // --- Main Body ---
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                holeHeaderSection // Contains Title, Par, Wind button, Impact
                Divider()
                teeShotSection    // Contains Tee Club, Fairway
                Divider()
                approachSection   // Contains Approach Dist/Club, Green Target/Putting
                Divider()
                scoreSection      // Contains Score buttons
            }
            .padding() // Add padding once around the main VStack
            .onAppear {
                 // Only initialize score if needed
                 if hole.score == 0 && hole.par > 0 { hole.score = hole.par }
            }
            // .onDisappear { /* No location updates to stop */ } // Removed location manager call
            .toolbar { // Keep keyboard toolbar
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer(); Button("Done") { isApproachDistanceFocused = false; isFirstPuttDistanceFocused = false }
                }
            }
            .sheet(isPresented: $showWindSettings) { // Keep manual wind settings sheet
                 WindSettingsView(windSpeed: $hole.windSpeed, windDirection: $hole.windDirection, approachDistance: hole.approachDistance)
                 .presentationDetents([.medium, .large])
            }
        } // End ScrollView
    } // End body


    // --- Extracted Subview Sections ---

    // MARK: Hole Header Section
    private var holeHeaderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hole \(hole.number)")
                .font(.largeTitle).fontWeight(.bold)
            parSelectionView // Extracted Par selection
            windSection      // Simplified Wind Section
            // weatherStatusMessageView // REMOVED - No automatic weather/location status
            windImpactDisplayView    // Keep wind impact based on manual/saved wind data
        }
    }

    // Extracted Par Selection View
    private var parSelectionView: some View {
        HStack {
            Text("Par:").font(.headline)
            ForEach([3, 4, 5], id: \.self) { parValue in
                Button { hole.par = parValue; hole.score = parValue } label: {
                    Text("\(parValue)").padding(.horizontal, 12).padding(.vertical, 6)
                        .background(hole.par == parValue ? Color.green : Color.gray.opacity(0.2))
                        .foregroundColor(hole.par == parValue ? .white : .primary).cornerRadius(8)
                }
            }
        }
    }

    // Extracted (and Simplified) Wind Section View
    private var windSection: some View {
         HStack(alignment: .center) {
             Text("Wind:").font(.subheadline)
             // Button to open manual wind settings
             Button { showWindSettings = true } label: {
                 WindIndicatorView(speed: hole.windSpeed, direction: hole.windDirection)
             }
             Spacer() // Keep spacer to align indicator left
             // "Current" button and ProgressView REMOVED
         }
    }

    // Extracted Wind Impact Display View
     @ViewBuilder
     private var windImpactDisplayView: some View {
         if let distance = hole.approachDistance, distance > 0 {
             let impact = calculateWindImpact(distance: distance) // Use the instance method
             if abs(impact) > 0 {
                 HStack {
                     Image(systemName: impact > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                         .foregroundColor(impact > 0 ? .green : .red)
                     Text("Wind \(impact > 0 ? "helps" : "hurts") by \(abs(impact))m.")
                         .font(.caption)
                     Spacer()
                     Text("Effective: \(distance + impact)m")
                         .font(.caption.weight(.medium))
                 }
                 .padding(8).background(Color.gray.opacity(0.1)).cornerRadius(6)
             }
         }
     }


    // MARK: Tee Shot Section
    private var teeShotSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tee Shot").font(.headline)
            HStack {
                Text("Club:").font(.subheadline); Spacer()
                Menu {
                    ForEach(teeClubOptions) { club in Button(club.name) { hole.teeClub = club } }
                    Button("Clear") { hole.teeClub = nil }
                } label: {
                    HStack { Text(hole.teeClub?.name ?? "Select Club").foregroundColor(hole.teeClub == nil ? .secondary : .primary); Image(systemName: "chevron.down") }
                    .padding(.horizontal, 12).padding(.vertical, 6).background(Color.gray.opacity(0.1)).cornerRadius(8)
                }
            }
            if !hole.isPar3 {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Fairway:").font(.subheadline)
                    HStack(spacing: 8) {
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
        VStack(alignment: .leading, spacing: 10) {
            Text("Approach Shot").font(.headline)
            HStack {
                Text("Distance:").font(.subheadline)
                distanceInput(value: $hole.approachDistance, placeholder: "Meters", focusState: $isApproachDistanceFocused)
            }
            HStack {
                Text("Club:").font(.subheadline); Spacer()
                Menu {
                    ForEach(approachClubOptions) { club in Button(club.name) { hole.approachClub = club } }
                    Button("Clear") { hole.approachClub = nil }
                } label: {
                    HStack { Text(hole.approachClub?.name ?? "Select Club").foregroundColor(hole.approachClub == nil ? .secondary : .primary); Image(systemName: "chevron.down") }
                    .padding(.horizontal, 12).padding(.vertical, 6).background(Color.gray.opacity(0.1)).cornerRadius(8)
                }
            }
            greenTargetAndPuttingSection
        }
    }

     // Extracted Green Target and Putting HStack content
     private var greenTargetAndPuttingSection: some View {
         HStack(alignment: .top, spacing: 20) {
             VStack(alignment: .center, spacing: 6) {
                 Text("Green Result:").font(.subheadline)
                 ImprovedGreenTargetView(selectedLocation: $hole.greenHitLocation)
                     .frame(width: 160, height: 160)
             }
             .frame(maxWidth: .infinity)
             VStack(alignment: .leading, spacing: 10) {
                 Text("Putting:").font(.headline)
                 VStack(alignment: .leading, spacing: 6){
                     Text("Putts:").font(.subheadline)
                     HStack {
                         ForEach(0...4, id: \.self) { putts in
                             Button { hole.putts = putts } label: {
                                 Text("\(putts)").frame(width: 35, height: 35).background(hole.putts == putts ? Color.blue : Color.gray.opacity(0.2))
                                     .foregroundColor(hole.putts == putts ? .white : .primary).clipShape(Circle())
                             }
                         }
                     }
                 }
                 VStack(alignment: .leading, spacing: 6) {
                     Text("First Putt Dist:").font(.subheadline)
                     distanceInput(value: $hole.firstPuttDistance, placeholder: "Feet", focusState: $isFirstPuttDistanceFocused)
                 }
             }
             .frame(maxWidth: .infinity)
         }
     }

    // MARK: Score Section
    private var scoreSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Score for Hole \(hole.number):").font(.headline)
            let scoreOptions = getScoreOptions(for: hole.par)
            HStack(spacing: 6) {
                ForEach(scoreOptions, id: \.self) { score in
                    Button { hole.score = score } label: {
                        Text(scoreString(for: score, par: hole.par)).fontWeight(.medium).frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(hole.score == score ? scoreColor(for: score, par: hole.par) : Color.gray.opacity(0.2))
                            .foregroundColor(hole.score == score ? .white : .primary).cornerRadius(8)
                    }
                }
            }
        }
    }


    // --- Helper Views/Functions ---

    private func distanceInput(value: Binding<Int?>, placeholder: String, focusState: FocusState<Bool>.Binding) -> some View {
        TextField(placeholder, value: value, format: .number)
            .keyboardType(.numberPad).padding(8).background(Color(.systemGray6)).cornerRadius(8)
            .focused(focusState).frame(width: 100)
    }

    private func fairwayButton(label: String, hit: Bool?, direction: FairwayMissDirection) -> some View {
        Button {
            hole.fairwayHit = hit
            hole.fairwayMissDirection = (hit == false) ? direction : .none
        } label: {
            Text(label).fontWeight(.medium).frame(maxWidth: .infinity).padding(.vertical, 8)
                .background(fairwayButtonColor(hit: hit, direction: direction))
                .foregroundColor(fairwayButtonForegroundColor(hit: hit, direction: direction)).cornerRadius(8)
        }
    }

    private func fairwayButtonColor(hit: Bool?, direction: FairwayMissDirection) -> Color {
        let isSelected: Bool = (hit == true && hole.fairwayHit == true) || (hit == false && hole.fairwayHit == false && hole.fairwayMissDirection == direction)
        return isSelected ? (hit == true ? .green : .orange) : Color.gray.opacity(0.2)
    }
     private func fairwayButtonForegroundColor(hit: Bool?, direction: FairwayMissDirection) -> Color {
         let isSelected: Bool = (hit == true && hole.fairwayHit == true) || (hit == false && hole.fairwayHit == false && hole.fairwayMissDirection == direction)
         return isSelected ? .white : .primary
     }

    // MARK: Weather Fetch Logic (REMOVED)
    // private func fetchCurrentWeather() { /* ... */ }
    // private func getWeatherData(for location: CLLocation) { /* ... */ }
    // private var appName: String { /* ... */ } // Not needed if fetchCurrentWeather is removed

    // MARK: Score Helpers
    private func getScoreOptions(for par: Int) -> [Int] { guard par >= 3 else { return [1, 2, 3, 4, 5] }; let base = par - 2; return (max(1, base)...par + 3).map { $0 } }
    private func scoreString(for score: Int, par: Int) -> String { guard par > 0 else { return "\(score)" }; let diff = score - par; if score == 1 { return "Ace!" }; if diff < -2 { return "\(diff)" }; if diff == -2 { return "Eagle" }; if diff == -1 { return "Birdie" }; if diff == 0 { return "Par" }; if diff == 1 { return "Bogey" }; if diff == 2 { return "Dbl" }; return "+\(diff)" }
    private func scoreColor(for score: Int, par: Int) -> Color { guard par > 0 else { return .gray }; let diff = score - par; if score == 1 { return .yellow }; if diff <= -2 { return .purple }; if diff == -1 { return .red }; if diff == 0 { return .green }; if diff == 1 { return .blue }; return diff == 2 ? .gray : .black.opacity(0.8) }
    func calculateWindImpact(distance: Int) -> Int { return WindCalculator.calculateImpact(distance: distance, windSpeed: hole.windSpeed, windDirection: Double(hole.windDirection)) }

} // End HoleView

// MARK: - Supporting Views Defined Locally

// Wind settings sheet (Keep this for manual wind setting)
struct WindSettingsView: View {
    @Binding var windSpeed: Double
    @Binding var windDirection: Int
    let approachDistance: Int?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                directionPickerSection
                speedSliderSection
                visualizerContainer
                windImpactPreview
                Spacer()
            }
            .padding().navigationTitle("Wind Settings").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }

    private var directionPickerSection: some View { VStack(alignment: .leading, spacing: 8) { Text("Wind Direction (From):").font(.subheadline); Picker("Direction", selection: $windDirection) { Text("N").tag(0); Text("NE").tag(45); Text("E").tag(90); Text("SE").tag(135); Text("S").tag(180); Text("SW").tag(225); Text("W").tag(270); Text("NW").tag(315) }.pickerStyle(SegmentedPickerStyle()) } }
    private var speedSliderSection: some View { VStack(alignment: .leading, spacing: 8) { Text("Wind Speed: \(Int(windSpeed.rounded())) m/s").font(.subheadline); Slider(value: $windSpeed, in: 0...25, step: 1) } }
    private var visualizerContainer: some View { ZStack { backgroundCircle; rotatingArrow; centerDot; directionLabels }.frame(height: 140) }
    private var backgroundCircle: some View { Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1).frame(width: 100, height: 100) }
    private var rotatingArrow: some View { Image(systemName: "location.north.fill").resizable().scaledToFit().frame(width: 20).rotationEffect(.degrees(Double(windDirection))).offset(y: -35).rotationEffect(.degrees(Double(windDirection))) }
    private var centerDot: some View { Circle().fill(Color.white).frame(width: 10, height: 10) }
    private var directionLabels: some View { ForEach([("N", 0), ("E", 90), ("S", 180), ("W", 270)], id: \.0) { labelData in Text(labelData.0).font(.caption).foregroundColor(.secondary).offset(y: -60).rotationEffect(.degrees(Double(-labelData.1))).rotationEffect(.degrees(Double(labelData.1))) } }
    @ViewBuilder private var windImpactPreview: some View { if let distance = approachDistance, distance > 0 { let impact = WindCalculator.calculateImpact(distance: distance, windSpeed: windSpeed, windDirection: Double(windDirection)); VStack(spacing: 4) { Text("Estimated Impact on \(distance)m shot").font(.subheadline); Text("Plays like: \(distance + impact)m").font(.headline).foregroundColor(impact > 0 ? .green : (impact < 0 ? .red : .primary)); Text(impact > 5 ? "Wind Helping" : (impact < -5 ? "Wind Hurting" : "Minimal Effect")).font(.caption).foregroundColor(.secondary) }.padding().background(Color.gray.opacity(0.1)).cornerRadius(8) } else { Text("Enter approach distance to see impact.").font(.caption).foregroundColor(.secondary) } }
}


// Improved GreenTargetView
struct ImprovedGreenTargetView: View {
    @Binding var selectedLocation: GreenHitLocation
    let locations: [[GreenHitLocation]] = [ [.longLeft, .long, .longRight], [.left, .center, .right], [.shortLeft, .short, .shortRight] ]
    var body: some View { VStack(spacing: 2) { ForEach(0..<3, id: \.self) { row in HStack(spacing: 2) { ForEach(0..<3, id: \.self) { col in let location = locations[row][col]; locationButton(for: location) } } } }.background(Color.black.opacity(0.1)).cornerRadius(8) }
    private func locationButton(for location: GreenHitLocation) -> some View { Button { selectedLocation = location } label: { ZStack { Rectangle().fill(locationColor(location)).aspectRatio(1, contentMode: .fit); if location == .center { centerMarkerView }; Text(directionText(for: location)).font(.system(size: 10)).foregroundColor(.white).fontWeight(selectedLocation == location ? .bold : .regular) } } }
    private var centerMarkerView: some View { Circle().stroke(Color.white.opacity(0.7), lineWidth: 2).padding(8) }
    private func locationColor(_ location: GreenHitLocation) -> Color { location == selectedLocation ? (location == .center ? Color.green : .orange) : Color.gray.opacity(0.3) }
    private func directionText(for location: GreenHitLocation) -> String { switch location { case .center: return "GIR"; case .longLeft: return "L/L"; case .long: return "Long"; case .longRight: return "L/R"; case .left: return "Left"; case .right: return "Right"; case .shortLeft: return "S/L"; case .short: return "Short"; case .shortRight: return "S/R" } }
}


// MARK: - Previews
#if DEBUG
struct HoleView_Previews: PreviewProvider {
     @State static var previewHole: Hole = { var hole = Hole(number: 1, par: 4); if let sampleRound = SampleData.sampleRounds.first, let sampleHole = sampleRound.holes.first { hole = sampleHole }; hole.score = hole.par; hole.approachDistance = 150; hole.windSpeed = 5; hole.windDirection = 270; return hole }()
     static var previews: some View { NavigationView { HoleView(hole: $previewHole) } }
 }
#endif


