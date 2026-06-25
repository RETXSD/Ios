# Vision Framework Reference — Text & Character Detection

Used by: visionml-agent

## Sentence Mode — VNRecognizeTextRequest

Used when user selects "Kalimat" scan mode. Detects and reads full text from image.

```swift
import Vision

class VisionTextService {
    func recognizeText(from image: UIImage) async throws -> [String] {
        guard let cgImage = image.cgImage else { throw VisionError.invalidImage }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let results = request.results as? [VNRecognizedTextObservation] ?? []
                let strings = results.compactMap { $0.topCandidates(1).first?.string }
                continuation.resume(returning: strings)
            }

            request.recognitionLanguages = ["ja-JP"]
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }
}
```

## Character Bounding Box — Single Char Crop

For single character mode, detect text bounding box and crop before passing to CoreML:

```swift
func detectAndCropCharacter(from image: UIImage) async throws -> UIImage {
    guard let cgImage = image.cgImage else { throw VisionError.invalidImage }
    var croppedImage: UIImage = image

    let request = VNDetectTextRectanglesRequest { request, _ in
        guard let observation = (request.results as? [VNTextObservation])?.first else { return }
        let boundingBox = observation.boundingBox
        // Convert Vision coords (origin bottom-left) to UIKit (origin top-left)
        let rect = VNImageRectForNormalizedRect(
            boundingBox,
            cgImage.width,
            cgImage.height
        )
        if let cropped = cgImage.cropping(to: rect) {
            croppedImage = UIImage(cgImage: cropped)
        }
    }

    request.reportCharacterBoxes = true
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    try handler.perform([request])
    return croppedImage
}
```

## Error Types

```swift
enum VisionError: LocalizedError {
    case invalidImage
    case noTextDetected
    case segmentationFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Gambar tidak valid."
        case .noTextDetected: return "Tidak ada huruf terdeteksi. Pastikan tulisan terlihat jelas."
        case .segmentationFailed: return "Gagal memisahkan karakter."
        }
    }
}
```

## Rules

- Always set `recognitionLanguages = ["ja-JP"]` for Japanese text
- Always use `.accurate` recognition level (slower but correct for kanji)
- Vision coordinate system has origin at bottom-left — always convert before cropping
- If no text detected → throw `VisionError.noTextDetected`, never return empty silently
- Run all Vision requests on background thread via `VNImageRequestHandler`
