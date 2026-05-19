import Foundation
import HealthKit

enum HealthKitManagerError: Error {
    case healthDataUnavailable
    case activeEnergyTypeUnavailable
}

final class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore: HKHealthStore
    private let calendar: Calendar

    private init(
        healthStore: HKHealthStore = HKHealthStore(),
        calendar: Calendar = .current
    ) {
        self.healthStore = healthStore
        self.calendar = calendar
    }

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitManagerError.healthDataUnavailable
        }

        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitManagerError.activeEnergyTypeUnavailable
        }

        let readTypes: Set<HKObjectType> = [activeEnergyType]
        let shareTypes: Set<HKSampleType> = [HKObjectType.workoutType()]

        try await healthStore.requestAuthorization(toShare: shareTypes, read: readTypes)
    }

    func authorizationStatus() -> PermissionStatus {
        guard HKHealthStore.isHealthDataAvailable() else {
            return .unavailable
        }

        switch healthStore.authorizationStatus(for: HKObjectType.workoutType()) {
        case .notDetermined:
            return .notDetermined
        case .sharingAuthorized:
            return .authorized
        case .sharingDenied:
            return .denied
        @unknown default:
            return .restricted
        }
    }

    func activeEnergyBurnedToday() async throws -> Double {
        let now = Date.now
        let startOfDay = calendar.startOfDay(for: now)
        return try await activeEnergyBurned(from: startOfDay, to: now)
    }

    func activeEnergyBurned(from startDate: Date, to endDate: Date) async throws -> Double {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitManagerError.healthDataUnavailable
        }

        guard let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitManagerError.activeEnergyTypeUnavailable
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let anchorDate = calendar.startOfDay(for: startDate)
        let interval = DateComponents(day: 1)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: activeEnergyType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchorDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let calories = results?
                    .statistics()
                    .compactMap { $0.sumQuantity()?.doubleValue(for: .kilocalorie()) }
                    .reduce(0, +) ?? 0

                continuation.resume(returning: calories)
            }

            healthStore.execute(query)
        }
    }

    func saveWorkout(_ workout: CompletedWorkout) async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitManagerError.healthDataUnavailable
        }

        let hkWorkout = HKWorkout(
            activityType: activityType(for: workout.workout.category),
            start: workout.startedAt,
            end: workout.endedAt,
            duration: workout.endedAt.timeIntervalSince(workout.startedAt),
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: workout.activeCalories),
            totalDistance: nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "Fitness Coach",
                "FitnessCoachWorkoutID": workout.id.uuidString
            ]
        )

        try await healthStore.save(hkWorkout)
    }

    private func activityType(for category: WorkoutCategory) -> HKWorkoutActivityType {
        switch category {
        case .strength:
            return .traditionalStrengthTraining
        case .cardio, .mixed:
            return .mixedCardio
        case .mobility:
            return .flexibility
        case .recovery:
            return .mindAndBody
        }
    }
}
