import SwiftUI

struct WorkoutsView: View {
    let progress: CalorieProgress

    @State private var workouts: [Workout] = []
    @State private var exercises: [ExerciseCatalogItem] = ExerciseCatalogService.defaultExercises
    private let recommendationService = WorkoutRecommendationService()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    Text("Exercise catalog")
                        .font(.title3.bold())
                        .foregroundStyle(FitnessTheme.text)
                        .padding(.horizontal)

                    Text("These workouts are used by the recommendation engine while Firebase is paused.")
                        .font(.body)
                        .foregroundStyle(FitnessTheme.textMuted)
                        .padding(.horizontal)

                    ForEach(exercises) { exercise in
                        ExerciseCatalogRow(exercise: exercise)
                            .padding(.horizontal)
                    }

                    Text("Progress-based picks")
                        .font(.title3.bold())
                        .foregroundStyle(FitnessTheme.text)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    ForEach(workouts) { workout in
                        WorkoutRow(workout: workout)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background { FitnessTheme.pageBackground }
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
