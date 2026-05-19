import Foundation

struct FitnessDashboardSummary: Equatable {
    let progress: CalorieProgress
    let healthKitStatus: PermissionStatus
    let cameraStatus: PermissionStatus
    let todayRecommendation: Workout?
    let readinessItems: [AppReadinessItem]

    static let preview = FitnessDashboardSummary(
        progress: CalorieProgress(goal: 500, activeEnergyBurned: 280),
        healthKitStatus: .notDetermined,
        cameraStatus: .notDetermined,
        todayRecommendation: Workout(
            title: "Strength and Cardio Blend",
            category: .mixed,
            difficulty: .intermediate,
            durationMinutes: 30,
            estimatedActiveCalories: 240,
            recommendationReason: "You are making progress, so a balanced workout keeps momentum without overreaching.",
            exercises: []
        ),
        readinessItems: [
            AppReadinessItem(
                title: "HealthKit Permission",
                status: .notChecked,
                detail: "Required to show daily active energy progress."
            ),
            AppReadinessItem(
                title: "Camera Permission",
                status: .notChecked,
                detail: "Required for real-time exercise form feedback."
            )
        ]
    )
}
