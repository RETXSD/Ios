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
  - `skeleton: PoseSkeleton?`
  - `createdAt: Date`
- `PoseSkeleton`
  - `joints: [PoseJoint]`
- `PoseJoint`
  - `id: PoseJointName`
  - `name: PoseJointName`
  - `point: CGPoint`
  - `confidence: Double`
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
- `AppUser`
  - `id: String`
  - `username: String`
  - `email: String`
- `UserFitnessProfile`
  - `userId: String`
  - `username: String`
  - `email: String`
  - `dailyCalorieTarget: Int`
  - `dailyWorkoutDurationMinutes: Int`
  - `weightKg: Double`
  - `age: Int`
  - `fitnessLevel: FitnessLevel`
  - `onboardingCompleted: Bool`
  - `createdAt: Date?`
  - `updatedAt: Date?`
- `ExerciseCatalogItem`
  - `id: String`
  - `name: String`
  - `category: ExerciseCategory`
  - `intensity: ExerciseIntensity`
  - `kcalPerMinute: Double`
  - `level: FitnessLevel`
  - `equipment: String`
  - `instructions: String`
  - `bodyFocus: [String]`
  - `aiTags: [String]`
  - `isActive: Bool`
  - `sortOrder: Int`
- `WorkoutRecommendation`
  - `id: String`
  - `userId: String`
  - `source: RecommendationSource`
  - `summary: String`
  - `dailyCalorieTarget: Int`
  - `dailyWorkoutDurationMinutes: Int`
  - `totalEstimatedCalories: Double`
  - `items: [WorkoutRecommendationItem]`
  - `createdAt: Date?`
- `WorkoutRecommendationItem`
  - `exerciseId: String`
  - `name: String`
  - `durationMinutes: Int`
  - `estimatedCalories: Double`
  - `intensity: ExerciseIntensity`
  - `instructions: String`
- `AIMessage`
  - `id: String`
  - `userId: String`
  - `role: AIMessageRole`
  - `content: String`
  - `createdAt: Date?`
- Supporting enums:
  - `WorkoutCategory`
  - `WorkoutDifficulty`
  - `CalorieDataSource`
  - `PermissionStatus`
  - `ExerciseFormIssue`
  - `AppReadinessItemStatus`
  - `FitnessLevel`
  - `ExerciseCategory`
  - `ExerciseIntensity`
  - `RecommendationSource`
  - `AIMessageRole`

Plain Swift models are used instead of SwiftData models because this project targets iOS 16.4/Xcode 14.3.1.

## Services Available
- `HealthKitManager`
  - Owns `HealthKitManager.shared`.
  - Requests HealthKit permissions.
  - Reads active energy burned in kilocalories.
  - Saves completed workouts to Apple Health.
- `CalorieGoalService`
  - Stores the local daily calorie goal in `UserDefaults`.
  - Calculates calorie progress for rings/cards.
- `WorkoutRecommendationService`
  - Existing HealthKit-progress-based recommendation service.
- `CameraSessionManager`
  - Owns an `AVCaptureSession`.
  - Requests camera permission and starts/stops capture.
  - Supports front/back camera switching.
  - Emits `CMSampleBuffer` frames through `sampleBufferHandler` for Vision analysis.
  - Keeps sample-buffer output unmirrored; front camera mirroring is handled by `AVCaptureVideoPreviewLayer` so Vision coordinates and displayed preview stay in sync.
- `ExerciseFormAnalyzer`
  - Runs Vision body pose detection from `CMSampleBuffer`.
  - Returns normalized body-pose skeleton joints through `FormFeedback.skeleton` for camera overlay rendering.
  - Counts supported workout reps with Vision joint angles and state machines.
  - Supports push-ups, squats, lunges, burpees, sit-ups, jumping jacks, mountain climbers, and plank feedback.
  - Uses the same broad approach described by Good-GYM: pose keypoints, joint-angle thresholds, and movement phases.
