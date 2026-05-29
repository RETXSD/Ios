import Foundation

final class RecommendationService {
    func generateRecommendation(
        profile: UserFitnessProfile,
        exercises: [ExerciseCatalogItem]
    ) async throws -> WorkoutRecommendation {
        guard profile.dailyWorkoutDurationMinutes > 0 else {
            return WorkoutRecommendation(
                id: UUID().uuidString,
                userId: profile.userId,
                source: .ruleBased,
                summary: "Add available workout time to generate today's plan.",
                dailyCalorieTarget: profile.dailyCalorieTarget,
                dailyWorkoutDurationMinutes: profile.dailyWorkoutDurationMinutes,
                totalEstimatedCalories: 0,
                items: [],
                createdAt: Date.now
            )
        }

        let availableExercises = filteredExercises(for: profile.fitnessLevel, exercises: exercises)
        let selected = chooseBalancedExercises(from: availableExercises, profile: profile)
        let durations = allocateDurations(totalMinutes: profile.dailyWorkoutDurationMinutes, itemCount: selected.count)
        let items = zip(selected, durations).map { exercise, duration in
            WorkoutRecommendationItem(
                exerciseId: exercise.id,
                name: exercise.name,
                durationMinutes: duration,
                estimatedCalories: Double(duration) * exercise.kcalPerMinute,
                intensity: exercise.intensity,
                instructions: exercise.instructions
            )
        }
        let totalCalories = items.reduce(0) { $0 + $1.estimatedCalories }

        return WorkoutRecommendation(
            id: UUID().uuidString,
            userId: profile.userId,
            source: .ruleBased,
            summary: recommendationSummary(profile: profile, totalCalories: totalCalories),
            dailyCalorieTarget: profile.dailyCalorieTarget,
            dailyWorkoutDurationMinutes: profile.dailyWorkoutDurationMinutes,
            totalEstimatedCalories: totalCalories,
            items: items,
            createdAt: Date.now
        )
    }

    func saveRecommendation(_ recommendation: WorkoutRecommendation, userId: String) async throws {
    }

    func latestRecommendation(userId: String) async throws -> WorkoutRecommendation? {
        nil
    }

    private func filteredExercises(
        for level: FitnessLevel,
        exercises: [ExerciseCatalogItem]
    ) -> [ExerciseCatalogItem] {
        exercises
            .filter(\.isActive)
            .filter { exercise in
                switch level {
                case .beginner:
                    return exercise.level == .beginner && exercise.intensity != .high
                case .intermediate:
                    return exercise.level == .beginner || exercise.level == .intermediate
                case .advanced:
                    return true
                }
            }
            .sorted { lhs, rhs in
                lhs.kcalPerMinute == rhs.kcalPerMinute
                    ? lhs.sortOrder < rhs.sortOrder
                    : lhs.kcalPerMinute > rhs.kcalPerMinute
            }
    }

    private func chooseBalancedExercises(
        from exercises: [ExerciseCatalogItem],
        profile: UserFitnessProfile
    ) -> [ExerciseCatalogItem] {
        let maxItems = max(1, min(4, profile.dailyWorkoutDurationMinutes / 8))
        let categoryPriority: [ExerciseCategory] = [.cardio, .strength, .core, .fullBody, .mobility, .recovery]
        var selected: [ExerciseCatalogItem] = []

        for category in categoryPriority where selected.count < maxItems {
            if let exercise = exercises.first(where: { $0.category == category && !selected.contains($0) }) {
                selected.append(exercise)
            }
        }

        for exercise in exercises where selected.count < maxItems && !selected.contains(exercise) {
            selected.append(exercise)
        }

        return selected
    }

    private func allocateDurations(totalMinutes: Int, itemCount: Int) -> [Int] {
        guard itemCount > 0 else {
            return []
        }

        let minutes = max(totalMinutes, itemCount)
        let baseDuration = minutes / itemCount
        let remainder = minutes % itemCount

        return (0..<itemCount).map { index in
            baseDuration + (index < remainder ? 1 : 0)
        }
    }

    private func recommendationSummary(profile: UserFitnessProfile, totalCalories: Double) -> String {
        if totalCalories >= Double(profile.dailyCalorieTarget) * 0.9 {
            return "A focused \(profile.fitnessLevel.rawValue) plan built to get close to today's calorie target."
        }

        return "A realistic \(profile.fitnessLevel.rawValue) plan for the available time. Reaching the full calorie target may need more minutes or higher intensity."
    }
}
