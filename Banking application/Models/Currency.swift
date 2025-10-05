//
//  Currency.swift
//  Banking application
//
//  Created by Илья Степаненко on 19.09.25.
//

struct Currency: Codable, Equatable {
    let code: String
    let name: String
    var isFavorite: Bool
}
