import Foundation

struct UserProgress: Codable, Equatable {
    var xp: Int
    var streak: Int
    var lastActiveDate: Date
    var unlockedLevels: [String]
    var lessonProgress: [String: Double]
    var examResults: [String: Int]

    static let fresh = UserProgress(
        xp: 0,
        streak: 1,
        lastActiveDate: Date.now,
        unlockedLevels: ["N5"],
        lessonProgress: ["N5": 0],
        examResults: [:]
    )

    func isUnlocked(_ level: String) -> Bool {
        unlockedLevels.contains(level)
    }
}