- `FormAudioFeedbackManager`
  - Uses `AVSpeechSynthesizer` to speak short correction cues when `FormFeedback` indicates low confidence, low score, or detected form issues.
  - Speaks English coaching cues such as knee alignment, deeper squat/push-up range, straight body line, hip alignment, and full-camera-frame guidance.
  - Configures `AVAudioSession` with `.playback` and `.spokenAudio` before speaking so voice cues are audible on physical iPhone even when the silent switch would mute normal app audio.
  - Applies a 4-second repeated-cue cooldown and stops speaking when reset.
- `AppReadinessService`
  - Returns checklist items for permissions, privacy, and app setup.
- `FitnessDashboardManager`
  - Aggregates HealthKit, recommendation, camera, and readiness data.
- `AuthService`
  - Local-only email/password register placeholder.
  - Local-only email/password login placeholder.
  - Google login is disabled while Firebase is paused.
  - Logout/current user.
- `UserProfileService`
  - Stores user profile data in memory while Firebase is paused.
  - Marks onboarding complete.
- `ExerciseCatalogService`
  - Returns the 10 default local exercises.
  - Seed method is a no-op while Firebase is paused.
- `RecommendationService`
  - Generates MVP rule-based plans from `UserFitnessProfile` + `ExerciseCatalogItem`.
  - Save/fetch latest recommendation are local no-ops while Firebase is paused.
- `AIAssistantService`
  - Calls a backend/proxy boundary for AI chat and AI workout recommendations.
  - Defaults to `http://127.0.0.1:8787` on simulator and `http://10.24.203.75:8787` on physical iPhone testing.
  - Does not store or send any AI API key from the iOS app.
- `Fitnessapp/ai-proxy`
  - Node.js DeepSeek proxy.
  - Reads `DEEPSEEK_API_KEY` from environment only.
  - Exposes `GET /health`, `POST /chat`, and `POST /recommendation`.
  - Calls `https://api.deepseek.com/chat/completions` with `deepseek-v4-pro`, thinking enabled, and high reasoning effort.

## Public APIs for UI Layer
```swift
final class AuthService {
    func register(username: String, email: String, password: String) async throws -> AppUser
    func login(email: String, password: String) async throws -> AppUser
    func loginWithGoogle() async throws -> AppUser
    func loginWithGoogle(idToken: String, accessToken: String) async throws -> AppUser
    func logout() throws
    func currentUser() -> AppUser?
}
```

```swift
final class UserProfileService {
    func fetchProfile(userId: String) async throws -> UserFitnessProfile?
    func saveProfile(_ profile: UserFitnessProfile) async throws
    func markOnboardingComplete(userId: String) async throws
}
```

```swift
final class ExerciseCatalogService {
    func fetchExercises() async throws -> [ExerciseCatalogItem]
    func seedDefaultExercisesIfNeeded() async throws
}
```

```swift
final class RecommendationService {
    func generateRecommendation(profile: UserFitnessProfile, exercises: [ExerciseCatalogItem]) async throws -> WorkoutRecommendation
    func saveRecommendation(_ recommendation: WorkoutRecommendation, userId: String) async throws
    func latestRecommendation(userId: String) async throws -> WorkoutRecommendation?
}
```

