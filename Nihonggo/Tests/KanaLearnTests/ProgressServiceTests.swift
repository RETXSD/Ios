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
}
