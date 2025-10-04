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
    let placeID: String
    
    enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case description = "description"
    }
}

struct GoogleNearbyResponse: Codable {
    let results: [GoogleATMPlace]
}

struct GoogleATMPlace: Codable {
    let name: String?
    let placeID: String
    let geometry: GoogleGeometry
    let vicinity: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case placeID = "place_id"
        case geometry = "geometry"
        case vicinity = "vicinity"
    }
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
    let formattedAddress: String?
    let geometry: GoogleGeometry
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case formattedAddress = "formatted_address"
        case geometry = "geometry"
    }
}
