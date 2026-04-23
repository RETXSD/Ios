//
//  ContentView.swift
//  To-Do List
//
//  Root view yang MEMILIKI ViewModel menggunakan @StateObject.
//  ViewModel ini kemudian diteruskan ke child view (TodoListView)
//  yang menggunakannya dengan @ObservedObject.
//

import SwiftUI

// MARK: - Content View (Root)

struct ContentView: View {

    // @StateObject: View ini adalah PEMILIK dari ViewModel.
    // SwiftUI akan membuat instance ViewModel sekali dan menjaganya
    // agar tidak di-reset selama view ini hidup.
    @StateObject private var viewModel = TodoViewModel()
    @StateObject private var authService = AuthService()

    var body: some View {
        Group {
            if authService.currentUser == nil {
                LoginPage(authService: authService)
            } else {
                NavigationStack {
                    TodoListView(viewModel: viewModel, authService: authService)
                        .navigationBarHidden(true)
                        .animation(.easeInOut(duration: 0.25), value: viewModel.showThemePicker)
                }
                .sheet(isPresented: $viewModel.showAddSheet) {
                    AddTodoSheet(isPresented: $viewModel.showAddSheet, theme: viewModel.theme) { title, note, dueDate in
                        viewModel.addTodo(title: title, note: note, dueDate: dueDate)
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                }
            }
        }
        .onChange(of: authService.currentUser?.uid) { uid in
            if uid == nil {
                viewModel.endUserSession()
            } else {
                viewModel.startUserSession()
            }
        }
        .task {
            if authService.currentUser?.uid != nil {
                viewModel.startUserSession()
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}