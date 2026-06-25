# Privacy Reference — Permissions & Data Policy

Used by: visionml-agent, qa-agent

## Required Info.plist Keys

```xml
<key>NSCameraUsageDescription</key>
<string>KanaLearn membutuhkan kamera untuk mendeteksi huruf Jepang dari tulisan tangan Anda.</string>
```

No other hardware permissions needed for this app.

## On-Device Only Policy

KanaLearn processes ALL data on-device. No image, character, or scan result is ever sent to an external server.

- CoreML inference: on-device only
- Vision text recognition: on-device only
- AVSpeechSynthesizer: on-device only
- Dictionary lookup: local JSON/SQLite bundle only
- AI Assistant: only exception — uses OpenAI API (user must be informed)

## AI Assistant Data Policy

If using OpenAI API for AI Assistant:
- User messages are sent to OpenAI API
- No personally identifiable information should be included in prompts
- Inform user in onboarding: "Percakapan dengan AI Assistant dikirim ke server OpenAI untuk diproses."
- Do not store conversation history on any external server

## Debug Log Policy

```swift
// CORRECT — gated behind DEBUG flag
#if DEBUG
print("MLInference: label=\(label), confidence=\(confidence)")
#endif

// WRONG — never log in production
print("User scanned: \(label)")
```

All print statements and debug logs must be inside `#if DEBUG` blocks.

## Camera Permission Flow

```swift
// Check before showing camera UI
func checkCameraPermission() async -> PermissionState {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        return .granted
    case .notDetermined:
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted ? .granted : .denied
    case .denied, .restricted:
        return .denied
    @unknown default:
        return .denied
    }
}
```

If denied → show settings deep link, never crash or show blank screen:
```swift
if let url = URL(string: UIApplication.openSettingsURLString) {
    await UIApplication.shared.open(url)
}
```

## Rules

- Never transmit images or scan results to any server
- Never log sensitive data outside `#if DEBUG`
- Always handle camera permission denial gracefully with settings redirect
- Inform user about AI Assistant data policy during onboarding
- No analytics SDK that transmits user behavior without consent
