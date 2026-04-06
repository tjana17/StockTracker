//
//  AppContainer.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 06/04/26.
//

import Foundation

final class AppContainer {
    
    static let shared = AppContainer()
    private init() { }
    
    private lazy var webSocketManager: WebSocketManagerProtocol = WebSocketManager(url: URL(string: "wss://ws.postman-echo.com/raw")!)
    
    private(set) lazy var repository: StockRepositoryProtocol = StockRepository(webSocketManager: webSocketManager)
    
    func makeStockListViewModel() -> StockListViewModel {
        StockListViewModel(repository: repository)
    }
    
    func makeStockDetailViewModel(for stock: Stock) -> StockDetailViewModel {
        StockDetailViewModel(stock: stock, repository: repository)
    }
}
