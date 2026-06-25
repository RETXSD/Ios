import XCTest
@testable import Nihonggo

final class LessonResourceTests: XCTestCase {
    func test_lessonsResource_allJlptLevelsHaveCards() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "lessons", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let lessons = try JSONDecoder().decode([Lesson].self, from: data)

        XCTAssertEqual(lessons.map(\.level), ["N5", "N4", "N3", "N2", "N1"])
        XCTAssertTrue(lessons.allSatisfy { !$0.cards.isEmpty })
    }
}
