import SwiftUI

struct GoalSummaryCard: View {
    let progress: CalorieProgress
    let profile: UserFitnessProfile?

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Daily Goal", systemImage: "target")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.primary)

                LabeledContent("Calorie Target", value: "\(profile?.dailyCalorieTarget ?? Int(progress.goal)) kcal")
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                if let profile {
                    LabeledContent("Workout Time", value: "\(profile.dailyWorkoutDurationMinutes) min")
                        .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                    LabeledContent("Weight", value: "\(profile.weightKg.formatted(.number.precision(.fractionLength(1)))) kg")
                        .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                    LabeledContent("Age", value: "\(profile.age)")
                        .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                    LabeledContent("Level", value: profile.fitnessLevel.rawValue.capitalized)
                        .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)
                }

                Divider()
                    .overlay(FitnessTheme.border)

                LabeledContent("Burned Today", value: "\(Int(progress.activeEnergyBurned)) kcal")
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)

                let target = Double(profile?.dailyCalorieTarget ?? Int(progress.goal))
                let remaining = max(target - progress.activeEnergyBurned, 0)
                LabeledContent("Remaining", value: "\(Int(remaining)) kcal")
                    .foregroundStyle(FitnessTheme.text, FitnessTheme.textMuted)
            }
        }
    }
}
