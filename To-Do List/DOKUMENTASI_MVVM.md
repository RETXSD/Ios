# 📋 MVVM Architecture Documentation — To-Do List App

> This document explains the file structure, SwiftUI property wrappers, and data flow for every user interaction in the To-Do List application.

---

## 📁 1. File Roles

| File | Layer | Purpose |
|------|-------|---------|
| `TodoItem.swift` | **Model** | Defines the data structure of a single task (id, title, note, dueDate, isCompleted) |
| `AppTheme.swift` | **Theme** | Defines the `AppTheme` struct and the `themes` array containing 5 color themes |
| `TodoViewModel.swift` | **ViewModel** | Holds all app state and business logic (add, delete, toggle, filter) |
| `ContentView.swift` | **View (Root)** | UI entry point; owns the ViewModel and delegates all rendering to `TodoListView` |
| `TodoListView.swift` | **View (Child)** | Renders the entire main screen (header, list, filters, progress bar); receives the ViewModel from its parent |
| `TodoRowView.swift` | **View (Component)** | Renders a single task row inside the list |
| `AddTodoSheet.swift` | **View (Sheet)** | A bottom sheet form for adding a new task |
| `TodoDetailView.swift` | **View (Detail)** | Detail and edit screen for an existing task |
| `SupportingViews.swift` | **View (Helper)** | Small reusable components: `GroupHeaderView` (date section header) and `FilterChip` (filter toggle button) |
| `To_Do_ListApp.swift` | **App Entry** | Application entry point; launches `ContentView` inside a `WindowGroup` |

---

## 🔑 2. Property Wrappers Explained

### `ObservableObject` — in `TodoViewModel`

```swift
class TodoViewModel: ObservableObject { ... }
```

- **What it is:** A protocol that marks this class as an observable source of truth that SwiftUI Views can subscribe to.
- **Why a class, not a struct:** `ObservableObject` requires a reference type so that all views observing the same instance receive updates when it changes.

---

### `@Published` — in `TodoViewModel`

```swift
@Published var todos: [TodoItem] = []
@Published var filterCompleted: Bool = false
@Published var selectedThemeIndex: Int = 0
@Published var showAddSheet: Bool = false
@Published var showThemePicker: Bool = false
```

- **What it is:** A property wrapper that automatically notifies all observers whenever the value changes.
- **Effect:** Any time a `@Published` property changes, every View observing this ViewModel will automatically re-render.

---

### `@StateObject` — in `ContentView`

```swift
@StateObject private var viewModel = TodoViewModel()
```

- **What it is:** Used to **create and own** a ViewModel instance.
- **Characteristics:**
  - The instance is created **once** when `ContentView` first appears.
  - The instance is **not reset** even if `ContentView` re-renders.
  - Only use this in the view that **first initializes** the ViewModel.
- **Analogy:** `@StateObject` is the homeowner — the one who buys and maintains the house.

---

### `@ObservedObject` — in `TodoListView`

```swift
@ObservedObject var viewModel: TodoViewModel
```

- **What it is:** Used to **receive and observe** a ViewModel that was created by a parent view.
- **Characteristics:**
  - Does not create a new instance — receives one injected from outside.
  - Auto re-renders when any `@Published` property in the ViewModel changes.
  - If the View is re-initialized, the reference can change.
- **Analogy:** `@ObservedObject` is the tenant — occupies the house but doesn't own it.

---

### `@State` — in local Views

```swift
// AddTodoSheet.swift
@State private var title: String = ""
@State private var note: String = ""
@State private var dueDate: Date = Date()

// TodoDetailView.swift
@State private var editingTitle: String = ""
@State private var editingNote: String = ""
@State private var editingDate: Date = Date()
@State private var isEditing: Bool = false
```

- **What it is:** Local state owned by a single View — no need to share it with other views.
- **Characteristics:**
  - Reset every time the View is destroyed and recreated.
  - Best for temporary UI data (e.g., TextField content before submission).
