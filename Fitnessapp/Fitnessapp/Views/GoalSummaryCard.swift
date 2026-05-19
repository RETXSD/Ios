import SwiftUI

struct GoalSummaryCard: View {
    let progress: CalorieProgress

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Daily Goal", systemImage: "target")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.secondary)

                LabeledContent("Goal", value: "\(Int(progress.goal)) kcal")
                    .foregroundStyle(.white, .secondary)

                LabeledContent("Burned Today", value: "\(Int(progress.activeEnergyBurned)) kcal")
                    .foregroundStyle(.white, .secondary)

                LabeledContent("Remaining", value: "\(Int(progress.remaining)) kcal")
                    .foregroundStyle(.white, .secondary)
            }
        }
    }
}
