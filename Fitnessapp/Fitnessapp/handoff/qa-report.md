# QA Report

## Test Coverage
- Unit tests written: none yet.
- UI tests written: none yet.
- No `FitnessappTests`, `FitnessappUITests`, test plan, or dedicated `QA/` folder was found.
- Missing unit coverage:
  - `CalorieGoalService` default goal, update goal, invalid goal, and `CalorieProgress` calculations.
  - `WorkoutRecommendationService` low-progress, medium-progress, near-goal, and goal-reached branches.
  - `RecommendationService` duration allocation, calorie estimates, and fitness-level filtering.
  - `ExerciseCatalogService.defaultExercises` count, ids, kcal/min values, and supported camera exercise names.
  - `ExerciseFormAnalyzer` state-machine behavior should be covered with fixture/sample pose data before trusting rep counts.
- Missing UI coverage:
  - Login/register local flow.
  - Empty-first onboarding form validation and save.
  - Four-tab navigation.
  - Coach camera permission, front/back switch, exercise guide changes, live reps, and session summary.
  - Profile edit flow.

## Privacy Compliance
- [ ] `NSHealthShareUsageDescription`
- [ ] `NSHealthUpdateUsageDescription`
- [x] `NSCameraUsageDescription`
- [x] No data transmitted externally while Firebase/AI are paused
- [x] No ungated `print`, `debugPrint`, `os_log`, or `Logger` calls found in app source
- [x] Camera frames are processed on-device only in the current implementation
- [ ] HealthKit capability/entitlement enabled and tested on device

## App Store Readiness
- [ ] App icon final review
- [ ] Screenshots
- [ ] App name, subtitle, description, and keywords
- [ ] Support URL
- [ ] Privacy Policy URL
- [ ] Age rating
- [ ] HealthKit capability and entitlements
- [ ] TestFlight tested
- [ ] Tested on physical iPhone camera
- [ ] Tested on iPhone SE
- [ ] Tested on iPhone Pro Max
- [ ] Production code signing/team restored for device/App Store builds

## Blockers
- HealthKit is still referenced in code, but the generated Info.plist build settings only include `NSCameraUsageDescription`. Add `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` before any HealthKit prompt or App Store review.
- HealthKit entitlement/capability is not confirmed in the project. Real Apple Health active-energy reading/writing is not App Store ready without it.
- There are no automated tests for business logic or critical UI flows. This is risky now that the app has onboarding validation, recommendation logic, and camera session state.
- `Persistence.swift` still contains default Core Data template `fatalError` paths. That can crash a production build if persistent container loading or preview insert fails.
- Camera rep counting and calorie/session summary have only build verification, not physical-device QA. Vision body-pose behavior must be tested on iPhone with real movement.

## Nice to Have
- Add a manual QA checklist under `QA/` for physical-device camera testing: lighting, distance, front/back camera, each exercise, switching exercises mid-session, leaving frame, stopping/resuming.
- Add clearer HealthKit denied/unavailable states so zero active energy is not confused with real progress.
- Add workout detail pages from the Workouts tab.
- Add demo video/GIF assets for each exercise guide after the MVP text guide is stable.
- Restore Firebase/AI only after camera MVP is stable, then add privacy disclosure and backend API-key boundary checks.
