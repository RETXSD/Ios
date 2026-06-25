# UI Reference — Screen Inventory & Flow for QA

Used by: qa-agent

## Screen Inventory

| Screen | File | Purpose |
|---|---|---|
| Splash | SplashView.swift | App launch, logo animation |
| Onboarding | OnboardingView.swift | Level selection, camera permission prompt |
| Home | HomeView.swift | Lesson grid N5–N1, XP bar, streak |
| Lesson Detail | LessonDetailView.swift | Flashcard stack for selected level |
| Exam | ExamView.swift | Quiz to unlock next level |
| Scan | ScanView.swift | Camera + result overlay |
| Dictionary | DictionaryView.swift | Search + results list |
| AI Assistant | AIAssistantView.swift | Chat interface |
| Profile | ProfileView.swift | XP, stats, level history |

## Critical User Flows

### Flow 1 — Lesson & Unlock
```
Home → tap N5 card (unlocked) → LessonDetail
→ swipe through flashcards → tap "Mulai Ujian"
→ ExamView → answer all questions → pass (score ≥ 70%)
→ UnlockCelebration sheet → N4 now unlocked on Home
```

### Flow 2 — Scan Character
```
Scan tab → ScanView opens → camera permission requested (first time)
→ mode = "Huruf" (default) → frame character → tap capture button
→ processing indicator → result overlay appears:
  character display + confidence badge + pronunciation button
→ tap 🔊 → audio plays
```

### Flow 3 — Scan Sentence
```
ScanView → toggle mode to "Kalimat"
→ frame handwritten sentence → tap capture
→ processing → result overlay: full sentence + meaning
→ tap 🔊 → audio reads full sentence
```

### Flow 4 — Dictionary Lookup
```
Kamus tab → DictionaryView → search bar focused
→ type "hand" → results appear:
  手 (te) · hand · N4 · audio button
→ tap 🔊 → pronunciation plays
→ tap result → detail: character + furigana + meaning + examples
```

### Flow 5 — AI Assistant
```
AI Chat tab → AIAssistantView → input field
→ type "て means what?" → send
→ AI response appears in chat bubble with Japanese characters
→ conversation continues (history maintained)
```

## Edge Cases to Test

| Screen | Edge Case | Expected Behavior |
|---|---|---|
| Home | All levels locked except N5 | N5 card tappable, N4–N1 show locked overlay + tooltip on tap |
| Lesson | Last flashcard reached | Show "Mulai Ujian" button, not next card |
| Exam | Score < 70% | Show fail state, "Coba Lagi" button, do NOT unlock next level |
| Scan | Camera permission denied | Show permission denied state with settings deep link |
| Scan | Low confidence result | Show red badge + "Coba lagi" message |
| Scan | No character detected | Show "Tidak ada huruf terdeteksi" empty state |
| Dictionary | Search returns no result | Show empty state: "Tidak ditemukan. Coba kata lain." |
| AI Chat | No internet | Show error: "Koneksi bermasalah. Coba lagi." |
| AI Chat | Very long message | Chat bubble wraps, does not overflow screen |

## Component Parameters

```swift
AppButton(title: String, style: .primary | .secondary | .gold | .ghost, action: () -> Void)
AppCard(content: () -> View)
AppBadge(text: String, style: .red | .ink | .soft | .gold | .cream)
ProgressBar(value: Double)  // 0.0 – 1.0
CharacterDisplay(character: String, fontSize: CGFloat = 60)
ConfidenceBadge(value: Float)  // shows color + percentage
AudioButton(action: () -> Void)
LockedOverlay()
```
