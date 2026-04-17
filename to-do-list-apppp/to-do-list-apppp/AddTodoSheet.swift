//
//  AddTodoSheet.swift
//  To-Do List
//

import SwiftUI

// MARK: - Add Todo Sheet

struct AddTodoSheet: View {
    @Binding var isPresented: Bool
    let theme: AppTheme
    let onAdd: (String, String, Date) -> Void

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var dueDate: Date = Date()
    @FocusState private var titleFocused: Bool

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Sheet handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(theme.secondaryText.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                HStack {
                    Text("New Task")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(theme.cardText)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.secondaryText)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

                // Title field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.system(size: 12))
                        .foregroundColor(theme.secondaryText)
                        .padding(.horizontal, 20)

                    TextField("What needs to be done?", text: $title)
                        .font(.system(size: 16))
                        .foregroundColor(theme.exprText)
                        .padding(14)
                        .background(theme.exprBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.accent.opacity(title.isEmpty ? 0.2 : 0.6), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .focused($titleFocused)
                }
                .padding(.bottom, 16)

                // Note field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Note (optional)")
                        .font(.system(size: 12))
                        .foregroundColor(theme.secondaryText)
                        .padding(.horizontal, 20)

                    TextField("Add a note...", text: $note)
                        .font(.system(size: 15))
                        .foregroundColor(theme.exprText)
                        .padding(14)
                        .background(theme.exprBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(theme.secondaryText.opacity(0.2), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 16)

                // Due date picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Date")
                        .font(.system(size: 12))
                        .foregroundColor(theme.secondaryText)
                        .padding(.horizontal, 20)

                    HStack {
                        DatePicker("Select Date & Time", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .font(.system(size: 15))
                            .foregroundColor(theme.cardText)
                            .tint(theme.accent)
                    }
                    .padding(14)
                    .background(theme.exprBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.secondaryText.opacity(0.2), lineWidth: 0.5)
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 32)

                // Add button
                Button(action: {
                    let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onAdd(trimmed, note.trimmingCharacters(in: .whitespacesAndNewlines), dueDate)
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Task")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? theme.secondaryText : theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? theme.buttonBackground
                            : theme.accent
                    )
                    .cornerRadius(14)
                }
                .padding(.horizontal, 20)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
        }
        .onAppear { titleFocused = true }
    }
}
