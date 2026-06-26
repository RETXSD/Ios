import XCTest
@testable import Nihonggo

final class LessonResourceTests: XCTestCase {
    func test_lessonsResource_allJlptLevelsHaveFiveStagesWithCards() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "lessons", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let lessons = try JSONDecoder().decode([Lesson].self, from: data)

        XCTAssertEqual(lessons.map(\.level), ["N5", "N4", "N3", "N2", "N1"])
        XCTAssertTrue(lessons.allSatisfy { $0.stages.count == 5 })
        XCTAssertTrue(lessons.allSatisfy { lesson in
            lesson.stages.enumerated().allSatisfy { index, stage in
                stage.number == index + 1 && stage.cards.count == 4
            }
        })
        XCTAssertTrue(lessons.allSatisfy { $0.stages.prefix(4).allSatisfy { !$0.isExam } })
        XCTAssertTrue(lessons.allSatisfy { $0.stages.last?.isExam == true })
    }
}
