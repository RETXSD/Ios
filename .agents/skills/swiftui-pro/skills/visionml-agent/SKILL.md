---
name: visionml-agent
description: Handles camera input, CoreML inference, and character detection for the KanaLearn iOS app. Use when implementing or reviewing anything related to the camera, ML model loading, character recognition, or confidence scoring.
license: MIT
metadata:
  author: kanalearn project
  version: "1.0"
---

Build and review CoreML and Vision framework code for the KanaLearn app. Report only genuine problems — do not nitpick or invent issues.

Review process:

1. Check camera session setup using `references/camera.md`.
2. Validate CoreML model integration using `references/coreml.md`.
3. Check Vision framework usage using `references/vision.md`.
4. Validate image preprocessing pipeline using `references/preprocessing.md`.
5. Ensure privacy compliance using `references/privacy.md`.
6. Final hygiene check using `references/hygiene.md`.


## Core Instructions

- Only work inside Services/ML/, Services/Camera/, and Models/ folders — do not touch Views/, Components/, or Tests/.
- Use AVFoundation for camera session — never UIImagePickerController.
- All inference must run on-device — no external API calls for ML.
- Expose results via async/await or Combine publisher — never callbacks.
- Never access UI components directly — communicate only through ViewModels.
- Image preprocessing must happen on a background thread — never on main thread.
- Handle all CoreML errors explicitly — never use try! or force unwrap on model output.


## Responsibilities

- Camera session — AVCaptureSession setup, still image capture, permission handling
- Single character mode — capture → preprocess → CoreML classify → return label + confidence
- Sentence mode — Vision VNRecognizeTextRequest → segment characters → classify each → assemble result
- CoreML model management — load JapaneseCharClassifier.mlmodel, manage model lifecycle
- Image preprocessing — grayscale conversion, resize to 64x64, normalize pixel values
- Low confidence handling — flag results below 50% threshold as unclear
- Result publishing — expose ScanResult via @Published or AsyncStream to ViewModels


## Model Spec

- File: JapaneseCharClassifier.mlmodel
- Type: CreateML Image Classifier
- Input: Grayscale image, 64x64px
- Output: String label (character) + Float confidence (0.0–1.0)
- Classes: Hiragana (92) + Katakana (92) + Kanji (2000+)
- Trained via: CreateML on macOS


## You MUST NOT

- Write any SwiftUI views or UI components
- Call external APIs or send image data to any server
- Run inference on the main thread
- Use force unwrap (!) on CoreML model outputs
- Access HealthKit or AVSpeechSynthesizer
- Write or modify unit tests or UI tests
- Configure Info.plist (only flag what needs to be added)


## Output Format

Organize findings by file. For each issue:

1. State the file and relevant line(s).
2. Name the rule being violated.
3. Show a brief before/after code fix.

Skip files with no issues. End with a prioritized summary.


## Handoff Protocol

You run FIRST, before $uiux-agent and $qa-agent.

You have no prior handoff file to read — begin from the project spec directly.

After completing your task, write handoff/ml-output.md with this exact structure:

```md
# Vision/ML Handoff

## Model Integration
- CoreML model file name and location
- Input format expected (size, color space, normalization)
- Output format (label type, confidence range)

## Services Available
- List every service with its file name, public methods, and return types

## Data Models
- ScanResult struct fields and types
- Any other shared models

## Scan Modes
- Describe single character mode flow
- Describe sentence mode flow
- Confidence threshold and fallback behavior

## Camera Permissions
- List all Info.plist keys that must be added
- Describe permission request flow

## Notes for UI/UX Agent
- What data to expect from ScanResult
- How to trigger scan (method name + params)
- Threading notes (which calls must be on main thread)
- Known limitations or edge cases
```

The $uiux-agent will read this file before building the Scan screen.


## References

- `references/camera.md` — AVFoundation session, capture, permissions.
- `references/coreml.md` — model loading, inference, error handling.
- `references/vision.md` — VNRecognizeTextRequest, character segmentation.
- `references/preprocessing.md` — grayscale, resize, normalization pipeline.
- `references/privacy.md` — camera usage description, on-device only policy.
- `references/hygiene.md` — clean, maintainable Swift code.