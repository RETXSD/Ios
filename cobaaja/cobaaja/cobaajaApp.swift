//
//  cobaajaApp.swift
//  cobaaja
//
//  Created by 11 on 2026/5/29.
//

import SwiftUI

@main
struct cobaajaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
