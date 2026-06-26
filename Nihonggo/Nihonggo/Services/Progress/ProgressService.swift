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
        normalizeStagedLessonProgress()
        updateStreakIfNeeded()
    }

    func markLessonProgress(level: String, completion: Double) {
        var updated = progress
        updated.lessonProgress[level] = min(max(completion, 0), 1)
        updated.xp += Int(max(completion, 0) * 20)
        progress = updated
        save()
    }

    func markStageProgress(level: String, stageNumber: Int, completion: Double) {
        var updated = progress
        updated.lessonProgress[stageKey(level: level, stageNumber: stageNumber)] = min(max(completion, 0), 1)
        updated.lessonProgress[level] = levelCompletion(level: level, progress: updated)
        updated.xp += Int(max(completion, 0) * 10)
        progress = updated
        save()
    }

    func recordExam(level: String, score: Int) {
        var updated = progress
        updated.examResults[level] = score
        if score >= 70 {
            unlockNextLevel(after: level, progress: &updated)
            updated.lessonProgress[level] = 1
            updated.xp += 100
        }
        progress = updated
        save()
    }

    func completion(for level: String) -> Double {
        levelCompletion(level: level, progress: progress)
    }

    func completion(level: String, stageNumber: Int) -> Double {
        progress.lessonProgress[stageKey(level: level, stageNumber: stageNumber)] ?? 0
    }

    func isStageUnlocked(level: String, stageNumber: Int) -> Bool {
        guard progress.isUnlocked(level) else { return false }
        guard stageNumber > 1 else { return true }
        return completion(level: level, stageNumber: stageNumber - 1) >= 1
    }

    func currentLevel() -> String {
        levels.last(where: progress.unlockedLevels.contains) ?? "N5"
    }

    private func unlockNextLevel(after level: String, progress: inout UserProgress) {
        guard let index = levels.firstIndex(of: level), levels.indices.contains(index + 1) else { return }
        let nextLevel = levels[index + 1]
        if !progress.unlockedLevels.contains(nextLevel) {
            progress.unlockedLevels.append(nextLevel)
            progress.lessonProgress[nextLevel] = progress.lessonProgress[nextLevel] ?? 0
        }
    }

    private func levelCompletion(level: String, progress: UserProgress) -> Double {
        let stageCompletions = (1...5).map { stageNumber in
            progress.lessonProgress[stageKey(level: level, stageNumber: stageNumber)] ?? 0
        }
        return stageCompletions.reduce(0, +) / Double(stageCompletions.count)
    }

    private func normalizeStagedLessonProgress() {
        var updated = progress
        var didChange = false

        for level in levels {
            let hasStageProgress = (1...5).contains { stageNumber in
                updated.lessonProgress[stageKey(level: level, stageNumber: stageNumber)] != nil
            }
            let normalizedCompletion = hasStageProgress ? levelCompletion(level: level, progress: updated) : 0

            if updated.lessonProgress[level] != normalizedCompletion {
                updated.lessonProgress[level] = normalizedCompletion
                didChange = true
            }
        }

        guard didChange else { return }
        progress = updated
        save()
    }

    private func stageKey(level: String, stageNumber: Int) -> String {
        "\(level)-L\(stageNumber)"
    }

    private func updateStreakIfNeeded(calendar: Calendar = .current) {
        let lastDay = calendar.startOfDay(for: progress.lastActiveDate)
        let today = calendar.startOfDay(for: Date.now)
        guard lastDay != today else { return }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today), lastDay == yesterday {
            var updated = progress
            updated.streak += 1
            updated.lastActiveDate = Date.now
            progress = updated
        } else {
            var updated = progress
            updated.streak = 1
            updated.lastActiveDate = Date.now
            progress = updated
        }
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
