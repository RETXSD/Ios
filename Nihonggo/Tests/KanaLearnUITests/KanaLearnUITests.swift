import XCTest

final class KanaLearnUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_onboardingFlow_tappingStart_reachesHomeTab() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Mulai Belajar"].tap()

        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 3))
    }

    func test_lessonFlow_openLessons_showsN5AndLockedN4() {
        let app = XCUIApplication()
        app.launch()
        completeOnboardingIfNeeded(app)

        app.tabBars.buttons["Lessons"].tap()

        XCTAssertTrue(app.staticTexts["N5"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Lulus level sebelumnya untuk membuka N4"].exists)
    }

    func test_scanFlow_openScan_showsModeToggleAndCapture() {
        let app = XCUIApplication()
        app.launch()
        completeOnboardingIfNeeded(app)

        app.tabBars.buttons["Scan"].tap()

        XCTAssertTrue(app.segmentedControls["Scan mode"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Capture"].exists)
    }

    func test_dictionaryFlow_searchWater_showsJapaneseResult() {
        let app = XCUIApplication()
        app.launch()
        completeOnboardingIfNeeded(app)

        app.tabBars.buttons["Kamus"].tap()
        app.searchFields.firstMatch.tap()
        app.searchFields.firstMatch.typeText("water\n")

        XCTAssertTrue(app.staticTexts["水"].waitForExistence(timeout: 3))
    }

    private func completeOnboardingIfNeeded(_ app: XCUIApplication) {
        let startButton = app.buttons["Mulai Belajar"]
        if startButton.waitForExistence(timeout: 1) {
            startButton.tap()
        }
    }
}
