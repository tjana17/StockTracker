//
//  MockStockRepository.swift
//  StockTrackerTests
//
//  Created by Janarthanan Kannan on 06/04/26.
//

import Combine
@testable import StockTracker

// MARK: -  MockStockRepository

final class MockStockRepository: StockRepositoryProtocol {
    
    // MARK: - Subjects
    
    private let stocksSubject = CurrentValueSubject<[Stock], Never>([])
    private let connectionSubject = CurrentValueSubject<ConnectionState, Never>(.disconnected)
    
    // MARK: - Publishers
    
    var stockPublisher: AnyPublisher<[StockTracker.Stock], Never> {
        stocksSubject.eraseToAnyPublisher()
    }
    
    var connectionStatePublisher: AnyPublisher<StockTracker.ConnectionState, Never> {
        connectionSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Spy properties
    
    private(set) var connectCalled = false
    private(set) var disconnectCalled = false
    
    // MARK: - StockRepositoryProtocol
    
    func connect() {
        connectCalled = true
        connectionSubject.send(.connected)
    }
    
    func disconnect() {
        disconnectCalled = true
        connectionSubject.send(.disconnected)
    }
    
    // MARK: - Test Helpers
    
    func emit(stocks: [Stock]) {
        stocksSubject.send(stocks)
    }
    
    func emit(state: ConnectionState) {
        connectionSubject.send(state)
    }
    
    
}
