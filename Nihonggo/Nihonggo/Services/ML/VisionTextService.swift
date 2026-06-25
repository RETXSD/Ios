import UIKit
import Vision

actor VisionTextService {
    func recognizeSentence(in image: UIImage) async throws -> ScanResult {
        guard let cgImage = image.cgImage else {
            throw ScanError.preprocessingFailed
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ja-JP"]
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.02

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImagePropertyOrientation)

        do {
            try handler.perform([request])
            let candidates = request.results?.compactMap { observation -> VNRecognizedText? in
                observation.topCandidates(1).first
            } ?? []
            let text = candidates.map(\.string).joined(separator: "")
            let confidence = candidates.map { Double($0.confidence) }.average

            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ScanError.noTextFound
            }

            return ScanResult(
                mode: .sentence,
                detectedText: text,
                confidence: confidence,
                meaning: "Terjemahan tersedia melalui kamus atau AI tutor."
            )
        } catch let error as ScanError {
            throw error
        } catch {
            throw ScanError.textRecognitionFailed(error.localizedDescription)
        }
    }
}

private extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}

private extension UIImage {
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up:
            return CGImagePropertyOrientation.up
        case .upMirrored:
            return CGImagePropertyOrientation.upMirrored
        case .down:
            return CGImagePropertyOrientation.down
        case .downMirrored:
            return CGImagePropertyOrientation.downMirrored
        case .left:
            return CGImagePropertyOrientation.left
        case .leftMirrored:
            return CGImagePropertyOrientation.leftMirrored
        case .right:
            return CGImagePropertyOrientation.right
        case .rightMirrored:
            return CGImagePropertyOrientation.rightMirrored
        @unknown default:
            return CGImagePropertyOrientation.up
        }
    }
}
