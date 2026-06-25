import Combine
import Foundation

@MainActor
final class LanguageSettings: ObservableObject {
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: storageKey)
        }
    }

    private let storageKey = "kanalearn.appLanguage"

    init() {
        let storedValue = UserDefaults.standard.string(forKey: storageKey)
        self.language = storedValue.flatMap(AppLanguage.init(rawValue:)) ?? .indonesia
    }
}
