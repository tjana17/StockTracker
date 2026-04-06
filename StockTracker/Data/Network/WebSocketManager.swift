//
//  WebSocketManager.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import Foundation
import Combine

// MARK: - Protocol
protocol WebSocketManagerProtocol: AnyObject {
    var messagePublisher: AnyPublisher<String, Never> { get }
    var statePublisher: AnyPublisher<ConnectionState, Never> { get }
    func connect()
    func disconnect()
    func send(_ message: String)
}

// MARK: - WebSocketManager

/// URLSession-based WebSocket manager with automatic exponential back-off reconnection.
final class WebSocketManager: NSObject, WebSocketManagerProtocol {
    var messagePublisher: AnyPublisher<String, Never> {
        messageSubject.eraseToAnyPublisher()
    }
    
    var statePublisher: AnyPublisher<ConnectionState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    private let stateSubject   = CurrentValueSubject<ConnectionState, Never>(.disconnected)
    private let messageSubject = PassthroughSubject<String, Never>()
    
    private let url: URL
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private var reconnectWorkItem: DispatchWorkItem?
    private var isIntentionallyDisconnected = false
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    // MARK: - WebSocketManagerProtocol
    
    func connect() {
        guard stateSubject.value == .disconnected else { return }
        isIntentionallyDisconnected = false
        startConnection()
    }
    
    func disconnect() {
        isIntentionallyDisconnected = true
        reconnectWorkItem?.cancel()
        reconnectWorkItem = nil
        reconnectAttempts = 0
        closeConnection(sendDisconnectedState: true)
    }
    
    func send(_ message: String) {
        guard stateSubject.value == .connected else { return }
        webSocketTask?.send(.string(message)) { [weak self] error in
            if let error { self?.handleFailure(error)}
        }
    }
    
    // MARK: - Private functions
    private func startConnection() {
        stateSubject.send(.connecting)
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()
        listenForNextMessage()
    }
    
    private func closeConnection(sendDisconnectedState: Bool) {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        if sendDisconnectedState { stateSubject.send(.disconnected) }
    }
    
    private func listenForNextMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let text): self.messageSubject.send(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) { self.messageSubject.send(text) }
                @unknown default: break
                }
                self.listenForNextMessage()
            case .failure(let error):
                self.handleFailure(error)
            }
        }
    }
    
    private func handleFailure(_ error: Error) {
        guard !isIntentionallyDisconnected else { return }
        let msg = (error as? URLError)?.localizedDescription ?? error.localizedDescription
        stateSubject.send(.error(msg))
        scheduleReconnect()
    }
    
    private func scheduleReconnect() {
        guard reconnectAttempts < maxReconnectAttempts else {
            stateSubject.send(.disconnected)
            return
        }
        reconnectAttempts += 1
        let delay = min(pow(2.0, Double(reconnectAttempts)),30.0)
        let item =  DispatchWorkItem { [weak self] in
            guard let self, self.reconnectWorkItem?.isCancelled == false else { return }
            self.closeConnection(sendDisconnectedState: false)
            self.stateSubject.send(.disconnected)
            self.startConnection()
        }
        reconnectWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }
    
}


// MARK: - URLSessionWebSocketDelegate

extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        reconnectAttempts = 0
        stateSubject.send(.connected)
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        stateSubject.send(.disconnected)
    }
}
