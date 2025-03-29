import SwiftUI

struct RoundView: View {
    @Binding var round: Round
    @State private var currentHoleIndex = 0
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    // Explicitly save data before leaving
                    saveHoleDataBeforeLeaving()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                    Text("Home")
                }
                
                Spacer()
                
                Text("Round: \(formattedDate)")
                    .font(.headline)
                
                Spacer()
                
                Text("\(currentHoleIndex + 1)/\(round.holes.count)")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Current hole view
            if round.holes.indices.contains(currentHoleIndex) {
                HoleView(hole: $round.holes[currentHoleIndex])
                    .padding()
                    .onChange(of: round.holes[currentHoleIndex]) { _ in
                        // Save data whenever a hole is updated
                        saveHoleDataToUserDefaults()
                    }
            }
            
            // Navigation buttons
            HStack {
                Button(action: {
                    if currentHoleIndex > 0 {
                        // Save current hole data before navigating
                        saveHoleDataToUserDefaults()
                        currentHoleIndex -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .disabled(currentHoleIndex == 0)
                .padding()
                .foregroundColor(currentHoleIndex == 0 ? .gray : .blue)
                
                Spacer()
                
                Button(action: {
                    // Save current hole data before navigating
                    saveHoleDataToUserDefaults()
                    
                    if currentHoleIndex < round.holes.count - 1 {
                        currentHoleIndex += 1
                    } else {
                        // Finish round, ensure data is saved, and return to home
                        saveHoleDataBeforeLeaving()
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text(currentHoleIndex < round.holes.count - 1 ? "Next" : "Finish Round")
                        .fontWeight(.semibold)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    if currentHoleIndex < round.holes.count - 1 {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
            }
            .padding(.bottom)
        }
        .navigationBarHidden(true)
        .onDisappear {
            // Make sure round is saved when we leave the view
            saveHoleDataBeforeLeaving()
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: round.date)
    }
    
    // Helper methods to ensure data is saved
    private func saveHoleDataToUserDefaults() {
        // Get all existing rounds
        let rounds = DataManager.shared.loadRounds()
        
        // Find and update the current round
        if let index = rounds.firstIndex(where: { $0.id == round.id }) {
            var updatedRounds = rounds
            updatedRounds[index] = round
            DataManager.shared.saveRounds(updatedRounds)
        }
    }
    
    private func saveHoleDataBeforeLeaving() {
        // Perform more comprehensive save when leaving
        saveHoleDataToUserDefaults()
        
        // Optional: log to debug
        print("Saved round with id: \(round.id)")
        print("Hole count: \(round.holes.count)")
        print("First hole score: \(round.holes.first?.score ?? 0)")
    }
}
