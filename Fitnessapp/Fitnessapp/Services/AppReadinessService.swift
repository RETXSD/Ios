import Foundation

final class AppReadinessService {
    private let healthKitManager: HealthKitManager
    private let cameraSessionManager: CameraSessionManager

    init(
        healthKitManager: HealthKitManager = .shared,
        cameraSessionManager: CameraSessionManager = CameraSessionManager()
    ) {
        self.healthKitManager = healthKitManager
        self.cameraSessionManager = cameraSessionManager
    }

    func readinessItems() async -> [AppReadinessItem] {
        [
            AppReadinessItem(
                title: "HealthKit Permission",
                status: readinessStatus(for: healthKitManager.authorizationStatus()),
                detail: "Required to show daily active energy progress."
            ),
            AppReadinessItem(
                title: "Camera Permission",
                status: readinessStatus(for: cameraSessionManager.cameraPermissionStatus()),
                detail: "Required for real-time exercise form feedback."
            ),
            AppReadinessItem(
                title: "Local Data Processing",
                status: .ready,
                detail: "Health data and camera frames are processed on device only."
            ),
            AppReadinessItem(
                title: "Usage Descriptions",
                status: .needsAttention,
                detail: "Info.plist must include HealthKit and camera usage descriptions before App Store submission."
            ),
            AppReadinessItem(
                title: "HealthKit Capability",
                status: .needsAttention,
                detail: "The HealthKit capability must be enabled in the app target before device testing."
            )
        ]
    }

    private func readinessStatus(for permissionStatus: PermissionStatus) -> AppReadinessItemStatus {
        switch permissionStatus {
        case .authorized:
            return .ready
        case .notDetermined:
            return .notChecked
        case .denied, .restricted, .unavailable:
            return .blocked
        }
    }
}
