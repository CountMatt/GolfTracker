import SwiftUI

struct HomeView: View {
    @State private var rounds: [Round] = []
    @State private var statistics: Statistics = Statistics()
    @State private var showingNewRoundOptions = false
    @State private var selectedTab = 0
    @State private var selectedRound: Round? = nil
    @State private var showRoundView = false
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                // HOME TAB
                NavigationView {
                    ZStack {
                        // Background color
                        Color(hex: "F8F9FA").ignoresSafeArea()
                        
                        ScrollView {
                            VStack(spacing: 24) {
                                // Header with subtle gradient background
                                ZStack {
                                    // Subtle gradient background
                                    LinearGradient(
                                        colors: [Color(hex: "E2EADF"), Color(hex: "F8F9FA")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .padding(.horizontal)
                                    
                                    VStack(spacing: 8) {
                                        Text("Golf Tracker")
                                            .font(.title)
                                            .bold()
                                            .foregroundColor(Color(hex: "252C34"))
                                        
                                        Text("\(statistics.totalRounds) rounds recorded")
                                            .font(.subheadline)
                                            .foregroundColor(Color(hex: "5F6B7A"))
                                    }
                                }
                                .padding(.top)
                                
                                // Start round action card
                                Button {
                                    showingNewRoundOptions = true
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Start New Round")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text("Record your next golf adventure")
                                                .font(.subheadline)
                                                .foregroundColor(Color.white.opacity(0.9))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "2D7D46"), Color(hex: "18A558")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: Color(hex: "2D7D46").opacity(0.3), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal)
                                    .buttonStyle(PressableButtonStyle())
                                }
                                
                                // Stats summary
                                StatSummaryView(statistics: statistics)
                                
                                // Recent rounds section
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("Recent Rounds")
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "252C34"))
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    if rounds.isEmpty {
                                        // Empty state
                                        VStack(spacing: 16) {
                                            Image(systemName: "flag.fill")
                                                .font(.system(size: 48))
                                                .foregroundColor(Color(hex: "CBD5E0"))
                                            
                                            Text("No rounds recorded yet")
                                                .font(.headline)
                                                .foregroundColor(Color(hex: "5F6B7A"))
                                            
                                            Text("Start a new round to begin tracking your golf journey")
                                                .font(.subheadline)
                                                .foregroundColor(Color(hex: "5F6B7A"))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 32)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(hex: "CBD5E0"), lineWidth: 1)
                                        )
                                        .padding(.horizontal)
                                    } else {
                                        // List of rounds
                                        VStack(spacing: 2) {
                                            ForEach(rounds.sorted(by: { $0.date > $1.date })) { round in
                                                RoundSummaryRow(round: round)
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 8)
                                                    .background(Color.white)
                                                    .contentShape(Rectangle())
                                                    .onTapGesture {
                                                        selectedRound = round
                                                        showRoundView = true
                                                    }
                                                
                                                if round.id != rounds.sorted(by: { $0.date > $1.date }).last?.id {
                                                    Divider()
                                                        .padding(.horizontal)
                                                }
                                            }
                                        }
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // Bottom spacing for tab bar
                                Spacer(minLength: 60)
                            }
                        }
                    }
                    .navigationBarHidden(true)
                    .edgesIgnoringSafeArea(.bottom)
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                
                // STATS TAB
                StatsView(statistics: statistics)
                    .tabItem {
                        Label("Statistics", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
            }
            .onAppear {
                loadData()
                
                // Apply this appearance modifier to fix tab bar
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithOpaqueBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
            
            // Navigation to round view
            .navigationDestination(isPresented: $showRoundView) {
                if let round = selectedRound {
                    if let index = rounds.firstIndex(where: { $0.id == round.id }) {
                        RoundView(round: $rounds[index])
                            .onDisappear {
                                saveData()
                            }
                    }
                }
            }
        }
        .confirmationDialog(
            "Choose number of holes",
            isPresented: $showingNewRoundOptions,
            titleVisibility: .visible
        ) {
            Button("9 Holes") {
                startNewRound(holeCount: 9)
                   
            }
            Button("18 Holes") {
                startNewRound(holeCount: 18)
                    
            }
            Button("Cancel", role: .cancel) { }
                
        }
    }
    
    // MARK: - Existing Data Methods (Keep these as they are)
    
    private func startNewRound(holeCount: Int) {
        let newRound = Round.createNew(holeCount: holeCount)
        rounds.append(newRound)
        saveData()
        
        selectedRound = newRound
        DispatchQueue.main.async {
            showRoundView = true
        }
    }
    
    private func loadData() {
        rounds = DataManager.shared.loadRounds()
        updateStatistics()
    }
    
    private func saveData() {
        DataManager.shared.saveRounds(rounds)
        updateStatistics()
    }
    
    private func updateStatistics() {
        let calculator = StatisticsCalculator()
        statistics = calculator.calculateStatistics(from: rounds)
    }
    
    private func deleteRound(_ round: Round) {
        if let index = rounds.firstIndex(where: { $0.id == round.id }) {
            rounds.remove(at: index)
            saveData()
        }
    }
    // Add this to the HomeView struct
    private func configureNavigation() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(Color.white)
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "252C34")),
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}

// For button press animations
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}




struct RoundSummaryRow: View {
    let round: Round
    
    var scoreString: String {
        let relativeToPar = round.scoreRelativeToPar
        if relativeToPar == 0 {
            return "Even par"
        } else if relativeToPar > 0 {
            return "+\(relativeToPar)"
        } else {
            return "\(relativeToPar)"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(formattedDate)
                    .font(.headline)
                Text(round.courseName)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(round.totalScore)")
                    .font(.headline)
                Text(scoreString)
                    .font(.subheadline)
                    .foregroundColor(round.scoreRelativeToPar <= 0 ? .green : .red)
            }
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: round.date)
    }
}


// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
