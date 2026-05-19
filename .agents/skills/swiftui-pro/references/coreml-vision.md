---
name: coreml-vision
description: Reviews and writes Core ML and Vision framework code for iOS apps. Use when reading, writing, or reviewing camera-based features, pose estimation, exercise form analysis, or any on-device ML inference.
license: MIT
metadata:
  author: generated for fitness coach project
  version: "1.0"
---

Review and write Core ML and Vision code for correctness, performance, and privacy. Report only genuine problems - do not nitpick or invent issues.

Review process:

1. Validate that camera permissions are declared and requested correctly.
2. Check that Vision requests are processed off the main thread.
3. Ensure Core ML models are loaded once and reused, not recreated per frame.
4. Validate that AVCaptureSession lifecycle is managed correctly (start/stop with view lifecycle).
5. Check that pose/body landmark results are handled safely with confidence thresholds.
6. Ensure camera feed is never stored or transmitted — process on-device only.


## Core Instructions

- Always process Vision requests on a background queue, never on the main thread.
- Load `MLModel` / `VNCoreMLModel` once at init — model loading is expensive.
- Use `AVCaptureSession` with `.medium` or `.high` preset for real-time inference; avoid `.photo`.
- Use `VNDetectHumanBodyPoseRequest` for exercise form analysis.
- Always check `observation.confidence` before using landmark results — discard if below 0.5.
- Use `CMSampleBuffer` for real-time camera frames, not `UIImage`.
- Stop `AVCaptureSession` when the view disappears to save battery.
- All camera processing must happen on-device — never upload raw video frames.


## Required Info.plist Keys

```xml
<key>NSCameraUsageDescription</key>
<string>We use your camera to analyze your exercise form in real time.</string>
```


## Common Patterns

### Setup AVCaptureSession

```swift
let session = AVCaptureSession()
session.sessionPreset = .high

guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
      let input = try? AVCaptureDeviceInput(device: device) else { return }

session.addInput(input)

let output = AVCaptureVideoDataOutput()
output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
session.addOutput(output)
```

### Run Body Pose Request

```swift
func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

    let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
        guard let observations = request.results as? [VNHumanBodyPoseObservation],
              let body = observations.first else { return }
        self?.analyzeForm(body)
    }

    let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
    try? handler.perform([request])
}
```

### Analyze Landmark with Confidence

```swift
func analyzeForm(_ observation: VNHumanBodyPoseObservation) {
    guard let leftKnee = try? observation.recognizedPoint(.leftKnee),
          let rightKnee = try? observation.recognizedPoint(.rightKnee),
          leftKnee.confidence > 0.5,
          rightKnee.confidence > 0.5 else { return }

    // Use leftKnee.location and rightKnee.location for angle calculation
}
```

### Load Core ML Model Once

```swift
class FormAnalyzer {
    private let model: VNCoreMLModel

    init() throws {
        let mlModel = try MyPoseClassifier(configuration: MLModelConfiguration()).model
        self.model = try VNCoreMLModel(for: mlModel)
    }
}
```


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary.


## References

- Apple Developer Docs: Vision — https://developer.apple.com/documentation/vision
- Apple Developer Docs: Core ML — https://developer.apple.com/documentation/coreml
- VNDetectHumanBodyPoseRequest for body landmark detection
- AVCaptureSession for real-time camera feed
