//
//  MetalPrice.swift
//  Banking application
//
//  Created by Илья Степаненко on 7.09.25.
//


struct MetalPrice: Decodable {
    let date: String
    let metalId: Int
    let value: Double
    
    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case metalId = "MetalId"
        case value = "Value"
    }
}
