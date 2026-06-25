import CoreImage
import CoreML
import UIKit

actor MLInferenceService {
    private let model: MLModel
    private let context = CIContext(options: [.useSoftwareRenderer: false])
    private let inputSize = CGSize(width: 64, height: 64)

    init(modelURL: URL? = Bundle.main.url(forResource: "JapaneseCharClassifier", withExtension: "mlmodelc")
        ?? Bundle.main.url(forResource: "JapaneseCharClassifier", withExtension: "mlmodel")) throws {
        guard let modelURL else {
            throw ScanError.modelNotFound
        }

        do {
            let compiledURL: URL
            if modelURL.pathExtension == "mlmodel" {
                compiledURL = try MLModel.compileModel(at: modelURL)
            } else {
                compiledURL = modelURL
            }

            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all
            self.model = try MLModel(contentsOf: compiledURL, configuration: configuration)
        } catch {
            throw ScanError.modelLoadFailed(error.localizedDescription)
        }
    }

    func classify(image: UIImage) async throws -> ScanResult {
        guard let pixelBuffer = makePixelBuffer(from: image) else {
            throw ScanError.preprocessingFailed
        }

        let inputName = model.modelDescription.inputDescriptionsByName.keys.first ?? "image"

        do {
            let input = try MLDictionaryFeatureProvider(dictionary: [
                inputName: MLFeatureValue(pixelBuffer: pixelBuffer)
            ])
            let output = try model.prediction(from: input)
            let label = output.featureValue(for: "classLabel")?.stringValue
                ?? output.featureValue(for: "target")?.stringValue
                ?? ""
            let probabilities = output.featureValue(for: "classLabelProbs")?.dictionaryValue
                ?? output.featureValue(for: "targetProbability")?.dictionaryValue
                ?? [:]
            let confidence = probabilities[label as NSString]?.doubleValue ?? 0

            guard !label.isEmpty else {
                throw ScanError.inferenceFailed("Output classLabel kosong.")
            }

            return ScanResult(mode: .character, detectedText: label, confidence: confidence)
        } catch let error as ScanError {
            throw error
        } catch {
            throw ScanError.inferenceFailed(error.localizedDescription)
        }
    }

    private func makePixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage else { return nil }

        let source = CIImage(cgImage: cgImage)
        let sourceExtent = source.extent
        let scale = max(inputSize.width / sourceExtent.width, inputSize.height / sourceExtent.height)
        let scaled = source.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let cropX = (scaled.extent.width - inputSize.width) / 2
        let cropY = (scaled.extent.height - inputSize.height) / 2
        let cropped = scaled.cropped(to: CGRect(x: cropX, y: cropY, width: inputSize.width, height: inputSize.height))
        let grayscale = cropped
            .applyingFilter("CIColorControls", parameters: [
                kCIInputSaturationKey: 0,
                kCIInputContrastKey: 1.15
            ])
            .transformed(by: CGAffineTransform(translationX: -cropped.extent.origin.x, y: -cropped.extent.origin.y))

        var pixelBuffer: CVPixelBuffer?
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_OneComponent8
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(inputSize.width),
            Int(inputSize.height),
            kCVPixelFormatType_OneComponent8,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else { return nil }

        context.render(
            grayscale,
            to: pixelBuffer,
            bounds: CGRect(origin: .zero, size: inputSize),
            colorSpace: CGColorSpaceCreateDeviceGray()
        )

        return pixelBuffer
    }
}
