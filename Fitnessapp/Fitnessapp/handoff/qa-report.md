# QA Report

## Test Coverage
- Unit tests written: none yet.
- UI tests written: none yet.
- Missing unit coverage:
  - `CalorieProgress` goal clamping, remaining calories, and goal-reached behavior.
  - `WorkoutRecommendationService` low, medium, near-goal, and goal-reached recommendation branches.
  - `CalorieGoalService` default goal, update goal, and invalid goal behavior.
  - HealthKit unavailable and permission-denied fallback behavior.
- Missing UI coverage:
  - First launch/onboarding flow.
  - Daily calorie goal entry.
  - Workout recommendation tap.
  - Camera permission prompt.
  - Landing page loading/permission states.

## Privacy Compliance
- [ ] `NSHealthShareUsageDescription`
- [ ] `NSHealthUpdateUsageDescription`
- [ ] `NSCameraUsageDescription`
- [x] No data transmitted externally
- [x] HealthKit data is not logged in production
- [x] Camera frames are processed on-device only
- [ ] HealthKit capability enabled

## App Store Readiness
- [ ] App icon final review
- [ ] Screenshots
- [ ] App name, subtitle, description, and keywords
- [ ] Support URL
- [ ] Privacy Policy URL
- [ ] Age rating
- [ ] HealthKit capability and entitlements
- [ ] TestFlight tested
- [ ] Tested on iPhone SE
- [ ] Tested on iPhone Pro Max

## Blockers
- Missing required privacy usage descriptions for HealthKit and Camera. The app must add:
  - `NSHealthShareUsageDescription`
  - `NSHealthUpdateUsageDescription`
  - `NSCameraUsageDescription`
- HealthKit capability/entitlement is not enabled, so real HealthKit device testing is not ready.
- No unit tests exist for calorie progress, goal storage, or workout recommendation logic.
- `Persistence.swift` still contains shipping `fatalError` calls from the default Core Data template.
- No UI tests exist for critical flows.

## Nice to Have
- Add explicit UI copy for HealthKit denied/unavailable states so zero active energy is not confused with real user progress.
- Add a dedicated QA folder for manual device-test notes.
- Add screenshots after the final 4-tab UI is built.
- Replace the placeholder Vision-only form feedback with a real Core ML classifier when a model is available.
