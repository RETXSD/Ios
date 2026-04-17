//
//  To_Do_ListApp.swift
//  To-Do List
//
//  Created by 11 on 2026/4/3.
//

import SwiftUI
import Firebase

@main
struct To_Do_ListApp: App {
    
    init() {
        // Configure Firebase on app launch
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
