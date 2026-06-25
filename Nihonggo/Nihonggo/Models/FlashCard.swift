import Foundation

struct FlashCard: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let character: String
    let reading: String
    let meaning: String
    let exampleJP: String
    let exampleReading: String
    let exampleEN: String
}
