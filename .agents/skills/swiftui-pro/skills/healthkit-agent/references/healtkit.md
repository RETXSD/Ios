---
name: healthkit
description: Reviews and writes HealthKit integration code for iOS apps. Use when reading, writing, or reviewing any code that accesses Apple Health data including activity, calories, workouts, and biometrics.
license: MIT
metadata:
  author: generated for fitness coach project
  version: "1.0"
---

Review and write HealthKit code for correctness, privacy compliance, and modern API usage. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Validate that HealthKit permissions are requested correctly and minimally.
2. Check that all Health data reads/writes use async/await properly.
3. Ensure queries use the most modern HKQuery APIs available.
4. Validate that Info.plist usage descriptions are present and meaningful.
5. Check that HealthKit availability is guarded with `HKHealthStore.isHealthDataAvailable()`.
6. Ensure sensitive data is never logged or sent to external servers.


## Core Instructions

- Always check `HKHealthStore.isHealthDataAvailable()` before any HealthKit call.
- Request only the minimum permissions needed — do not bulk-request all types upfront.
- Use `HKStatisticsCollectionQuery` for time-series data like daily calories.
- Use `HKAnchoredObjectQuery` for live updates rather than polling.
- Always handle the case where the user denies permission — HealthKit returns no error, just empty data.
- Wrap all HealthKit calls in `async`/`await` using Swift Concurrency.
- Store `HKHealthStore` as a single shared instance, not recreated per view.
- Never hardcode unit types — use `HKUnit` constants.


## Required Info.plist Keys

```xml
<key>NSHealthShareUsageDescription</key>
<string>We read your activity data to track calorie progress.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>We save your workouts to Apple Health.</string>
```


## Common Patterns

### Request Permission

```swift
let typesToRead: Set<HKObjectType> = [
    HKQuantityType(.activeEnergyBurned),
    HKQuantityType(.basalEnergyBurned)
]

try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
```

### Read Active Energy (Today)

```swift
func fetchActiveCaloriesToday() async -> Double {
    let type = HKQuantityType(.activeEnergyBurned)
    let now = Date()
    let startOfDay = Calendar.current.startOfDay(for: now)
    let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)

    let stats = try? await healthStore.statisticsCollection(
        for: type,
        predicate: predicate,
        options: .cumulativeSum
    )

    return stats?.statistics().first?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
}
```

### Save Workout

```swift
let workout = HKWorkout(
    activityType: .running,
    start: startDate,
    end: endDate,
    duration: duration,
    totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
    totalDistance: nil,
    metadata: nil
)

try await healthStore.save(workout)
```


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary.


## References

- Apple Developer Docs: HealthKit — https://developer.apple.com/documentation/healthkit
- HKStatisticsCollectionQuery for time-series aggregation
- HKAnchoredObjectQuery for real-time updates