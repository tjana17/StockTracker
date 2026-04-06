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
    
    var body: some View {
       StockListView(viewModel: viewModel)
    }
}
