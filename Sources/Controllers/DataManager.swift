import Foundation

class DataManager {
    // Make thread-safe with lazy initialization
    @MainActor static let shared: DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    private let roundsKey = "savedRounds"
    
    func saveRounds(_ rounds: [Round]) {
        // Save to UserDefaults for quick access
        do {
            let data = try JSONEncoder().encode(rounds)
            UserDefaults.standard.set(data, forKey: roundsKey)
        } catch {
            print("Error saving rounds: \(error.localizedDescription)")
        }
    }
    
    func loadRounds() -> [Round] {
        // First try to load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: roundsKey) {
            do {
                let rounds = try JSONDecoder().decode([Round].self, from: data)
                return rounds
            } catch {
                print("Error loading rounds from UserDefaults: \(error.localizedDescription)")
            }
        }
        
        // Return sample data if nothing saved yet
        return SampleData.sampleRounds
    }
    
    func deleteRound(with id: UUID) {
        var rounds = loadRounds()
        rounds.removeAll { $0.id == id }
        saveRounds(rounds)
    }
}
