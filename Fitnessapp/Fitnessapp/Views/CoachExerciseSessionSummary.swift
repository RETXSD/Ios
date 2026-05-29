import Foundation

struct CoachExerciseSessionSummary: Identifiable, Equatable {
    let id: String
    let exerciseName: String
    var repCount: Int
    var durationSeconds: TimeInterval
    var kcalPerMinute: Double

    var estimatedCalories: Double {
        max(durationSeconds / 60, 0) * kcalPerMinute
    }
}
