//
//  PriceChangeView.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import SwiftUI

enum PriceChangeStyle {
    case compact    // used in list rows
    case large      // used in detail screen
}

struct PriceChangeView: View {
    
    let stock: Stock
    let style: PriceChangeStyle
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: stock.isPositiveChange ? "arrow.up.right" : "arrow.down.right")
                .font(iconFont)
            Text(stock.formattedChange)
                .font(labelFont)
        }
        .foregroundStyle(stock.isPositiveChange ? Color.green : Color.red)
        .padding(.horizontal, style == .large ? 12 : 6)
        .padding(.vertical,   style == .large ? 6  : 3)
        .background(
            (stock.isPositiveChange ? Color.green : Color.red)
                .opacity(0.12)
                .clipShape(Capsule())
        )
        .contentTransition(.numericText())
        .animation(.easeInOut(duration: 0.25), value: stock.change)
    }

    private var iconFont:  Font { style == .large ? .subheadline.bold() : .caption2.bold() }
    private var labelFont: Font { style == .large ? .subheadline.bold() : .caption2 }
}

#Preview {
    
    let stock = Stock(id: "AAPL", symbol: "AAPL", name: "Apple Inc.",
                      price: 182.50, previousPrice: 180.00, change: 2.50, changePercent: 1.38)
    return VStack {
        PriceChangeView(stock: stock, style: .compact)
        PriceChangeView(stock: stock, style: .large)
    }
    .padding()
}
