import CoreML
import UIKit
import Vision

actor MLInferenceService {
    private let hiraganaModel: KanaModel
    private let katakanaModel: KanaModel
    private let ambiguityMargin = 0.12

    init(
        hiraganaModelURL: URL? = Bundle.main.url(forResource: "hiraganaTrain", withExtension: "mlmodelc")
            ?? Bundle.main.url(forResource: "hiraganaTrain", withExtension: "mlmodel"),
        katakanaModelURL: URL? = Bundle.main.url(forResource: "katakanaTrain", withExtension: "mlmodelc")
            ?? Bundle.main.url(forResource: "katakanaTrain", withExtension: "mlmodel")
    ) throws {
        self.hiraganaModel = try Self.loadModel(url: hiraganaModelURL, script: .hiragana)
        self.katakanaModel = try Self.loadModel(url: katakanaModelURL, script: .katakana)
    }

    func classify(image: UIImage) async throws -> ScanResult {
        let hiraganaCandidate = try classify(image: image, using: hiraganaModel)
        let katakanaCandidate = try classify(image: image, using: katakanaModel)
        let candidates = [hiraganaCandidate, katakanaCandidate].sorted { $0.selectionScore > $1.selectionScore }

        guard let best = candidates.first, let runnerUp = candidates.dropFirst().first else {
            throw ScanError.inferenceFailed("Tidak ada hasil model kana.")
        }

        let margin = best.selectionScore - runnerUp.selectionScore
        let isAmbiguous = margin < ambiguityMargin
        let confidence = isAmbiguous ? min(best.confidence, 0.49) : best.confidence
        let scriptNote = isAmbiguous
            ? "Auto Kana kurang yakin: Hiragana \(hiraganaCandidate.debugText), Katakana \(katakanaCandidate.debugText)."
            : "Auto Kana: \(best.script.displayName) \(best.debugText)."

        return ScanResult(
            mode: .character,
            detectedText: best.character,
            confidence: confidence,
            meaning: scriptNote
        )
    }

    private static func loadModel(url: URL?, script: KanaScript) throws -> KanaModel {
        guard let url else {
            throw ScanError.modelNotFound
        }

        do {
            let compiledURL: URL
            if url.pathExtension == "mlmodel" {
                compiledURL = try MLModel.compileModel(at: url)
            } else {
                compiledURL = url
            }

            let configuration = MLModelConfiguration()
            configuration.computeUnits = .all
            let model = try MLModel(contentsOf: compiledURL, configuration: configuration)
            let visionModel = try VNCoreMLModel(for: model)

            return KanaModel(
                script: script,
                model: visionModel
            )
        } catch let error as ScanError {
            throw error
        } catch {
            throw ScanError.modelLoadFailed(error.localizedDescription)
        }
    }

    private func classify(image: UIImage, using kanaModel: KanaModel) throws -> KanaPrediction {
        guard let cgImage = image.cgImage else {
            throw ScanError.preprocessingFailed
        }

        do {
            let request = VNCoreMLRequest(model: kanaModel.model)
            request.imageCropAndScaleOption = .scaleFit

            let handler = VNImageRequestHandler(
                cgImage: cgImage,
                orientation: image.cgImagePropertyOrientation,
                options: [:]
            )
            try handler.perform([request])

            let observations = (request.results as? [VNClassificationObservation]) ?? []
            guard let bestObservation = observations.first else {
                throw ScanError.inferenceFailed("Output classLabel kosong.")
            }

            let rawLabel = bestObservation.identifier
            let confidence = Double(bestObservation.confidence)
            let runnerUpConfidence = observations.dropFirst().first.map { Double($0.confidence) } ?? 0
            let character = kanaModel.script.character(for: rawLabel)

            guard !rawLabel.isEmpty, !character.isEmpty else {
                throw ScanError.inferenceFailed("Output classLabel kosong atau belum dipetakan.")
            }

            return KanaPrediction(
                script: kanaModel.script,
                rawLabel: rawLabel,
                character: character,
                confidence: confidence,
                runnerUpConfidence: runnerUpConfidence
            )
        } catch let error as ScanError {
            throw error
        } catch {
            throw ScanError.inferenceFailed(error.localizedDescription)
        }
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

private struct KanaModel {
    let script: KanaScript
    let model: VNCoreMLModel
}

private struct KanaPrediction {
    let script: KanaScript
    let rawLabel: String
    let character: String
    let confidence: Double
    let runnerUpConfidence: Double

    var confidenceMargin: Double {
        max(confidence - runnerUpConfidence, 0)
    }

    var selectionScore: Double {
        confidence * max(confidenceMargin, 0.01)
    }

    var percentText: String {
        "\(Int((confidence * 100).rounded()))%"
    }

    var debugText: String {
        "\(character)/\(rawLabel) \(percentText), gap \(Int((confidenceMargin * 100).rounded()))%"
    }
}

private enum KanaScript {
    case hiragana
    case katakana

    var displayName: String {
        switch self {
        case .hiragana:
            return "Hiragana"
        case .katakana:
            return "Katakana"
        }
    }

    func character(for rawLabel: String) -> String {
        let normalized = rawLabel.lowercased()
        switch self {
        case .hiragana:
            return hiraganaMap[normalized] ?? ""
        case .katakana:
            return katakanaMap[normalized] ?? ""
        }
    }

    private var hiraganaMap: [String: String] {
        [
            "aa": "あ", "a": "あ",
            "ii": "い", "i": "い",
            "uu": "う", "u": "う",
            "ee": "え", "e": "え",
            "oo": "お", "o": "お",
            "ka": "か", "ki": "き", "ku": "く", "ke": "け", "ko": "こ",
            "sa": "さ", "shi": "し", "si": "し", "su": "す", "se": "せ", "so": "そ",
            "ta": "た", "chi": "ち", "ti": "ち", "tsu": "つ", "tu": "つ", "te": "て", "to": "と",
            "na": "な", "ni": "に", "nu": "ぬ", "ne": "ね", "no": "の",
            "ha": "は", "hi": "ひ", "fu": "ふ", "hu": "ふ", "he": "へ", "ho": "ほ",
            "ma": "ま", "mi": "み", "mu": "む", "me": "め", "mo": "も",
            "ya": "や", "yu": "ゆ", "yo": "よ",
            "ra": "ら", "ri": "り", "ru": "る", "re": "れ", "ro": "ろ",
            "wa": "わ", "wo": "を", "nn": "ん", "n": "ん"
        ]
    }

    private var katakanaMap: [String: String] {
        [
            "aa": "ア", "a": "ア",
            "ii": "イ", "i": "イ", "yi": "イ",
            "uu": "ウ", "u": "ウ", "wu": "ウ",
            "ee": "エ", "e": "エ",
            "oo": "オ", "o": "オ",
            "ka": "カ", "ki": "キ", "ku": "ク", "ke": "ケ", "ko": "コ",
            "ga": "ガ", "gi": "ギ", "gu": "グ", "ge": "ゲ", "go": "ゴ",
            "sa": "サ", "shi": "シ", "si": "シ", "su": "ス", "se": "セ", "so": "ソ",
            "za": "ザ", "zi": "ジ", "ji": "ジ", "zu": "ズ", "ze": "ゼ", "zo": "ゾ",
            "ta": "タ", "chi": "チ", "ti": "チ", "tsu": "ツ", "tu": "ツ", "te": "テ", "to": "ト",
            "da": "ダ", "di": "ヂ", "du": "ヅ", "de": "デ", "do": "ド",
            "na": "ナ", "ni": "ニ", "nu": "ヌ", "ne": "ネ", "no": "ノ",
            "ha": "ハ", "hi": "ヒ", "fu": "フ", "hu": "フ", "he": "ヘ", "ho": "ホ",
            "ba": "バ", "bi": "ビ", "bu": "ブ", "be": "ベ", "bo": "ボ",
            "pa": "パ", "pi": "ピ", "pu": "プ", "pe": "ペ", "po": "ポ",
            "ma": "マ", "mi": "ミ", "mu": "ム", "me": "メ", "mo": "モ",
            "ya": "ヤ", "yu": "ユ", "yo": "ヨ",
            "ra": "ラ", "ri": "リ", "ru": "ル", "re": "レ", "ro": "ロ",
            "wa": "ワ", "wo": "ヲ", "nn": "ン", "n": "ン"
        ]
    }
}
