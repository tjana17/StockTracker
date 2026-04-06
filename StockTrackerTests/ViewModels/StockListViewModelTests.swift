//
//  StockListViewModelTests.swift
//  StockTrackerTests
//
//  Created by Janarthanan Kannan on 06/04/26.
//

import XCTest
import Combine
@testable import StockTracker

final class StockListViewModelTests: XCTestCase {
    
    private var repository: MockStockRepository!
    private var viewModel: StockListViewModel!
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        repository = MockStockRepository()
        viewModel  = StockListViewModel(repository: repository)
    }

    override func tearDown() {
        cancellables.removeAll()
        viewModel  = nil
        repository = nil
        super.tearDown()
    }

    // Initial state is disconnected with no stocks
    func test_initialState() {
        XCTAssertEqual(viewModel.connectionState, .disconnected)
        XCTAssertTrue(viewModel.displayedStocks.isEmpty)
    }

    // Toggling connection calls through to the repository
    func test_toggleConnection_connectsAndDisconnects() {
        viewModel.toggleConnection()
        XCTAssertTrue(repository.connectCalled)

        repository.emit(state: .connected)
        wait(for: viewModel.$connectionState.filter { $0 == .connected }, timeout: 1.0)

        viewModel.toggleConnection()
        XCTAssertTrue(repository.disconnectCalled)
    }

    // Stock list populates when the repository emits
    func test_stocks_populateFromRepository() {
        repository.emit(stocks: StockData.initialStocks)
        wait(for: viewModel.$displayedStocks.filter { !$0.isEmpty }, timeout: 1.0)
        XCTAssertEqual(viewModel.displayedStocks.count, StockData.initialStocks.count)
    }

    // Sorting by price produces descending order
    func test_sortByPrice_isDescending() {
        repository.emit(stocks: StockData.initialStocks)
        wait(for: viewModel.$displayedStocks.filter { !$0.isEmpty }, timeout: 1.0)

        viewModel.sortOption = .byPrice

        let prices = viewModel.displayedStocks.map(\.price)
        XCTAssertEqual(prices, prices.sorted(by: >))
    }

    // MARK: - Helpers

    private func wait<P: Publisher>(for publisher: P, timeout: TimeInterval) where P.Output: Any, P.Failure == Never {
        let exp = expectation(description: "publisher")
        publisher.first().sink { _ in exp.fulfill() }.store(in: &cancellables)
        wait(for: [exp], timeout: timeout)
    }

}
