//
//  NihonggoApp.swift
//  Nihonggo
//
//  Created by 11 on 2026/6/15.
//

import SwiftUI

@main
struct NihonggoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
