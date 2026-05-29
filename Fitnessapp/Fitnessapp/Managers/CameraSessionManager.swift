import AVFoundation
import Combine
import Foundation

enum CameraSessionManagerError: Error {
    case permissionDenied
    case deviceUnavailable
    case inputUnavailable
    case outputUnavailable
}

enum CameraPosition: String, CaseIterable, Identifiable {
    case front = "Front"
    case back = "Back"

    var id: String { rawValue }

    var capturePosition: AVCaptureDevice.Position {
        switch self {
        case .front:
            return .front
        case .back:
            return .back
        }
    }

    var toggled: CameraPosition {
        switch self {
        case .front:
            return .back
        case .back:
            return .front
        }
    }
}

final class CameraSessionManager: NSObject, ObservableObject {
    let session: AVCaptureSession

    @Published private(set) var permissionStatus: PermissionStatus
    @Published private(set) var isRunning = false
    @Published private(set) var selectedPosition: CameraPosition = .front

    var sampleBufferHandler: ((CMSampleBuffer) -> Void)?

    private let sessionQueue = DispatchQueue(label: "Fitnessapp.CameraSessionManager.session")
    private let videoOutputQueue = DispatchQueue(label: "Fitnessapp.CameraSessionManager.videoOutput")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var isConfigured = false

    init(session: AVCaptureSession = AVCaptureSession()) {
        self.session = session
        self.permissionStatus = Self.currentCameraPermissionStatus()
        super.init()
    }

    func requestCameraAccess() async -> PermissionStatus {
        let status: PermissionStatus
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            status = .authorized
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            status = granted ? .authorized : .denied
        case .denied:
            status = .denied
        case .restricted:
            status = .restricted
        @unknown default:
            status = .unavailable
        }

        await MainActor.run {
            permissionStatus = status
        }
        return status
    }

    func cameraPermissionStatus() -> PermissionStatus {
        Self.currentCameraPermissionStatus()
    }

    func startSession() async throws {
        let status = await requestCameraAccess()
        guard status == .authorized else {
            throw CameraSessionManagerError.permissionDenied
        }

        try await configureSession(position: selectedPosition, forceReconfigure: false)
        await withCheckedContinuation { continuation in
            sessionQueue.async { [session] in
                if !session.isRunning {
                    session.startRunning()
                }
                continuation.resume()
            }
        }

        await MainActor.run {
            isRunning = true
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }

            DispatchQueue.main.async {
                self.isRunning = false
            }
        }
    }

    func switchCamera() async throws {
        let nextPosition = selectedPosition.toggled
        try await configureSession(position: nextPosition, forceReconfigure: true)

        await MainActor.run {
            selectedPosition = nextPosition
        }
    }

    private static func currentCameraPermissionStatus() -> PermissionStatus {
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

    private func configureSession(
        position: CameraPosition,
        forceReconfigure: Bool
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            sessionQueue.async { [weak self] in
                guard let self else { return }

                do {
                    try self.configureSessionOnQueue(
                        position: position,
                        forceReconfigure: forceReconfigure
                    )
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func configureSessionOnQueue(
        position: CameraPosition,
        forceReconfigure: Bool
    ) throws {
        guard forceReconfigure || !isConfigured else { return }

        session.beginConfiguration()
        session.sessionPreset = .high
        defer { session.commitConfiguration() }

        if forceReconfigure {
            session.inputs.forEach { session.removeInput($0) }
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position.capturePosition) else {
            throw CameraSessionManagerError.deviceUnavailable
        }

        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            throw CameraSessionManagerError.inputUnavailable
        }
        session.addInput(input)

        if !session.outputs.contains(videoOutput) {
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
            guard session.canAddOutput(videoOutput) else {
                throw CameraSessionManagerError.outputUnavailable
            }
            session.addOutput(videoOutput)
        }

        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = position == .front && connection.isVideoMirroringSupported
        }

        isConfigured = true
    }
}

extension CameraSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        sampleBufferHandler?(sampleBuffer)
    }
}
