import Foundation

struct CalorieProgress: Equatable {
    let goal: Double
    let activeEnergyBurned: Double
    let remaining: Double
    let progressRatio: Double
    let isGoalReached: Bool

    init(goal: Double, activeEnergyBurned: Double) {
        let safeGoal = max(goal, 1)
        let safeActiveEnergy = max(activeEnergyBurned, 0)

        self.goal = safeGoal
        self.activeEnergyBurned = safeActiveEnergy
        self.remaining = max(safeGoal - safeActiveEnergy, 0)
        self.progressRatio = min(max(safeActiveEnergy / safeGoal, 0), 1)
        self.isGoalReached = safeActiveEnergy >= safeGoal
    }
}
