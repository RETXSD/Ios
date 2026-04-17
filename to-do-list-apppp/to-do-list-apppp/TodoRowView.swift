//
//  TodoRowView.swift
//  To-Do List
//

import SwiftUI

// MARK: - Todo Row View

struct TodoRowView: View {
    let item: TodoItem
    let theme: AppTheme
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onTap: () -> Void

    var isOverdue: Bool {
        guard !item.isCompleted else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.startOfDay(for: item.dueDate) < today
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: item.dueDate)
    }

    // Accent color: red for overdue, theme accent for completed, secondary for normal
    var titleColor: Color {
        if isOverdue { return Color(red: 0.9, green: 0.2, blue: 0.2) }
        if item.isCompleted { return theme.secondaryText }
        return theme.cardText
    }

    var dateColor: Color {
        isOverdue ? Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.8) : theme.secondaryText
    }

    var body: some View {
        HStack(spacing: 12) {
            // Checkmark / circle button
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(
                        item.isCompleted ? theme.accent :
                        isOverdue ? Color(red: 0.9, green: 0.2, blue: 0.2) :
                        theme.secondaryText
                    )
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading, spacing: 4) {
                // Task title
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(titleColor)
                    .strikethrough(item.isCompleted, color: theme.secondaryText)

                // Note (if any)
                if !item.note.isEmpty {
                    Text(item.note)
                        .font(.system(size: 12))
                        .foregroundColor(isOverdue ? Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.7) : theme.secondaryText)
                        .lineLimit(1)
                }

                // Due date row
                HStack(spacing: 4) {
                    Image(systemName: isOverdue ? "calendar.badge.exclamationmark" : "calendar")
                        .font(.system(size: 10))
                    Text(formattedDate)
                        .font(.system(size: 11))
                }
                .foregroundColor(dateColor)
                .strikethrough(item.isCompleted, color: theme.secondaryText)

                // Overdue badge
                if isOverdue {
                    Label("Out of schedule", systemImage: "clock.badge.exclamationmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(red: 0.9, green: 0.2, blue: 0.2))
                        .cornerRadius(6)
                }
            }

            Spacer()

            // Trash button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 18))
                    .foregroundColor(Color.red.opacity(0.8))
                    .padding(8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            isOverdue
                ? Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.07)
                : theme.cardBackground
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isOverdue ? Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.4) : theme.accent.opacity(0.2),
                    lineWidth: isOverdue ? 1 : 0.5
                )
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
