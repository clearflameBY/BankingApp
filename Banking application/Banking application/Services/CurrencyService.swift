//
//  CurrencyService.swift
//  Banking application
//
//  Created by Илья Степаненко on 13.08.25.
//

import Foundation
import UIKit

class CurrencyService {
    
    func fetchRatesForCurrency(completion: @escaping (Result<[CurrencyRate], Error>) -> Void) {
        let urlString = "https://api.nbrb.by/exrates/rates?periodicity=0"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let data = data else { return }
            
            do {
                let rates = try JSONDecoder().decode([CurrencyRate].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(rates))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func fetchRatesForMetals(dayForMetalCurrencyString: String) {
        
        let metalsURL = URL(string: "https://api.nbrb.by/bankingots/prices?startdate=\(dayForMetalCurrencyString)&endDate=\(dayForMetalCurrencyString)")!
        
        URLSession.shared.dataTask(with: metalsURL) { data, _, error  in
            guard let data = data else { return }
            do {
                let metals = try JSONDecoder().decode([MetalPrice].self, from: data)
                let filtered = metals.filter { $0.metalId == 0 || $0.metalId == 1 }
                
                DispatchQueue.main.async {
                    for metal in filtered {
                        let name = metal.metalId == 0 ? "Золото" : "Серебро"
                        DashboardViewController.curenciesData.append("\(name): \(metal.value) BYN/грамм")
                    }
                    DashboardViewController.customView.rates.reloadData()
                }
            } catch {
                print("Ошибка парсинга металлов:", error)
                print("Ответ сервера:", String(data: data, encoding: .utf8) ?? "нет данных")
            }
        }.resume()
      
    }
}
