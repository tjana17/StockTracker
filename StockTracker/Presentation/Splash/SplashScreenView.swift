//
//  SplashScreenView.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 06/04/26.
//

import SwiftUI

// MARK: - SplashScreenView

struct SplashScreenView: View {
    
    let onFinished: () -> Void
    
    // MARK: Animation states
    @State private var showTitle:    Bool     = false
    @State private var showSubtitle: Bool     = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            background
            
            VStack(spacing: 40) {
                titleBlock
            }
        }
        
        .onAppear { runSequence() }
    }
    
    // MARK: Background

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.04, blue: 0.14),
                Color(red: 0.06, green: 0.08, blue: 0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - TitleBlock
    private var titleBlock: some View {
        VStack(spacing: 10) {
            
            //Icon
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.25), Color.green.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.green.opacity(0.35), lineWidth: 1)
                    )
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.green)
            }
            .opacity(showTitle ? 1 : 0)
            .scaleEffect(showTitle ? 1 : 0.6)
            .animation(.spring(response: 0.5, dampingFraction: 0.65), value: showTitle)
            
            // App name
            Text("Stock Tracker")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(white: 0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 16)
                .animation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.08), value: showTitle)
            
            // Tagline
            Text("Real-time markets at a glance")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.white.opacity(0.42))
                .opacity(showSubtitle ? 1 : 0)
                .offset(y: showSubtitle ? 0 : 10)
                .animation(.easeOut(duration: 0.45).delay(0.1), value: showSubtitle)
            
        }
    }
    
    private func runSequence() {
        // 1. Title + icon after line finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showTitle = true
        }

        // 2. Tagline shortly after
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSubtitle = true
        }

        // 3. Transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.55)) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashScreenView(onFinished: {})
}
