//
//  CoinPriceResponce.swift
//  Banking application
//
//  Created by Илья Степаненко on 15.09.25.
//

struct BitcoinPriceResponse: Decodable {
    let bitcoin: [String: Double]
}

struct EthereumPriceResponse: Decodable {
    let ethereum: [String: Double]
}
