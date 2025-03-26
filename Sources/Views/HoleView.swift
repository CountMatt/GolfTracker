//
//  HoleView.swift
//  GolfTracker
//
//  Created by Matteo Keller on 25.03.2025.
//


// File: Sources/Views/HoleView.swift
import SwiftUI



struct HoleView: View {
    @Binding var hole: Hole
    @FocusState private var isApproachDistanceFocused: Bool
    @FocusState private var isFirstPuttDistanceFocused: Bool
    
    // Add this function right here
    private func saveHoleData() {
        // This forces the binding to update by accessing it
        let _ = hole
    }
    
    // Rest of your existing code...
    // Limited club selections for tee and approach shots
    private let teeClubOptions = [
        Club(type: .driver, name: "Driver"),
        Club(type: .wood, name: "7W"),
        Club(type: .iron, name: "4i"),
        Club(type: .iron, name: "5i"),
        Club(type: .iron, name: "6i")
    ]
    
    private let approachClubOptions = [
        Club(type: .wood, name: "7W"),
        Club(type: .iron, name: "4i"),
        Club(type: .iron, name: "5i"),
        Club(type: .iron, name: "6i"),
        Club(type: .iron, name: "7i"),
        Club(type: .iron, name: "8i"),
        Club(type: .iron, name: "9i"),
        Club(type: .wedge, name: "PW"),
        Club(type: .wedge, name: "50°"),
        Club(type: .wedge, name: "54°"),
        Club(type: .wedge, name: "58°")
    ]
       
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Hole header with par selection
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hole \(hole.number)")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Par:")
                            .font(.headline)
                        
                        ForEach([3, 4, 5], id: \.self) { parValue in
                            Button(action: {
                                hole.par = parValue
                                // Auto-set the initial score to match par
                                hole.score = parValue
                            }) {
                                Text("\(parValue)")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(hole.par == parValue ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundColor(hole.par == parValue ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.bottom, 4)
                
                Divider()
                
                // Tee shot section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tee Shot")
                        .font(.headline)
                    
                    // Club dropdown selector
                    HStack {
                        Text("Club:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(teeClubOptions) { club in
                                Button(club.name) {
                                    hole.teeClub = club
                                }
                            }
                        } label: {
                            HStack {
                                Text(hole.teeClub?.name ?? "Select Club")
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    if !hole.isPar3 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fairway:")
                                .font(.subheadline)
                            
                            HStack(spacing: 8) {
                                Button(action: {
                                    hole.fairwayHit = false
                                    hole.fairwayMissDirection = .left
                                }) {
                                    Text("Left")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(hole.fairwayHit == false && hole.fairwayMissDirection == .left ?
                                                    Color.red.opacity(0.7) : Color.gray.opacity(0.2))
                                        .foregroundColor(hole.fairwayHit == false && hole.fairwayMissDirection == .left ?
                                            .white : .primary)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    hole.fairwayHit = true
                                }) {
                                    Text("Hit")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(hole.fairwayHit == true ? Color.green : Color.gray.opacity(0.2))
                                        .foregroundColor(hole.fairwayHit == true ? .white : .primary)
                                        .cornerRadius(8)
                                }
                                
                                Button(action: {
                                    hole.fairwayHit = false
                                    hole.fairwayMissDirection = .right
                                }) {
                                    Text("Right")
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(hole.fairwayHit == false && hole.fairwayMissDirection == .right ?
                                                    Color.red.opacity(0.7) : Color.gray.opacity(0.2))
                                        .foregroundColor(hole.fairwayHit == false && hole.fairwayMissDirection == .right ?
                                            .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Approach shot section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Approach Shot")
                        .font(.headline)
                    
                    HStack {
                        Text("Distance:")
                            .font(.subheadline)
                        
                        ZStack(alignment: .trailing) {
                            TextField("Meters", value: $hole.approachDistance, format: .number)
                                .keyboardType(.numberPad)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .focused($isApproachDistanceFocused)
                            
                            if isApproachDistanceFocused {
                                Button("Done") {
                                    isApproachDistanceFocused = false
                                }
                                .padding(.trailing, 8)
                                .foregroundColor(.blue)
                            }
                        }
                        .frame(width: 120)
                    }
                    
                    // Approach club dropdown
                    HStack {
                        Text("Club:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Menu {
                            ForEach(approachClubOptions) { club in
                                Button(club.name) {
                                    hole.approachClub = club
                                }
                            }
                        } label: {
                            HStack {
                                Text(hole.approachClub?.name ?? "Select Club")
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Green hit location and putts in same row
                    HStack(alignment: .top, spacing: 16) {
                        // Green target view
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Green Hit Location:")
                                .font(.subheadline)
                            
                            ImprovedGreenTargetView(selectedLocation: $hole.greenHitLocation)
                                .frame(width: 180, height: 180)
                        }
                        
                        // Putts section next to green
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Putts:")
                                .font(.subheadline)
                            
                            VStack(spacing: 8) {
                                // Putts selector
                                HStack {
                                    ForEach(1...4, id: \.self) { putts in
                                        Button(action: {
                                            hole.putts = putts
                                        }) {
                                            Text("\(putts)")
                                                .frame(width: 30)
                                                .padding(.vertical, 8)
                                                .background(hole.putts == putts ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(hole.putts == putts ? .white : .primary)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                // First putt distance
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("First Putt:")
                                        .font(.caption)
                                    
                                    ZStack(alignment: .trailing) {
                                        TextField("Feet", value: $hole.firstPuttDistance, format: .number)
                                            .keyboardType(.numberPad)
                                            .padding(8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                            .focused($isFirstPuttDistanceFocused)
                                        
                                        if isFirstPuttDistanceFocused {
                                            Button("Done") {
                                                isFirstPuttDistanceFocused = false
                                            }
                                            .padding(.trailing, 8)
                                            .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                // Score section at the end
                VStack(alignment: .leading, spacing: 8) {
                    Text("Score:")
                        .font(.headline)
                    
                    // Dynamic score buttons based on par
                    let scoreOptions = getScoreOptions(for: hole.par)
                    
                    HStack(spacing: 6) {
                        ForEach(scoreOptions, id: \.self) { score in
                            Button(action: {
                                hole.score = score
                            }) {
                                Text(scoreString(for: score, par: hole.par))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(hole.score == score ?
                                                scoreColor(for: score, par: hole.par) :
                                                    Color.gray.opacity(0.2))
                                    .foregroundColor(hole.score == score ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
            .onAppear {
                // Initialize score to par value when view appears
                if hole.score == 0 {
                    hole.score = hole.par
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isApproachDistanceFocused = false
                        isFirstPuttDistanceFocused = false
                    }
                }
                
            }
            .onDisappear {
                // Make sure data is saved when leaving the view
                saveHoleData()
            }
            
        }
        
    }
    
    
    
    // Helper function to get score options based on par
    private func getScoreOptions(for par: Int) -> [Int] {
        switch par {
        case 3:
            return [2, 3, 4, 5, 6]
        case 4:
            return [3, 4, 5, 6, 7]
        case 5:
            return [3, 4, 5, 6, 7]
        default:
            return [par - 1, par, par + 1, par + 2, par + 3]
        }
    }
    
    // Helper function to show score in golf terms
    private func scoreString(for score: Int, par: Int) -> String {
        let diff = score - par
        
        if diff == -2 {
            return "Eagle"
        } else if diff == -1 {
            return "Birdie"
        } else if diff == 0 {
            return "Par"
        } else if diff == 1 {
            return "Bogey"
        } else if diff == 2 {
            return "Dbl"
        } else {
            return "\(score)"
        }
    }
    
    // Helper function to color score buttons
    private func scoreColor(for score: Int, par: Int) -> Color {
        let diff = score - par
        
        if diff <= -2 {
            return Color.purple   // Eagle or better
        } else if diff == -1 {
            return Color.red      // Birdie
        } else if diff == 0 {
            return Color.green    // Par
        } else if diff == 1 {
            return Color.blue     // Bogey
        } else {
            return Color.gray     // Double bogey or worse
        }
    }
}

// Improved GreenTargetView with correct coloring
struct ImprovedGreenTargetView: View {
    @Binding var selectedLocation: GreenHitLocation
    
    // Grid layout: 3x3 grid of locations
    let locations: [[GreenHitLocation]] = [
        [.longLeft, .long, .longRight],
        [.left, .center, .right],
        [.shortLeft, .short, .shortRight]
    ]
    
    var body: some View {
        VStack(spacing: 2) {
            VStack(spacing: 2) {
                ForEach(0..<3) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<3) { col in
                            let location = locations[row][col]
                            Button(action: {
                                selectedLocation = location
                            }) {
                                ZStack {
                                    Rectangle()
                                        .fill(getLocationColor(location))
                                        .frame(width: 52, height: 52)
                                    
                                    if location == .center {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 32, height: 32)
                                    }
                                    
                                    Text(getDirectionText(for: location))
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .fontWeight(selectedLocation == location ? .bold : .regular)
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.black.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    // Get color based on location - green for GIR, light red for misses
    private func getLocationColor(_ location: GreenHitLocation) -> Color {
        if location == selectedLocation {
            return location == .center ? Color.green : Color.red.opacity(0.7)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private func getDirectionText(for location: GreenHitLocation) -> String {
        switch location {
        case .center: return "GIR"
        case .longLeft: return "L/L"
        case .long: return "Long"
        case .longRight: return "L/R"
        case .left: return "Left"
        case .right: return "Right"
        case .shortLeft: return "S/L"
        case .short: return "Short"
        case .shortRight: return "S/R"
        }
    }
}
