import AVFoundation
import Combine
import UIKit

@MainActor
final class CameraViewModel: NSObject, ObservableObject {
    @Published private(set) var session = AVCaptureSession()
    @Published private(set) var authorizationStatus: AVAuthorizationStatus
    @Published private(set) var scanResult: ScanResult?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isSessionRunning = false
    @Published private(set) var isProcessing = false

    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.kanalearn.camera.session")
    private let mlServiceProvider: () throws -> MLInferenceService
    private let textService = VisionTextService()
    private var mlService: MLInferenceService?
    private var photoContinuation: CheckedContinuation<UIImage, Error>?
    private var isConfigured = false

    var canOpenSettings: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    override init() {
        self.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        self.mlServiceProvider = { try MLInferenceService() }
        super.init()
    }

    init(mlServiceProvider: @escaping () throws -> MLInferenceService) {
        self.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        self.mlServiceProvider = mlServiceProvider
        super.init()
    }

    func requestCameraAccess() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            authorizationStatus = status
            configureSessionIfNeeded()
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            authorizationStatus = granted ? .authorized : .denied
            if granted {
                configureSessionIfNeeded()
            } else {
                errorMessage = ScanError.permissionDenied.localizedDescription
            }
        case .denied, .restricted:
            authorizationStatus = status
            errorMessage = ScanError.permissionDenied.localizedDescription
        @unknown default:
            authorizationStatus = status
            errorMessage = ScanError.cameraUnavailable.localizedDescription
        }
    }

    func startSession() {
        guard authorizationStatus == .authorized else { return }
        configureSessionIfNeeded()
        let captureSession = session
        sessionQueue.async { [weak self, captureSession] in
            guard let self, !captureSession.isRunning else { return }
            captureSession.startRunning()
            Task { @MainActor in
                self.isSessionRunning = true
            }
        }
    }

    func stopSession() {
        let captureSession = session
        sessionQueue.async { [weak self, captureSession] in
            guard let self, captureSession.isRunning else { return }
            captureSession.stopRunning()
            Task { @MainActor in
                self.isSessionRunning = false
            }
        }
    }

    func capture(mode: ScanMode) async {
        guard authorizationStatus == .authorized else {
            errorMessage = ScanError.permissionDenied.localizedDescription
            return
        }

        isProcessing = true
        errorMessage = nil

        do {
            let image = try await capturePhoto()
            let result: ScanResult
            switch mode {
            case .character:
                let mlService = try kanaMLService()
                result = try await mlService.classify(image: image)
            case .sentence:
                result = try await textService.recognizeSentence(in: image)
            }
            scanResult = result
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isProcessing = false
    }

    func clearResult() {
        scanResult = nil
    }

    func settingsURL() -> URL? {
        URL(string: UIApplication.openSettingsURLString)
    }

    private func configureSessionIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true
        let captureSession = session
        let captureOutput = photoOutput

        sessionQueue.async { [weak self, captureSession, captureOutput] in
            guard let self else { return }

            captureSession.beginConfiguration()
            captureSession.sessionPreset = .photo

            do {
                guard let device = Self.bestAvailableCamera() else {
                    throw ScanError.cameraUnavailable
                }

                let input = try AVCaptureDeviceInput(device: device)

                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }

                if captureSession.canAddOutput(captureOutput) {
                    captureSession.addOutput(captureOutput)
                    captureOutput.maxPhotoQualityPrioritization = .balanced
                }

                captureSession.commitConfiguration()
            } catch {
                captureSession.commitConfiguration()
                Task { @MainActor in
                    self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                }
            }
        }
    }

    private func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            photoContinuation = continuation
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .off
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    private func kanaMLService() throws -> MLInferenceService {
        if let mlService {
            return mlService
        }

        let service = try mlServiceProvider()
        mlService = service
        return service
    }

    nonisolated private static func bestAvailableCamera() -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(for: .video)
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        Task { @MainActor in
            if let error {
                photoContinuation?.resume(throwing: error)
                photoContinuation = nil
                return
            }

            guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
                photoContinuation?.resume(throwing: ScanError.captureFailed)
                photoContinuation = nil
                return
            }

            photoContinuation?.resume(returning: image)
            photoContinuation = nil
        }
    }
}
