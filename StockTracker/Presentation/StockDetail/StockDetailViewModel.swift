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

    init(stock: Stock) {
        self.stock = stock
    }
}
func makeStockDetailViewModel(for stock: Stock) -> StockDetailViewModel {
    StockDetailViewModel(
        stock: stock
    )
}
