//
//  MockWebSocketManager.swift
//  StockTrackerTests
//
//  Created by Janarthanan Kannan on 06/04/26.
//

import Combine
@testable import StockTracker

// MARK: - MockWebSocketManager

final class MockWebSocketManager: WebSocketManagerProtocol {
    
    // MARK: - Subjects

    private let stateSubject   = CurrentValueSubject<ConnectionState, Never>(.disconnected)
    private let messageSubject = PassthroughSubject<String, Never>()
    
    
    // MARK: - Publishers

    var statePublisher: AnyPublisher<ConnectionState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    var messagePublisher: AnyPublisher<String, Never> {
        messageSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Spy properties
    private(set) var connectCallCount    = 0
    private(set) var disconnectCallCount = 0
    private(set) var sentMessages: [String] = []
    
    // MARK: - StockRepositoryProtocol
    func connect() {
        connectCallCount += 1
        stateSubject.send(.connected)
    }
    
    func disconnect() {
        disconnectCallCount += 1
        stateSubject.send(.disconnected)
    }
    
    func send(_ message: String) {
        sentMessages.append(message)
        messageSubject.send(message)
    }
    
    // MARK: - Test Helpers
    func simulateState(_ state: ConnectionState) {
        stateSubject.send(state)
    }
    
    func simulateIncomingMessage(_ message: String) {
        messageSubject.send(message)
    }
}
