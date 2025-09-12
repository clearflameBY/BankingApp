//
//  ModelForMap.swift
//  Banking application
//
//  Created by Илья Степаненко on 1.09.25.
//

struct DgisResponse: Codable {
    let result: DgisResult
}

struct DgisResult: Codable {
    let items: [DgisPlace]
}

struct DgisPlace: Codable {
    let id: String
    let point: DgisPoint
    let address_name: String?
    let name: String
}

struct DgisPoint: Codable {
    let lat: Double
    let lon: Double
}

struct DgisSuggestResponse: Codable {
    let result: SuggestResult?
}

struct SuggestResult: Codable {
    let items: [DgisSuggestItem]
}

struct DgisSuggestItem: Codable {
    let name: String
    let id: String?
}

struct Point: Codable {
    let lat: Double
    let lon: Double
}

struct DgisItemResponse: Codable {
    let result: DgisItemResult
}

struct DgisItemResult: Codable {
    let items: [DgisPlace]
}
