//
//  FitnessappApp.swift
//  Fitnessapp
//
//  Created by 11 on 2026/5/8.
//

import SwiftUI

@main
struct FitnessappApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
