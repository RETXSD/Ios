import XCTest
@testable import Nihonggo

@MainActor
final class ProgressServiceTests: XCTestCase {
    func test_progressService_passingExam_unlocksNextLevelAndPersistsScore() {
        let url = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let service = ProgressService(fileURL: url)

        service.recordExam(level: "N5", score: 85)

        XCTAssertTrue(service.progress.unlockedLevels.contains("N4"))
        XCTAssertEqual(service.progress.examResults["N5"], 85)
        XCTAssertEqual(service.progress.lessonProgress["N5"], 1)
    }

    func test_progressService_failingExam_doesNotUnlockNextLevel() {
        let url = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let service = ProgressService(fileURL: url)

        service.recordExam(level: "N5", score: 69)

        XCTAssertFalse(service.progress.unlockedLevels.contains("N4"))
        XCTAssertEqual(service.progress.examResults["N5"], 69)
    }

    func test_progressService_stageUnlockRequiresPreviousStageCompletion() {
        let url = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let service = ProgressService(fileURL: url)

        XCTAssertTrue(service.isStageUnlocked(level: "N5", stageNumber: 1))
        XCTAssertFalse(service.isStageUnlocked(level: "N5", stageNumber: 2))

        service.markStageProgress(level: "N5", stageNumber: 1, completion: 1)

        XCTAssertTrue(service.isStageUnlocked(level: "N5", stageNumber: 2))
        XCTAssertEqual(service.completion(for: "N5"), 0.2, accuracy: 0.001)
    }

    func test_progressService_legacyFlatLevelCompletionWithoutStages_resetsToZero() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        let legacyProgress = UserProgress(
            xp: 40,
            streak: 1,
            lastActiveDate: Date.now,
            unlockedLevels: ["N5"],
            lessonProgress: ["N5": 1],
            examResults: [:]
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(legacyProgress).write(to: url)

        let service = ProgressService(fileURL: url)

        XCTAssertEqual(service.completion(for: "N5"), 0)
        XCTAssertEqual(service.progress.lessonProgress["N5"], 0)
    }
}
