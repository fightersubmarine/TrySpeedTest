//
//  SettingsViewModel.swift
//  TrySpeedTest
//
//  Created by Александр on 18.04.2024.
//

import SwiftUI
import CoreData
import Combine

final class SettingsViewModel: ObservableObject {
    let dataManager: DataManager
    
    @Published var testURL: String = ""
    @Published var measureDownloadSpeed = true
    @Published var measureUploadSpeed = true
    @Published var selectedTheme: Theme = .device
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataManager: DataManager, settingsModel: SettingsModel?) {
        self.dataManager = dataManager
        self.testURL = settingsModel?.taskURL ?? "https://www.google.com"
        self.selectedTheme = Theme(rawValue: Int(settingsModel?.selectedTheme ?? 0)) ?? .device
        self.measureDownloadSpeed = settingsModel?.instantSpeed ?? true
        self.measureUploadSpeed = settingsModel?.measuredSpeed ?? true
        
        $testURL
            .sink { [weak self] url in
                if self != nil {
                    NetworkManager.shared.updateTestURL(url)
                }
            }
            .store(in: &cancellables)

        $measureDownloadSpeed
            .sink { [weak self] measure in
                if self != nil {
                    NetworkManager.shared.updateDownloadSpeedMeasurement(measure)
                }
            }
            .store(in: &cancellables)

        $measureUploadSpeed
            .sink { [weak self] measure in
                if self != nil {
                    NetworkManager.shared.updateUploadSpeedMeasurement(measure)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchSettings() {
        if let existingSettings = fetchSettingsModel() {
            self.testURL = existingSettings.taskURL ?? ""
            self.selectedTheme = Theme(rawValue: Int(existingSettings.selectedTheme)) ?? .device
            self.measureDownloadSpeed = existingSettings.instantSpeed
            self.measureUploadSpeed = existingSettings.measuredSpeed
        }
    }
    
    func fetchSettingsModel() -> SettingsModel? {
        let fetchRequest: NSFetchRequest<SettingsModel> = SettingsModel.fetchRequest()
        do {
            let settings = try dataManager.context.fetch(fetchRequest)
            return settings.first
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveSettingsIfNeeded() {
        // Получаем существующие настройки
        guard let existingSettings = fetchSettingsModel() else {
            // Если данных нет, сохраняем текущие настройки
            saveSettings()
            return
        }
        
        // Проверяем, отличаются ли текущие настройки от существующих
        if testURL != existingSettings.taskURL ||
           selectedTheme.rawValue != existingSettings.selectedTheme ||
           measureDownloadSpeed != existingSettings.instantSpeed ||
           measureUploadSpeed != existingSettings.measuredSpeed {
            
            // Если настройки отличаются, сохраняем их
            saveSettings()
        }
    }
    
    private func saveSettings() {
        dataManager.addItem(taskURL: testURL,
                            selectedTheme: Int16(selectedTheme.rawValue),
                            measuredSpeed: measureUploadSpeed,
                            instantSpeed: measureDownloadSpeed,
                            context: dataManager.context)
    }
    
}
