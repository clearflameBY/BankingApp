//
//  MetaPrice.swift
//  Banking application
//
//  Created by Илья Степаненко on 22.08.25.
//
import Foundation

struct MetalModel: Equatable, Decodable, Identifiable {
    let id = UUID()
    let date: String
    let metalId: Int
    let value: Double
    
    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case metalId = "MetalId"
        case value = "Value"
    }
}
