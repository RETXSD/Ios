# UI/UX Handoff

## Screens Built
- `ContentView.swift` — Hosts the app shell by rendering `FitnessAppTabView`.
- `Views/FitnessAppTabView.swift` — Bottom tab navigation shell with Home, Workouts, Coach, and Profile.
- `Views/HomeView.swift` — Home dashboard with daily active energy, calorie goal progress, recommendation, and status.
- `Views/WorkoutsView.swift` — Workout recommendations list based on current calorie progress.
- `Views/CoachView.swift` — Camera/form-coach placeholder screen with permission status and feedback area.
- `Views/ProfileView.swift` — Goal summary and app readiness checklist.
- `Views/TodayHeaderView.swift` — Home header.
- `Views/HomeCalorieCard.swift` — Active energy and calorie progress card.
- `Views/HomeRecommendationCard.swift` — Today's workout card.
- `Views/HomeStatusCard.swift` — HealthKit and Camera permission status card.
- `Views/CoachPreviewCard.swift` — Coach camera preview placeholder and camera permission status.
- `Views/CoachFeedbackCard.swift` — Live feedback placeholder.
- `Views/GoalSummaryCard.swift` — Profile daily goal summary.
- `Views/ProfileReadinessCard.swift` — Profile readiness checklist.

## Navigation Flow
- Root view:
  - `ContentView` -> `FitnessAppTabView`
- Bottom tab navigation:
  - `Home`
  - `Workouts`
  - `Coach`
  - `Profile`
- Each tab owns its own `NavigationStack`.
- No `NavigationView` is used.
- There are no detail routes yet; workout detail and camera session screens can be added later with `navigationDestination`.

## Components Available
- `FitnessTheme`
  - Shared colors: `background`, `surface`, `primary`, `secondary`, `gold`, `border`.
- `FitnessCard`
  - Generic card container with dark surface, 8px corner radius, and subtle border.
- `CalorieProgressRing`
  - Parameters: `progress: CalorieProgress`.
- `StatusBadge`
  - Parameters: `title: String`, `status: AppReadinessItemStatus`.
- `MetricPill`
  - Parameters: `title: String`, optional `systemImage: String?`.
- `WorkoutRow`
  - Parameters: `workout: Workout`.

## Data Bindings Used
- `FitnessAppTabView`
  - Calls `FitnessDashboardManager.loadSummary()`.
  - Stores `FitnessDashboardSummary` in local `@State`.
- `HomeView`
  - Expects `FitnessDashboardSummary`.
  - Uses `CalorieProgress`, `Workout?`, `PermissionStatus`.
- `WorkoutsView`
  - Expects `CalorieProgress`.
  - Calls `WorkoutRecommendationService.recommendations(for:)`.
- `CoachView`
  - Expects `PermissionStatus` for camera state.
  - Does not start camera capture yet.
- `ProfileView`
  - Expects `FitnessDashboardSummary`.
  - Uses `CalorieProgress` and `[AppReadinessItem]`.

## Notes for QA Agent
- Build verified with:
  - `xcodebuild -project Fitnessapp/Fitnessapp.xcodeproj -scheme Fitnessapp -sdk iphonesimulator -derivedDataPath /private/tmp/FitnessappDerivedData build -quiet`
- The UI now matches the agreed 4-tab app structure: Home, Workouts, Coach, Profile.
- Permission prompt buttons are intentionally not present yet because `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`, and `NSCameraUsageDescription` are still missing.
- Coach screen is a placeholder UI until Info.plist privacy strings and a real camera preview wrapper are added.
- Workouts screen currently lists recommendations but has no workout detail route.
- Profile screen shows readiness status but does not yet allow editing the daily calorie goal.
- Test Dynamic Type on small screens, especially `HomeCalorieCard` and `ProfileReadinessCard`.
- Test VoiceOver labels for tab items, progress ring, readiness badges, and workout rows.
