//
//  StockTrackerApp.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import SwiftUI

@main
struct StockTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}


private struct RootView: View {

    @StateObject private var viewModel = AppContainer.shared.makeStockListViewModel()
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView {
                    showSplash = false
                }
                .transition(.opacity)
                .zIndex(1)
            } else {
                StockListView(viewModel: viewModel)
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.55), value: showSplash)
    }
}
