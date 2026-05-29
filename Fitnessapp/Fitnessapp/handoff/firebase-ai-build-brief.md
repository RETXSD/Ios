# Firebase + AI Fitness App Build Brief

## Purpose
Update the Fitness Coach app into a Firebase-first fitness recommendation app.

The user wants:

- Register/login with username, email, password.
- Login with Google.
- Firebase as the main database source.
- User profile setup after auth.
- User inputs:
  - Daily calorie target in kcal.
  - Daily workout duration in minutes.
  - Current body weight.
  - Current age.
  - Optional fitness level.
- Exercise catalog stored in Firebase.
- AI assistant that recommends workouts based on the user profile, calorie target, available time, age, weight, and exercise catalog.

The user already has:

- Firebase CLI/terminal connected.
- `GoogleService-Info.plist` present in `Fitnessapp/Fitnessapp/GoogleService-Info.plist`.
- AI API key prepared.

## Important Direction
Use Firebase directly for the exercise catalog, user profile, auth, and recommendation data. Do not rely on local JSON as the primary source.

Recommended Firebase collections:

- `users`
- `exercises`
- `recommendations`
- `aiChats` or `aiMessages`

Use local fallback/sample data only if needed for previews or offline development.

## Agent Scope
This brief is for the fullstack/service agent, not the UI agent.

Work should be mostly inside:

- `Models/`
- `Services/`
- `Managers/`

Project configuration may be required for Firebase packages, `GoogleService-Info.plist`, URL schemes, Google Sign-In, and generated Info.plist keys. If the active agent is not allowed to modify project settings, document the exact required changes in the handoff.

Do not hardcode the AI API key in the iOS app. Use a backend boundary, preferably Firebase Cloud Functions, so the key stays server-side.

## Current App Context
The current app already has:

- 4-tab UI:
  - Home
  - Workouts
  - Coach
  - Profile
- Existing non-UI models/services/managers for HealthKit and workout recommendation.
- `fullstack-output.md`, `uiux-output.md`, and `qa-report.md` in the `handoff/` folder.

The new Firebase-first flow should become the main app direction. HealthKit can remain as a future/secondary integration, but user profile + exercise catalog + recommendations should come from Firebase.

## User Flow

### 1. Auth
Screens expected by UI:

- Login
- Register
- Google Sign-In
- Logout from Profile

Register input:

- Username
- Email/gmail
- Password

Login input:

- Email/gmail
- Password

Google login:

- Use Firebase Auth with Google provider.

### 2. Onboarding/Profile Setup
After first login/register, user must fill:

- Daily calorie target in kcal
- Daily workout duration in minutes
- Current weight
- Current age
- Fitness level

Fitness level values:

- `beginner`
- `intermediate`
- `advanced`

After onboarding, save profile to Firebase under the authenticated user.

### 3. Workout Recommendations
The app should recommend a workout list based on:

- Daily calorie target
- Available workout duration
- Age
- Weight
- Fitness level
- Exercise catalog

Each recommended item should include:

- Exercise name
- Duration
- Estimated calories
- Intensity
- Instructions

Use simple kcal/min logic for MVP before deeper AI personalization.

### 4. AI Assistant
The AI assistant should:

- Read user profile fields.
- Read exercise catalog.
- Generate or explain workout recommendations.
- Answer simple user questions about the suggested plan.

Important:

- Do not store the AI API key in the app bundle.
- Prefer Firebase Cloud Functions:
  - iOS app calls Cloud Function.
  - Cloud Function calls AI provider.
  - Cloud Function returns structured recommendation JSON.

## Firebase Data Model

### Collection: `users`
Document ID:

- Firebase Auth UID

Suggested fields:

```json
{
  "uid": "auth-user-id",
  "username": "Adrian",
  "email": "user@example.com",
  "dailyCalorieTarget": 500,
  "dailyWorkoutDurationMinutes": 30,
  "weightKg": 70,
  "age": 20,
  "fitnessLevel": "beginner",
  "createdAt": "serverTimestamp",
  "updatedAt": "serverTimestamp"
}
```

### Collection: `exercises`
Document ID:

- Stable lowercase slug, such as `running`, `walking`, `squats`.

Suggested fields:

```json
{
  "id": "running",
  "name": "Running",
  "category": "cardio",
  "intensity": "high",
  "kcalPerMinute": 10,
  "level": "intermediate",
  "equipment": "none",
  "instructions": "Run at a steady pace. Keep your posture tall and breathe consistently.",
  "bodyFocus": ["legs", "cardio"],
  "aiTags": ["fatLoss", "endurance", "outdoor", "highCalorieBurn"],
  "isActive": true,
  "sortOrder": 10
}
```

