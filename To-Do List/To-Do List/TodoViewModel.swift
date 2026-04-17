//
//  TodoViewModel.swift
//  To-Do List
//

import SwiftUI
import Combine

// MARK: - ViewModel

class TodoViewModel: ObservableObject {
    
    // MARK: - Firebase Service
    @ObservedObject private var firebaseService = FirebaseService()
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Published State
    
    @Published var todos: [TodoItem] = []
    
    @Published var filterCompleted: Bool = false
    @Published var selectedThemeIndex: Int = 0
    @Published var showAddSheet: Bool = false
    @Published var showThemePicker: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Init
    
    init() {
        // Subscribe to Firebase service's todos changes
        firebaseService.$todos
            .receive(on: DispatchQueue.main)
            .assign(to: &$todos)
        
        // Subscribe to loading state
        firebaseService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
        
        // Subscribe to error messages
        firebaseService.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Computed Properties
    
    var theme: AppTheme { themes[selectedThemeIndex] }
    
    var completedCount: Int { todos.filter { $0.isCompleted }.count }
    
    var overdueCount: Int { todos.filter { isOverdue($0) }.count }
    
    var filteredTodos: [TodoItem] {
        let list = filterCompleted ? todos.filter { $0.isCompleted } : todos
        return list.sorted { $0.dueDate < $1.dueDate }
    }
    
    var groupedTodos: [TodoGroup] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // --- Overdue section (only shown in "All" mode) ---
        // Include completed overdue tasks too, so they appear crossed-out
        // instead of disappearing the moment they are checked off.
        let overdueTasks = filterCompleted ? [] : filteredTodos.filter {
            calendar.startOfDay(for: $0.dueDate) < today
        }
        let overdueIDs = Set(overdueTasks.map { $0.id })
        
        // --- Normal tasks: everything except overdue items ---
        let normalTasks = filteredTodos.filter { !overdueIDs.contains($0.id) }
        
        let grouped = Dictionary(grouping: normalTasks) { item in
            calendar.startOfDay(for: item.dueDate)
        }
        
        let sortedKeys = grouped.keys.sorted()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        
        var groups: [TodoGroup] = []
        
        // Overdue group pinned at the top
        if !overdueTasks.isEmpty {
            groups.append(TodoGroup(
                date: .distantPast,
                title: "Overdue",
                items: overdueTasks.sorted { $0.dueDate < $1.dueDate },
                isOverdue: true
            ))
        }
        
        // Date-grouped normal tasks
        for key in sortedKeys {
            let title: String
            if calendar.isDateInToday(key) {
                title = "Today - (\(dateFormatter.string(from: key)))"
            } else if calendar.isDateInTomorrow(key) {
                title = "Tomorrow - (\(dateFormatter.string(from: key)))"
            } else if calendar.isDateInYesterday(key) {
                title = "Yesterday - (\(dateFormatter.string(from: key)))"
            } else {
                title = "\(dayFormatter.string(from: key)) - (\(dateFormatter.string(from: key)))"
            }
            groups.append(TodoGroup(date: key, title: title, items: grouped[key]!, isOverdue: false))
        }
        
        return groups
    }
    
    // MARK: - Overdue Helper
    
    func isOverdue(_ item: TodoItem) -> Bool {
        guard !item.isCompleted else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.startOfDay(for: item.dueDate) < today
    }
    
    // MARK: - Actions
    
    func addTodo(title: String, note: String, dueDate: Date) {
        Task {
            do {
                try await firebaseService.addTodo(title: title, note: note, dueDate: dueDate)
            } catch {
                errorMessage = "Failed to add todo: \(error.localizedDescription)"
                print("❌ Error adding todo: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteTodo(id: UUID) {
        Task {
            do {
                try await firebaseService.deleteTodo(id: id)
            } catch {
                errorMessage = "Failed to delete todo: \(error.localizedDescription)"
                print("❌ Error deleting todo: \(error.localizedDescription)")
            }
        }
    }
    
    func toggleTodo(id: UUID) {
        guard let todo = todos.first(where: { $0.id == id }) else { return }
        let newCompletionStatus = !todo.isCompleted
        
        Task {
            do {
                try await firebaseService.toggleTodo(id: id, isCompleted: newCompletionStatus)
            } catch {
                errorMessage = "Failed to toggle todo: \(error.localizedDescription)"
                print("❌ Error toggling todo: \(error.localizedDescription)")
            }
        }
    }
    
    func updateTodo(id: UUID, title: String, note: String, dueDate: Date) {
        Task {
            do {
                try await firebaseService.updateTodo(id: id, title: title, note: note, dueDate: dueDate)
            } catch {
                errorMessage = "Failed to update todo: \(error.localizedDescription)"
                print("❌ Error updating todo: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Supporting Types

extension TodoViewModel {
    struct TodoGroup: Identifiable {
        var id: Date { date }
        let date: Date
        let title: String
        let items: [TodoItem]
        var isOverdue: Bool = false
    }
}
