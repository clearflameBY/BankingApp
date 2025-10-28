//
//  CurrencyServiceForCharts.swift
//  Banking application
//
//  Created by Илья Степаненко on 24.08.25.
//

import Foundation

protocol CurrencyServiceForChartsInterface {
    func fetchHistoryForCurrency(curId: Int, startDate: String, endDate: String, completion: @escaping ([CurrencyHistory]) -> Void)
    func fetchHistoryForMetals(curId: Int, startDate: String, endDate: String, completion: @escaping ([MetalModel]) -> Void)
    func fetchHistoryForCryptos(for coinID: String, completion: @escaping ([CryptosPricePoint]) -> Void)
}

class CurrencyServiceForCharts: CurrencyServiceForChartsInterface {
    
    func fetchHistoryForCurrency(curId: Int, startDate: String, endDate: String, completion: @escaping ([CurrencyHistory]) -> Void) {
        let urlString = "https://api.nbrb.by/ExRates/Rates/Dynamics/\(curId)?startDate=\(startDate)&endDate=\(endDate)"
        guard let url = URL(string: urlString) else {
        completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let history = try? JSONDecoder().decode([CurrencyHistory].self, from: data)
                completion(history ?? [])
            } else {
                completion([])
            }
        }.resume()
    }
    
    func fetchHistoryForMetals(curId: Int, startDate: String, endDate: String, completion: @escaping ([MetalModel]) -> Void) {
        let urlString = "https://api.nbrb.by/bankingots/prices?startdate=\(startDate)&endDate=\(endDate)"
        guard let url = URL(string: urlString) else {
        completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                let history = try? JSONDecoder().decode([MetalModel].self, from: data)
                let filteredHistory = history?.filter { $0.metalId == curId }
                completion(filteredHistory ?? [])
            } else {
                completion([])
            }
        }.resume()
    }
    
    func fetchHistoryForCryptos(for coinID: String, completion: @escaping ([CryptosPricePoint]) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/coins/\(coinID)/market_chart?vs_currency=usd&days=7"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let prices = json["prices"] as? [[Any]] {
                    let points = prices.compactMap { entry -> CryptosPricePoint? in
                        guard let timestamp = entry[0] as? Double,
                              let price = entry[1] as? Double else { return nil }
                        let date = Date(timeIntervalSince1970: timestamp / 1000)
                        return CryptosPricePoint(date: date, price: price)
                    }
                    DispatchQueue.main.async {
                        completion(points)
                    }
                }
            } catch {
                print("Ошибка парсинга: \(error)")
            }
        }.resume()
    }
}
