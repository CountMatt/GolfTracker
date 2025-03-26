//
//  GreenTargetView.swift
//  GolfTracker
//
//  Created by Matteo Keller on 25.03.2025.
//


// File: Sources/Views/Components/GreenTargetView.swift
import SwiftUI

struct GreenTargetView: View {
    @Binding var selectedLocation: GreenHitLocation
    
    // Grid layout: 3x3 grid of locations
    let locations: [[GreenHitLocation]] = [
        [.longLeft, .long, .longRight],
        [.left, .center, .right],
        [.shortLeft, .short, .shortRight]
    ]
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Green Hit Location")
                .font(.headline)
                .padding(.bottom, 4)
            
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
                                        .fill(selectedLocation == location ? Color.green : Color.gray.opacity(0.3))
                                        .frame(width: 60, height: 60)
                                    
                                    if location == .center {
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 40, height: 40)
                                    }
                                    
                                    // Show directional indicators
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
            
            Text(getLocationDescription(for: selectedLocation))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
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
    
    private func getLocationDescription(for location: GreenHitLocation) -> String {
        switch location {
        case .center: return "Green in Regulation"
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
}
