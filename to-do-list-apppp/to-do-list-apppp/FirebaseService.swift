//
//  FirebaseService.swift
//  To-Do List
//
//  Handles all Firestore operations without authentication.
//  Uses cloud-based storage with real-time sync.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - Firebase Service

class FirebaseService: NSObject, ObservableObject {

    @Published var todos: [TodoItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var db: Firestore
    private var listener: ListenerRegistration?
    private let collectionName = "todos"
    
    override init() {
        self.db = Firestore.firestore()
        super.init()
        Task {
            await startRealtimeListener()
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Real-time Sync
    
    /// Sets up a real-time listener to sync todos from Firestore.
    @MainActor
    private func startRealtimeListener() async {
        listener?.remove()
        isLoading = true
        
        let todosRef = db.collection(collectionName)
        
        listener = todosRef.addSnapshotListener { [weak self] querySnapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Failed to load todos: \(error.localizedDescription)"
                    print("❌ Snapshot listener error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self?.todos = []
                    return
                }
                
                do {
                    let todos = try documents.compactMap { doc -> TodoItem? in
                        try doc.data(as: TodoItem.self)
                    }.sorted { $0.dueDate < $1.dueDate }
                    
                    self?.todos = todos
                    print("✅ Synced \(todos.count) todos from Firestore")
                } catch {
                    self?.errorMessage = "Failed to decode todos: \(error.localizedDescription)"
                    print("❌ Decode error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    /// Adds a new todo to Firestore.
    func addTodo(title: String, note: String, dueDate: Date) async throws {
        let todoItem = TodoItem(title: title, note: note, dueDate: dueDate)
        let todosRef = db.collection(collectionName)
        
        try await todosRef.document((todoItem.id.uuidString) ?? UUID().uuidString).setData(from: todoItem)
        print("✅ Added todo: \(title)")
    }
    
    /// Updates an existing todo in Firestore.
    func updateTodo(id: UUID, title: String, note: String, dueDate: Date) async throws {
        let todosRef = db.collection(collectionName)
        
        try await todosRef.document(id.uuidString).updateData([
            "title": title,
            "note": note,
            "dueDate": dueDate
        ])
        print("✅ Updated todo: \(id)")
    }
    
    /// Toggles the completion status of a todo.
    func toggleTodo(id: UUID, isCompleted: Bool) async throws {
        let todosRef = db.collection(collectionName)
        
        try await todosRef.document(id.uuidString).updateData([
            "isCompleted": isCompleted,
            "completedAt": isCompleted ? Date() : NSNull()
        ])
        print("✅ Toggled todo completion: \(id)")
    }
    
    /// Deletes a todo from Firestore.
    func deleteTodo(id: UUID) async throws {
        let todosRef = db.collection(collectionName)
        
        try await todosRef.document(id.uuidString).delete()
        print("✅ Deleted todo: \(id)")
    }
    
    /// Deletes all completed todos from previous days.
    func deleteCompletedFromPreviousDays() async throws {
        let today = Calendar.current.startOfDay(for: Date())
        let todosRef = db.collection(collectionName)
        
        // Query for completed tasks from before today
        let query = todosRef
            .whereField("isCompleted", isEqualTo: true)
            .whereField("completedAt", isLessThan: today)
        
        let snapshot = try await query.getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
        print("✅ Deleted \(snapshot.documents.count) completed tasks from previous days")
    }
}
