# App Store Reference — Submission Checklist

Used by: qa-agent

## Required Assets

### App Icon
- 1024×1024px PNG, no alpha channel, no rounded corners (Apple adds them)
- Place in `Assets.xcassets/AppIcon.appiconset`
- Design: torii red background, white Japanese character (学 or 日)

### Launch Screen
- Use `LaunchScreen.storyboard` or SwiftUI `LaunchScreen` info.plist key
- Background: tatamiCream (#F5EFE0)
- Centered app logo or character

### Screenshots (required for App Store listing)
- iPhone 6.7" — 1290×2796px (iPhone 15 Pro Max)
- iPhone 6.5" — 1242×2688px (iPhone 11 Pro Max)
- Minimum 3 screenshots, maximum 10
- Suggested screens: Home, Scan result, Dictionary, AI Chat

## Info.plist Required Keys

```xml
<key>NSCameraUsageDescription</key>
<string>KanaLearn membutuhkan kamera untuk mendeteksi huruf Jepang dari tulisan tangan Anda.</string>

<key>CFBundleDisplayName</key>
<string>KanaLearn</string>

<key>LSMinimumSystemVersion</key>
<string>16.0</string>

<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
```

## Privacy Manifest (Required iOS 17+)

Create `PrivacyInfo.xcprivacy` in project root:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <key>NSPrivacyAccessedAPITypes</key>
    <array></array>
    <key>NSPrivacyCollectedDataTypes</key>
    <array></array>
    <key>NSPrivacyTracking</key>
    <false/>
</dict>
</plist>
```

## App Store Metadata

```
App Name: KanaLearn
Subtitle: Belajar Huruf Jepang
Category: Education
Secondary Category: Reference

Description (EN):
KanaLearn helps you master Japanese characters — Hiragana, Katakana, and Kanji — 
through structured lessons and real-time handwriting recognition.

Scan your handwritten characters with the camera to get instant feedback,
check your confidence score, and hear native pronunciation.

Features:
• Structured lessons N5 to N1
• Camera-based handwriting detection
• Confidence score for each character
• Built-in Japanese dictionary
• AI language tutor assistant

Keywords: japanese, hiragana, katakana, kanji, learn japanese, JLPT, nihongo
```

## TestFlight Checklist

- [ ] Archive build in Xcode (Product → Archive)
- [ ] Upload to App Store Connect via Xcode Organizer
- [ ] Add TestFlight testers (internal first)
- [ ] Submit for Beta App Review if external testers needed
- [ ] Test on physical device — not just simulator (camera required)

## Pre-Submission QA Checklist

- [ ] No crash on cold launch (test 5x)
- [ ] No crash when camera permission denied
- [ ] No crash when no internet (AI chat graceful error)
- [ ] App icon visible and correct in Settings
- [ ] Launch screen shows without flash of wrong background
- [ ] All 4 tabs load without error
- [ ] Scan works on physical device (camera required)
- [ ] Audio plays for pronunciation
- [ ] No debug print logs visible in console (release build)
- [ ] Memory usage stable after 10 minutes of use

## Rejection Risk Flags

| Risk | Prevention |
|---|---|
| Missing privacy usage description | NSCameraUsageDescription must be present |
| Crash on launch | Test on clean device, no existing app data |
| AI chat with inappropriate content | System prompt restricts to Japanese learning only |
| Low-quality screenshots | Use real device screenshots, not simulator |