```swift
final class AIAssistantService {
    init(baseURL: URL = AIAssistantService.defaultBaseURL, urlSession: URLSession = .shared)
    func generateAIRecommendation(profile: UserFitnessProfile, exercises: [ExerciseCatalogItem], planPreference: String?) async throws -> WorkoutRecommendation
    func sendMessage(_ message: String, userId: String) async throws -> AIMessage
}
```

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
    var sampleBufferHandler: ((CMSampleBuffer) -> Void)?

    func requestCameraAccess() async -> PermissionStatus
    func cameraPermissionStatus() -> PermissionStatus
    func startSession() async throws
    func stopSession()
    func switchCamera() async throws
}
```

```swift
final class ExerciseFormAnalyzer {
    func analyzeFrame(_ sampleBuffer: CMSampleBuffer, exercise: String, cameraPosition: CameraPosition = .front) async throws -> FormFeedback
}
```

```swift
@MainActor
final class FormAudioFeedbackManager {
    init(cooldownSeconds: TimeInterval = 4, minimumScoreForSilence: Double = 0.78)
    func speakCorrectionIfNeeded(for feedback: FormFeedback)
    func reset()
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
- Firebase connection status:
  - Firebase runtime is paused/disabled.
  - `FitnessappApp.swift` does not import `FirebaseCore` and does not call `FirebaseApp.configure()`.
  - Firebase package products are no longer linked to the `Fitnessapp` target.
  - `GoogleService-Info.plist` is not copied into the app bundle.
- Current local implementation files are in:
  - `Fitnessapp/Fitnessapp/Models/`
  - `Fitnessapp/Fitnessapp/Services/`
- The Xcode project now includes all new model/service Swift files in the `Fitnessapp` target.
- Build verified:
  - `xcodebuild -project Fitnessapp/Fitnessapp.xcodeproj -scheme Fitnessapp -sdk iphonesimulator -derivedDataPath /private/tmp/FitnessappDerivedData build -quiet`
- AI assistant boundary:
  - `AIAssistantView` is now wired to `AIAssistantService` through `AIAssistantViewModel`.
  - Do not put the DeepSeek API key in Swift, plist files, Firebase client config, or any app bundle resource.
  - Use `Fitnessapp/ai-proxy` with `DEEPSEEK_API_KEY` in `.env` or backend environment only.
  - For physical iPhone testing, the default LAN proxy URL is currently `http://10.24.203.75:8787`; update it if the Mac's Wi-Fi IP changes.
  - Generated Info.plist build settings allow local HTTP testing with `NSLocalNetworkUsageDescription` and `NSAppTransportSecurity.NSAllowsArbitraryLoads`.
  - Local proxy health and a short `/chat` request were verified successfully.
  - `/recommendation` now has a 120-second endpoint timeout and returns a rule-based fallback plan if DeepSeek is too slow.
  - `AIAssistantService` uses a 180-second URLSession timeout so the UI can survive slower local proxy responses.
  - AI proxy supports separate model routing: `DEEPSEEK_CHAT_MODEL` for chat and `DEEPSEEK_RECOMMENDATION_MODEL` for generated workout plans. Current `.env` maps chat `flash` to `deepseek-chat` and recommendation `pro` to `deepseek-v4-pro`.
  - AI workout plan requests now accept optional user preference text, e.g. no running or low impact.
  - Plan preference is applied before calling DeepSeek and before generating fallback plans, so excluded exercises such as running/lari are removed even when the AI request times out.
  - Chat now has a server-side fitness-topic guardrail. Off-topic messages are rejected before calling DeepSeek, while fitness/gym/workout/calorie/recovery/nutrition-adjacent questions are allowed.
- Exercise catalog seed status:
  - `ExerciseCatalogService.defaultExercises` contains Running, Walking, Squats, Push-ups, Jumping Jacks, Plank, Lunges, Burpees, Mountain Climbers, and Sit-ups.
  - `seedDefaultExercisesIfNeeded()` is currently a no-op.
- Recommendation logic:
  - Beginner gets beginner non-high-intensity exercises.
  - Intermediate gets beginner + intermediate exercises.
  - Advanced can use all active exercises.
  - Duration is split across up to 4 balanced categories.
  - Calories use `durationMinutes * kcalPerMinute`.
- Future Firebase restore:
  - Re-link Firebase package products.
  - Add `FirebaseApp.configure()` back to app startup.
  - Re-add `GoogleService-Info.plist` to bundle resources.
  - Replace local service stubs with Firebase implementations.
