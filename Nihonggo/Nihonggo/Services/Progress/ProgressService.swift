import Combine
import Foundation

@MainActor
final class ProgressService: ObservableObject {
    @Published private(set) var progress: UserProgress

    private let fileURL: URL
    private let levels = ["N5", "N4", "N3", "N2", "N1"]

    init(fileURL: URL = URL.documentsDirectory.appending(path: "userProgress.json")) {
        self.fileURL = fileURL
        self.progress = Self.load(from: fileURL)
        updateStreakIfNeeded()
    }

    func markLessonProgress(level: String, completion: Double) {
        progress.lessonProgress[level] = min(max(completion, 0), 1)
        progress.xp += Int(max(completion, 0) * 20)
        save()
    }

    func recordExam(level: String, score: Int) {
        progress.examResults[level] = score
        if score >= 70 {
            unlockNextLevel(after: level)
            progress.lessonProgress[level] = 1
            progress.xp += 100
        }
        save()
    }

    func completion(for level: String) -> Double {
        progress.lessonProgress[level] ?? 0
    }

    func currentLevel() -> String {
        levels.last(where: progress.unlockedLevels.contains) ?? "N5"
    }

    private func unlockNextLevel(after level: String) {
        guard let index = levels.firstIndex(of: level), levels.indices.contains(index + 1) else { return }
        let nextLevel = levels[index + 1]
        if !progress.unlockedLevels.contains(nextLevel) {
            progress.unlockedLevels.append(nextLevel)
            progress.lessonProgress[nextLevel] = progress.lessonProgress[nextLevel] ?? 0
        }
    }

    private func updateStreakIfNeeded(calendar: Calendar = .current) {
        let lastDay = calendar.startOfDay(for: progress.lastActiveDate)
        let today = calendar.startOfDay(for: Date.now)
        guard lastDay != today else { return }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), lastDay == yesterday {
            progress.streak += 1
        } else {
            progress.streak = 1
        }
        progress.lastActiveDate = Date.now
        save()
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(progress)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            #if DEBUG
            print("Progress save failed: \(error.localizedDescription)")
            #endif
        }
    }

    private static func load(from fileURL: URL) -> UserProgress {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(UserProgress.self, from: data)
        } catch {
            return .fresh
        }
    }
}
