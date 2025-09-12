//
//  2GisService.swift
//  Banking application
//
//  Created by Илья Степаненко on 1.09.25.

//import Foundation
//
//final class DgisService {
//    private let apiKey = "666718af-29db-461a-967f-9b0cb1cc20e5" // вставь сюда ключ от 2GIS
//    private let baseURL = "https://catalog.api.2gis.com/3.0/items"
//
//    func searchPlaces(query: String, completion: @escaping (Result<[DgisPlace], Error>) -> Void) {
//        guard var urlComponents = URLComponents(string: baseURL) else {
//            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
//            return
//        }
//        
//        urlComponents.queryItems = [
//            URLQueryItem(name: "q", value: query),
//            URLQueryItem(name: "key", value: apiKey),
//            URLQueryItem(name: "fields", value: "items.point,items.address")
//        ]
//        
//        guard let url = urlComponents.url else {
//            completion(.failure(NSError(domain: "Invalid URL components", code: -1)))
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let data = data else {
//                completion(.failure(NSError(domain: "No data", code: -1)))
//                return
//            }
//            
//            do {
//                let response = try JSONDecoder().decode(DgisResponse.self, from: data)
//                completion(.success(response.result.items))
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
//}
