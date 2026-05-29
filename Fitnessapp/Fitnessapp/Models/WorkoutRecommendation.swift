import Foundation

struct WorkoutRecommendation: Identifiable, Codable, Equatable {
    let id: String
    var userId: String
    var source: RecommendationSource
    var summary: String
    var dailyCalorieTarget: Int
    var dailyWorkoutDurationMinutes: Int
    var totalEstimatedCalories: Double
    var items: [WorkoutRecommendationItem]
    var createdAt: Date?
}