- **When to use:** When data is only needed within one view and does not need to be stored in the ViewModel.

---

### `@Binding` — in child views that need two-way communication

```swift
// AddTodoSheet.swift
@Binding var isPresented: Bool

// TodoDetailView.swift
@Binding var item: TodoItem
```

- **What it is:** A two-way reference to state owned by a parent view. The child can **read and write** the parent's value.
- **How it's created:** The parent passes it with the `$` prefix → `$viewModel.showAddSheet`, `$viewModel.todos[idx]`
- **Characteristics:**
  - Does not own the data — it points to the parent's data.
  - Changes from the child are immediately reflected in the parent (and vice versa).
- **Analogy:** Like a TV remote — not the TV itself, but can control it (data lives in the parent).

---

### `@FocusState` — in `AddTodoSheet`

```swift
@FocusState private var titleFocused: Bool
```

- **What it is:** Manages and reads the keyboard focus state of a TextField.
- **Usage:** When the sheet appears, the keyboard automatically pops up because `titleFocused = true` is set in `.onAppear`.

---

### `@Environment(\.dismiss)` — in `TodoDetailView`

```swift
@Environment(\.dismiss) private var dismiss
```

- **What it is:** Pulls the `dismiss` function from SwiftUI's environment to programmatically close the current view.
- **Usage:** Called when the user taps the "Back" button or after a task is deleted.

---

## 🔄 3. Data Flow Per Feature

### ➕ Add Task (FAB Button)

```
User taps the "+" floating button (FAB in TodoListView)
    │
    ▼
viewModel.showAddSheet = true                       [TodoListView]
    │
    ▼
.sheet(isPresented: $viewModel.showAddSheet) fires  [ContentView]
    │
    ▼
AddTodoSheet appears
    │
    ▼ User fills in Title, Note, Due Date
    │   @State private var title, note, dueDate     [AddTodoSheet — local only]
    │
    ▼ User taps "Add Task"
    │
    ▼
onAdd(trimmed, note, dueDate) callback is called    [AddTodoSheet]
    │
    ▼
viewModel.addTodo(title:note:dueDate:)              [TodoViewModel]
    │   → New TodoItem is created
    │   → todos.append(item)
    │   → todos.sort by dueDate
    │   → @Published todos changes ✅
    │
    ▼
isPresented = false → sheet is dismissed
    │
    ▼
TodoListView & ContentView automatically re-render
(because @ObservedObject / @StateObject detect the @Published change)
```

---

### ☑️ Toggle Task Complete/Incomplete (Checkmark in Row)

```
User taps the checkmark button in TodoRowView
    │
    ▼
onToggle() closure is called                        [TodoRowView]
    │
    ▼
viewModel.toggleTodo(id: item.id)                   [TodoListView → TodoViewModel]
    │
    ▼
func toggleTodo(id:) {
    todos[idx].isCompleted.toggle()                 [TodoViewModel]
    @Published todos changes ✅
}
    │
    ▼
TodoListView re-renders → row shows new checkmark / strikethrough state
Progress bar also updates automatically (completedCount recomputed)
```

---

### 🗑️ Delete Task (from Row / Swipe)

```
User taps the trash icon in TodoRowView OR swipes left
    │
    ▼
onDelete() closure is called                        [TodoRowView]
    │
    ▼
viewModel.deleteTodo(id: item.id)                   [TodoListView → TodoViewModel]
    │
    ▼
func deleteTodo(id:) {
    todos.removeAll { $0.id == id }                 [TodoViewModel]
    withAnimation → smooth removal
    @Published todos changes ✅
}
    │
    ▼
TodoListView re-renders → item is removed from the list
```

---

### 🔍 Delete Task (from Detail View)

