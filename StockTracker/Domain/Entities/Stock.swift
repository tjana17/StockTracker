//
//  Stock.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import Foundation

struct Stock: Identifiable, Equatable, Hashable {
    let id: String  // same as symbol
    let symbol: String
    let name: String
    let price: Double
    let previousPrice: Double
    let change: Double          // price - previousPrice
    let changePercent: Double   // (change / previousPrice) * 100
    
    var isPositiveChange: Bool { change >= 0 }
    
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
    
    var formattedChange: String {
        let sign = change >= 0 ? "+" : ""
        let amt = String(format: "$%.2f", change)
        let pct  = String(format: "%.2f", changePercent)
        return "\(sign)\(amt) (\(sign)\(pct)%)"
    }
    
    // Hashable — identity is the symbol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
