//
//  StockRowView.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import SwiftUI

struct StockRowView: View {
    let stock: Stock
    @State private var flashColor: Color = .clear
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            
            // Symbol badge
            Text(stock.symbol)
                .font(.system(.headline, design: .monospaced).bold())
                .foregroundStyle(.primary)
                .frame(width: 56, alignment: .leading)
            
            // Company name
            Text(stock.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()
            
            // Price + change
            VStack(alignment: .trailing, spacing: 4) {
                Text(stock.formattedPrice)
                    .font(.system(.headline, design: .rounded).bold())
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.3), value: stock.price)
                
                PriceChangeView(stock: stock, style: .compact)
            }
        }
        .padding(.vertical, 6)
        .background(flashColor.ignoresSafeArea())
        .onChange(of: stock.price) { _, _ in
            flashRow()
        }
    }
    
    private func flashRow() {
        let target: Color = stock.isPositiveChange
            ? .green.opacity(0.15)
            : .red.opacity(0.15)

        withAnimation(.easeIn(duration: 0.1))  { flashColor = target }
        withAnimation(.easeOut(duration: 0.5).delay(0.1)) { flashColor = .clear }
    }
}

#Preview {
    let stock = Stock(id: "NVDA", symbol: "NVDA", name: "NVIDIA Corp.",
                      price: 485.30, previousPrice: 480.00, change: 5.30, changePercent: 1.10)
    return List {
        StockRowView(stock: stock)
    }
}