```
User taps "Delete Task" in TodoDetailView
    │
    ▼
onDelete() closure is called                        [TodoDetailView]
    │
    ▼ (onDelete was passed from TodoListView when opening the NavigationLink)
viewModel.deleteTodo(id: todos[idx].id)             [TodoViewModel]
    │
    ▼
dismiss() is called → navigates back to main screen [TodoDetailView]
    │
    ▼
@Published todos changes → list updates ✅
```

---

### ✏️ Edit Task (in Detail View)

```
User taps "Edit" in TodoDetailView
    │
    ▼
isEditing = true                                    [@State local in TodoDetailView]
editingTitle = item.title                           (copy current values into @State)
editingNote  = item.note
editingDate  = item.dueDate
    │
    ▼ User changes TextField / DatePicker
    │   → editingTitle, editingNote, editingDate update  [@State local]
    │
    ▼ User taps "Save"
    │
    ▼
saveEdits() is called                               [TodoDetailView]
    │
    ▼
item.title   = trimmed    ← item is a @Binding into viewModel.todos[idx]
item.note    = ...
item.dueDate = ...
    │
    ▼
Writing to @Binding directly mutates viewModel.todos[idx]
    │
    ▼
@Published todos changes → all observers re-render ✅
isEditing = false → returns to view mode
```

---

### 🎨 Change Theme

```
User taps the 🎨 icon in the header
    │
    ▼
viewModel.showThemePicker.toggle()                  [TodoListView → TodoViewModel]
    │
    ▼
@Published showThemePicker = true → theme picker row appears
    │
    ▼ User taps a theme name (e.g., "Ocean")
    │
    ▼
viewModel.selectedThemeIndex = i                    [TodoViewModel]
viewModel.showThemePicker    = false
    │
    ▼
@Published changes → entire UI re-renders with new theme
(theme = themes[selectedThemeIndex] is recomputed)
```

---

### 🔽 Filter All / Done

```
User taps the "Done" or "All" chip
    │
    ▼
viewModel.filterCompleted = true / false            [TodoListView → TodoViewModel]
    │
    ▼
@Published filterCompleted changes
    │
    ▼
var filteredTodos: [TodoItem] recomputed            [TodoViewModel — computed property]
    return filterCompleted
        ? todos.filter { $0.isCompleted }
        : todos
    │
    ▼
todoList re-renders with filtered data ✅
```

---

## 🗺️ 4. Overall Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        TodoViewModel                            │
│  @Published todos            ← main data source                │
│  @Published showAddSheet     ← controls sheet visibility       │
│  @Published filterCompleted  ← controls list filter            │
│  @Published selectedThemeIndex ← controls active theme         │
│                                                                 │
│  func addTodo()    ← appends a new TodoItem                    │
│  func deleteTodo() ← removes an item by id                     │
│  func toggleTodo() ← flips isCompleted on an item              │
│  func updateTodo() ← updates title, note, dueDate              │
└────────────┬────────────────────────────────────────────────────┘
             │ @StateObject (OWNER)
             ▼
┌─────────────────────┐
│    ContentView      │  ← Root View, coordinates sheet + nav
│  @StateObject VM    │  → opens .sheet AddTodoSheet
└────────┬────────────┘
         │ passes viewModel
         │ @ObservedObject (RECEIVER)
         ▼
┌─────────────────────┐
│    TodoListView     │  ← Main screen, observes ViewModel
│  @ObservedObject VM │  → renders list, header, filters
└────────┬────────────┘
         │ passes data + closures
         ├──────────────────────────────────┐
         ▼                                  ▼
┌────────────────┐                ┌──────────────────────┐
│  TodoRowView   │                │   TodoDetailView      │
│  item, theme   │                │  @Binding item        │
│  onToggle()    │                │  @State isEditing     │
│  onDelete()    │                │  onDelete() closure   │
└────────────────┘                └──────────────────────┘

