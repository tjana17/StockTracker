//
//  StockRepository.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import Foundation
import Combine

// MARK: - Protocol - StockRepositoryProtocol

protocol StockRepositoryProtocol: AnyObject {
    var stockPublisher: AnyPublisher<[Stock], Never> { get }
    var connectionStatePublisher: AnyPublisher<ConnectionState, Never> { get }
    func connect()
    func disconnect()
}

// MARK: - StockUpdateMessage

private struct StockUpdateMessage: Codable {
    let symbol: String
    let price: Double
}

// MARK: - StockRepository

final class StockRepository: StockRepositoryProtocol {
    var stockPublisher: AnyPublisher<[Stock], Never> {
        stocksSubject.eraseToAnyPublisher()
    }
    
    var connectionStatePublisher: AnyPublisher<ConnectionState, Never> {
        connectionSubject.eraseToAnyPublisher()
    }
    
    private let webSocketManager: WebSocketManagerProtocol
    private let stocksSubject: CurrentValueSubject<[Stock], Never>
    private let connectionSubject = CurrentValueSubject<ConnectionState, Never>(.disconnected)
    private var simulationCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    init(webSocketManager: WebSocketManagerProtocol) {
        self.webSocketManager = webSocketManager
        self.stocksSubject = CurrentValueSubject(StockData.initialStocks)
        setupBindings()
    }
    
    func connect() {
        webSocketManager.connect()
    }
    
    func disconnect() {
        webSocketManager.disconnect()
    }
    
    // MARK: - Private Functions
    private func setupBindings() {
        webSocketManager.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.connectionSubject.send(state)
                switch state {
                case .connected:
                    self?.startSimulation()
                case .disconnected, .error:
                    self?.stopSimulation()
                case .connecting:
                    break
                }
            }
            .store(in: &cancellables)
        
        webSocketManager.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.processMessage($0)
            }
            .store(in: &cancellables)
    }
    
    private func startSimulation() {
        simulationCancellable?.cancel()
        simulationCancellable = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.sendBatchUpdate() }
    }
    
    private func stopSimulation() {
        simulationCancellable?.cancel()
        simulationCancellable = nil
    }
    
    private func sendBatchUpdate() {
        guard connectionSubject.value == .connected else { return }
        let stocks = stocksSubject.value
        guard !stocks.isEmpty else { return }

        var seen = Set<Int>()
        while seen.count < min(3, stocks.count) { seen.insert(Int.random(in: 0..<stocks.count)) }

        for index in seen {
            let stock    = stocks[index]
            let newPrice = (stock.price * (1 + Double.random(in: -0.025...0.025))).rounded(toDecimalPlaces: 2)
            guard let json = try? JSONEncoder().encode(StockUpdateMessage(symbol: stock.symbol, price: newPrice)),
                  let text = String(data: json, encoding: .utf8) else { continue }
            webSocketManager.send(text)
        }
    }

    private func processMessage(_ raw: String) {
        guard let data   = raw.data(using: .utf8),
              let update = try? JSONDecoder().decode(StockUpdateMessage.self, from: data) else { return }

        var stocks = stocksSubject.value
        guard let idx = stocks.firstIndex(where: { $0.symbol == update.symbol }) else { return }

        let old = stocks[idx]
        stocks[idx] = Stock(
            id:            old.id,
            symbol:        old.symbol,
            name:          old.name,
            price:         update.price,
            previousPrice: old.price,
            change:        update.price - old.price,
            changePercent: old.price != 0 ? ((update.price - old.price) / old.price) * 100 : 0
        )
        stocksSubject.send(stocks)
    }
}
