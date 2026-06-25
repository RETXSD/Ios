import Foundation

struct Lesson: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let level: String
    let title: String
    let summary: String
    let cards: [FlashCard]

    var isN5: Bool {
        level == "N5"
    }
}
