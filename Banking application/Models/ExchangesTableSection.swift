//
//  ExchangeTableSection.swift
//  Banking application
//
//  Created by Илья Степаненко on 1.10.25.
//

enum exchangesTableSection: Int, CaseIterable {
    case favorites
    case fiat
    case crypto
    case metal
    
    var title: String {
        switch self {
        case .favorites: return "Избранные"
        case .fiat: return "Валюты"
        case .crypto: return "Криптовалюты"
        case .metal: return "Драгметаллы"
        }
    }
}
