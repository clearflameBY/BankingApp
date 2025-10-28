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
    let results: [GooglePlace]
}

struct GooglePlace: Codable {
    let name: String?
    let placeID: String
    let geometry: GoogleGeometry
    let vicinity: String?
    let openingHours: PlaceOpenNow? // Nearby: just open_now
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case placeID = "place_id"
        case geometry = "geometry"
        case vicinity = "vicinity"
        case openingHours = "opening_hours"
    }
}

struct PlaceOpenNow: Codable {
    let openNow: Bool
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
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
    
    // Full schedule from Place Details
    let openingHours: OpeningHours?
    let currentOpeningHours: OpeningHours?
    let utcOffsetMinutes: Int?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case formattedAddress = "formatted_address"
        case geometry = "geometry"
        case openingHours = "opening_hours"
        case currentOpeningHours = "current_opening_hours"
        case utcOffsetMinutes = "utc_offset_minutes"
    }
}

// MARK: - Opening hours (Place Details)

struct OpeningHours: Codable {
    // Current "open now" flag
    let openNow: Bool?
    // Text by day of the week (localized, depends on &language=)
    let weekdayText: [String]?
    // Work periods (for parsing by time)
    let periods: [OpeningPeriod]?
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case weekdayText = "weekday_text"
        case periods = "periods"
    }
}

struct OpeningPeriod: Codable {
    let open: OpeningTime?
    let close: OpeningTime?
}

struct OpeningTime: Codable {
    // day: 0 (Sunday) … 6 (Saturday)
    let day: Int?
    // time: "HHmm", for example "0900"
    let time: String?
    // date: "YYYYMMDD" — occurs in current_opening_hours
    let date: String?
}
