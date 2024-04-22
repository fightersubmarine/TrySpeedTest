//
//  AppView.swift
//  TrySpeedTest
//
//  Created by Александр on 16.04.2024.
//

import SwiftUI

// MARK: - Enum for tabBar

enum Tab {
    case home, settings
}

// MARK: - Extension for CGFloat and Double

private extension CGFloat {
    static let verticalPadding: CGFloat = 20
    static let horizontalPadding: CGFloat = 27
    static let buttonSpacing: CGFloat = 60
}

private extension Double {
    static let buttonOpacity: Double = 0.7
}

struct AppView: View {
    // MARK: - Properties
    @State private var selectedTab: Tab = .home
    let tabBarButtons: [Tab] = [.home, .settings]
    @StateObject var settingsViewModel = SettingsViewModel(dataManager: DataManager(), settingsModel: nil) 
    
    // MARK: - init
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                MainScreenView()
                    .tag(Tab.home)
                SettingsView()
                    .tag(Tab.settings)
            }
            
            Spacer()
            
            HStack(spacing: .buttonSpacing) {
                ForEach(tabBarButtons, id: \.self) { tab in
                    TapBarButton(selectedTab: $selectedTab, tab: tab)
                }
            }
            .padding(.vertical, .verticalPadding)
            .frame(maxWidth: .infinity)
            .background(Color("tabBarColor"))
        }
        .environmentObject(settingsViewModel) // Установите модель настроек как объект окружения
        .onAppear {
            settingsViewModel.fetchSettings()
        }
    }
}
//MARK: - Castom TapBarButtons

struct TapBarButton: View {
    @Binding var selectedTab: Tab
    
    let tab: Tab
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedTab = tab
            }
        }) {
            HStack {
                Image(systemName: imageName(for: tab))
                    .foregroundColor(Color("textColorSet"))
                if selectedTab == tab {
                    Text(title(for: tab))
                        .foregroundColor(Color("textColorSet"))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, .verticalPadding)
        .padding(.horizontal, .horizontalPadding)
        .background(selectedTab == tab ? .white : .clear)
        .clipShape(Capsule())
        .opacity(selectedTab == tab ? 1 : .buttonOpacity)
    }
    
    private func imageName(for tab: Tab) -> String {
        switch tab {
        case .home:
            return "house"
        case .settings:
            return "gear"
        }
    }
    
    private func title(for tab: Tab) -> String {
        switch tab {
        case .home:
            return "Home"
        case .settings:
            return "Settings"
        }
    }
}
