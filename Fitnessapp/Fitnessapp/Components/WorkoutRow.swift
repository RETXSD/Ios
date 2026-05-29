import SwiftUI

struct WorkoutRow: View {
    let workout: Workout

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(workout.title)
                            .font(.headline)
                            .foregroundStyle(FitnessTheme.text)

                        Text(workout.recommendationReason)
                            .font(.subheadline)
                            .foregroundStyle(FitnessTheme.textMuted)
                    }

                    Spacer()

                    Text(workout.estimatedActiveCalories, format: .number.precision(.fractionLength(0)))
                        .font(.headline.bold())
                        .foregroundStyle(FitnessTheme.primary)
                        .accessibilityLabel("Estimated calories")
                }

                HStack {
                    MetricPill(workout.category.rawValue)
                    MetricPill(workout.difficulty.rawValue)
                    MetricPill("\(workout.durationMinutes) min", systemImage: "clock")
                }
            }
        }
    }
}
