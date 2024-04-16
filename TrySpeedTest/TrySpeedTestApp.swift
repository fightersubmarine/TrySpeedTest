//
//  TrySpeedTestApp.swift
//  TrySpeedTest
//
//  Created by Алина on 16.04.2024.
//

import SwiftUI

@main
struct TrySpeedTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
