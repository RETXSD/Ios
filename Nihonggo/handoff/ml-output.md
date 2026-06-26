# Vision/ML Handoff

## Model Integration
- CoreML model file names and locations:
  - `Nihonggo/Nihonggo/Resources/hiraganaTrain.mlmodel`, compiled by Xcode to `hiraganaTrain.mlmodelc`.
  - `Nihonggo/Nihonggo/Resources/katakanaTrain.mlmodel`, compiled by Xcode to `katakanaTrain.mlmodelc`.
- Input format expected: model-described color image, currently 299x299 BGR/color image for both supplied CreateML classifiers. Still photos are passed through `VNCoreMLRequest` with `.scaleFit` so Vision handles orientation, scaling, and model-compatible preprocessing.
- Output format: `classLabel` as romaji-style `String` plus `classLabelProbs` as `[String: Double]`; confidence is normalized as `Double` in the `0.0...1.0` range.
- `MLInferenceService` maps romaji model labels to visible Hiragana/Katakana characters before publishing `ScanResult.detectedText`.

## Services Available
- `Services/ML/MLInferenceService.swift`
  - `init(hiraganaModelURL: URL? = Bundle.main.url(...), katakanaModelURL: URL? = Bundle.main.url(...)) throws`
  - `func classify(image: UIImage) async throws -> ScanResult`
- `Services/ML/VisionTextService.swift`
  - `func recognizeSentence(in image: UIImage) async throws -> ScanResult`
- `Services/Camera/CameraViewModel.swift`
  - `@Published private(set) var session: AVCaptureSession`
  - `@Published private(set) var authorizationStatus: AVAuthorizationStatus`
  - `@Published private(set) var scanResult: ScanResult?`
  - `@Published private(set) var errorMessage: String?`
  - `@Published private(set) var isSessionRunning: Bool`
  - `@Published private(set) var isProcessing: Bool`
  - `func requestCameraAccess() async`
  - `func startSession()`
  - `func stopSession()`
  - `func capture(mode: ScanMode) async`
  - `func clearResult()`
  - `func settingsURL() -> URL?`

## Data Models
- `ScanResult`
  - `id: UUID`
  - `mode: ScanMode`
  - `detectedText: String`
  - `confidence: Double`
  - `meaning: String?`
  - `createdAt: Date`
  - `isLowConfidence: Bool`
  - `userMessage: String?`
- `ScanMode`: `.character` displays as `Huruf`; `.sentence` displays as `Kalimat`.
- `ScanError`: localized camera, model, preprocessing, inference, and Vision text recognition errors.

## Scan Modes
- Single character mode flow: `CameraViewModel.capture(mode: .character)` captures a still image, passes it to cached `MLInferenceService.classify(image:)`, runs both Hiragana and Katakana classifiers through `VNCoreMLRequest`, chooses the strongest prediction using a confidence-plus-runner-up-gap score, maps the romaji label to kana, and publishes `scanResult` on the main actor.
- Sentence mode flow: `CameraViewModel.capture(mode: .sentence)` captures a still image, passes it to `VisionTextService.recognizeSentence(in:)`, runs `VNRecognizeTextRequest` with `ja-JP`, assembles the top candidates, and publishes `scanResult`.
- Confidence threshold and fallback behavior: `ScanResult.isLowConfidence` is `true` below `0.5`; `userMessage` becomes `Tulisan kurang jelas, coba lagi`.
- Auto Kana ambiguity behavior: if the Hiragana/Katakana selection-score margin is below 0.12, the best label is still shown but confidence is capped below 0.5 so UI displays the low-confidence fallback.

## Camera Permissions
- Info.plist keys to add:
  - `NSCameraUsageDescription`: `KanaLearn uses your camera to recognize handwritten Japanese characters on device.`
- Permission request flow: UI calls `requestCameraAccess()` before scanning. `.notDetermined` prompts the system dialog, `.authorized` configures the session, and `.denied` or `.restricted` sets a localized error and exposes `settingsURL()` for a Settings deep link.

## Notes for UI/UX Agent
- Expect `scanResult` to include `detectedText`, `confidence`, optional `meaning`, and optional low-confidence `userMessage`.
- Trigger scan with `await cameraViewModel.capture(mode: selectedMode)`, where `selectedMode` is `.character` or `.sentence`.
- `CameraViewModel` is `@MainActor`; views can observe it with `@StateObject`/`@ObservedObject`. Inference and Vision work are isolated to actors and are not run on the main actor.
- Known limitations: character mode currently supports supplied Hiragana/Katakana model classes only; Kanji should be scanned through sentence mode/Vision OCR until a Kanji dataset exists. The sentence mode currently returns a placeholder meaning; Dictionary/AI can refine this in UI/service layers.
