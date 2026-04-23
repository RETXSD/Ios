//
//  TodoDetailView.swift
//  To-Do List
//

import SwiftUI

// MARK: - Todo Detail View

struct TodoDetailView: View {
    @Binding var item: TodoItem
    let theme: AppTheme
    let onSave: (UUID, String, String, Date) -> Void
    let onToggle: (UUID) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var editingTitle: String = ""
    @State private var editingNote: String = ""
    @State private var editingDate: Date = Date()
    @State private var isEditing: Bool = false

    var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Navigation bar
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Back")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(theme.accent)
                    }
                    Spacer()
                    if isEditing {
                        Button(action: saveEdits) {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(theme.accent)
                        }
                    } else {
                        Button(action: {
                            editingTitle = item.title
                            editingNote = item.note
                            editingDate = item.dueDate
                            isEditing = true
                        }) {
                            Text("Edit")
                                .font(.system(size: 16))
                                .foregroundColor(theme.accent)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Status card
                        HStack(spacing: 14) {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 32))
                                .foregroundColor(item.isCompleted ? theme.accent : theme.secondaryText)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.isCompleted ? "Completed" : "In Progress")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(item.isCompleted ? theme.accent : theme.secondaryText)
                                Text(dateFormatter.string(from: item.createdAt))
                                    .font(.system(size: 11))
                                    .foregroundColor(theme.secondaryText.opacity(0.7))
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(theme.cardBackground)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(theme.accent.opacity(0.2), lineWidth: 0.5)
                        )

                        // Title section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 12))
                                .foregroundColor(theme.secondaryText)

                            if isEditing {
                                TextField("Task title", text: $editingTitle)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(theme.exprText)
                                    .padding(14)
                                    .background(theme.exprBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(theme.accent.opacity(0.5), lineWidth: 1)
                                    )
                            } else {
                                Text(item.title)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(item.isCompleted ? theme.secondaryText : theme.cardText)
                                    .strikethrough(item.isCompleted, color: theme.secondaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .background(theme.exprBackground)
                                    .cornerRadius(12)
                            }
                        }

                        // Note section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Note")
                                .font(.system(size: 12))
                                .foregroundColor(theme.secondaryText)

                            if isEditing {
                                TextField("Add a note...", text: $editingNote, axis: .vertical)
                                    .font(.system(size: 15))
                                    .foregroundColor(theme.exprText)
                                    .lineLimit(4...8)
                                    .padding(14)
                                    .background(theme.exprBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(theme.accent.opacity(0.3), lineWidth: 0.5)
                                    )
                            } else {
                                Text(item.note.isEmpty ? "No note added." : item.note)
                                    .font(.system(size: 15))
                                    .foregroundColor(item.note.isEmpty ? theme.secondaryText.opacity(0.5) : theme.cardText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .background(theme.exprBackground)
                                    .cornerRadius(12)
                            }
                        }

                        // Due date section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Due Date")
                                .font(.system(size: 12))
                                .foregroundColor(theme.secondaryText)

                            if isEditing {
                                DatePicker("Select Date", selection: $editingDate, displayedComponents: [.date, .hourAndMinute])
                                    .font(.system(size: 15))
                                    .foregroundColor(theme.cardText)
                                    .tint(theme.accent)
                                    .padding(14)
                                    .background(theme.exprBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(theme.accent.opacity(0.3), lineWidth: 0.5)
                                    )
                            } else {
                                Text(dateFormatter.string(from: item.dueDate))
                                    .font(.system(size: 15))
                                    .foregroundColor(theme.cardText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .background(theme.exprBackground)
                                    .cornerRadius(12)
                            }
                        }

                        // Action buttons (view mode only)
                        if !isEditing {
                            Button(action: {
                                onToggle(item.id)
                            }) {
                                HStack {
                                    Image(systemName: item.isCompleted ? "arrow.uturn.backward.circle" : "checkmark.circle")
                                        .font(.system(size: 16))
                                    Text(item.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(item.isCompleted ? theme.secondaryText : theme.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(theme.buttonBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke((item.isCompleted ? theme.secondaryText : theme.accent).opacity(0.3), lineWidth: 0.5)
                                )
                            }

                            Button(action: {
                                onDelete()
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                    Text("Delete Task")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.2))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(theme.buttonBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.9, green: 0.3, blue: 0.2).opacity(0.3), lineWidth: 0.5)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Private Methods

    private func saveEdits() {
        let trimmed = editingTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let trimmedNote = editingNote.trimmingCharacters(in: .whitespacesAndNewlines)
        item.title = trimmed
        item.note = trimmedNote
        item.dueDate = editingDate
        onSave(item.id, trimmed, trimmedNote, editingDate)
        isEditing = false
    }
}
