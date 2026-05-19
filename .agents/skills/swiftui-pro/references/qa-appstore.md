---
name: qa-appstore
description: Reviews code quality, test coverage, and App Store submission readiness for iOS apps. Use when writing tests, reviewing privacy compliance, or preparing for App Store submission.
license: MIT
metadata:
  author: generated for fitness coach project
  version: "1.0"
---

Review iOS app code and project configuration for test quality, privacy compliance, and App Store readiness. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Validate that unit tests cover all core business logic.
2. Check that UI tests cover critical user flows.
3. Ensure all required privacy usage descriptions are present in Info.plist.
4. Validate that entitlements match actual feature usage.
5. Check App Store metadata completeness (name, description, screenshots, keywords).
6. Ensure no debug/test code ships in production builds.
7. Validate crash-free launch on a clean install.


## Core Instructions

- Write unit tests for all model logic, calorie calculations, and workout recommendations.
- Write UI tests for: onboarding flow, calorie goal entry, workout recommendation tap, camera permission prompt.
- Use `XCTest` for unit tests, `XCUIApplication` for UI tests.
- Never use `sleep()` in UI tests — use `XCTNSPredicateExpectation` for async waits.
- All `fatalError`, `print`, and debug logging must be removed or gated behind `#if DEBUG`.
- Validate that `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`, and `NSCameraUsageDescription` are all present.
- Test on both iPhone SE (small screen) and iPhone Pro Max (large screen) before submitting.
- Ensure minimum iOS deployment target matches what was declared in App Store Connect.


## Privacy Checklist

```
[ ] NSHealthShareUsageDescription — present and describes actual usage
[ ] NSHealthUpdateUsageDescription — present if writing workouts to Health
[ ] NSCameraUsageDescription — present and describes exercise form feature
[ ] No user data sent to external servers without explicit consent
[ ] HealthKit data never logged to console in production
[ ] Camera frames processed on-device only
```


## App Store Submission Checklist

```
[ ] App icon — all required sizes provided (1024x1024 for App Store)
[ ] Screenshots — provided for all required device sizes
[ ] App name — unique, under 30 characters
[ ] Subtitle — under 30 characters
[ ] Description — clear, no placeholder text
[ ] Keywords — relevant, under 100 characters total
[ ] Support URL — valid and accessible
[ ] Privacy Policy URL — required for apps using HealthKit or Camera
[ ] Age rating — configured correctly
[ ] Build uploaded via Xcode or Transporter
[ ] TestFlight tested before submission
```


## Common Patterns

### Unit Test — Calorie Logic

```swift
final class CalorieCalculatorTests: XCTestCase {
    func testDailyGoalProgress() {
        let calculator = CalorieCalculator(goal: 500)
        calculator.addBurned(200)
        XCTAssertEqual(calculator.remainingCalories, 300)
        XCTAssertFalse(calculator.goalReached)
    }

    func testGoalReached() {
        let calculator = CalorieCalculator(goal: 500)
        calculator.addBurned(500)
        XCTAssertTrue(calculator.goalReached)
    }
}
```

### UI Test — Async Wait

```swift
func testCameraPermissionPrompt() {
    let app = XCUIApplication()
    app.launch()

    app.buttons["Start Workout"].tap()

    let alert = app.alerts.firstMatch
    let exists = NSPredicate(format: "exists == true")
    expectation(for: exists, evaluatedWith: alert)
    waitForExpectations(timeout: 5)

    XCTAssertTrue(alert.exists)
}
```

### Debug Gate

```swift
// Before
print("HealthKit data: \(calories)")

// After
#if DEBUG
print("HealthKit data: \(calories)")
#endif
```


## Output Format

Organize findings by category: Tests, Privacy, App Store Readiness. For each issue:

1. State the category and specific problem.
2. Name the rule being violated.
3. Show a fix or checklist item to complete.

End with a prioritized summary of blockers vs. nice-to-haves.
