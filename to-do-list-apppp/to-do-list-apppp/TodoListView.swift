//
//  TodoListView.swift
//  To-Do List
//
//  Child view yang menerima viewModel dari parent menggunakan @ObservedObject.
//  Karena view ini tidak membuat/memiliki ViewModel, cukup mengobservasi yang diberikan.
//

import SwiftUI

// MARK: - Todo List View

struct TodoListView: View {

    // @ObservedObject: View ini TIDAK memiliki ViewModel.
    // ViewModel dibuat di parent (ContentView) dan diteruskan ke sini.
    // Setiap kali ViewModel berubah, view ini akan di-render ulang.
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var authService: AuthService

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            // Theme picker (collapsible)
            if viewModel.showThemePicker {
                themePicker
            }

            // Motivational subtitle
            Text("Focus on what matters most today ✨")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(viewModel.theme.secondaryText.opacity(0.8))
                .padding(.bottom, 6)

            // Progress bar
            if !viewModel.todos.isEmpty {
                progressBar
            }

            // Filter chips
            filterChips

            // Todo list or empty state
            if viewModel.filteredTodos.isEmpty {
                emptyState
            } else {
                todoList
            }
        }
        .background(viewModel.theme.background.ignoresSafeArea())
        .overlay(addButton, alignment: .bottomTrailing)
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(authService.displayName.map { "Hi, \($0) 👋" } ?? "My Tasks")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(viewModel.theme.cardText)
                Text("\(viewModel.completedCount) of \(viewModel.todos.count) completed")
                    .font(.system(size: 12))
                    .foregroundColor(viewModel.theme.secondaryText)
            }
            Spacer()
            HStack(spacing: 8) {
                // Profile button
                NavigationLink(destination: ProfileView(
                    authService: authService,
                    theme: viewModel.theme
                )) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [viewModel.theme.accent, viewModel.theme.accent.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                        Text(avatarLetter)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                // Theme picker button
                Button(action: { viewModel.showThemePicker.toggle() }) {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 20))
                        .foregroundColor(viewModel.theme.accent)
                        .padding(8)
                        .background(viewModel.theme.buttonBackground)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // Avatar initial letter derived from auth service
    private var avatarLetter: String {
        let name = authService.displayName ?? authService.userEmail ?? "?"
        return String(name.prefix(1)).uppercased()
    }

    private var themePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(themes.indices, id: \.self) { i in
                    Button(action: {
                        viewModel.selectedThemeIndex = i
                        viewModel.showThemePicker = false
                    }) {
                        Text(themes[i].name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(i == viewModel.selectedThemeIndex ? themes[i].accent : themes[i].cardText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(themes[i].cardBackground)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(i == viewModel.selectedThemeIndex ? themes[i].accent : Color.clear, lineWidth: 2)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 12)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(viewModel.theme.cardBackground)
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 4)
                    .fill(viewModel.theme.accent)
                    .frame(
                        width: viewModel.todos.isEmpty ? 0 : geo.size.width * CGFloat(viewModel.completedCount) / CGFloat(viewModel.todos.count),
                        height: 6
                    )
                    .animation(.spring(response: 0.4), value: viewModel.completedCount)
            }
        }
        .frame(height: 6)
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
    }

    private var filterChips: some View {
        HStack(spacing: 10) {
            FilterChip(label: "All (\(viewModel.todos.count))", isSelected: !viewModel.filterCompleted, theme: viewModel.theme) {
                viewModel.filterCompleted = false
            }
            FilterChip(label: "Done (\(viewModel.completedCount))", isSelected: viewModel.filterCompleted, theme: viewModel.theme) {
                viewModel.filterCompleted = true
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: viewModel.filterCompleted ? "checkmark.circle" : "tray")
                    .font(.system(size: 48))
                    .foregroundColor(viewModel.theme.secondaryText.opacity(0.4))
                Text(viewModel.filterCompleted ? "Nothing completed yet" : "No tasks yet")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(viewModel.theme.secondaryText)
                if !viewModel.filterCompleted {
                    Text("Tap + to add your first task")
                        .font(.system(size: 13))
                        .foregroundColor(viewModel.theme.secondaryText.opacity(0.6))
                }
            }
            Spacer()
        }
    }

    private var todoList: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.groupedTodos) { group in
                    Section(header: GroupHeaderView(title: group.title, theme: viewModel.theme, isOverdue: group.isOverdue)) {
                        ForEach(group.items) { item in
                            let globalIndex = viewModel.todos.firstIndex(where: { $0.id == item.id })

                            NavigationLink(destination: {
                                if let idx = globalIndex {
                                    TodoDetailView(
                                        item: $viewModel.todos[idx],
                                        theme: viewModel.theme,
                                        onSave: { id, title, note, dueDate in
                                            viewModel.updateTodo(id: id, title: title, note: note, dueDate: dueDate)
                                        },
                                        onToggle: { id in
                                            viewModel.toggleTodo(id: id)
                                        },
                                        onDelete: { viewModel.deleteTodo(id: viewModel.todos[idx].id) }
                                    )
                                }
                            }) {
                                TodoRowView(
                                    item: item,
                                    theme: viewModel.theme,
                                    onToggle: { viewModel.toggleTodo(id: item.id) },
                                    onDelete: { viewModel.deleteTodo(id: item.id) },
                                    onTap: {}
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }

    private var addButton: some View {
        Button(action: { viewModel.showAddSheet = true }) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(viewModel.theme.background)
                .frame(width: 56, height: 56)
                .background(viewModel.theme.accent)
                .clipShape(Circle())
                .shadow(color: viewModel.theme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 28)
    }
}
