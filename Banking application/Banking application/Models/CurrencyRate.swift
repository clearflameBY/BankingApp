//
//  CurrencyRate.swift
//  Banking application
//
//  Created by Илья Степаненко on 13.08.25.
//

struct CurrencyRate: Decodable {
    let curID: Int
    let curAbbreviation: String
    let curScale: Double
    let curName: String
    let curOfficialRate: Double
    
    enum CodingKeys: String, CodingKey {
        case curID = "Cur_ID"
        case curAbbreviation = "Cur_Abbreviation"
        case curScale = "Cur_Scale"
        case curName = "Cur_Name"
        case curOfficialRate = "Cur_OfficialRate"
    }
}