### Collection: `recommendations`
Document ID:

- Auto ID or date-based ID.

Suggested fields:

```json
{
  "userId": "auth-user-id",
  "createdAt": "serverTimestamp",
  "source": "localRuleBased|ai",
  "dailyCalorieTarget": 500,
  "dailyWorkoutDurationMinutes": 30,
  "totalEstimatedCalories": 280,
  "items": [
    {
      "exerciseId": "jumping-jacks",
      "name": "Jumping Jacks",
      "durationMinutes": 10,
      "estimatedCalories": 80,
      "intensity": "medium",
      "instructions": "Jump while spreading your legs and raising your arms overhead, then return to the starting position."
    }
  ],
  "summary": "A balanced beginner-friendly plan focused on cardio and strength."
}
```

### Collection: `aiMessages`
Optional for AI assistant chat history.

Suggested fields:

```json
{
  "userId": "auth-user-id",
  "role": "user|assistant",
  "content": "Can you adjust this workout?",
  "createdAt": "serverTimestamp"
}
```

## Exercise Catalog Seed
Seed these documents into Firebase `exercises`.

### Running
- `id`: `running`
- `name`: `Running`
- `category`: `cardio`
- `intensity`: `high`
- `kcalPerMinute`: `10`
- `level`: `intermediate`
- `equipment`: `none`
- `instructions`: `Run at a steady pace. Keep your posture tall and breathe consistently.`
- `bodyFocus`: `["legs", "cardio"]`
- `aiTags`: `["fatLoss", "endurance", "outdoor", "highCalorieBurn"]`

### Walking
- `id`: `walking`
- `name`: `Walking`
- `category`: `cardio`
- `intensity`: `low`
- `kcalPerMinute`: `4`
- `level`: `beginner`
- `equipment`: `none`
- `instructions`: `Walk at a comfortable pace. Keep shoulders relaxed.`
- `bodyFocus`: `["legs", "cardio"]`
- `aiTags`: `["beginnerFriendly", "recovery", "lowImpact"]`

### Squats
- `id`: `squats`
- `name`: `Squats`
- `category`: `strength`
- `intensity`: `medium`
- `kcalPerMinute`: `6`
- `level`: `beginner`
- `equipment`: `none`
- `instructions`: `Stand with feet shoulder-width apart, lower your hips, then stand back up.`
- `bodyFocus`: `["legs", "glutes"]`
- `aiTags`: `["beginnerFriendly", "strength", "noEquipment"]`

### Push-ups
- `id`: `push-ups`
- `name`: `Push-ups`
- `category`: `strength`
- `intensity`: `medium`
- `kcalPerMinute`: `7`
- `level`: `beginner`
- `equipment`: `none`
- `instructions`: `Start in a plank position. Lower your chest toward the floor, then push back up while keeping your body straight.`
- `bodyFocus`: `["chest", "arms", "core"]`
- `aiTags`: `["strength", "upperBody", "noEquipment"]`

### Jumping Jacks
- `id`: `jumping-jacks`
- `name`: `Jumping Jacks`
- `category`: `cardio`
- `intensity`: `medium`
- `kcalPerMinute`: `8`
- `level`: `beginner`
- `equipment`: `none`
- `instructions`: `Jump while spreading your legs and raising your arms overhead, then return to the starting position.`
- `bodyFocus`: `["fullBody", "cardio"]`
- `aiTags`: `["fatLoss", "cardio", "noEquipment"]`

### Plank
- `id`: `plank`
- `name`: `Plank`
- `category`: `core`
- `intensity`: `medium`
- `kcalPerMinute`: `4`
- `level`: `beginner`
- `equipment`: `none`
- `instructions`: `Hold your body in a straight line on your forearms and toes. Keep your core tight and avoid dropping your hips.`
- `bodyFocus`: `["core"]`
- `aiTags`: `["core", "stability", "noEquipment"]`

### Lunges
- `id`: `lunges`
- `name`: `Lunges`
- `category`: `strength`
- `intensity`: `medium`
- `kcalPerMinute`: `6`
- `level`: `beginner`
- `equipment`: `none`
- `instructions`: `Step one leg forward, lower your body until both knees are bent, then push back to standing position.`
- `bodyFocus`: `["legs", "glutes"]`
- `aiTags`: `["strength", "balance", "noEquipment"]`

