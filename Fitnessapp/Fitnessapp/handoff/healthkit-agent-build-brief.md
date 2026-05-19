# HealthKit Agent Build Brief

## Purpose
Build the non-UI foundation for the Fitness Coach app. The UI direction is a 4-tab SwiftUI app:

- Home
- Workouts
- Coach
- Profile

The product goals are:

- Daily calorie goal tracking
- Apple Health active energy progress
- Workout recommendations
- Camera-based exercise form feedback using Vision and Core ML
- App Store readiness and privacy-safe local processing

## Agent Scope
Work only inside these folders:

- `Models/`
- `Services/`
- `Managers/`

Do not modify:

- `Views/`
- `Components/`
- SwiftUI navigation
- UI tests or unit tests
- Info.plist
- Entitlements
- App Store metadata

If project settings, capabilities, permissions, or entitlements are needed, document them in `handoff/fullstack-output.md` instead of changing them.

## Current App State
The app is currently close to the default Xcode Core Data template. Prefer creating a clean service/model foundation with small, understandable files over doing a broad project migration.

Use SwiftData models if the project can support them cleanly. If switching away from the current Core Data template would create project-file risk, create plain Swift model types first and document that choice in the handoff.

## UI Product Direction
The UI agent will later build a premium dark fitness interface using:

- Near-black background
- Red-orange primary progress and calls to action
- Orange workout intensity accents
- Gold accents for milestones, streaks, and achievements
- Off-white text with muted gray secondary labels

Do not implement UI colors here. Use clear model fields that allow the UI to present status, progress, milestones, and readiness states.

## Data Needed by Each Tab

### Home Tab
The UI needs:

- Current daily calorie goal
- Today's active energy burned from Apple Health
- Remaining active calories to goal
- Progress ratio for a calorie progress ring
- Whether the goal is reached
- Today's recommended workout
- HealthKit permission status

### Workouts Tab
The UI needs:

- List of recommended workouts
- Workout title
- Category
- Difficulty
- Estimated duration in minutes
- Estimated active calories
- Short recommendation reason
- Optional exercise list

Recommendation behavior:

- Low calorie progress: recommend cardio or mixed workout
- Medium progress: recommend balanced strength/cardio workout
- Near goal: recommend mobility, recovery, or a short finisher
- Goal reached: recommend recovery or optional light workout

### Coach Tab
The UI needs:

- Camera permission status
- Camera session lifecycle methods
- Body-pose analysis result
- Exercise name
- Form score
- Confidence score
- Rep count
- Human-readable feedback message
- Detected form issues

All camera frames must stay on-device. Vision/Core ML work must run off the main thread. If no custom Core ML model exists yet, create a clean placeholder classifier boundary and implement the Vision body-pose pipeline so the model can be added later.

### Profile Tab
The UI needs:

- Daily calorie goal read/update API
- HealthKit authorization status
- Camera authorization status
- Local-only privacy status
- App readiness checklist items for QA/UI display

## Models to Create
Create one Swift file per model.

### UserProfile
- `id: UUID`
- `dailyCalorieGoal: Double`
- `createdAt: Date`
- `updatedAt: Date`

### Workout
- `id: UUID`
- `title: String`
- `category: WorkoutCategory`
- `difficulty: WorkoutDifficulty`
- `durationMinutes: Int`
- `estimatedActiveCalories: Double`
- `recommendationReason: String`
- `exercises: [Exercise]`

### Exercise
- `id: UUID`
- `name: String`
- `targetMuscles: [String]`
- `sets: Int?`
- `reps: Int?`
- `durationSeconds: Int?`

### CalorieLog
- `id: UUID`
- `date: Date`
- `activeEnergyBurned: Double`
- `dailyGoal: Double`
- `source: CalorieDataSource`

### FormFeedback
- `id: UUID`
- `exerciseName: String`
- `score: Double`
- `confidence: Double`
- `repCount: Int`
- `message: String`
- `detectedIssues: [String]`
- `createdAt: Date`

### CompletedWorkout
- `id: UUID`
- `workout: Workout`
- `startedAt: Date`
- `endedAt: Date`
- `activeCalories: Double`

### CalorieProgress
- `goal: Double`
- `activeEnergyBurned: Double`
- `remaining: Double`
- `progressRatio: Double`
- `isGoalReached: Bool`

Clamp `progressRatio` from `0` to `1` for UI progress rings.

### AppReadinessItem
- `id: UUID`
- `title: String`
- `status: AppReadinessItemStatus`
- `detail: String`

