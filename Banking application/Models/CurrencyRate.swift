//
//  CurrencyRate.swift
//  Banking application
//
//  Created by Илья Степаненко on 13.08.25.
//
import Foundation

struct CurrencyRate: Decodable, Identifiable {
    let id = UUID()
    let date: String
    let curOfficialRate: Double
    let curID: Int
    let curAbbreviation: String
    let curScale: Double
    let curName: String
    
    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case curOfficialRate = "Cur_OfficialRate"
        case curID = "Cur_ID"
        case curAbbreviation = "Cur_Abbreviation"
        case curScale = "Cur_Scale"
        case curName = "Cur_Name"
    }
}

struct CurrencyRate2: Codable {
    let name: String   // "USD"
    let fullName: String // "Доллар США"
    let rate: Double   // курс
    let type: CurrencyType
}

enum CurrencyType: String, Codable {
    case fiat
    case crypto
    case metal
}
