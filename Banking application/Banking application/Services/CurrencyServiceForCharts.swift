//
//  CurrencyServiceForCharts.swift
//  Banking application
//
//  Created by Илья Степаненко on 24.08.25.
//

import Foundation

class CurrencyServiceForCharts {
    
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
}