┌─────────────────────┐
│    AddTodoSheet     │  ← opened by ContentView (.sheet)
│  @Binding isPresented│
│  @State title, note │  ← temporary local form data
│  onAdd() closure    │  → calls viewModel.addTodo()
└─────────────────────┘
```

---

## 📌 5. Quick Reference — When to Use Which Wrapper

| Scenario | Use | Example in this project |
|----------|-----|------------------------|
| Create and own a ViewModel | `@StateObject` | `ContentView` |
| Receive a ViewModel from parent | `@ObservedObject` | `TodoListView` |
| Mark a class as observable | `ObservableObject` | `TodoViewModel` |
| Auto-notify views on change | `@Published` | `todos`, `showAddSheet` |
| Temporary local state in one view | `@State` | `title` in `AddTodoSheet` |
| Two-way reference to parent's data | `@Binding` | `item` in `TodoDetailView` |
| Control keyboard focus | `@FocusState` | `titleFocused` in `AddTodoSheet` |
| Access SwiftUI environment values | `@Environment` | `dismiss` in `TodoDetailView` |

---

## 💾 6. TodoPersistenceService — Data Flow & Mechanics

### Role in the Architecture

`TodoPersistenceService` is a **Service layer** that sits between the ViewModel and the file system. It has one responsibility: reading and writing `[TodoItem]` as a JSON file on disk. The ViewModel owns an instance of it and calls it — but the Views never touch it directly.

```
┌─────────────┐        ┌──────────────────────┐        ┌───────────────┐
│    Views    │  --->  │    TodoViewModel      │  --->  │ Persistence   │
│ (SwiftUI)   │        │  @Published todos     │        │  Service      │
│             │  <---  │  didSet → save()      │  --->  │  todos.json   │
└─────────────┘        │  init() → load()      │  <---  └───────────────┘
                       └──────────────────────┘
```

---

### File Location

```swift
private var fileURL: URL {
    FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("todos.json")
}
```

The JSON file is stored in the app's **Documents directory** — a private sandbox folder on the device. This folder:
- Persists across app launches ✅
- Survives app updates ✅
- Is deleted only when the app is uninstalled ✅
- Is not accessible to other apps ✅

**Example path on Simulator:**
```
/Users/<you>/Library/Developer/CoreSimulator/Devices/<id>/
    data/Containers/Data/Application/<app-id>/Documents/todos.json
```

---

### How `save()` Works

```swift
func save(_ todos: [TodoItem]) {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(todos)
    try data.write(to: fileURL, options: .atomic)
}
```

**Step-by-step:**

```
[TodoItem] array in memory
    │
    ▼
JSONEncoder.encode(todos)
    │   → Each TodoItem is serialized field by field
    │   → UUID  → string  (e.g. "3F2504E0-4F89-11D3-9A0C-0305E82C3301")
    │   → Date  → ISO-8601 string (e.g. "2026-04-10T09:00:00Z")
    │   → String, Bool → native JSON types
    │
    ▼
Data (raw bytes of JSON text)
    │
    ▼
data.write(to: fileURL, options: .atomic)
    │   → .atomic writes to a temp file first, then renames it
    │   → Prevents file corruption if the app crashes mid-write
    │
    ▼
todos.json written to Documents directory ✅
```

**Example output in `todos.json`:**
```json
[
  {
    "id": "3F2504E0-4F89-11D3-9A0C-0305E82C3301",
    "title": "Buy groceries",
    "note": "Milk, eggs, bread",
    "isCompleted": false,
    "createdAt": "2026-04-10T01:30:00Z",
    "dueDate": "2026-04-10T09:00:00Z"
  },
  {
    "id": "7A8B9C0D-1E2F-3A4B-5C6D-7E8F9A0B1C2D",
    "title": "Submit assignment",
    "note": "",
    "isCompleted": true,
    "createdAt": "2026-04-09T20:00:00Z",
    "dueDate": "2026-04-11T23:59:00Z"
  }
]
```

---

### How `load()` Works

```swift
func load() -> [TodoItem] {
    guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
    let data = try Data(contentsOf: fileURL)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode([TodoItem].self, from: data)
}
```

**Step-by-step:**

```
App launches → TodoViewModel.init() calls persistence.load()
    │
    ▼