### Burpees
- `id`: `burpees`
- `name`: `Burpees`
- `category`: `fullBody`
- `intensity`: `high`
- `kcalPerMinute`: `10`
- `level`: `intermediate`
- `equipment`: `none`
- `instructions`: `Start standing, drop into a squat, kick your feet back into plank, return to squat, then jump up.`
- `bodyFocus`: `["fullBody", "cardio"]`
- `aiTags`: `["fatLoss", "highCalorieBurn", "conditioning"]`

### Mountain Climbers
- `id`: `mountain-climbers`
- `name`: `Mountain Climbers`
- `category`: `cardio`
- `intensity`: `high`
- `kcalPerMinute`: `9`
- `level`: `intermediate`
- `equipment`: `none`
- `instructions`: `Start in a plank position and quickly drive your knees toward your chest one at a time.`
- `bodyFocus`: `["core", "cardio"]`
- `aiTags`: `["fatLoss", "core", "conditioning"]`

### Sit-ups
- `id`: `sit-ups`
- `name`: `Sit-ups`
- `category`: `core`
- `intensity`: `medium`
- `kcalPerMinute`: `5`
- `level`: `beginner`
- `equipment`: `none`
- `instructions`: `Lie on your back with knees bent, lift your upper body toward your knees, then lower yourself back down.`
- `bodyFocus`: `["core"]`
- `aiTags`: `["core", "beginnerFriendly", "noEquipment"]`

## Recommendation Logic for MVP
Use simple kcal/min estimates first.

Inputs:

- `dailyCalorieTarget`
- `dailyWorkoutDurationMinutes`
- `weightKg`
- `age`
- `fitnessLevel`
- exercise catalog

MVP algorithm:

1. Filter exercises by user fitness level:
   - Beginner users can receive beginner exercises.
   - Intermediate users can receive beginner + intermediate exercises.
   - Advanced users can receive all levels.
2. Prefer exercises that match the calorie target and duration.
3. Build a plan where total duration is close to `dailyWorkoutDurationMinutes`.
4. Estimate calories:
   - `estimatedCalories = durationMinutes * kcalPerMinute`
5. Keep total estimated calories close to target.
6. Mix categories when possible:
   - Cardio
   - Strength
   - Core
   - Full Body
7. Avoid too many high-intensity items for beginner users.

Example:

User:

- Target: `300 kcal`
- Duration: `30 min`
- Level: `beginner`

Plan:

- Jumping Jacks, 10 min, 80 kcal
- Squats, 10 min, 60 kcal
- Walking, 10 min, 40 kcal
- Total: 180 kcal

If target cannot be reached inside the available time, return the best realistic plan and explain that the target may require more time or higher intensity.

## AI Assistant Contract
The AI should return structured JSON, not plain text only.

Suggested request payload:

```json
{
  "userProfile": {
    "dailyCalorieTarget": 500,
    "dailyWorkoutDurationMinutes": 30,
    "weightKg": 70,
    "age": 20,
    "fitnessLevel": "beginner"
  },
  "exerciseCatalog": [
    {
      "id": "walking",
      "name": "Walking",
      "category": "cardio",
      "intensity": "low",
      "kcalPerMinute": 4,
      "level": "beginner",
      "equipment": "none",
      "instructions": "Walk at a comfortable pace. Keep shoulders relaxed."
    }
  ]
}
```

Suggested response:

```json
{
  "summary": "A beginner-friendly workout plan focused on cardio and strength.",
  "totalDurationMinutes": 30,
  "totalEstimatedCalories": 210,
  "items": [
    {
      "exerciseId": "jumping-jacks",
      "name": "Jumping Jacks",
      "durationMinutes": 10,
      "estimatedCalories": 80,
      "intensity": "medium",
      "instructions": "Jump while spreading your legs and raising your arms overhead, then return to the starting position."
    }
  ],
  "notes": [
    "Your calorie target may require more time or higher intensity."
  ]
}
```

## Services/Managers to Build

### AuthService
Responsibilities:

- Register with username, email, password.
- Login with email and password.
- Login with Google.
- Logout.
- Expose current user state.

Suggested API:

```swift
final class AuthService {
    func register(username: String, email: String, password: String) async throws -> AppUser
    func login(email: String, password: String) async throws -> AppUser
    func loginWithGoogle() async throws -> AppUser
    func logout() throws
    func currentUser() -> AppUser?
}
```

### UserProfileService
Responsibilities:

- Create/update user profile in Firestore.
- Fetch current user's profile.
- Track onboarding completion.

Suggested API:

```swift
final class UserProfileService {
    func fetchProfile(userId: String) async throws -> UserFitnessProfile?
    func saveProfile(_ profile: UserFitnessProfile) async throws
    func markOnboardingComplete(userId: String) async throws
}
```

