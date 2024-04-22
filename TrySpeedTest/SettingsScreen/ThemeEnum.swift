//
//  ThemeEnum.swift
//  TrySpeedTest
//
//  Created by Алина on 22.04.2024.
//

import Foundation
import SwiftUI

enum Theme: Int {
    case device
    case light
    case dark
    
    /// Возвращает стиль пользовательского интерфейса на основе выбранной темы.
    func getUserInterfaceStyle() -> UIUserInterfaceStyle {
        
        switch self {
        case .device:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
