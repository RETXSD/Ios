//
//  SupportingViews.swift
//  To-Do List
//

import SwiftUI

// MARK: - Group Header View

struct GroupHeaderView: View {
    let title: String
    let theme: AppTheme
    var isOverdue: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            if isOverdue {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(isOverdue ? "⚠️ \(title)" : title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isOverdue ? .white : theme.accent)
            Spacer()
            if isOverdue {
                Text("Past due date")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 14)
        .background(
            isOverdue
                ? Color(red: 0.85, green: 0.15, blue: 0.15)
                : theme.background.opacity(0.95)
        )
        .cornerRadius(8)
        .padding(.bottom, 4)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? theme.background : theme.secondaryText)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? theme.accent : theme.buttonBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : theme.secondaryText.opacity(0.2), lineWidth: 0.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
