# CoreML Reference — Model Loading & Inference

Used by: visionml-agent

## Model File

- Name: `JapaneseCharClassifier.mlmodel`
- Add to Xcode project target — it auto-generates a Swift class
- Input: `CVPixelBuffer` (grayscale, 64x64)
- Output: `JapaneseCharClassifierOutput` with `classLabel: String` and `classLabelProbs: [String: Double]`

## Loading the Model

```swift
import CoreML

class MLInferenceService {
    private let model: JapaneseCharClassifier

    init() throws {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine
        self.model = try JapaneseCharClassifier(configuration: config)
    }
}
```

Always use `.cpuAndNeuralEngine` — lets CoreML pick the fastest on-device compute unit automatically.

## Running Inference

```swift
func classify(image: UIImage) async throws -> ScanResult {
    guard let pixelBuffer = image.toGrayscalePixelBuffer(size: CGSize(width: 64, height: 64)) else {
        throw MLError.preprocessingFailed
    }

    let input = JapaneseCharClassifierInput(image: pixelBuffer)
    let output = try await model.prediction(from: input)

    let label = output.classLabel
    let confidence = Float(output.classLabelProbs[label] ?? 0)

    return ScanResult(character: label, confidence: confidence, isLowConfidence: confidence < 0.5)
}
```

## Error Handling

```swift
enum MLError: LocalizedError {
    case preprocessingFailed
    case modelNotFound
    case inferenceError(String)

    var errorDescription: String? {
        switch self {
        case .preprocessingFailed: return "Gagal memproses gambar. Coba foto ulang."
        case .modelNotFound: return "Model tidak ditemukan."
        case .inferenceError(let msg): return msg
        }
    }
}
```

Never use `try!` or force unwrap on model outputs. Always handle errors explicitly.

## Confidence Threshold

```swift
extension ScanResult {
    var confidenceLevel: ConfidenceLevel {
        switch confidence {
        case 0.8...: return .high    // show green badge
        case 0.5..<0.8: return .mid  // show gold badge
        default: return .low         // show red badge + "coba lagi"
        }
    }
}
```

## Threading

- Never run inference on the main thread
- Wrap in `Task { }` or use `async/await` — CoreML prediction is already async in iOS 16+
- Publish results back to main thread via `@MainActor`

```swift
@MainActor
func handleResult(_ result: ScanResult) {
    self.scanResult = result
}
```

## Rules

- Never use `try!` anywhere in ML code
- Always run on background thread
- Always validate pixelBuffer is not nil before passing to model
- Confidence below 0.5 → return `isLowConfidence: true`, show fallback UI
