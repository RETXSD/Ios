import AVFoundation
import Foundation

enum CameraSessionManagerError: Error {
    case permissionDenied
    case deviceUnavailable
    case inputUnavailable
    case outputUnavailable
}

final class CameraSessionManager {
    let session: AVCaptureSession

    private let sessionActor = CameraSessionActor()

    init(session: AVCaptureSession = AVCaptureSession()) {
        self.session = session
    }

    func requestCameraAccess() async -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            return granted ? .authorized : .denied
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .unavailable
        }
    }

    func cameraPermissionStatus() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .authorized
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .unavailable
        }
    }

    func startSession() async throws {
        guard cameraPermissionStatus() == .authorized else {
            throw CameraSessionManagerError.permissionDenied
        }

        try await configureSessionIfNeeded()
        await sessionActor.start(session)
    }

    func stopSession() {
        Task {
            await sessionActor.stop(session)
        }
    }

    private func configureSessionIfNeeded() async throws {
        try await sessionActor.configure(session)
    }
}

private actor CameraSessionActor {
    private var isConfigured = false

    func configure(_ session: AVCaptureSession) throws {
        guard !isConfigured else { return }

        session.beginConfiguration()
        session.sessionPreset = .high
        defer { session.commitConfiguration() }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw CameraSessionManagerError.deviceUnavailable
        }

        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            throw CameraSessionManagerError.inputUnavailable
        }
        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        guard session.canAddOutput(output) else {
            throw CameraSessionManagerError.outputUnavailable
        }
        session.addOutput(output)

        isConfigured = true
    }

    func start(_ session: AVCaptureSession) {
        guard !session.isRunning else { return }
        session.startRunning()
    }

    func stop(_ session: AVCaptureSession) {
        guard session.isRunning else { return }
        session.stopRunning()
    }
}
