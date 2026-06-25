# Navigation Reference — NavigationStack & Tab Bar

Used by: uiux-agent

## App Structure

```
TabView (bottom tab)
├── Tab 1: Lessons (学)
│   └── NavigationStack
│       ├── HomeView (lesson grid N5–N1)
│       ├── LessonDetailView (flashcard stack)
│       └── ExamView (unlock test)
├── Tab 2: Scan (📷)
│   └── NavigationStack
│       └── ScanView (camera + result)
├── Tab 3: Kamus (辞)
│   └── NavigationStack
│       └── DictionaryView (search + results)
└── Tab 4: AI Chat (🤖)
    └── NavigationStack
        └── AIAssistantView (chat UI)
```

## TabView Setup

```swift
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            LessonsTab()
                .tabItem { Label("Lessons", systemImage: "book.fill") }
                .tag(0)
            ScanTab()
                .tabItem { Label("Scan", systemImage: "camera.fill") }
                .tag(1)
            DictionaryTab()
                .tabItem { Label("Kamus", systemImage: "text.book.closed.fill") }
                .tag(2)
            AIAssistantTab()
                .tabItem { Label("AI Chat", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(3)
        }
        .accentColor(Color.toriiRed)
    }
}
```

## NavigationStack — Lesson Flow

```swift
// Root
NavigationStack {
    HomeView()
        .navigationTitle("KanaLearn")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Lesson.self) { lesson in
            LessonDetailView(lesson: lesson)
        }
        .navigationDestination(for: ExamDestination.self) { dest in
            ExamView(lesson: dest.lesson)
        }
}

// Card tap
NavigationLink(value: lesson) {
    LessonCard(lesson: lesson)
}
```

## Locked Card — No NavigationLink

```swift
// CORRECT — locked card uses tap gesture, not NavigationLink
struct LessonCard: View {
    let lesson: Lesson

    var body: some View {
        AppCard {
            CharacterDisplay(character: lesson.previewChar)
        }
        .overlay { if lesson.isLocked { LockedOverlay() } }
        .onTapGesture {
            if lesson.isLocked {
                showLockedTooltip = true
            }
        }
    }
}
```

## Unlock Sheet

```swift
.sheet(isPresented: $showUnlockSheet) {
    UnlockCelebrationView(level: nextLevel)
}
```

## Rules

- Always use `NavigationStack` — never `NavigationView`
- Use `navigationDestination(for:)` — never `NavigationLink(destination:)` deprecated form
- Never nest `NavigationStack` inside `NavigationStack`
- Locked cards must NOT use `NavigationLink`
- Always set `.navigationTitle` on each tab root view
