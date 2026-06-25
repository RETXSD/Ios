import Foundation

actor DictionaryService {
    private let dictionaryURL: URL?
    private var cachedEntries: [DictionaryEntry]?

    init(dictionaryURL: URL? = Bundle.main.url(forResource: "dictionary", withExtension: "json")) {
        self.dictionaryURL = dictionaryURL
    }

    func loadEntries() async -> [DictionaryEntry] {
        if let cachedEntries {
            return cachedEntries
        }

        guard let url = dictionaryURL else {
            cachedEntries = Self.fallbackEntries
            return Self.fallbackEntries
        }

        do {
            let data = try Data(contentsOf: url)
            let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
            cachedEntries = entries
            return entries
        } catch {
            #if DEBUG
            print("Dictionary load failed: \(error.localizedDescription)")
            #endif
            cachedEntries = Self.fallbackEntries
            return Self.fallbackEntries
        }
    }

    func search(_ query: String, jlpt: String? = nil) async -> [DictionaryEntry] {
        let entries = await loadEntries()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return entries.filter { entry in
            let matchesLevel = jlpt == nil || entry.jlpt == jlpt
            guard !trimmed.isEmpty else { return matchesLevel }
            return matchesLevel
                && (entry.character.localizedStandardContains(trimmed)
                    || entry.reading.localizedStandardContains(trimmed)
                    || entry.meaning.localizedStandardContains(trimmed)
                    || entry.examples.contains { example in
                        example.jp.localizedStandardContains(trimmed)
                            || example.reading.localizedStandardContains(trimmed)
                            || example.en.localizedStandardContains(trimmed)
                    })
        }
    }

    private static let fallbackEntries = [
        DictionaryEntry(
            id: "fallback-hiragana-a",
            character: "あ",
            reading: "a",
            meaning: "hiragana a",
            jlpt: "N5",
            examples: [DictionaryExample(jp: "あ", reading: "a", en: "hiragana character")]
        ),
        DictionaryEntry(
            id: "fallback-katakana-a",
            character: "ア",
            reading: "a",
            meaning: "katakana a",
            jlpt: "N5",
            examples: [DictionaryExample(jp: "ア", reading: "a", en: "katakana character")]
        ),
        DictionaryEntry(
            id: "fallback-water",
            character: "水",
            reading: "mizu / sui",
            meaning: "water",
            jlpt: "N5",
            examples: [DictionaryExample(jp: "水を飲む", reading: "mizu o nomu", en: "drink water")]
        ),
        DictionaryEntry(
            id: "fallback-hand",
            character: "手",
            reading: "te",
            meaning: "hand",
            jlpt: "N4",
            examples: [DictionaryExample(jp: "手紙", reading: "tegami", en: "letter")]
        )
    ]
}
