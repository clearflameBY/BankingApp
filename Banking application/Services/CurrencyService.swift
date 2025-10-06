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
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchRatesForMetals(dayForMetalCurrencyString: String, completion: @escaping (Result<[MetalModel], Error>) -> Void) {
        
        let urlString = "https://api.nbrb.by/bankingots/prices?startdate=\(dayForMetalCurrencyString)&endDate=\(dayForMetalCurrencyString)"
        guard let metalsURL = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: metalsURL) { data, _, error  in
            guard let data = data else { return }
            
            do {
                let metals = try JSONDecoder().decode([MetalModel].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(metals))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchCryptoPrice(crypto: String, completion: @escaping (Double?) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(crypto)&vs_currencies=usd"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                var price : Double? = nil
                if crypto == "bitcoin" {
                    let result = try JSONDecoder().decode(BitcoinPriceResponse.self, from: data)
                    price = result.bitcoin["usd"]
                } else if crypto == "ethereum" {
                    let result = try JSONDecoder().decode(EthereumPriceResponse.self, from: data)
                    price = result.ethereum["usd"]
                }
                completion(price)
            } catch {
                print("Ошибка парсинга: \(error)")
            }
        }.resume()
    }
}
