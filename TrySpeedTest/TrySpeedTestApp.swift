//
//  TrySpeedTestApp.swift
//  TrySpeedTest
//
//  Created by Александр on 16.04.2024.
//

import SwiftUI

@main
struct TrySpeedTestApp: App {
    let dataManager = DataManager()
    var settingsModel: SettingsModel?
    let settingsViewModel: SettingsViewModel
    
    init() {
        settingsModel = dataManager.loadItems()
        settingsViewModel = SettingsViewModel(dataManager: dataManager, settingsModel: settingsModel) // Инициализируем модель настроек
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataManager.context)
                .environmentObject(settingsViewModel) // Передал модель настроек через @EnvironmentObject
        }
    }
}
