import Foundation

struct CalorieLog: Identifiable, Equatable {
    let id: UUID
    let date: Date
    let activeEnergyBurned: Double
    let dailyGoal: Double
    let source: CalorieDataSource

    init(
        id: UUID = UUID(),
        date: Date,
        activeEnergyBurned: Double,
        dailyGoal: Double,
        source: CalorieDataSource
    ) {
        self.id = id
        self.date = date
        self.activeEnergyBurned = activeEnergyBurned
        self.dailyGoal = dailyGoal
        self.source = source
    }
}
