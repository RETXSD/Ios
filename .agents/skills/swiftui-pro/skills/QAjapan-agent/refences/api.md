# API Reference — Modern SwiftUI APIs

Used by: uiux-agent

## Minimum Target: iOS 16

All APIs must be iOS 16+. Never use deprecated APIs.

## Navigation

```swift
// CORRECT — iOS 16+
NavigationStack { }
.navigationDestination(for: MyType.self) { value in View() }

// WRONG — deprecated
NavigationView { }
NavigationLink(destination: View()) { }
```

## State & Data Flow

```swift
// View owns the ViewModel
@StateObject private var vm = MyViewModel()

// View receives ViewModel from parent
@ObservedObject var vm: MyViewModel

// Simple local state
@State private var isFlipped = false

// Shared app state
@EnvironmentObject var appState: AppState

// Async task on appear
.task {
    await vm.loadData()
}
```

## Async/Await in Views

```swift
// CORRECT — use .task modifier
.task {
    await vm.fetchLessons()
}

// CORRECT — button async action
Button("Scan") {
    Task {
        await vm.startScan()
    }
}

// WRONG — never call async from synchronous context without Task
Button("Scan") {
    await vm.startScan()  // compiler error
}
```

## List & ForEach

```swift
// CORRECT — identifiable items
ForEach(lessons) { lesson in
    LessonCard(lesson: lesson)
}

// CORRECT — with id
ForEach(characters, id: \.self) { char in
    CharacterDisplay(character: char)
}
```

## Sheet & Full Screen Cover

```swift
// Sheet — partial cover
.sheet(isPresented: $showExamResult) {
    ExamResultView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}

// Full screen
.fullScreenCover(isPresented: $showOnboarding) {
    OnboardingView()
}
```

## Searchable

```swift
// Dictionary search bar
NavigationStack {
    DictionaryResultsList(results: vm.results)
        .searchable(text: $vm.searchQuery, prompt: "Cari kata atau huruf...")
        .onChange(of: vm.searchQuery) { _, newValue in
            Task { await vm.search(query: newValue) }
        }
}
```

## Overlay & ZStack

```swift
// CORRECT — overlay for locked state
LessonCard(lesson: lesson)
    .overlay {
        if lesson.isLocked {
            LockedOverlay()
        }
    }

// CORRECT — overlay for scan result
CameraPreview()
    .overlay(alignment: .bottom) {
        if let result = vm.scanResult {
            ScanResultOverlay(result: result)
        }
    }
```

## Observable (iOS 17+) vs ObservableObject

Since minimum target is iOS 16, use `ObservableObject` + `@Published`:

```swift
// CORRECT for iOS 16
class ScanViewModel: ObservableObject {
    @Published var scanResult: ScanResult?
    @Published var isScanning = false
}

// iOS 17+ only — don't use unless target raised
@Observable class ScanViewModel { }
```

## Rules

- Minimum iOS 16 — never use APIs below iOS 16
- Always use `.task` for async work on appear, not `.onAppear` + `Task { }`
- Never use `NavigationView`
- Never use deprecated `NavigationLink(destination:)` form
- Use `@StateObject` for ViewModels owned by the view
- Use `@ObservedObject` for injected ViewModels
