import Foundation

enum ScanMode: String, CaseIterable, Codable, Identifiable {
    case character = "Huruf"
    case sentence = "Kalimat"

    var id: String { rawValue }
}

struct ScanResult: Identifiable, Codable, Equatable {
    let id: UUID
    let mode: ScanMode
    let detectedText: String
    let confidence: Double
    let meaning: String?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        mode: ScanMode,
        detectedText: String,
        confidence: Double,
        meaning: String? = nil,
        createdAt: Date = Date.now
    ) {
        self.id = id
        self.mode = mode
        self.detectedText = detectedText
        self.confidence = confidence
        self.meaning = meaning
        self.createdAt = createdAt
    }

    var isLowConfidence: Bool {
        confidence < 0.5
    }

    var userMessage: String? {
        isLowConfidence ? "Tulisan kurang jelas, coba lagi" : nil
    }
}

enum ScanError: LocalizedError, Equatable {
    case cameraUnavailable
    case permissionDenied
    case captureFailed
    case modelNotFound
    case modelLoadFailed(String)
    case preprocessingFailed
    case inferenceFailed(String)
    case textRecognitionFailed(String)
    case noTextFound

    var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "Kamera tidak tersedia di perangkat ini."
        case .permissionDenied:
            return "Izin kamera ditolak. Aktifkan izin kamera di Settings."
        case .captureFailed:
            return "Gagal mengambil gambar. Coba lagi."
        case .modelNotFound:
            return "Model hiraganaTrain atau katakanaTrain belum tersedia."
        case .modelLoadFailed(let reason):
            return "Gagal memuat model: \(reason)"
        case .preprocessingFailed:
            return "Gagal menyiapkan gambar untuk pemindaian."
        case .inferenceFailed(let reason):
            return "Gagal mengenali karakter: \(reason)"
        case .textRecognitionFailed(let reason):
            return "Gagal membaca kalimat: \(reason)"
        case .noTextFound:
            return "Tidak ada tulisan yang terdeteksi."
        }
    }
}
