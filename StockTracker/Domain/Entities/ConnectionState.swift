//
//  ConnectionState.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import Foundation

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)

    var isConnected: Bool { self == .connected }
    var isConnecting: Bool { self == .connecting }

    var displayText: String {
        switch self {
        case .disconnected:        return "Disconnected"
        case .connecting:          return "Connecting..."
        case .connected:           return "Connected"
        case .error(let message):  return "Error: \(message)"
        }
    }
}
