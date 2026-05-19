import SwiftUI

struct WorkoutsView: View {
    let progress: CalorieProgress

    @State private var workouts: [Workout] = []
    private let recommendationService = WorkoutRecommendationService()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    Text("Recommended for your current calorie progress.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    ForEach(workouts) { workout in
                        WorkoutRow(workout: workout)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(FitnessTheme.background)
            .navigationTitle("Workouts")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(FitnessTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .task(id: progress.progressRatio) {
                workouts = await recommendationService.recommendations(for: progress)
            }
        }
    }
}
