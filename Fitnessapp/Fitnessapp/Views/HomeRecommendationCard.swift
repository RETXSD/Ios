import SwiftUI

struct HomeRecommendationCard: View {
    let workout: Workout?

    var body: some View {
        FitnessCard {
            VStack(alignment: .leading, spacing: 12) {
                Label("Today's Workout", systemImage: "bolt.heart.fill")
                    .font(.headline)
                    .foregroundStyle(FitnessTheme.secondary)

                if let workout {
                    Text(workout.title)
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    HStack {
                        MetricPill(workout.category.rawValue)
                        MetricPill(workout.difficulty.rawValue)
                        MetricPill("\(workout.durationMinutes) min")
                    }

                    Text(workout.recommendationReason)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Label("A recommendation will appear after dashboard data loads.", systemImage: "figure.walk")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