### ExerciseCatalogService
Responsibilities:

- Fetch active exercises from Firestore.
- Seed initial exercise catalog if needed.
- Decode exercise documents into app models.

Suggested API:

```swift
final class ExerciseCatalogService {
    func fetchExercises() async throws -> [ExerciseCatalogItem]
    func seedDefaultExercisesIfNeeded() async throws
}
```

### RecommendationService
Responsibilities:

- Generate MVP rule-based recommendation locally from Firebase exercise catalog.
- Save generated recommendations to Firestore.
- Fetch latest recommendations.

Suggested API:

```swift
final class RecommendationService {
    func generateRecommendation(profile: UserFitnessProfile, exercises: [ExerciseCatalogItem]) async throws -> WorkoutRecommendation
    func saveRecommendation(_ recommendation: WorkoutRecommendation, userId: String) async throws
    func latestRecommendation(userId: String) async throws -> WorkoutRecommendation?
}
```

### AIAssistantService
Responsibilities:

- Call a secure backend endpoint or Firebase Cloud Function.
- Send user profile + exercise catalog.
- Receive structured recommendation JSON.
- Save AI recommendations/chat messages if needed.

Suggested API:

```swift
final class AIAssistantService {
    func generateAIRecommendation(profile: UserFitnessProfile, exercises: [ExerciseCatalogItem]) async throws -> WorkoutRecommendation
    func sendMessage(_ message: String, userId: String) async throws -> AIMessage
}
```

## Models to Build

### AppUser
- `id: String`
- `username: String`
- `email: String`

### UserFitnessProfile
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

### ExerciseCatalogItem
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

### WorkoutRecommendation
- `id: String`
- `userId: String`
- `source: RecommendationSource`
- `summary: String`
- `dailyCalorieTarget: Int`
- `dailyWorkoutDurationMinutes: Int`
- `totalEstimatedCalories: Double`
- `items: [WorkoutRecommendationItem]`
- `createdAt: Date?`

### WorkoutRecommendationItem
- `exerciseId: String`
- `name: String`
- `durationMinutes: Int`
- `estimatedCalories: Double`
- `intensity: ExerciseIntensity`
- `instructions: String`

### AIMessage
- `id: String`
- `userId: String`
- `role: AIMessageRole`
- `content: String`
- `createdAt: Date?`

## Enums to Build

- `FitnessLevel`
  - `beginner`
  - `intermediate`
  - `advanced`
- `ExerciseCategory`
  - `cardio`
  - `strength`
  - `core`
  - `fullBody`
  - `mobility`
  - `recovery`
- `ExerciseIntensity`
  - `low`
  - `medium`
  - `high`
- `RecommendationSource`
  - `ruleBased`
  - `ai`
- `AIMessageRole`
  - `user`
  - `assistant`

## UI Requirements for UI Agent Later
After fullstack/service implementation, UI should support:

- Auth flow:
  - Login screen.
  - Register screen.
  - Google Sign-In button.
- Onboarding flow:
  - Daily calorie target input.
  - Daily workout duration input.
  - Weight input.
  - Age input.
  - Fitness level picker.
- Home:
  - Current profile summary.
  - Today recommendation summary.
  - AI assistant CTA.
- Workouts:
  - Recommendation list.
  - Exercise detail/instructions.
- Profile:
  - Edit profile inputs.
  - Logout.
- AI Assistant:
  - Recommendation explanation.
  - Chat-style prompt/response.

## Privacy and Security Requirements

- Never commit the AI API key into the iOS app or repository.
- Do not store user password manually in Firestore.
- Use Firebase Auth for credentials.
- Firestore `users/{uid}` documents must only be readable/writable by the signed-in user.
- Firestore `recommendations` and `aiMessages` must be scoped by `userId`.
- Exercise catalog can be readable by all signed-in users.
- If using Cloud Functions for AI, validate auth token before generating recommendations.

## Expected Handoff Output
After implementation, write or update:

`handoff/fullstack-output.md`

Include:

- Firebase packages/config added.
- Auth APIs available.
- Firestore collections used.
- Exercise catalog seed status.
- Recommendation APIs.
- AI backend boundary.
- Any required project settings still missing.

Also update:

`handoff/uiux-output.md`

Only if UI APIs or screen data contracts changed.

## Open Questions
- Which AI provider/model will the backend call?
- Will recommendations be generated only on demand, or automatically after onboarding changes?
- Should the exercise catalog be editable from an admin panel later?
- Should weight be stored in kg only, or support kg/lb?
- Should age be stored as a number, or should date of birth be used instead?
