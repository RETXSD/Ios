import Foundation

struct AIMessage: Identifiable, Codable, Equatable {
    let id: String
    var userId: String
    var role: AIMessageRole
    var content: String
    var createdAt: Date?
}
