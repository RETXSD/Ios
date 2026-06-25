import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case indonesia
    case chineseSimplified
    case english

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .indonesia:
            return "Indonesia"
        case .chineseSimplified:
            return "中文（简体）"
        case .english:
            return "English"
        }
    }

    var aiInstruction: String {
        switch self {
        case .indonesia:
            return "Reply in Indonesian. Keep explanations concise and beginner-friendly."
        case .chineseSimplified:
            return "请用简体中文回答。解释要简短，适合初学者。"
        case .english:
            return "Reply in English. Keep explanations concise and beginner-friendly."
        }
    }
}
