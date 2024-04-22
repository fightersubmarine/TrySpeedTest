//
//  MainScreenView.swift
//  TrySpeedTest
//
//  Created by Александр on 16.04.2024.
//

import SwiftUI

// MARK: - String for Main View

struct MainScreenString {
    static let initialInstantSpeed: String = "0"
    static let initialMeasuredSpeed: String = "0"
    static let topTitle: String = "Speed Test"
    static let instantSpeedTitle: String = "Instantaneous Speed"
    static let measuredSpeedTitle: String = "Measured Speed"
    static let startButtonTitle: String = "Start"
}


// MARK: - Extension for CGFloat

private extension CGFloat {
    static let widthCircle: CGFloat = 200
    static let heightCircle: CGFloat = 200
    static let lineWidthCircle: CGFloat = 10
    static let firstOffset: CGFloat = 20
    static let secondOffset: CGFloat = 40
    static let cornerRadiusForButton: CGFloat = 10
}

struct MainScreenView: View {
    
// MARK: - Properties
    
    @StateObject private var viewModel = MainScreenViewModel()
    
    
    
// MARK: - Body
    
    var body: some View {
        VStack {
            
// MARK: - Title
            Text("\(MainScreenString.topTitle)")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("labelTextColorSet"))
                .padding()
            
// MARK: - Content
            Spacer()
            
            VStack {
                Circle()
                    .trim(from: .zero, to: 1)
                    .stroke(viewModel.isTesting ? Color("greenNeonColor") : Color.gray, lineWidth: .lineWidthCircle)
                    .frame(width: .widthCircle, height: .heightCircle)
                    .animation(.easeInOut, value: viewModel.isTesting)
                
                VStack {
                    Text("\(MainScreenString.instantSpeedTitle)")
                    Text("\(viewModel.instantSpeed) byte")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .foregroundColor(Color("labelTextColorSet"))
                .offset(y: .firstOffset)
                
                VStack {
                    Text("\(MainScreenString.measuredSpeedTitle)")
                    Text("\(viewModel.measuredSpeed) Mbps")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .foregroundColor(Color("labelTextColorSet"))
                .offset(y: .secondOffset)
            }
            
// MARK: - Button
            Spacer()
            
            Button(action: {
                viewModel.startSpeedTest()
            }) {
                Text("\(MainScreenString.startButtonTitle)")
                    .font(.headline)
                    .padding()
                    .background(Color("greenNeonColor"))
                    .foregroundColor(.white)
                    .cornerRadius(.cornerRadiusForButton)
            }
            .padding()
        }
        .padding()
    }
    
}


