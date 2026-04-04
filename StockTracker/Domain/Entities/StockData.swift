//
//  StockData.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import Foundation

// MARK: - Seed data (25 symbols)

enum StockData {

    static let initialStocks: [Stock] = [
        make("AAPL",  "Apple Inc.",                    182.50),
        make("GOOG",  "Alphabet Inc.",                 141.80),
        make("TSLA",  "Tesla Inc.",                    238.45),
        make("AMZN",  "Amazon.com Inc.",               178.25),
        make("MSFT",  "Microsoft Corp.",               374.00),
        make("NVDA",  "NVIDIA Corp.",                  485.30),
        make("META",  "Meta Platforms Inc.",           325.60),
        make("JPM",   "JPMorgan Chase & Co.",          197.45),
        make("V",     "Visa Inc.",                     256.80),
        make("MA",    "Mastercard Inc.",               415.60),
        make("CVX",   "Chevron Corp.",                 152.40),
        make("BAC",   "Bank of America Corp.",          33.20),
        make("DIS",   "The Walt Disney Co.",            91.45),
    ]

    static func description(for symbol: String) -> String {
        descriptions[symbol] ?? "A leading publicly traded company listed on major US stock exchanges."
    }

    // MARK: - Private helpers

    private static func make(_ symbol: String, _ name: String, _ price: Double) -> Stock {
        Stock(id: symbol, symbol: symbol, name: name,
              price: price, previousPrice: price, change: 0, changePercent: 0)
    }

    // Static descriptions taken from google. for showing a description text based on companies.
    private static let descriptions: [String: String] = [
        "AAPL":  "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide.",
        "GOOG":  "Alphabet Inc. operates through Google Services, Google Cloud, and Other Bets.",
        "TSLA":  "Tesla, Inc. designs, develops, manufactures, leases, and sells battery electric vehicles, solar energy products, and energy storage systems.",
        "AMZN":  "Amazon.com, Inc. operates the world's largest e-commerce marketplace and cloud computing platform (AWS).",
        "MSFT":  "Microsoft Corporation develops and supports software, services, devices, and solutions worldwide.",
        "NVDA":  "NVIDIA Corporation pioneered GPU-accelerated computing.",
        "META":  "Meta Platforms, Inc. builds technologies that help people connect.",
        "JPM":   "JPMorgan Chase & Co. is the largest US bank by assets, providing consumer banking, investment banking.",
        "V":     "Visa Inc. operates the world's largest retail electronic payments network, enabling fast, secure transactions between consumers, merchants, financial institutions, and governments across 200+ countries.",
        "MA":    "Mastercard Incorporated is a global technology company operating one of the world's fastest payment processing networks, connecting consumers, financial institutions, merchants, and governments through its multi-rail network.",
        "CVX":   "Chevron Corporation is a multinational energy company engaged in integrated energy and chemicals operations worldwide, with upstream exploration and production, downstream refining, and growing renewable energy investments.",
        "BAC":   "Bank of America Corporation serves approximately 68 million consumer and small business clients through retail banking, wealth management (Merrill), and one of the largest investment banking platforms in the world.",
        "DIS":   "The Walt Disney Company is a diversified worldwide entertainment company with segments in film, streaming (Disney+, Hulu, ESPN+), theme parks, merchandise licensing, and broadcast television (ABC, ESPN).",
    ]
}
