//
//  WindInputView.swift
//  GolfTracker
//
//  Created by Matteo Keller on 28.03.2025.
//


// Create a new file called WindInputView.swift
import SwiftUI

struct WindInputView: View {
    @Binding var windSpeed: Double
    @Binding var windDirection: Int
    @Binding var isPresented: Bool
    let approachDistance: Int?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Wind Settings")
                .font(.headline)
            
            // Wind direction picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Wind Direction:")
                    .font(.subheadline)
                
                Picker("Direction", selection: $windDirection) {
                    Text("N").tag(0)
                    Text("NE").tag(45)
                    Text("E").tag(90)
                    Text("SE").tag(135)
                    Text("S").tag(180)
                    Text("SW").tag(225)
                    Text("W").tag(270)
                    Text("NW").tag(315)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Wind speed slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Wind Speed: \(Int(windSpeed)) m/s")
                    .font(.subheadline)
                
                Slider(value: $windSpeed, in: 0...20, step: 1)
            }
            
            // Distance impact calculation
            if let distance = approachDistance {
                let impact = calculateWindImpact(
                    distance: distance, 
                    windSpeed: windSpeed, 
                    windDirection: Double(windDirection)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Shot Impact:")
                        .font(.subheadline)
                    
                    HStack {
                        Text("Adjusted distance:")
                        Spacer()
                        Text("\(distance + impact) meters")
                            .foregroundColor(impact > 0 ? .green : (impact < 0 ? .red : .primary))
                            .fontWeight(.semibold)
                    }
                    
                    Text(impactDescription(impact: impact))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            // Buttons
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                Spacer()
                
                Button("Apply") {
                    isPresented = false
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
    
    // Wind impact calculation
    private func calculateWindImpact(distance: Int, windSpeed: Double, windDirection: Double) -> Int {
        // Convert degrees to radians for calculation
        let radians = (windDirection * .pi) / 180.0
        
        // Calculate headwind/tailwind component (0° = North)
        // If you're shooting north and wind is from north (0°), that's a pure headwind
        let headwindComponent = cos(radians) * windSpeed
        
        // Calculate crosswind component
        let crosswindComponent = sin(radians) * windSpeed
        
        // Headwind generally reduces distance more than crosswind
        let headwindImpact = -headwindComponent * 2.5  // 2.5m per 1m/s headwind
        let crosswindImpact = abs(crosswindComponent) * 0.8  // 0.8m per 1m/s crosswind
        
        // Total impact (negative = shorter, positive = longer)
        let totalImpact = Int(headwindImpact - crosswindImpact)
        
        return totalImpact
    }
    
    private func impactDescription(impact: Int) -> String {
        if impact > 10 {
            return "Strong tailwind is helping your shot significantly"
        } else if impact > 0 {
            return "Light tailwind is slightly helping your shot"
        } else if impact == 0 {
            return "Wind has minimal impact on this shot"
        } else if impact > -10 {
            return "Light headwind is slightly hurting your shot"
        } else {
            return "Strong headwind is significantly hurting your shot"
        }
    }
}
