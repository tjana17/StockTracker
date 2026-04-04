//
//  StockListViewModel.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import Foundation
import Combine

// MARK: - Sort option

enum SortOption: String, CaseIterable, Identifiable {
    case none = "Default"
    case byPrice = "By Price"
    case byChange = "By Change"
    
    var id: String { rawValue }
}

// MARK: - ViewModel

final class StockListViewModel: ObservableObject {
    
    // MARK: - Outputs (observed by the view)
    
    @Published var sortOption: SortOption = .none {
        didSet { applySort() }
    }
    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published private(set) var displayedStocks: [Stock] = []
    private var allStocks: [Stock] = StockData.initialStocks

    var isConnected: Bool  { connectionState.isConnected }
    var isConnecting: Bool { connectionState.isConnecting }
    
    // MARK: - Init
    init() {
        applySort()
        
    }
    
    // MARK: - Inputs

    func toggleConnection() {
        if isConnected || isConnecting {
            print("Disconnect")
        } else {
            print("Connect")
        }
    }
    
    private func applySort() {
        switch sortOption {
        case .none:
            displayedStocks = allStocks
        case .byPrice:
            displayedStocks = allStocks.sorted { $0.price > $1.price }
        case .byChange:
            displayedStocks = allStocks.sorted { $0.change > $1.change }
        }
    }
}

