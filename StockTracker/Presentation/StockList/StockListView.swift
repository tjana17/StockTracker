//
//  StockListView.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import SwiftUI

struct StockListView: View {
    
    @ObservedObject var viewModel: StockListViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ConnectionStatusView(state: viewModel.connectionState)
                if viewModel.displayedStocks.isEmpty {
                    emptyState
                } else {
                    stockList
                }
            }
            .navigationTitle("Stock Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { sortMenu }
                ToolbarItem(placement: .topBarTrailing) { connectionButton }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var stockList: some View {
        List(viewModel.displayedStocks) { stock in
            NavigationLink(value: stock) {
                StockRowView(stock: stock)
            }
            .listRowSeparator(.visible)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .listStyle(.plain)
        .navigationDestination(for: Stock.self) { stock in
            StockDetailView(
                viewModel: AppContainer.shared.makeStockDetailViewModel(for: stock)
            )
        }
        .animation(.default, value: viewModel.displayedStocks.map(\.id))
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No data yet")
                .font(.title3.bold())
            Text("Tap Start to connect to the live feed.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
    
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    Label(option.rawValue, systemImage: viewModel.sortOption == option ? "checkmark" : "")
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                .labelStyle(.iconOnly)
        }
    }
    
    private var connectionButton: some View {
        Button(action: viewModel.toggleConnection) {
            if viewModel.isConnecting {
                ProgressView().scaleEffect(0.85)
            } else {
                Text(viewModel.isConnected ? "Stop" : "Start")
                    .fontWeight(.semibold)
                    .foregroundStyle(viewModel.isConnected ? .red : .green)
            }
        }
        .disabled(viewModel.isConnecting)
        .animation(.default, value: viewModel.connectionState)
    }
}

#Preview {
    StockListView(viewModel: AppContainer.shared.makeStockListViewModel())
}
