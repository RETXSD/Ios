import XCTest
@testable import Nihonggo

@MainActor
final class LanguageSettingsTests: XCTestCase {
    func test_appLanguage_indonesia_returnsIndonesianAIError() {
        XCTAssertEqual(AppLanguage.indonesia.text(.aiProxyError), "Koneksi AI bermasalah. Pastikan proxy server berjalan.")
    }

    func test_appLanguage_chineseSimplified_returnsChineseDictionaryTitle() {
        XCTAssertEqual(AppLanguage.chineseSimplified.text(.dictionaryTitle), "词典")
    }

    func test_appLanguage_english_returnsEnglishScanError() {
        XCTAssertEqual(AppLanguage.english.text(.scanGenericError), "Scan failed. Try again.")
    }
}
