# Hygiene Reference — Clean & Maintainable Swift Code

Used by: visionml-agent, uiux-agent, qa-agent

## File Organization

```swift
// Standard file structure
import SwiftUI

// MARK: - View
struct LessonDetailView: View {
    // MARK: Properties
    @StateObject private var vm: LessonDetailViewModel
    @State private var isFlipped = false

    // MARK: Body
    var body: some View {
        content
            .navigationTitle(vm.lesson.title)
            .task { await vm.loadCards() }
    }

    // MARK: Subviews
    private var content: some View {
        VStack { }
    }
}

// MARK: - Preview
#Preview {
    LessonDetailView(lesson: .mock)
}
```

## Naming Conventions

```swift
// Views — noun + "View"
struct FlashcardView: View { }
struct ScanResultOverlay: View { }

// ViewModels — noun + "ViewModel"
class ScanViewModel: ObservableObject { }

// Services — noun + "Service"
class MLInferenceService { }
class AudioService { }

// Models — plain noun
struct ScanResult { }
struct Lesson { }

// Enums — UpperCamelCase, cases lowerCamelCase
enum ConfidenceLevel { case high, mid, low }
enum ScanMode { case character, sentence }
```

## No Force Unwrap

```swift
// WRONG
let model = try! JapaneseCharClassifier()
let result = output.classLabel!

// CORRECT
guard let model = try? JapaneseCharClassifier() else {
    throw MLError.modelNotFound
}
```

## No Magic Numbers

```swift
// WRONG
if confidence > 0.8 { }
.frame(width: 64, height: 64)

// CORRECT
enum MLConstants {
    static let highConfidenceThreshold: Float = 0.8
    static let lowConfidenceThreshold: Float = 0.5
    static let modelInputSize = CGSize(width: 64, height: 64)
}

if confidence > MLConstants.highConfidenceThreshold { }
.frame(width: MLConstants.modelInputSize.width,
       height: MLConstants.modelInputSize.height)
```

## Error Handling

```swift
// CORRECT — explicit, localized errors
enum DictionaryError: LocalizedError {
    case notFound(String)
    case databaseUnavailable

    var errorDescription: String? {
        switch self {
        case .notFound(let query): return "'\(query)' tidak ditemukan di kamus."
        case .databaseUnavailable: return "Kamus tidak tersedia. Coba restart app."
        }
    }
}

// WRONG — swallowed errors
try? service.lookup(query)  // never silently swallow
```

## Debug Logs

```swift
// CORRECT
#if DEBUG
print("[MLInference] label=\(label), confidence=\(confidence)")
#endif

// WRONG — logs in production
print("User scanned: \(label)")
```

## Mock Data for Previews

```swift
extension Lesson {
    static let mock = Lesson(
        id: UUID(),
        level: "N5",
        title: "Hiragana Dasar",
        isLocked: false,
        progress: 0.65
    )
}

extension ScanResult {
    static let mock = ScanResult(
        character: "あ",
        confidence: 0.92,
        isLowConfidence: false
    )
}
```

## Rules

- Use `// MARK: -` sections in every file
- No force unwrap (`!`) anywhere except `@IBOutlet` (not used here)
- No magic numbers — use enums or constants
- No swallowed errors with `try?` on critical paths
- All debug logs inside `#if DEBUG`
- Every model must have a `.mock` static property for previews
- Maximum 200 lines per file — break into subviews or extensions if longer
