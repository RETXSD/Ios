import Foundation

enum CalorieGoalError: Error {
    case invalidGoal
}

final class CalorieGoalService {
    private let storage: UserDefaults
    private let goalKey = "fitnessCoach.dailyCalorieGoal"
    private let defaultGoal = 500.0

    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }

    func currentGoal() async throws -> Double {
        let storedGoal = storage.double(forKey: goalKey)
        return storedGoal > 0 ? storedGoal : defaultGoal
    }

    func updateGoal(_ calories: Double) async throws {
        guard calories > 0 else {
            throw CalorieGoalError.invalidGoal
        }

        storage.set(calories, forKey: goalKey)
    }

    func dailyProgress(activeEnergy: Double, goal: Double) -> CalorieProgress {
        CalorieProgress(goal: goal, activeEnergyBurned: activeEnergy)
    }
}
