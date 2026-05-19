import Foundation

final class FitnessDashboardManager {
    private let healthKitManager: HealthKitManager
    private let calorieGoalService: CalorieGoalService
    private let workoutRecommendationService: WorkoutRecommendationService
    private let cameraSessionManager: CameraSessionManager
    private let appReadinessService: AppReadinessService

    init(
        healthKitManager: HealthKitManager = .shared,
        calorieGoalService: CalorieGoalService = CalorieGoalService(),
        workoutRecommendationService: WorkoutRecommendationService = WorkoutRecommendationService(),
        cameraSessionManager: CameraSessionManager = CameraSessionManager()
    ) {
        self.healthKitManager = healthKitManager
        self.calorieGoalService = calorieGoalService
        self.workoutRecommendationService = workoutRecommendationService
        self.cameraSessionManager = cameraSessionManager
        self.appReadinessService = AppReadinessService(
            healthKitManager: healthKitManager,
            cameraSessionManager: cameraSessionManager
        )
    }

    func loadSummary() async -> FitnessDashboardSummary {
        let goal = (try? await calorieGoalService.currentGoal()) ?? 500
        let activeEnergy = (try? await healthKitManager.activeEnergyBurnedToday()) ?? 0
        let progress = calorieGoalService.dailyProgress(activeEnergy: activeEnergy, goal: goal)
        let recommendation = await workoutRecommendationService.todayRecommendation(for: progress)
        let readinessItems = await appReadinessService.readinessItems()

        return FitnessDashboardSummary(
            progress: progress,
            healthKitStatus: healthKitManager.authorizationStatus(),
            cameraStatus: cameraSessionManager.cameraPermissionStatus(),
            todayRecommendation: recommendation,
            readinessItems: readinessItems
        )
    }
}
