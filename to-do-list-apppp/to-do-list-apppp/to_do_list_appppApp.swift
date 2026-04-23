//
//  to_do_list_appppApp.swift
//  to-do-list-apppp
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

@main
struct to_do_list_appppApp: App {

    init() {
        FirebaseApp.configure()
        configureFirestore()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Handle Google Sign-In redirect URL
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }

    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        Firestore.firestore().settings = settings
    }
}
