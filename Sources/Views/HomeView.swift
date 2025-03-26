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
                    ScrollView {
                        VStack(spacing: 16) {
                            // Header
                            Text("Golf Tracker")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top)
                            
                            // Stats summary
                            StatSummaryView(statistics: statistics)
                            
                            // New round button
                            Button {
                                showingNewRoundOptions = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New Round")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Recent rounds
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recent Rounds")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                if rounds.isEmpty {
                                    Text("No rounds recorded yet")
                                        .foregroundColor(.gray)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    ForEach(rounds.sorted(by: { $0.date > $1.date })) { round in
                                        RoundSummaryRow(round: round)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemBackground))
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                selectedRound = round
                                                showRoundView = true
                                            }
                                            .padding(.horizontal, 8)
                                        
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                    .padding(.bottom, 20)
                                }
                            }
                        }
                        .padding(.bottom, 50) // Extra bottom padding
                    }
                    .navigationBarHidden(true)
                    .edgesIgnoringSafeArea(.bottom) // Important to fix tab bar area
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
