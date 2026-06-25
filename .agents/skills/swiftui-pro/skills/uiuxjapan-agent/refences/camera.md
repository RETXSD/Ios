# Camera Reference — AVFoundation

Used by: visionml-agent

## Session Setup

Always use `AVCaptureSession` directly — never `UIImagePickerController` or `PHPickerViewController`.

```swift
class CameraViewModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()

    func configure() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }

        session.commitConfiguration()
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.stopRunning()
        }
    }
}
```

## Still Image Capture

```swift
func capturePhoto() {
    let settings = AVCapturePhotoSettings()
    settings.flashMode = .auto
    output.capturePhoto(with: settings, delegate: self)
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        // pass image to MLInferenceService
    }
}
```

## SwiftUI Preview Layer

```swift
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiView.bounds
        }
    }
}
```

## Permissions

Always request permission before starting session. Add to Info.plist:
```
NSCameraUsageDescription — "KanaLearn membutuhkan kamera untuk mendeteksi huruf Jepang dari tulisan tangan Anda."
```

```swift
func requestPermission() async -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized: return true
    case .notDetermined:
        return await AVCaptureDevice.requestAccess(for: .video)
    default: return false
    }
}
```

## Rules

- Always run `session.startRunning()` and `stopSession()` on a background thread
- Always call `session.beginConfiguration()` / `commitConfiguration()` when modifying session
- Never retain `AVCaptureSession` in a View — always in a ViewModel or Service
- Stop session when view disappears to conserve battery
