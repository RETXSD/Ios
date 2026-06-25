import XCTest
@testable import Nihonggo

final class ScanResultTests: XCTestCase {
    func test_scanResult_confidenceBelowThreshold_returnsLowConfidenceMessage() {
        let result = ScanResult(mode: .character, detectedText: "あ", confidence: 0.49)

        XCTAssertTrue(result.isLowConfidence)
        XCTAssertEqual(result.userMessage, "Tulisan kurang jelas, coba lagi")
    }

    func test_scanResult_confidenceAtThreshold_doesNotReturnLowConfidenceMessage() {
        let result = ScanResult(mode: .character, detectedText: "あ", confidence: 0.5)

        XCTAssertFalse(result.isLowConfidence)
        XCTAssertNil(result.userMessage)
    }
}
