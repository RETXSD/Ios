import Foundation

struct CompletedWorkout: Identifiable, Equatable {
    let id: UUID
    let workout: Workout
    let startedAt: Date
    let endedAt: Date
    let activeCalories: Double

    init(
        id: UUID = UUID(),
        workout: Workout,
        startedAt: Date,
        endedAt: Date,
        activeCalories: Double
    ) {
        self.id = id
        self.workout = workout
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.activeCalories = activeCalories
    }
}
