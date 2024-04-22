//
//  DataManager.swift
//  TrySpeedTest
//
//  Created by Александр on 19.04.2024.
//

import Foundation
import CoreData

final class DataManager: ObservableObject {
    // MARK: - Properties
    
    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrySpeedTestDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    // MARK: - Public Methods
    
    var context: NSManagedObjectContext {
        return Self.persistentContainer.viewContext
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("Data saved")
        } catch {
            print("Saved error \(error.localizedDescription)")
        }
    }
    
    /// Adds a new item to the CoreData entity.
    ///
    /// - Parameters:
    ///   - taskURL: The URL of the task.
    ///   - selectedTheme: The selected theme.
    ///   - measuredSpeed: Flag indicating whether speed is measured.
    ///   - instantSpeed: Flag indicating whether instant speed is used.
    ///   - context: The managed object context.
    
    func addItem(taskURL: String?, selectedTheme: Int16, measuredSpeed: Bool, instantSpeed: Bool, context: NSManagedObjectContext) {
        if let existingSettings = loadItems() {
            // Если запись уже существует, обновляем ее значения
            existingSettings.taskURL = taskURL
            existingSettings.selectedTheme = selectedTheme
            existingSettings.measuredSpeed = measuredSpeed
            existingSettings.instantSpeed = instantSpeed
        } else {
            // Если запись не существует, создаем новую
            let settingsModel = SettingsModel(context: context)
            settingsModel.taskURL = taskURL
            settingsModel.selectedTheme = selectedTheme
            settingsModel.measuredSpeed = measuredSpeed
            settingsModel.instantSpeed = instantSpeed
        }
        save(context: context)
    }
    
    
    /// - Returns: The first SettingsModel object, if exists.
    func loadItems() -> SettingsModel? {
        let fetchRequest: NSFetchRequest<SettingsModel> = SettingsModel.fetchRequest()
        do {
            let settings = try context.fetch(fetchRequest)
            return settings.first
        } catch {
            print("Fetch error: \(error.localizedDescription)")
            return nil
        }
    }
}
