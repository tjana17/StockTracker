//
//  StockDetailViewModel.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import Foundation
import Combine

final class StockDetailViewModel: ObservableObject {

    @Published private(set) var stock: Stock

    init(stock: Stock, repository: StockRepositoryProtocol) {
        self.stock = stock
        let symbol = stock.symbol
        
        /// assign(to:) ties the subscription lifetime to the @Published property - No Cancellables needed.
        repository.stockPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0.first { $0.symbol == symbol } }
            .assign(to: &$stock)
    }
}
