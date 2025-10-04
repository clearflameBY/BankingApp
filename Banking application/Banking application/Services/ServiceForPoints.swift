//
//  ServiceForPoints.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.10.25.
//
import Foundation

class ServiceForPoints {
        
    func fetchPlaceDetails(placeID: String, completion: @escaping (GooglePlaceDetails?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&key=\(MapViewController.googleApiKey)&language=ru"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let response = try JSONDecoder().decode(GoogleDetailsResponse.self, from: data)
                completion(response.result)
            } catch {
                print("Ошибка парсинга места:", error)
            }
        }.resume()
    }
    
    func fetchSuggestions(query: String, completion: @escaping ([GooglePlaceSuggestion]) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&key=\(MapViewController.googleApiKey)&language=ru"
        
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let response = try JSONDecoder().decode(GoogleAutocompleteResponse.self, from: data)
                completion(response.predictions)
            } catch {
                print("Ошибка парсинга подсказок:", error)
            }
        }.resume()
    }
}
