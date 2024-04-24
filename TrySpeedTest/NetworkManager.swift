//
//  NetworkManager.swift
//  TrySpeedTest
//
//  Created by Александр on 17.04.2024.
//

import Alamofire
import Network

final class NetworkManager {
    
// MARK: - Properties
    static let shared = NetworkManager()
    
    private var monitor: NWPathMonitor!
    private var queue: DispatchQueue!
    
    private var testURL: String = "https://www.google.com"
    private var measureDownloadSpeed = true
    private var measureUploadSpeed = true
    
    // MARK: - Initializer
    
    private init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "NetworkMonitor")
    }
    
    // MARK: - Public Func
    
    // Method to update test URL
    func updateTestURL(_ url: String) {
        testURL = url
    }
    
    // Flag to enable/disable download speed measurement.
    func updateDownloadSpeedMeasurement(_ measure: Bool) {
        measureDownloadSpeed = measure
    }
    
    // Flag to enable/disable speed measurement
    func updateUploadSpeedMeasurement(_ measure: Bool) {
        measureUploadSpeed = measure
    }
    
    /// Run a speed test to measure network speed.
        
    func runSpeedTest(completion: @escaping (Result<MainScreenModel?, Error>) -> Void) {
        if monitor != nil {
            monitor.cancel()
        }
        
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                let startTime = DispatchTime.now()
                AF.request(self.testURL).responseData { response in
                    switch response.result {
                    case .success(let data):
                        var mainScreenModel: MainScreenModel? = nil
                        let endTime = DispatchTime.now()
                        let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                        let timeInterval = Double(nanoTime) / 1_000_000_000 // Duration in seconds
                        
                        let speed = Double(data.count)
                        let downloadSpeed = Double(data.count) / Double(response.metrics?.taskInterval.duration ?? 1) / 1024.0 / 1024.0
                        let measuredSpeedRounded = String(format: "%.2f", downloadSpeed)
                        let uploadSpeed = speed / timeInterval / 1024.0 / 1024.0 // MBps
                        let uploadSpeedRounded = String(format: "%.2f", uploadSpeed)
                        
                        if self.measureDownloadSpeed && self.measureUploadSpeed {
                            mainScreenModel = MainScreenModel(instantaneousSpeed: "\(speed)", measuredSpeed: "\(measuredSpeedRounded)", uploadSpeed: "\(uploadSpeedRounded)")
                        } else if self.measureDownloadSpeed {
                            mainScreenModel = MainScreenModel(instantaneousSpeed: "\(speed)", measuredSpeed: "\(measuredSpeedRounded)", uploadSpeed: "zero")
                        } else if self.measureUploadSpeed {
                            mainScreenModel = MainScreenModel(instantaneousSpeed: "\(speed)", measuredSpeed: "zero", uploadSpeed: "\(uploadSpeedRounded)")
                        }
                        completion(.success(mainScreenModel))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } else {
                completion(.failure(NetworkError.noInternetConnection))
            }
        }
        
        monitor.start(queue: queue)
    }
}

// MARK: - Enum Error

enum NetworkError: Error {
    case noInternetConnection
}

// MARK: - Extension for double

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

///Инстантный (мгновенный) объем данных (в байтах): Этот параметр измеряется как размер данных, полученных в ответ на запрос к url (в данном случае - "https://www.google.com"). Он вычисляется как data.count.
///Измеренная скорость (в мегабайтах в секунду): Этот параметр вычисляется как отношение размера данных к времени, затраченному на их получение. Для этого размер данных делится на длительность задачи (в секундах), полученную из метрик ответа (response.metrics?.taskInterval.duration). Результат затем делится на 1024 дважды для перевода в мегабайты (1 Кб = 1024 байта, 1 Мб = 1024 Кб) и округляется до сотых.
