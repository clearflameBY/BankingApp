//
//  CurrencyData.swift
//  Banking application
//
//  Created by Илья Степаненко on 24.08.25.
//

import Foundation

struct CurrencyHistory: Decodable, Identifiable {
    let id = UUID()
    let date: String
    let curOfficialRate: Double
    
    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case curOfficialRate = "Cur_OfficialRate"
    }
}
