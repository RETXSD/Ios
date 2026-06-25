# ML Reference — Service Contracts for QA

Used by: qa-agent

## MLInferenceService

```swift
// Public API
class MLInferenceService {
    func classify(image: UIImage) async throws -> ScanResult
}
```

### Test Cases

| Condition | Expected Result |
|---|---|
| Valid hiragana image, clear writing | `ScanResult` with correct label, confidence > 0.8 |
| Valid kanji image, clear writing | `ScanResult` with correct label, confidence > 0.7 |
| Blank/empty image | Throws `MLError.preprocessingFailed` |
| Very faint writing | `ScanResult` with `isLowConfidence: true`, confidence < 0.5 |
| Non-Japanese character | Returns closest match with low confidence |
| Nil CGImage | Throws `MLError.preprocessingFailed` |

### Unit Test Template

```swift
func test_classify_clearHiragana_returnsCorrectLabel() async throws {
    let service = MLInferenceService()
    let image = UIImage(named: "test_hiragana_a")!
    let result = try await service.classify(image: image)
    XCTAssertEqual(result.character, "あ")
    XCTAssertGreaterThan(result.confidence, 0.8)
    XCTAssertFalse(result.isLowConfidence)
}

func test_classify_blankImage_throwsPreprocessingError() async {
    let service = MLInferenceService()
    let blankImage = UIImage()
    do {
        _ = try await service.classify(image: blankImage)
        XCTFail("Expected error not thrown")
    } catch MLError.preprocessingFailed {
        // pass
    } catch {
        XCTFail("Wrong error type: \(error)")
    }
}
```

## VisionTextService

```swift
// Public API
class VisionTextService {
    func recognizeText(from image: UIImage) async throws -> [String]
    func detectAndCropCharacter(from image: UIImage) async throws -> UIImage
}
```

### Test Cases

| Condition | Expected Result |
|---|---|
| Image with full sentence | Returns array of strings, joined = full sentence |
| Image with single character | Returns array with 1 element |
| Blank image | Throws `VisionError.noTextDetected` |
| Image with non-Japanese text | Returns detected text (may be incorrect labels) |

## ScanResult Model

```swift
struct ScanResult {
    let character: String      // detected character/sentence
    let confidence: Float      // 0.0 – 1.0
    let isLowConfidence: Bool  // true if confidence < 0.5
    let mode: ScanMode         // .character or .sentence
}
```

## Confidence Thresholds

| Range | Level | UI Behavior |
|---|---|---|
| 0.8 – 1.0 | High | Green badge, "Sempurna!" |
| 0.5 – 0.79 | Mid | Gold badge, "Lumayan, terus berlatih" |
| 0.0 – 0.49 | Low | Red badge, "Coba lagi, tulisan kurang jelas" |

## Threading Contract

- All `MLInferenceService` calls run on background thread internally
- All published results are delivered on `@MainActor`
- QA must not test threading directly — test observable state changes instead
