//
//  TodoPersistenceService.swift
//  To-Do List
//
//  Handles reading and writing the todos array as a JSON file
//  stored in the app's Documents directory.
//

import Foundation

// MARK: - Persistence Service

class TodoPersistenceService {

    // Name of the JSON file saved on disk
    private let fileName = "todos.json"

    /// Full path to the JSON file in the app's Documents directory
    private var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    // MARK: - Save

    /// Encodes the todos array to JSON and writes it to disk.
    /// Called automatically every time the todos array changes.
    func save(_ todos: [TodoItem]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601   // store dates as readable ISO-8601 strings
            encoder.outputFormatting = .prettyPrinted // human-readable JSON file
            let data = try encoder.encode(todos)
            try data.write(to: fileURL, options: .atomic) // .atomic = safe write (temp file first)
            print("✅ Saved \(todos.count) todos to \(fileURL.lastPathComponent)")
        } catch {
            print("❌ Failed to save todos: \(error.localizedDescription)")
        }
    }

    // MARK: - Load

    /// Reads the JSON file from disk and decodes it back to a todos array.
    /// Returns an empty array if the file doesn't exist yet or decoding fails.
    func load() -> [TodoItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("ℹ️ No saved data found. Starting fresh.")
            return []
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let todos = try decoder.decode([TodoItem].self, from: data)
            print("✅ Loaded \(todos.count) todos from \(fileURL.lastPathComponent)")
            return todos
        } catch {
            print("❌ Failed to load todos: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - File Location (debug helper)

    /// Prints the full path of the JSON file — useful for inspecting in Finder during development.
    func printFilePath() {
        print("📂 JSON file path: \(fileURL.path)")
    }
}
