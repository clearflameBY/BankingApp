//
//  GoogleAPIModels.swift
//  Banking application
//
//  Created by Илья Степаненко on 1.09.25.
//

// MARK: - Google Places API Responses

struct GoogleAutocompleteResponse: Codable {
    let predictions: [GooglePlaceSuggestion]
}

struct GooglePlaceSuggestion: Codable {
    let description: String
    let place_id: String
}

struct GoogleNearbyResponse: Codable {
    let results: [GoogleATMPlace]
}

struct GoogleATMPlace: Codable {
    let name: String?
    let place_id: String
    let geometry: GoogleGeometry
    let vicinity: String?
}

struct GoogleGeometry: Codable {
    let location: GoogleLocation
}

struct GoogleLocation: Codable {
    let lat: Double
    let lng: Double
}

struct GoogleDetailsResponse: Codable {
    let result: GooglePlaceDetails
}

struct GooglePlaceDetails: Codable {
    let name: String
    let formatted_address: String?
    let geometry: GoogleGeometry
}
