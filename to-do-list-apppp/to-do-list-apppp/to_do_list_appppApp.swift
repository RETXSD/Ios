//
//  to_do_list_appppApp.swift
//  to-do-list-apppp
//
//  Created by 11 on 2026/4/16.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct to_do_list_appppApp: App {
    
    init() {
        FirebaseApp.configure()
        configureFirestore()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureFirestore() {
        // Enable offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
    }
}
