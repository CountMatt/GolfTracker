// File: Sources/Controllers/DataManager.swift
import Foundation
import OSLog // Import OSLog for better logging

@MainActor // Ensure shared instance and methods accessing it are on main thread by default
class DataManager {
    static let shared = DataManager() // Simpler singleton initialization
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "DataManager")
    
    // Define the filename for storing rounds data
    private let roundsFilename = "rounds.json"
    
    // Computed property to get the URL for the data file in the Documents directory
    private var roundsFileURL: URL {
        do {
            // Get the user's documents directory URL
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory,
                                                                 in: .userDomainMask,
                                                                 appropriateFor: nil,
                                                                 create: true) // Create directory if it doesn't exist
            // Append our filename to the directory path
            return documentsDirectory.appendingPathComponent(roundsFilename)
        } catch {
            // If we can't get the documents directory, something is seriously wrong.
            // Log the error and crash. This path is crucial.
            logger.critical("FATAL ERROR: Could not determine Documents directory: \(error.localizedDescription)")
            fatalError("Could not determine Documents directory: \(error.localizedDescription)")
        }
    }
    
    // Private initializer to enforce singleton pattern
    private init() {
        logger.info("DataManager initialized. Data file path: \(self.roundsFileURL.path)")
    }
    
    // Function to save the array of Round objects to the JSON file
    func saveRounds(_ rounds: [Round]) {
        // Use JSONEncoder to convert the [Round] array into Data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Use a standard date format
        encoder.outputFormatting = .prettyPrinted // Make JSON easier to read (optional)
        
        do {
            let data = try encoder.encode(rounds)
            // Write the encoded Data to the file URL atomically (safer)
            try data.write(to: roundsFileURL, options: [.atomicWrite, .completeFileProtection])
            logger.info("Successfully saved \(rounds.count) rounds to \(self.roundsFileURL.lastPathComponent)")
        } catch {
            // Log any errors during encoding or writing
            logger.error("Error saving rounds to \(self.roundsFileURL.path): \(error.localizedDescription)")
        }
    }
    
    // Function to load the array of Round objects from the JSON file
    func loadRounds() -> [Round] {
        // Check if the data file exists
        guard FileManager.default.fileExists(atPath: roundsFileURL.path) else {
            logger.info("Rounds file not found at \(self.roundsFileURL.path). Returning empty array (or sample data).")
            // If the file doesn't exist, return an empty array or initial sample data
            // return SampleData.sampleRounds // Uncomment this line if you want sample data on first launch
            return [] // Return empty array if no file exists
        }
        
        // Use JSONDecoder to convert Data back into a [Round] array
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // Match the encoding strategy
        
        do {
            // Read the Data from the file URL
            let data = try Data(contentsOf: roundsFileURL)
            // Decode the Data into an array of Round objects
            let rounds = try decoder.decode([Round].self, from: data)
            logger.info("Successfully loaded \(rounds.count) rounds from \(self.roundsFileURL.lastPathComponent)")
            return rounds
        } catch {
            // Log any errors during reading or decoding
            // This could happen if the file is corrupted or the data format changed
            logger.error("Error loading rounds from \(self.roundsFileURL.path): \(error.localizedDescription). Returning empty array.")
            // Consider deleting the corrupted file or attempting a backup recovery here if needed
            // For now, just return an empty array to prevent crashing
            return []
        }
    }
    
    // Keep the delete function, as it correctly uses load/save
    func deleteRound(with id: UUID) {
        var rounds = loadRounds()
        if rounds.removeAll(where: { $0.id == id }) != nil {
            logger.info("Deleting round with ID: \(id)")
            saveRounds(rounds)
        } else {
            logger.warning("Attempted to delete round with ID \(id), but it was not found.")
        }
    }
}
