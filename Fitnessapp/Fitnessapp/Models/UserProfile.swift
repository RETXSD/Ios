import Foundation

struct UserProfile: Identifiable, Equatable {
    let id: UUID
    var dailyCalorieGoal: Double
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        dailyCalorieGoal: Double,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.dailyCalorieGoal = dailyCalorieGoal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
