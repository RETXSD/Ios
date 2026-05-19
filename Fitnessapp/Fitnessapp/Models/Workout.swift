import Foundation

struct Workout: Identifiable, Equatable {
    let id: UUID
    let title: String
    let category: WorkoutCategory
    let difficulty: WorkoutDifficulty
    let durationMinutes: Int
    let estimatedActiveCalories: Double
    let recommendationReason: String
    let exercises: [Exercise]

    init(
        id: UUID = UUID(),
        title: String,
        category: WorkoutCategory,
        difficulty: WorkoutDifficulty,
        durationMinutes: Int,
        estimatedActiveCalories: Double,
        recommendationReason: String,
        exercises: [Exercise] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.difficulty = difficulty
        self.durationMinutes = durationMinutes
        self.estimatedActiveCalories = estimatedActiveCalories
        self.recommendationReason = recommendationReason
        self.exercises = exercises
    }
}
