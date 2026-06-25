import XCTest
@testable import Nihonggo

final class DictionaryServiceTests: XCTestCase {
    func test_dictionaryService_searchEnglishKeyword_returnsMatchingEntry() async {
        let service = DictionaryService(dictionaryURL: nil)

        let results = await service.search("water")

        XCTAssertTrue(results.contains { $0.character == "水" })
    }

    func test_dictionaryService_searchJapaneseCharacter_returnsMatchingEntry() async {
        let service = DictionaryService(dictionaryURL: nil)

        let results = await service.search("手")

        XCTAssertEqual(results.first?.reading, "te")
    }

    func test_dictionaryService_emptyQuery_returnsFallbackEntries() async {
        let service = DictionaryService(dictionaryURL: nil)

        let results = await service.search("")

        XCTAssertGreaterThanOrEqual(results.count, 2)
    }
}
