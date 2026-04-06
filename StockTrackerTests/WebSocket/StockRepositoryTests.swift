//
//  StockRepositoryTests.swift
//  StockTrackerTests
//
//  Created by Janarthanan Kannan on 06/04/26.
//

import XCTest
import Combine
@testable import StockTracker

final class StockRepositoryTests: XCTestCase {

    private var mockWS: MockWebSocketManager!
    private var repo: StockRepository!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockWS = MockWebSocketManager()
        repo   = StockRepository(webSocketManager: mockWS)
    }

    override func tearDown() {
        cancellables.removeAll()
        repo   = nil
        mockWS = nil
        super.tearDown()
    }

    // connect/disconnect delegate to the WebSocket manager
    func test_connectionLifecycle() {
        repo.connect()
        XCTAssertEqual(mockWS.connectCallCount, 1)

        repo.disconnect()
        XCTAssertEqual(mockWS.disconnectCallCount, 1)
    }

    // Incoming price message updates the matching stock and computes change correctly
    func test_receivedMessage_updatesStockWithCorrectChange() {
        let stock    = StockData.initialStocks[0]
        let newPrice = stock.price + 10.0

        let exp = expectation(description: "stock updated")
        repo.stockPublisher
            .compactMap { $0.first(where: { $0.symbol == stock.symbol }) }
            .filter { $0.price == newPrice }
            .first()
            .sink { updated in
                XCTAssertEqual(updated.change, 10.0, accuracy: 0.001)
                exp.fulfill()
            }
            .store(in: &cancellables)

        let json = try! JSONEncoder().encode(StockUpdateMessage(symbol: stock.symbol, price: newPrice))
        mockWS.simulateIncomingMessage(String(data: json, encoding: .utf8)!)

        wait(for: [exp], timeout: 1.0)
    }

    // Malformed JSON is silently ignored — no crash
    func test_malformedMessage_doesNotCrash() {
        mockWS.simulateIncomingMessage("not valid json {{")
    }

    // Unknown symbol does not trigger a stocks emission
    func test_unknownSymbol_doesNotAlterStocks() {
        var emitCount = 0
        let noEmitExp = expectation(description: "no extra emission")
        noEmitExp.isInverted = true

        repo.stockPublisher
            .dropFirst()
            .sink { _ in emitCount += 1; noEmitExp.fulfill() }
            .store(in: &cancellables)

        let json = try! JSONEncoder().encode(StockUpdateMessage(symbol: "UNKNOWN_XYZ", price: 123.45))
        mockWS.simulateIncomingMessage(String(data: json, encoding: .utf8)!)

        wait(for: [noEmitExp], timeout: 0.3)
        XCTAssertEqual(emitCount, 0)
    }

}
