import Foundation

struct UserFitnessProfile: Identifiable, Codable, Equatable {
    var id: String { userId }

    let userId: String
    var username: String
    var email: String
    var dailyCalorieTarget: Int
    var dailyWorkoutDurationMinutes: Int
    var weightKg: Double
    var age: Int
    var fitnessLevel: FitnessLevel
    var onboardingCompleted: Bool
    var createdAt: Date?
    var updatedAt: Date?
}
