# Stock Tracker

A real-time stock price tracking iOS app built with SwiftUI, Combine, and WebSocket connectivity. 
Follows Clean Architecture with MVVM pattern using only native iOS frameworks.

---

## Features

- **Real-Time Price Updates** — WebSocket-based live price streaming with 1-second refresh intervals
- **Major US Stocks** — Pre-loaded with AAPL, GOOG, TSLA, AMZN, MSFT, NVDA, META, and more
- **Price Change Visualization** — Color-coded indicators (green/red) with animated numeric transitions
- **Flash Animation** — Rows flash on price updates to draw attention to changes
- **Connection Management** — Start/stop WebSocket connection with a single tap
- **Connection Status Badge** — Animated pulsing dot indicating live connection state
- **Sorting Options** — Sort by default, by price (descending), or by change (descending)
- **Stock Detail View** — Company description, live price, and change percentage per stock
- **Auto-Reconnect** — Exponential backoff reconnection (up to 5 attempts)

---

## Requirements

| Requirement | Version |
|---|---|
| iOS | 17.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |
| macOS (for development) | 14.0+ (Sonoma) |

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/tjana/StockTracker.git
cd "StockTracker"
```

### 2. Open in Xcode

```bash
open "StockTracker.xcodeproj"
```

### 3. Build and Run

- Select a simulator (iPhone 15 or later recommended) or a physical device
- Press `Cmd + R` or click the **Run** button
- No external dependencies — no `pod install` or `swift package resolve` required

---

## Project Structure

```
StockTracker/
├── App/
│   └── StockTrackerApp.swift       # App entry point
│
├── DI/
│   └── AppContainer.swift                 # Dependency injection container
│
├── Domain/
│   └── Entities/
│       ├── Stock.swift                    # Stock model
│       └── StockData.swift                # Seed stocks + company descriptions
│       └── ConnectionState.swift          # ConnectionState enum
│
├── Data/
│   ├── Network/
│   │   └── WebSocketManager.swift         # URLSession WebSocket + reconnect logic
│   └── Repositories/
│       └── StockRepository.swift          # Repository + price update simulation
│
├── Presentation/
│   ├── StockList/
│   │   ├── StockListView.swift            # Main list screen
│   │   └── StockListViewModel.swift       # List ViewModel (sorting, connection)
│   ├── StockDetail/
│   │   ├── StockDetailView.swift          # Detail screen
│   │   └── StockDetailViewModel.swift     # Detail ViewModel (live tracking)
│   └── Components/
│       ├── StockRowView.swift             # List row with flash animation
│       ├── PriceChangeView.swift          # Reusable price change badge
│       └── ConnectionStatusView.swift     # Animated connection status badge
│
└── Assets.xcassets/                       # App icons and accent color

```

---

## Architecture

The app follows **Clean Architecture** with three distinct layers and an **MVVM** presentation pattern.

```
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│                                                              │
│   StockListView  ◄──►  StockListViewModel                   │
│   ├── ConnectionStatusView                                   │
│   ├── StockRowView ◄── PriceChangeView (compact)            │
│   └── StockDetailView  ◄──►  StockDetailViewModel           │
│          └── PriceChangeView (large)                        │
└──────────────────────────┬───────────────────────────────────┘
                           │ @Published / Combine
┌──────────────────────────▼───────────────────────────────────┐
│                      DATA LAYER                              │
│                                                              │
│   StockRepository (StockRepositoryProtocol)                 │
│   ├── stocksPublisher: CurrentValueSubject<[Stock]>         │
│   ├── connectionStatePublisher                              │
│   ├── connect() / disconnect()                              │
│   └── processMessage() + startSimulation()                  │
│                          │                                   │
│   WebSocketManager (WebSocketManagerProtocol)               │
│   ├── statePublisher                                        │
│   ├── messagePublisher                                      │
│   └── Exponential backoff (max 5 retries)                   │
└──────────────────────────┬───────────────────────────────────┘
                           │
                  URLSessionWebSocketTask
              (wss://ws.postman-echo.com/raw)
```

### Data Flow

1. User taps **Start** → `toggleConnection()` → `repository.connect()`
2. WebSocket transitions: `.disconnected` → `.connecting` → `.connected`
3. A 1-second timer fires, sending JSON updates for 3 random stocks per tick
4. `processMessage()` decodes the payload and recalculates price/change
5. `stocksSubject` emits the updated `[Stock]` array
6. ViewModels receive updates via Combine, Views re-render automatically

---

## Design Patterns

| Pattern | Usage |
|---|---|
| MVVM | Views observe `@Published` properties on ViewModels |
| Repository | Abstracts data source behind `StockRepositoryProtocol` |
| Dependency Injection | `AppContainer` singleton wires dependencies at startup |
| Protocol-Oriented | Protocols for WebSocket and Repository enable mock injection |
| Combine | Reactive publishers replace delegate callbacks and notifications |

---

## WebSocket & Resilience

- **Endpoint:** `wss://ws.postman-echo.com/raw` (echo server for simulation)
- **Message format:** `{"symbol": "AAPL", "price": 185.50}`
- **Reconnect strategy:** Exponential backoff — delays of 2, 4, 8, 16, 32 seconds (capped at 30s), max 5 attempts
- **Manual disconnect:** Cancels pending reconnects to avoid background reconnection after user action

---

## Unit Tests

Run tests with `Cmd + U` in Xcode.

### StockListViewModelTests (4 tests)

| Test | Description |
|---|---|
| `test_initialState` | ViewModel starts disconnected with an empty stock list |
| `test_toggleConnection_connectsAndDisconnects` | Toggling calls connect then disconnect on the repository |
| `test_stocks_populateFromRepository` | Stock list updates when the repository emits stocks |
| `test_sortByPrice_isDescending` | Sorting by price produces a descending order |

### StockRepositoryTests (4 tests)

| Test | Description |
|---|---|
| `test_connectionLifecycle` | `connect()` and `disconnect()` each delegate to WebSocketManager |
| `test_receivedMessage_updatesStockWithCorrectChange` | Valid JSON updates the stock price and computes change accurately |
| `test_malformedMessage_doesNotCrash` | Malformed JSON is silently ignored without crashing |
| `test_unknownSymbol_doesNotAlterStocks` | Unknown ticker symbols do not trigger a stocks emission |

---

## Stocks Included

| Symbol | Company |
|---|---|
| AAPL | Apple Inc. |
| GOOG | Alphabet Inc. |
| TSLA | Tesla Inc. |
| AMZN | Amazon.com Inc. |
| MSFT | Microsoft Corporation |
| NVDA | NVIDIA Corporation |
| META | Meta Platforms Inc. |
| BRKB | Berkshire Hathaway |
| JPM | JPMorgan Chase |
| V | Visa Inc. |
| MA | Mastercard Inc. |
| CVX | Chevron Corporation |
| BAC | Bank of America |
| DIS | The Walt Disney Company |

---

## Dependencies

None. The app uses only native Apple frameworks:

- **SwiftUI** — Declarative UI
- **Combine** — Reactive data binding
- **Foundation** — URLSession WebSocket API
- **XCTest** — Unit testing

---

<h3>Screens</h3>
<hr>
<div style="float:left">
<img src="Screen/stock_tracker.gif"  width = "393" height = "852" />
</div>

## License

This project is available for personal and educational use.
