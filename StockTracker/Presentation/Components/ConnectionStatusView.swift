//
//  ConnectionStatusView.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import SwiftUI

struct ConnectionStatusView: View {
    
    let state: ConnectionState

    @State private var pulse = false
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(dotColor.opacity(0.25))
                    .frame(width: 14, height: 14)
                    .scaleEffect(pulse ? 1.6 : 1.0)
                    .animation(
                        state == .connected ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: pulse
                    )
                
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)
            }
            .onAppear {
                pulse = (state == .connected)
            }
            .onChange(of: state) { _, newState in
                pulse = (newState == .connected)
            }
            
            Text(state.displayText)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }
    
    private var dotColor: Color {
        switch state {
        case .connected:    return .green
        case .disconnected: return .orange
        case .connecting:   return .secondary
        case .error(_):     return .red
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        ConnectionStatusView(state: .connected)
        ConnectionStatusView(state: .connecting)
        ConnectionStatusView(state: .disconnected)
        ConnectionStatusView(state: .error("Timeout"))
    }
}
