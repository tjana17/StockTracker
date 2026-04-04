//
//  Double+Extensions.swift
//  StockTracker
//
//  Created by Janarthanan Kannan on 04/04/26.
//

import Foundation

extension Double {
    func rounded(toDecimalPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}