## Enums to Create
Use UI-friendly raw values where useful.

- `WorkoutCategory`
  - `strength`
  - `cardio`
  - `mobility`
  - `recovery`
  - `mixed`
- `WorkoutDifficulty`
  - `beginner`
  - `intermediate`
  - `advanced`
- `CalorieDataSource`
  - `healthKit`
  - `manual`
  - `preview`
- `PermissionStatus`
  - `notDetermined`
  - `authorized`
  - `denied`
  - `restricted`
  - `unavailable`
- `ExerciseFormIssue`
  - `kneesCavingIn`
  - `backRounding`
  - `limitedRangeOfMotion`
  - `unstableTempo`
  - `lowConfidence`
  - `unknown`
- `AppReadinessItemStatus`
  - `ready`
  - `needsAttention`
  - `blocked`
  - `notChecked`

## Services and Managers to Create

### HealthKitManager
Responsibilities:

- Own a single shared `HKHealthStore` instance
- Request authorization for active energy read access and workout write access
- Read today's active energy burned
- Read active energy for a date range
- Save completed workouts to Apple Health
- Return authorization state through `PermissionStatus`

Suggested public API:

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

### CalorieGoalService
Responsibilities:

- Store the user's daily calorie goal
- Provide a default first-launch goal
- Update the goal
- Calculate progress values

Suggested public API:

```swift
final class CalorieGoalService {
    func currentGoal() async throws -> Double
    func updateGoal(_ calories: Double) async throws
    func dailyProgress(activeEnergy: Double, goal: Double) -> CalorieProgress
}
```

### WorkoutRecommendationService
Responsibilities:

- Generate workout recommendations based on calorie progress
- Provide fallback recommendations when HealthKit data is unavailable
- Provide one main recommendation for the Home tab

Suggested public API:

```swift
final class WorkoutRecommendationService {
    func recommendations(for progress: CalorieProgress) async -> [Workout]
    func todayRecommendation(for progress: CalorieProgress) async -> Workout?
}
```

### CameraSessionManager
Responsibilities:

- Manage `AVCaptureSession`
- Request camera access
- Report camera permission status
- Start and stop camera capture
- Keep camera setup out of SwiftUI views

Suggested public API:

```swift
final class CameraSessionManager {
    func requestCameraAccess() async -> PermissionStatus
    func cameraPermissionStatus() -> PermissionStatus
    func startSession() async throws
    func stopSession()
}
```

### ExerciseFormAnalyzer
Responsibilities:

- Run Vision body-pose detection on a background queue
- Use a Core ML classifier boundary if a model is available
- Load any ML model once at initialization, not per frame
- Return `FormFeedback`
- Never upload or transmit camera frames

Suggested public API:

```swift
final class ExerciseFormAnalyzer {
    func analyzeFrame(_ sampleBuffer: CMSampleBuffer, exercise: String) async throws -> FormFeedback
}
```

### AppReadinessService
Responsibilities:

- Report local checklist status values for UI and QA
- Include HealthKit permission, camera permission, local-only data status, and placeholder App Store readiness items

Suggested public API:

```swift
final class AppReadinessService {
    func readinessItems() async -> [AppReadinessItem]
}
```

## Privacy and Safety Requirements

- Never upload camera frames.
- Never upload HealthKit data.
- Do not add external networking.
- Keep all camera and health processing on-device.
- Use async/await for asynchronous work.
- Process Vision and Core ML work away from the main actor.
- Gate debug-only logging behind `#if DEBUG`.
- Do not recreate `HKHealthStore` per view or per request.

## Expected Handoff Output
After implementation, write this file:

`handoff/fullstack-output.md`

Use this exact structure:

```md
# Fullstack Handoff

## Models Created
- List every SwiftData or Swift model with its properties and types

## Services Available
- List every service/manager with its public methods and return types

## Public APIs for UI Layer
- List what the UI agent can call, with exact method signatures

## HealthKit Data Available
- List what health data is being fetched and in what format

## Notes for UI/UX Agent
- Any constraints or requirements the UI agent must know
```

## Build Notes

- The UI agent will use `NavigationStack` and a 4-tab structure later.
- Do not call HealthKit, camera, Vision, or Core ML directly from views.
- If capabilities or Info.plist usage strings are missing, document the exact required keys in `fullstack-output.md`.
- If a real Core ML model is not present, make the analyzer easy to replace later.
- Favor small files and clear public APIs over clever abstractions.
