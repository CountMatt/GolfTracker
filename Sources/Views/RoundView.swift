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
            }
            
            // Navigation buttons
            HStack {
                Button(action: {
                    if currentHoleIndex > 0 {
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
                    if currentHoleIndex < round.holes.count - 1 {
                        currentHoleIndex += 1
                    } else {
                        // Finish round and return to home
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
            // Make sure round is saved when we leave
            // This will update the binding which updates the round in HomeView
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: round.date)
    }
}
