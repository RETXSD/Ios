import Foundation

struct WorkoutRecommendationItem: Codable, Equatable {
    let exerciseId: String
    var name: String
    var durationMinutes: Int
    var estimatedCalories: Double
    var intensity: ExerciseIntensity
    var instructions: String
}
