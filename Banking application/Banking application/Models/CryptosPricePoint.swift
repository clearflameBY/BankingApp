//
//  CryptoPricePoint.swift
//  Banking application
//
//  Created by Илья Степаненко on 15.09.25.
//
import Foundation

struct CryptosPricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
}
