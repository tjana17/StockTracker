//
//  StockDetailView.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import SwiftUI

struct StockDetailView: View {
    @StateObject var viewModel: StockDetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                headerSection
                priceSection
                Divider()
                aboutSection
                
            }
            .padding()
        }
        .navigationTitle("NVDA")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("NVDA")
                .font(.largeTitle.bold())
            Text("NVDIA Group")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("$158.33")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: "$158.33")

            PriceChangeView(stock: viewModel.stock, style: .large)

            // Live indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(.green)
                    .frame(width: 6, height: 6)
                Text("Live")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 2)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.title3.bold())

            Text("A leading publicly traded company listed on major US stock exchanges.")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(5)
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

//#Preview {
//    let mockViewModel = StockDetailViewModel(stock: Stock)
//    StockDetailView(viewModel: mockViewModel)
//}
