//
//  FirebaseService.swift
//  To-Do List
//
//  Handles all Firestore operations and anonymous authentication.
//  Replaces local JSON persistence with cloud-based storage and real-time sync.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - Firebase Service

class FirebaseService: NSObject, ObservableObject {

    @Published var todos: [TodoItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    
    private var db: Firestore
    private var listener: ListenerRegistration?
    private var currentUserID: String?
    
    override init() {
        self.db = Firestore.firestore()
        super.init()
        Task {
            await authenticateAnonymously()
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Authentication
    
    /// Authenticates the user anonymously on app launch.
    /// If already signed in, reuses existing session.
    @MainActor
    private func authenticateAnonymously() async {
        isLoading = true
        
        do {
            // Check if user is already authenticated
            if let user = Auth.auth().currentUser {
                currentUserID = user.uid
                isAuthenticated = true
                startRealtimeListener()
            } else {
                // Sign in anonymously
                let result = try await Auth.auth().signInAnonymously()
                currentUserID = result.user.uid
                isAuthenticated = true
                startRealtimeListener()
                print("✅ Anonymous authentication successful. User ID: \(result.user.uid)")
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Authentication failed: \(error.localizedDescription)"
            print("❌ Authentication error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Real-time Sync
    
    /// Sets up a real-time listener to sync todos from Firestore.
    /// Called after successful authentication.
    private func startRealtimeListener() {
        guard let userID = currentUserID else { return }
        
        listener?.remove()
        
        let todosRef = db.collection("users").document(userID).collection("todos")
        
        listener = todosRef.addSnapshotListener { [weak self] querySnapshot, error in
            DispatchQueue.main.async {
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
        guard let userID = currentUserID else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let todoItem = TodoItem(title: title, note: note, dueDate: dueDate)
        let todosRef = db.collection("users").document(userID).collection("todos")
        
        try await todosRef.document(todoItem.id.uuidString).setData(from: todoItem)
        print("✅ Added todo: \(title)")
    }
    
    /// Updates an existing todo in Firestore.
    func updateTodo(id: UUID, title: String, note: String, dueDate: Date) async throws {
        guard let userID = currentUserID else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let todosRef = db.collection("users").document(userID).collection("todos")
        
        try await todosRef.document(id.uuidString).updateData([
            "title": title,
            "note": note,
            "dueDate": dueDate
        ])
        print("✅ Updated todo: \(id)")
    }
    
    /// Toggles the completion status of a todo.
    func toggleTodo(id: UUID, isCompleted: Bool) async throws {
        guard let userID = currentUserID else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let todosRef = db.collection("users").document(userID).collection("todos")
        
        try await todosRef.document(id.uuidString).updateData([
            "isCompleted": isCompleted,
            "completedAt": isCompleted ? Date() : NSNull()
        ])
        print("✅ Toggled todo completion: \(id)")
    }
    
    /// Deletes a todo from Firestore.
    func deleteTodo(id: UUID) async throws {
        guard let userID = currentUserID else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let todosRef = db.collection("users").document(userID).collection("todos")
        
        try await todosRef.document(id.uuidString).delete()
        print("✅ Deleted todo: \(id)")
    }
    
    /// Deletes all completed todos from previous days.
    func deleteCompletedFromPreviousDays() async throws {
        guard let userID = currentUserID else {
            throw NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let todosRef = db.collection("users").document(userID).collection("todos")
        
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
