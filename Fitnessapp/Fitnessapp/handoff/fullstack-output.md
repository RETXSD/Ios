# Fullstack Handoff

## Models Created
- `UserProfile`
  - `id: UUID`
  - `dailyCalorieGoal: Double`
  - `createdAt: Date`
  - `updatedAt: Date`
- `Workout`
  - `id: UUID`
  - `title: String`
  - `category: WorkoutCategory`
  - `difficulty: WorkoutDifficulty`
  - `durationMinutes: Int`
  - `estimatedActiveCalories: Double`
  - `recommendationReason: String`
  - `exercises: [Exercise]`
- `Exercise`
  - `id: UUID`
  - `name: String`
  - `targetMuscles: [String]`
  - `sets: Int?`
  - `reps: Int?`
  - `durationSeconds: Int?`
- `CalorieLog`
  - `id: UUID`
  - `date: Date`
  - `activeEnergyBurned: Double`
  - `dailyGoal: Double`
  - `source: CalorieDataSource`
- `FormFeedback`
  - `id: UUID`
  - `exerciseName: String`
  - `score: Double`
  - `confidence: Double`
  - `repCount: Int`
  - `message: String`
  - `detectedIssues: [String]`
  - `createdAt: Date`
- `CompletedWorkout`
  - `id: UUID`
  - `workout: Workout`
  - `startedAt: Date`
  - `endedAt: Date`
  - `activeCalories: Double`
- `CalorieProgress`
  - `goal: Double`
  - `activeEnergyBurned: Double`
  - `remaining: Double`
  - `progressRatio: Double`
  - `isGoalReached: Bool`
- `AppReadinessItem`
  - `id: UUID`
  - `title: String`
  - `status: AppReadinessItemStatus`
  - `detail: String`
- `FitnessDashboardSummary`
  - `progress: CalorieProgress`
  - `healthKitStatus: PermissionStatus`
  - `cameraStatus: PermissionStatus`
  - `todayRecommendation: Workout?`
  - `readinessItems: [AppReadinessItem]`
- Supporting enums:
  - `WorkoutCategory`
  - `WorkoutDifficulty`
  - `CalorieDataSource`
  - `PermissionStatus`
  - `ExerciseFormIssue`
  - `AppReadinessItemStatus`

Plain Swift models were created instead of SwiftData models because the target is iOS 16.4/Xcode 14-era and SwiftData would require iOS 17+ plus project migration.

## Services Available
- `HealthKitManager`
  - Owns a single shared `HKHealthStore` through `HealthKitManager.shared`.
  - Requests minimum HealthKit permissions for active energy read access and workout write access.
  - Reads active energy burned in kilocalories.
  - Saves completed workouts to Apple Health.
- `CalorieGoalService`
  - Stores the daily calorie goal in `UserDefaults`.
  - Provides a default goal of `500`.
  - Calculates clamped calorie progress for UI rings.
- `WorkoutRecommendationService`
  - Returns recommendations based on calorie progress.
  - Handles low, medium, near-goal, and goal-reached progress states.
- `CameraSessionManager`
  - Owns an `AVCaptureSession`.
  - Requests and reports camera permission.
  - Configures front camera input and video output.
  - Starts/stops capture off the main path through an actor.
- `ExerciseFormAnalyzer`
  - Accepts `CMSampleBuffer`.
  - Runs `VNDetectHumanBodyPoseRequest` on an actor-backed background path.
  - Returns `FormFeedback`.
  - Includes placeholder rule-based analysis until a real Core ML classifier is added.
- `AppReadinessService`
  - Returns checklist items for HealthKit permission, camera permission, local-only processing, usage descriptions, and HealthKit capability.
- `FitnessDashboardManager`
  - Aggregates the landing page data from `HealthKitManager`, `CalorieGoalService`, `WorkoutRecommendationService`, `CameraSessionManager`, and `AppReadinessService`.
  - Returns one `FitnessDashboardSummary` for `ContentView`.

## Public APIs for UI Layer
```swift
final class HealthKitManager {
    static let shared: HealthKitManager

    func requestAuthorization() async throws
    func authorizationStatus() -> PermissionStatus
    func activeEnergyBurnedToday() async throws -> Double
    func activeEnergyBurned(from startDate: Date, to endDate: Date) async throws -> Double
    func saveWorkout(_ workout: CompletedWorkout) async throws
}
```

```swift
final class CalorieGoalService {
    func currentGoal() async throws -> Double
    func updateGoal(_ calories: Double) async throws
    func dailyProgress(activeEnergy: Double, goal: Double) -> CalorieProgress
}
```

```swift
final class WorkoutRecommendationService {
    func recommendations(for progress: CalorieProgress) async -> [Workout]
    func todayRecommendation(for progress: CalorieProgress) async -> Workout?
}
```

```swift
final class CameraSessionManager {
    let session: AVCaptureSession

    func requestCameraAccess() async -> PermissionStatus
    func cameraPermissionStatus() -> PermissionStatus
    func startSession() async throws
    func stopSession()
}
```

```swift
final class ExerciseFormAnalyzer {
    func analyzeFrame(_ sampleBuffer: CMSampleBuffer, exercise: String) async throws -> FormFeedback
}
```

```swift
final class AppReadinessService {
    func readinessItems() async -> [AppReadinessItem]
}
```

```swift
final class FitnessDashboardManager {
    func loadSummary() async -> FitnessDashboardSummary
}
```

## HealthKit Data Available
- Active energy burned:
  - Source: `HKQuantityTypeIdentifier.activeEnergyBurned`
  - Unit: `HKUnit.kilocalorie()`
  - Public methods:
    - `activeEnergyBurnedToday() async throws -> Double`
    - `activeEnergyBurned(from:to:) async throws -> Double`
- Workouts saved:
  - Source object: `CompletedWorkout`
  - Saved as `HKWorkout`
  - Energy unit: kilocalories
  - Activity type mapping:
    - `strength` -> `.traditionalStrengthTraining`
    - `cardio` and `mixed` -> `.mixedCardio`
    - `mobility` -> `.flexibility`
    - `recovery` -> `.mindAndBody`

## Notes for UI/UX Agent
- New implementation files are in:
  - `Fitnessapp/Fitnessapp/Models/`
  - `Fitnessapp/Fitnessapp/Services/`
  - `Fitnessapp/Fitnessapp/Managers/`
- `ContentView.swift` now uses `FitnessDashboardManager` as the landing-page data source.
- The Xcode project was updated so these files compile in the `Fitnessapp` target.
- The build was verified with:
  - `xcodebuild -project Fitnessapp/Fitnessapp.xcodeproj -scheme Fitnessapp -sdk iphonesimulator -derivedDataPath /private/tmp/FitnessappDerivedData build -quiet`
- Do not call HealthKit, camera, Vision, or Core ML APIs directly from SwiftUI views. Route calls through the managers/services above.
- `CameraSessionManager.session` is exposed so a future camera preview view can attach it through a UI-only preview wrapper.
- HealthKit read authorization status cannot be directly inspected for active energy. `authorizationStatus()` reflects workout write authorization and HealthKit availability; denied read access may appear as empty HealthKit results.
- Required generated Info.plist keys still need to be configured before device/App Store work:
  - `NSHealthShareUsageDescription`
  - `NSHealthUpdateUsageDescription`
  - `NSCameraUsageDescription`
- Required capabilities/entitlements still need to be configured before real HealthKit device testing:
  - HealthKit capability
- No custom Core ML model is present yet. `ExerciseFormAnalyzer` uses Vision body pose detection plus simple rule-based feedback and is structured so a classifier can be added later.
