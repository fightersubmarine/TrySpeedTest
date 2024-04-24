//
//  MainScreenViewModel.swift
//  TrySpeedTest
//
//  Created by Александр on 17.04.2024.
//

import SwiftUI

final class MainScreenViewModel: ObservableObject {

// MARK: - Properties

    @Published var instantSpeed: String = MainScreenString.initialInstantSpeed
    @Published var measuredSpeed: String = MainScreenString.initialMeasuredSpeed
    @Published var uploadSpeed: String = MainScreenString.initialUploadSpeed
    @Published var isTesting: Bool = false
    
    func startSpeedTest() {
        // Показываем, что тестирование началось
        isTesting = true
        
        // Вызываем сетевой запрос для теста скорости
        NetworkManager.shared.runSpeedTest { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let speedResult):
                    // Обновляем данные с учетом полученных результатов
                    self.instantSpeed = speedResult?.instantaneousSpeed ?? "zero"
                    self.measuredSpeed = speedResult?.measuredSpeed ?? "zero"
                    self.uploadSpeed = speedResult?.uploadSpeed ?? "zero"
                case .failure(let error):
                    // Обрабатываем ошибку 
                    print("Failed to fetch speed test data: \(error)")
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // Показываем, что тестирование завершено после задержки в 1 секунду
                    self.isTesting = false
                }
            }
        }
    }
}
