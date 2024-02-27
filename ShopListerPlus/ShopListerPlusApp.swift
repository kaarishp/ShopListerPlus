//
//  ShopListerPlusApp.swift
//  ShopListerPlus
//
//  Created by Kaarish Parameswaran on 2024-02-24.
//

import SwiftUI

@main
struct ShopListerPlusApp: App {
    @StateObject private var viewModel = ListViewModel()
    @State private var isActive: Bool = false

    var body: some Scene {
        WindowGroup {
            if isActive {
                ContentView()
                    .environmentObject(viewModel)
            } else {
                LaunchScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                            withAnimation {
                                isActive = true
                            }
                        }
                    }
            }
        }
    }
}
