# QA Report

## Test Coverage
- Unit tests written in `Tests/KanaLearnTests/ScanResultTests.swift` for low-confidence threshold and fallback message behavior.
- Unit tests written in `Tests/KanaLearnTests/ProgressServiceTests.swift` for exam pass unlock, score persistence, failed-exam locked state, internal stage unlock rules, and legacy flat progress migration.
- Unit tests written in `Tests/KanaLearnTests/DictionaryServiceTests.swift` for English, Japanese, and empty-query dictionary lookup.
- Unit test written in `Tests/KanaLearnTests/AIAssistantServiceTests.swift` for graceful AI proxy connection error.
- Unit tests written in `Tests/KanaLearnTests/LanguageSettingsTests.swift` for Indonesian, Simplified Chinese, and English UI/error strings.
- Unit test written in `Tests/KanaLearnTests/LessonResourceTests.swift` to verify all JLPT levels exist, each contains five internal stages, stages 1-4 are practice, and stage 5 is final exam.
- UI tests written in `Tests/KanaLearnUITests/KanaLearnUITests.swift` for onboarding, lesson locked state, scan controls, and dictionary search.
- Project blocker: the original `Nihonggo.xcodeproj` has no XCTest/UI test targets yet, so these files are present but not wired into an executable test scheme.

## Privacy Compliance
- [x] NSCameraUsageDescription
- [x] Camera permission flow verified in code path
- [x] No image data transmitted externally
- [x] AI chat data policy confirmed
- [x] Debug logs gated behind #if DEBUG

## Accessibility
- [x] VoiceOver tested on all screens by code review
- [ ] Dynamic Type verified at all sizes
- [ ] Reduce Motion verified (flashcard animation disabled)
- [x] All interactive elements have accessibilityLabel or textual labels
- [ ] Full language switch VoiceOver pass for Indonesian, Simplified Chinese, and English

## Design System
- [x] No hardcoded colors outside `Theme/AppTheme.swift`
- [x] All shadows flat offset only
- [x] Confidence badge color logic correct
- [x] Locked state renders correctly by code review

## App Store Readiness
- [x] App icon set complete
- [ ] Launch screen configured
- [ ] Privacy Policy URL ready
- [ ] TestFlight build tested
- [x] No crash on cold launch verified by successful simulator build

## Blockers
- Add `Resources/JapaneseCharClassifier.mlmodel`; character scan currently reports the graceful missing-model error.
- Add XCTest and UI test targets to `Nihonggo.xcodeproj`, then attach the test files.
- Verify camera permission and camera capture on a physical device.
- Verify all remaining static lesson/dictionary content is acceptable as learning content even when UI language changes.
- Verify mixed exam modes manually on simulator/device until XCTest target is wired: reading, meaning match, fill blank, and flashcard recall.
- Verify each JLPT level contains 5 internal levels in the UI and only unlocks the next internal level after passing the previous one.
- Verify old `Documents/userProgress.json` files with flat `N5: 1` progress no longer show N5 as complete before stage progress exists.
- Verify lesson grid to N5 detail navigation and opening N5 Level 1 does not trigger simultaneous-access runtime crashes.
- Configure launch screen and Privacy Policy URL before App Store submission.

## Nice to Have
- Persist onboarding completion instead of keeping it in memory.
- Replace sentence-mode placeholder meaning with dictionary or AI-backed translation.
- Add richer fixture-driven tests for CoreML output once the real model is available.
