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
                        } else {
                            mainScreenModel = MainScreenModel(instantaneousSpeed: "\(speed)", measuredSpeed: "zero", uploadSpeed: "zero")
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

///Download Speed (скорость загрузки): После отправки запроса на тестируемый URL скорость загрузки данных рассчитывается как количество данных, загруженных за определенное время. Результат выражается в мегабайтах в секунду (Mbps).
///Upload Speed (скорость выгрузки): Рассчитывается на основе времени, затраченного на отправку данных, и объема отправленных данных. Результат также выражается в мегабайтах в секунду (Mbps).
///Instantaneous Speed (мгновенная скорость): Передается в модель данных, представляющую скорости загрузки и выгрузки, в качестве общей информации о текущей скорости, без определенного временного интервала.
