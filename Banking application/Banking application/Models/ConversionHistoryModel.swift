//
//  CurrencyHistoryModel.swift
//  Banking application
//
//  Created by Илья Степаненко on 1.10.25.
//

import Foundation

struct ConversionHistoryModel {
    let id: UUID
    let valueFrom: Double
    let valueTo: Double
    let currencyFrom: String
    let currencyTo: String
    let date: Date
}
