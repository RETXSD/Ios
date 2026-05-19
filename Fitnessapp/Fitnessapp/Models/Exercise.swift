import Foundation

struct Exercise: Identifiable, Equatable {
    let id: UUID
    let name: String
    let targetMuscles: [String]
    let sets: Int?
    let reps: Int?
    let durationSeconds: Int?

    init(
        id: UUID = UUID(),
        name: String,
        targetMuscles: [String],
        sets: Int? = nil,
        reps: Int? = nil,
        durationSeconds: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.targetMuscles = targetMuscles
        self.sets = sets
        self.reps = reps
        self.durationSeconds = durationSeconds
    }
}
