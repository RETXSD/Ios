import Foundation

final class WorkoutRecommendationService {
    func recommendations(for progress: CalorieProgress) async -> [Workout] {
        if progress.isGoalReached {
            return recoveryRecommendations(progress: progress)
        }

        switch progress.progressRatio {
        case 0..<0.35:
            return highEnergyRecommendations(progress: progress)
        case 0.35..<0.75:
            return balancedRecommendations(progress: progress)
        default:
            return nearGoalRecommendations(progress: progress)
        }
    }

    func todayRecommendation(for progress: CalorieProgress) async -> Workout? {
        await recommendations(for: progress).first
    }

    private func highEnergyRecommendations(progress: CalorieProgress) -> [Workout] {
        [
            Workout(
                title: "Cardio Burn Builder",
                category: .cardio,
                difficulty: .intermediate,
                durationMinutes: 35,
                estimatedActiveCalories: min(max(progress.remaining, 280), 450),
                recommendationReason: "Your calorie progress is low today, so this session focuses on steady active energy.",
                exercises: [
                    Exercise(name: "Warm-up Walk", targetMuscles: ["Legs"], durationSeconds: 300),
                    Exercise(name: "Interval Run", targetMuscles: ["Legs", "Core"], durationSeconds: 1200),
                    Exercise(name: "Bike Sprint Finisher", targetMuscles: ["Legs"], durationSeconds: 360)
                ]
            ),
            Workout(
                title: "Full-Body Sweat Circuit",
                category: .mixed,
                difficulty: .beginner,
                durationMinutes: 28,
                estimatedActiveCalories: min(max(progress.remaining * 0.8, 220), 380),
                recommendationReason: "A mixed circuit helps raise active calories without requiring long cardio blocks.",
                exercises: [
                    Exercise(name: "Bodyweight Squat", targetMuscles: ["Quads", "Glutes"], sets: 3, reps: 12),
                    Exercise(name: "Push-up", targetMuscles: ["Chest", "Triceps"], sets: 3, reps: 10),
                    Exercise(name: "Mountain Climber", targetMuscles: ["Core"], durationSeconds: 180)
                ]
            )
        ]
    }

    private func balancedRecommendations(progress: CalorieProgress) -> [Workout] {
        [
            Workout(
                title: "Strength and Cardio Blend",
                category: .mixed,
                difficulty: .intermediate,
                durationMinutes: 30,
                estimatedActiveCalories: min(max(progress.remaining, 180), 320),
                recommendationReason: "You are making progress, so a balanced workout keeps momentum without overreaching.",
                exercises: [
                    Exercise(name: "Reverse Lunge", targetMuscles: ["Glutes", "Hamstrings"], sets: 3, reps: 10),
                    Exercise(name: "Dumbbell Row", targetMuscles: ["Back", "Biceps"], sets: 3, reps: 12),
                    Exercise(name: "Jump Rope", targetMuscles: ["Calves", "Core"], durationSeconds: 300)
                ]
            ),
            Workout(
                title: "Upper Body Push",
                category: .strength,
                difficulty: .beginner,
                durationMinutes: 25,
                estimatedActiveCalories: min(max(progress.remaining * 0.7, 140), 260),
                recommendationReason: "A focused strength session adds useful work while preserving energy for tomorrow.",
                exercises: [
                    Exercise(name: "Incline Push-up", targetMuscles: ["Chest", "Triceps"], sets: 3, reps: 12),
                    Exercise(name: "Shoulder Press", targetMuscles: ["Shoulders"], sets: 3, reps: 10),
                    Exercise(name: "Plank", targetMuscles: ["Core"], durationSeconds: 180)
                ]
            )
        ]
    }

    private func nearGoalRecommendations(progress: CalorieProgress) -> [Workout] {
        [
            Workout(
                title: "Goal-Line Mobility",
                category: .mobility,
                difficulty: .beginner,
                durationMinutes: 18,
                estimatedActiveCalories: min(max(progress.remaining, 80), 160),
                recommendationReason: "You are close to your target, so this keeps you moving without unnecessary strain.",
                exercises: [
                    Exercise(name: "Hip Opener Flow", targetMuscles: ["Hips"], durationSeconds: 360),
                    Exercise(name: "Thoracic Rotation", targetMuscles: ["Back"], durationSeconds: 240),
                    Exercise(name: "Hamstring Stretch", targetMuscles: ["Hamstrings"], durationSeconds: 240)
                ]
            ),
            Workout(
                title: "Short Finisher",
                category: .cardio,
                difficulty: .beginner,
                durationMinutes: 12,
                estimatedActiveCalories: min(max(progress.remaining, 90), 180),
                recommendationReason: "A compact finisher can close the remaining gap efficiently.",
                exercises: [
                    Exercise(name: "Fast Walk", targetMuscles: ["Legs"], durationSeconds: 480),
                    Exercise(name: "Step-up", targetMuscles: ["Quads", "Glutes"], sets: 2, reps: 12)
                ]
            )
        ]
    }

    private func recoveryRecommendations(progress: CalorieProgress) -> [Workout] {
        [
            Workout(
                title: "Recovery Reset",
                category: .recovery,
                difficulty: .beginner,
                durationMinutes: 15,
                estimatedActiveCalories: 70,
                recommendationReason: "You reached your calorie goal, so recovery helps protect tomorrow's performance.",
                exercises: [
                    Exercise(name: "Breathing Reset", targetMuscles: ["Core"], durationSeconds: 180),
                    Exercise(name: "Easy Mobility Flow", targetMuscles: ["Full body"], durationSeconds: 540)
                ]
            ),
            Workout(
                title: "Optional Light Walk",
                category: .recovery,
                difficulty: .beginner,
                durationMinutes: 20,
                estimatedActiveCalories: 90,
                recommendationReason: "A relaxed walk keeps the streak alive without turning recovery into another hard session.",
                exercises: [
                    Exercise(name: "Outdoor Walk", targetMuscles: ["Legs"], durationSeconds: 1200)
                ]
            )
        ]
    }
}
