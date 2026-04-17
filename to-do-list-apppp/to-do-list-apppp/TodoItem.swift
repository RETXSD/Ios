//
//  TodoItem.swift
//  To-Do List
//

import Foundation
import FirebaseFirestoreSwift

// MARK: - Model

struct TodoItem: Identifiable, Codable {
    var id: UUID
    var title: String
    var note: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date
    /// Timestamp of when the task was marked complete.
    /// nil means the task is not completed (or was uncompleted).
    var completedAt: Date?

    init(id: UUID = UUID(), title: String, note: String = "", isCompleted: Bool = false, dueDate: Date = Date()) {
        self.id = id
        self.title = title
        self.note = note
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.dueDate = dueDate
        self.completedAt = nil
    }
}
