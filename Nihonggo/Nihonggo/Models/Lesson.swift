import Foundation

struct Lesson: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let level: String
    let title: String
    let summary: String
    let stages: [LessonStage]
    let cards: [FlashCard]

    var isN5: Bool {
        level == "N5"
    }

    init(id: String, level: String, title: String, summary: String, stages: [LessonStage], cards: [FlashCard]? = nil) {
        self.id = id
        self.level = level
        self.title = title
        self.summary = summary
        self.stages = stages
        self.cards = cards ?? stages.flatMap(\.cards)
    }

    init(id: String, level: String, title: String, summary: String, cards: [FlashCard]) {
        self.id = id
        self.level = level
        self.title = title
        self.summary = summary
        self.cards = cards
        self.stages = [
            LessonStage(
                id: "\(id)-stage-1",
                number: 1,
                title: "Practice",
                summary: summary,
                mode: .mixedPractice,
                cards: cards
            )
        ]
    }

    enum CodingKeys: String, CodingKey {
        case id
        case level
        case title
        case summary
        case stages
        case cards
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        level = try container.decode(String.self, forKey: .level)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        let decodedStages = try container.decodeIfPresent([LessonStage].self, forKey: .stages) ?? []
        let decodedCards = try container.decodeIfPresent([FlashCard].self, forKey: .cards) ?? []
        stages = decodedStages.isEmpty
            ? [LessonStage(id: "\(id)-stage-1", number: 1, title: "Practice", summary: summary, mode: .mixedPractice, cards: decodedCards)]
            : decodedStages
        cards = decodedCards.isEmpty ? stages.flatMap(\.cards) : decodedCards
    }
}

struct LessonStage: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let number: Int
    let title: String
    let summary: String
    let mode: LessonStageMode
    let cards: [FlashCard]

    var isExam: Bool {
        mode == .finalExam
    }
}

enum LessonStageMode: String, Codable, Equatable, Hashable {
    case mixedPractice
    case finalExam
}