FileManager.fileExists(atPath:)
    │
    ├── File NOT found (first launch ever)
    │       └── return []   →  todos starts empty ✅
    │
    └── File found
            │
            ▼
        Data(contentsOf: fileURL)
            │   → Reads raw bytes from todos.json
            │
            ▼
        JSONDecoder.decode([TodoItem].self, from: data)
            │   → Each JSON object is mapped back to a TodoItem struct
            │   → ISO-8601 strings → Date objects
            │   → UUID strings → UUID objects
            │
            ▼
        [TodoItem] array returned → assigned to viewModel.todos ✅
            │
            ▼
        SwiftUI re-renders the list with restored data ✅
```

---

### How `save()` Is Triggered — The `didSet` Hook

The key design decision: `save()` is never called manually inside `addTodo()`, `deleteTodo()`, etc. Instead, the `todos` property in `TodoViewModel` uses `didSet`:

```swift
@Published var todos: [TodoItem] = [] {
    didSet {
        persistence.save(todos)   // ← fires automatically on every change
    }
}
```

**This means `save()` is triggered by ANY of these actions:**

| User Action | Function Called | didSet fires? |
|-------------|----------------|---------------|
| Add a task | `addTodo()` | ✅ Yes |
| Delete a task | `deleteTodo()` | ✅ Yes |
| Toggle complete | `toggleTodo()` | ✅ Yes |
| Edit & save | `updateTodo()` / `@Binding` write | ✅ Yes |

---

### Complete Data Flow — Save (Write)

```
User performs any action (add / delete / toggle / edit)
    │
    ▼
TodoViewModel mutates todos array
    │
    ▼
didSet fires on @Published var todos
    │
    ▼
persistence.save(todos) called             [TodoPersistenceService]
    │
    ▼
JSONEncoder encodes [TodoItem] → Data
    │
    ▼
data.write(to: fileURL, .atomic)
    │
    ▼
todos.json updated on disk ✅
```

---

### Complete Data Flow — Load (Read)

```
App launches (cold start or from background)
    │
    ▼
To_Do_ListApp creates ContentView
    │
    ▼
ContentView initializes @StateObject TodoViewModel()
    │
    ▼
TodoViewModel.init() runs
    │
    ▼
persistence.load() called                  [TodoPersistenceService]
    │
    ├── todos.json does NOT exist
    │       └── return []
    │               └── todos = []  →  empty list shown ✅
    │
    └── todos.json exists
            │
            ▼
        Data(contentsOf: fileURL) reads file
            │
            ▼
        JSONDecoder decodes → [TodoItem]
            │
            ▼
        todos = decoded array
            │
            ▼
        @Published todos changes → UI renders with saved data ✅
```

---

### Why `Codable` on `TodoItem`?

```swift
struct TodoItem: Identifiable, Codable { ... }
```

`Codable` = `Encodable + Decodable`. Adding it tells Swift to auto-generate JSON encoding/decoding logic for all properties. Since every property type is already natively `Codable` (`UUID`, `String`, `Bool`, `Date`), **no manual encode/decode code is needed**.

| Property | Swift Type | JSON Representation |
|----------|-----------|---------------------|
| `id` | `UUID` | `"3F2504E0-..."` (string) |
| `title` | `String` | `"Buy groceries"` |
| `note` | `String` | `"Milk, eggs"` |
| `isCompleted` | `Bool` | `true` / `false` |
| `createdAt` | `Date` | `"2026-04-10T01:30:00Z"` |
| `dueDate` | `Date` | `"2026-04-10T09:00:00Z"` |

---

*Created for academic purposes — MVVM Architecture with SwiftUI*
