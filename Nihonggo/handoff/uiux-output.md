# UI/UX Handoff

## Screens Built
- `App/ContentView.swift`: onboarding gate and main tab shell.
- `Views/Onboarding/SplashView.swift`: branded splash-style display.
- `Views/Onboarding/OnboardingView.swift`: first-run overview and start button.
- `Views/Home/HomeView.swift`: current level, XP, streak, and daily route summary.
- `Views/Lesson/LessonGridView.swift`: JLPT level list with lock overlays, progress, and 5-level badge.
- `Views/Lesson/LessonDetailView.swift`: five internal stages per JLPT level; stages 1-4 are practice and stage 5 is the final exam.
- `Views/Lesson/FlashcardView.swift`: front/back flashcard display with audio.
- `Views/Lesson/ExamView.swift`: mixed exam with reading choice, meaning matching, fill-blank sentence, flashcard recall, pass/fail result, unlock trigger.
- `Views/Scan/ScanView.swift`: camera preview, Huruf/Kalimat segmented picker, capture, results, confidence badge, Settings link on denied permission.
- `Views/Dictionary/DictionaryView.swift`: searchable dictionary list and detail sheet with examples.
- `Views/AIAssistant/AIAssistantView.swift`: multi-turn chat with proxy error display.
- `Views/Profile/ProfileView.swift`: JLPT badge, XP, streak, per-level completion.
- `Views/More/MoreView.swift`: language picker for Indonesia, Simplified Chinese, and English; shows AI language note.

## Navigation Flow
- `ContentView` shows `OnboardingView` first, then switches to a six-tab `TabView`.
- Tabs: Home, Lessons, Scan, Kamus, AI, More.
- Lessons tab uses `NavigationStack` with `Lesson` value navigation into `LessonDetailView`, then a stage-specific push into `ExamView`.
- `LessonDetailView` now shows stage cards instead of mutating a flat flashcard index; this removes the old progress write path that could trigger Swift exclusivity issues.
- Home “Open Lesson” now pushes `LessonGridView` directly; it no longer uses an unhandled value navigation route.
- Dictionary tab uses a `sheet(item:)` for entry details.
- Scan and AI are single-screen `NavigationStack` flows.

## Components Available
- `AppButton(title, systemImage, style, action)`: pill button with flat shadow.
- `AppCard { content }`: 7px card, 2px border, flat shadow.
- `AppBadge(text, color, systemImage)`: compact status badge.
- `ProgressBar(progress, label)`: labeled progress meter.
- `CharacterDisplay(character, reading)`: large serif character display with VoiceOver reading value.
- `ConfidenceBadge(confidence)`: green >= 80%, gold 50-79%, red < 50%.
- `AudioButton(text, audioService)`: ja-JP speech trigger.
- `LockedOverlay(message)`: lock state overlay for gated lessons.

## Data Bindings Used
- Home/Profile bind to `ProgressService.$progress`.
- Lessons bind to `LessonViewModel.lessons`, `unlockedLevels`, and `ProgressService` completion.
- Exam records scores through shared `ProgressService`; pass threshold is 70%.
- Stage progress is stored as `N5-L1` style keys and summarized into the parent JLPT level completion.
- Only stage 1 is open inside an unlocked JLPT level; stages 2-5 require the previous stage to be complete.
- Final exam completion and next JLPT unlock only happen on scores >= 70%.
- Exam rotates question modes from `ExamQuestionKind`: reading, meaning, blank, flashcard recall.
- Scan binds to `ScanViewModel` and its `CameraViewModel` handoff contract.
- Dictionary binds to `DictionaryViewModel.entries`, `query`, and `selectedEntry`.
- AI binds to `AIAssistantViewModel.messages`, `draft`, `isSending`, and `errorMessage`.
- All main screens observe `LanguageSettings.language` through `EnvironmentObject` for UI copy, alerts, and AI prompt language.

## Design Tokens Applied
- UI uses `AppTheme` colors (`toriiRed`, `sakuraBlush`, `sumiInk`, `washiWhite`, `tatamiCream`, `kinkakuGold`), 2px borders, and flat zero-blur shadows.
- More language selector uses existing `AppCard`, `AppBadge`, and neubrutalist border/shadow rules.

## Notes for QA Agent
- `JapaneseCharClassifier.mlmodel` is still a required external resource; character scan should show a graceful missing-model error until it is added.
- Add `NSCameraUsageDescription` to Info.plist before device testing camera permission.
- Onboarding state is in-memory for this build, so relaunch will show onboarding again.
- AI chat sends text only to `http://localhost:3000/chat`; proxy errors should show `Koneksi AI bermasalah. Pastikan proxy server berjalan.`
- Verify Dynamic Type around cards, dictionary rows, and the scan overlay; text uses system styles but dense horizontal rows may wrap on very small widths.
- Verify language switching updates tab labels, screen titles, scan error text, AI greeting, AI proxy error, and AI system prompt language without relaunch.
- Verify lesson buttons: Home open lesson, N-level detail stage cards, locked internal stages, final exam unlock, and mixed exam answer submission.
- Regression check: tap N5 from the lesson grid and open Level 1; previous simultaneous-access runtime crash should no longer reproduce.
