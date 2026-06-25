# Views Reference — SwiftUI Structure & Composition

Used by: uiux-agent

## File Structure

One view per file. Never combine multiple screens in one file.

```
Views/
├── Onboarding/
│   ├── SplashView.swift
│   └── OnboardingView.swift
├── Home/
│   └── HomeView.swift
├── Lesson/
│   ├── LessonGridView.swift
│   ├── LessonDetailView.swift
│   ├── FlashcardView.swift
│   └── ExamView.swift
├── Scan/
│   └── ScanView.swift
├── Dictionary/
│   └── DictionaryView.swift
├── AIAssistant/
│   └── AIAssistantView.swift
├── Profile/
│   └── ProfileView.swift
Components/
├── AppButton.swift
├── AppCard.swift
├── AppBadge.swift
├── ProgressBar.swift
├── CharacterDisplay.swift
├── ConfidenceBadge.swift
├── AudioButton.swift
└── LockedOverlay.swift
```

## View Composition Rules

```swift
// CORRECT — view delegates to ViewModel
struct HomeView: View {
    @StateObject private var vm = HomeViewModel()

    var body: some View {
        LessonGridView(lessons: vm.lessons)
            .onAppear { vm.loadLessons() }
    }
}

// WRONG — business logic in view
struct HomeView: View {
    var body: some View {
        // Never compute lesson unlock state here
        // Never call CoreML here
        // Never call AVSpeechSynthesizer here
    }
}
```

## Flashcard Flip Animation

```swift
struct FlashcardView: View {
    @State private var isFlipped = false
    @State private var rotation = 0.0

    var body: some View {
        ZStack {
            if isFlipped {
                CardBack(character: character)
                    .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            } else {
                CardFront(character: character)
                    .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            }
        }
        .onTapGesture { flip() }
    }

    func flip() {
        withAnimation(.easeInOut(duration: 0.3)) {
            rotation += 180
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isFlipped.toggle()
        }
    }
}
```

Disable animation when Reduce Motion is on:
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

func flip() {
    if reduceMotion {
        isFlipped.toggle()
    } else {
        withAnimation(.easeInOut(duration: 0.3)) { rotation += 180 }
    }
}
```

## Locked State Overlay

```swift
struct LockedOverlay: View {
    var body: some View {
        ZStack {
            Color.sumiInk.opacity(0.6)
            VStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.washiWhite)
                Text("Selesaikan ujian dulu")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.washiWhite)
            }
        }
        .cornerRadius(7)
    }
}
```

## Character Display

```swift
struct CharacterDisplay: View {
    let character: String
    var fontSize: CGFloat = 60

    var body: some View {
        Text(character)
            .font(.custom("HiraMinProN-W3", size: fontSize))  // serif Japanese font
            .foregroundColor(Color.toriiRed)
            .accessibilityLabel(character)
            .accessibilityValue("Japanese character")
    }
}
```

## Rules

- Never write business logic, API calls, or ML calls inside a View
- Always use `@StateObject` for ViewModels owned by a view, `@ObservedObject` for injected ones
- Always check `accessibilityReduceMotion` before playing animations
- Every screen must handle: loading state, empty state, error state
- Never use `GeometryReader` unless absolutely necessary for layout
