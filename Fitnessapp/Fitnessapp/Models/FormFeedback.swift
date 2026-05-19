import Foundation

struct FormFeedback: Identifiable, Equatable {
    let id: UUID
    let exerciseName: String
    let score: Double
    let confidence: Double
    let repCount: Int
    let message: String
    let detectedIssues: [String]
    let createdAt: Date

    init(
        id: UUID = UUID(),
        exerciseName: String,
        score: Double,
        confidence: Double,
        repCount: Int,
        message: String,
        detectedIssues: [String] = [],
        createdAt: Date = Date.now
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.score = score
        self.confidence = confidence
        self.repCount = repCount
        self.message = message
        self.detectedIssues = detectedIssues
        self.createdAt = createdAt
    }
}
