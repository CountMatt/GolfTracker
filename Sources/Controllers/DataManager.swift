

// File: Sources/Controllers/DataManager.swift
import Foundation
import OSLog
import SwiftUI // Import SwiftUI for ObservableObject

// Dedicated Actor for safe file operations off the main thread
actor FileActor {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "FileActor")
    private let roundsFilename = "rounds.json"

    // Computed property to get the URL for the data file
    private var roundsFileURL: URL {
        // Using force-try here, as failure is considered fatal for the app's state.
        // Proper error handling could involve fallback mechanisms or reporting.
        // swiftlint:disable:next force_try
        try! FileManager.default.url(for: .documentDirectory,
                                     in: .userDomainMask,
                                     appropriateFor: nil,
                                     create: true)
            .appendingPathComponent(roundsFilename)
    }

    // Saves the provided rounds array to disk
    func save(_ rounds: [Round]) throws {
        logger.debug("Attempting to save \(rounds.count) rounds to file...")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted // Optional: for readability

        let data = try encoder.encode(rounds)
        try data.write(to: roundsFileURL, options: [.atomicWrite, .completeFileProtection])
        logger.info("Successfully saved \(rounds.count) rounds to \(self.roundsFileURL.lastPathComponent)")
    }

    // Loads rounds from disk
    func load() throws -> [Round] {
        logger.debug("Attempting to load rounds from file...")
        guard FileManager.default.fileExists(atPath: roundsFileURL.path) else {
            logger.info("Rounds file not found. Returning empty array.")
            return [] // No file exists yet
        }

        let data = try Data(contentsOf: roundsFileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let rounds = try decoder.decode([Round].self, from: data)
        logger.info("Successfully loaded \(rounds.count) rounds from \(self.roundsFileURL.lastPathComponent)")
        return rounds
    }
}


@MainActor // Ensures @Published updates happen on the main thread
class DataManager: ObservableObject {
    @Published private(set) var rounds: [Round] = [] // The single source of truth

    static let shared = DataManager() // Singleton instance

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "GolfTracker", category: "DataManager")
    private let fileActor = FileActor() // Instance of the actor for file operations

    // Private initializer to load data asynchronously on creation
    private init() {
        logger.info("DataManager initializing...")
        Task {
            await loadInitialData()
            logger.info("Initial data load complete. \(self.rounds.count) rounds loaded.")
        }
    }

    // Loads initial data from the file actor
    private func loadInitialData() async {
        do {
            let loadedRounds = try await fileActor.load()
            // Assign on MainActor (guaranteed by class annotation)
            self.rounds = loadedRounds
            // Optional: Load sample data if file was empty
            // if self.rounds.isEmpty {
            //     self.rounds = SampleData.sampleRounds
            //     await saveChanges() // Save sample data immediately if loaded
            // }
        } catch {
            logger.error("Failed to load initial rounds: \(error.localizedDescription)")
            // Handle error appropriately, e.g., show an alert to the user
        }
    }

    // Saves the current state of the 'rounds' array asynchronously
    private func saveChanges() async {
        logger.debug("Save changes requested...")
        let currentRounds = self.rounds // Capture current state for saving
        do {
            try await fileActor.save(currentRounds)
        } catch {
            logger.error("Failed to save rounds: \(error.localizedDescription)")
            // Handle save error (e.g., retry logic, user alert)
        }
    }

    // --- Public Methods for Modifying Data ---

    func addRound(_ newRound: Round) {
        logger.info("Adding new round: \(newRound.id)")
        rounds.append(newRound)
        Task { await saveChanges() } // Trigger async save
    }

    func updateRound(_ updatedRound: Round) {
        guard let index = rounds.firstIndex(where: { $0.id == updatedRound.id }) else {
            logger.warning("Attempted to update round (\(updatedRound.id)) but it was not found.")
            return
        }
        logger.info("Updating round: \(updatedRound.id)")
        rounds[index] = updatedRound
        Task { await saveChanges() } // Trigger async save
    }

    func deleteRound(withId id: UUID) {
        logger.info("Requesting deletion for round: \(id)")
        let initialCount = rounds.count
        rounds.removeAll(where: { $0.id == id })
        if rounds.count < initialCount { // Check if the count decreased
            logger.info("Round \(id) removed from memory.")
            Task { await saveChanges() } // Trigger async save
        } else {
            logger.warning("Attempted to delete round (\(id)) but it was not found in memory (count did not change).")
        }
    }
}
