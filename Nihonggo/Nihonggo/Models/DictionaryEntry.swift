import Foundation

struct DictionaryEntry: Identifiable, Codable, Equatable {
    let id: String
    let character: String
    let reading: String
    let meaning: String
    let jlpt: String
    let examples: [DictionaryExample]
}

struct DictionaryExample: Identifiable, Codable, Equatable {
    let id: UUID
    let jp: String
    let reading: String
    let en: String

    init(id: UUID = UUID(), jp: String, reading: String, en: String) {
        self.id = id
        self.jp = jp
        self.reading = reading
        self.en = en
    }

    enum CodingKeys: String, CodingKey {
        case jp
        case reading
        case en
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.jp = try container.decode(String.self, forKey: .jp)
        self.reading = try container.decode(String.self, forKey: .reading)
        self.en = try container.decode(String.self, forKey: .en)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jp, forKey: .jp)
        try container.encode(reading, forKey: .reading)
        try container.encode(en, forKey: .en)
    }
}
