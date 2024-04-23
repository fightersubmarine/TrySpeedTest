//
//  SettingsView.swift
//  TrySpeedTest
//
//  Created by Александр on 16.04.2024.
//

import SwiftUI

//MARK: - String for settings view

struct SettingsViewString {
    static let themeLabel: String = "Theme"
    static let themeDevice: String = "Device"
    static let themeLight: String = "Light"
    static let themeDark: String = "Dark"
    static let urlLabel: String = "URL Settings"
    static let enterUrl: String = "Enter url address"
    static let measureDownloadLabel: String = "Measure download speed"
    static let measureUploadLabel: String = "Measure upload speed"
    static let invalidURL: String = "Invalid URL example: https://www.google.com"
    static let error: String = "ERROR:"
    static let ok: String = "OK"
    
}

//MARK: - Private extension

private extension CGFloat {
    static let widthBorder: CGFloat = 2
    static let validTitlePadding: CGFloat = 2
}

private extension String {
    /// Проверяет, является ли строка допустимым URL-адресом.
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count && self.hasPrefix("https://")
        } else {
            return false
        }
    }}

struct SettingsView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.scenePhase) var scenePhase
    @FocusState private var isTextFieldFocused: Bool
    @State private var isURLValid = true
    @State private var showingAlert = false
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            
            // MARK: Theme Section

            Text("\(SettingsViewString.themeLabel)")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("labelTextColorSet"))
            
            VStack {
                
                Picker(selection: $settingsViewModel.selectedTheme, label: Text("\(SettingsViewString.themeLabel)")) {
                    Text("\(SettingsViewString.themeDevice)").tag(Theme.device)
                    Text("\(SettingsViewString.themeLight)").tag(Theme.light)
                    Text("\(SettingsViewString.themeDark)").tag(Theme.dark)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            VStack {
                
                // MARK: URL Settings Section
                
                Text("\(SettingsViewString.urlLabel)")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("labelTextColorSet"))
                    .padding()

                TextField("\(SettingsViewString.enterUrl)", text: $settingsViewModel.testURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .border(Color("textFieldColor"), width: .widthBorder)
                    .padding()
                    .focused($isTextFieldFocused)
                    .onTapGesture {
                        hideKeyboard()
                    }
                    .onChange(of: settingsViewModel.testURL) { newValue in
                        // Проверка URL и установка флага в зависимости от валидности
                        isURLValid = newValue.isValidURL
                    }

                // Визуализация сообщения об ошибке при невалидном URL
                if !isURLValid {
                    Text("\(SettingsViewString.invalidURL)")
                        .foregroundColor(.red)
                        .padding(.top, .validTitlePadding)
                }
                
                // Переключатели для измерения скорости загрузки и выгрузки
                Toggle(isOn: $settingsViewModel.measureDownloadSpeed) {
                    Text("\(SettingsViewString.measureDownloadLabel)")
                }
                .padding()

                Toggle(isOn: $settingsViewModel.measureUploadSpeed) {
                    Text("\(SettingsViewString.measureUploadLabel)")
                }
                .padding()
            }
        }
        .padding()
        .onChange(of: settingsViewModel.selectedTheme) { _ in
            // Применяем выбранную тему к каждой сцене приложения
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = settingsViewModel.selectedTheme.getUserInterfaceStyle()
                }
            }
        }
        .onDisappear {
            // Вызываем метод сохранения данных при уходе с экрана, только если URL валиден
            if isURLValid {
                settingsViewModel.saveSettingsIfNeeded()
            } else {
                showingAlert = true
            }
        }
        .alert(isPresented: $showingAlert) {
            // Вызываем окно с предупреждением если не прошли валидацию
            Alert(title: Text("\(SettingsViewString.error)"), message: Text("\(SettingsViewString.invalidURL)"), dismissButton: .default(Text("\(SettingsViewString.ok)")))
        }
        .onChange(of: scenePhase) {
            // Вызываем метод сохранения если пользователь перезапускает приложение оставаясь на экране настроек
            newPhase in
            if newPhase == .background {
                if isURLValid {
                    settingsViewModel.saveSettingsIfNeeded()
                } else { return }
            }
        }
    }

    private func hideKeyboard() {
        isTextFieldFocused = false
    }
}
