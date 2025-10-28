//
//  ServiceForPoints.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.10.25.
//
import Foundation
import MapKit

protocol InformationForMapServiceInterface {
    var locationManager: CLLocationManager { get }
    func fetchPlaceDetails(placeID: String, completion: @escaping (GooglePlaceDetails?) -> Void)
    func fetchSuggestions(query: String, completion: @escaping ([GooglePlaceSuggestion]) -> Void)
    func fetchATMs()
    func fetchBanks()
    func addATMsAnnotations()
    func addBanksAnnotations()
    func setupATMsScrollCards()
    func setupBanksScrollCards()
    func showPlaceDetailsScreen(details: GooglePlaceDetails)
}

class InformationForMapService: InformationForMapServiceInterface {
    
    var locationManager = CLLocationManager()
    private let defaultLocation = CLLocationCoordinate2D(latitude: 53.90454, longitude: 27.56152) // Minsk by default
    private let radius = 2000
    private var coordinate: CLLocationCoordinate2D {
        locationManager.location?.coordinate ?? defaultLocation
    }
        
    func fetchPlaceDetails(placeID: String, completion: @escaping (GooglePlaceDetails?) -> Void) {
        // We request exactly those fields that are needed
        let fields = "place_id,name,formatted_address,geometry,opening_hours,current_opening_hours"
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=\(fields)&key=\(MapViewController.googleApiKey)&language=ru"
        
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
    
    func fetchATMs() {

        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&type=atm&key=\(MapViewController.googleApiKey)&language=ru"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Ошибка запроса:", error)
                return
            }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(GoogleNearbyResponse.self, from: data)
                DispatchQueue.main.async {
                    MapViewController.placesATMs = response.results
                    self?.addATMsAnnotations()
                    self?.setupATMsScrollCards()
                }
                if let string = String(data: data, encoding: .utf8) {
                    print("Полученные данные:\n\(string)")
                } else {
                    print("Не удалось преобразовать данные в строку")
                }
            } catch {
                print("Ошибка парсинга:", error)
            }
        }.resume()
    }
    
    func fetchBanks() {

        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&type=bank&key=\(MapViewController.googleApiKey)&language=ru"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Ошибка запроса:", error)
                return
            }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(GoogleNearbyResponse.self, from: data)
                DispatchQueue.main.async {
                    MapViewController.placesBanks = response.results
                    self?.addBanksAnnotations()
                    self?.setupBanksScrollCards()
                }
            } catch {
                print("Ошибка парсинга:", error)
            }
        }.resume()
    }
    
    func addATMsAnnotations() {
        
        for place in MapViewController.placesATMs {
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.vicinity
            annotation.coordinate = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
            MapViewController.customView.mapView.addAnnotation(annotation)
        }
        
        if let first = MapViewController.placesATMs.first {
            MapViewController.customView.mapView.setRegion(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: first.geometry.location.lat, longitude: first.geometry.location.lng),
                    latitudinalMeters: 2000,
                    longitudinalMeters: 2000
                ), animated: true)
        }
    }
    
    func addBanksAnnotations() {
        
        for place in MapViewController.placesBanks {
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.vicinity
            annotation.coordinate = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
            MapViewController.customView.mapView.addAnnotation(annotation)
        }
        
        if let first = MapViewController.placesBanks.first {
            MapViewController.customView.mapView.setRegion(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: first.geometry.location.lat, longitude: first.geometry.location.lng),
                    latitudinalMeters: 2000,
                    longitudinalMeters: 2000
                ), animated: true)
        }
    }
    
    func setupATMsScrollCards() {
        
        for (index, place) in MapViewController.placesATMs.enumerated() {
            let card = UIButton()
            card.backgroundColor = .systemGray3
            card.layer.cornerRadius = 10
            let title = place.vicinity ?? place.name ?? "ATM"
            card.setTitle("Банкомат: " + title, for: .normal)
            card.titleLabel?.font = .systemFont(ofSize: 14)
            card.titleLabel?.numberOfLines = 3
            card.tag = index
            card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
            card.widthAnchor.constraint(equalToConstant: 200).isActive = true
            MapViewController.customView.stackView.addArrangedSubview(card)
        }
    }
    
    func setupBanksScrollCards() {
    
        for (index, place) in MapViewController.placesBanks.enumerated() {
            let card = UIButton()
            card.backgroundColor = .systemGray3
            card.layer.cornerRadius = 10
            let title = place.vicinity ?? place.name ?? "Bank"
            card.setTitle("Отделение банка: " + title, for: .normal)
            card.titleLabel?.font = .systemFont(ofSize: 14)
            card.titleLabel?.numberOfLines = 3
            card.tag = index
            card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
            card.widthAnchor.constraint(equalToConstant: 200).isActive = true
            MapViewController.customView.stackView.addArrangedSubview(card)
        }
    }
    
    @objc private func cardTapped(_ sender: UIButton) {
        MapViewController.places = MapViewController.placesBanks + MapViewController.placesATMs
        let place = MapViewController.places[sender.tag]
        let coord = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
        MapViewController.customView.mapView.setCenter(coord, animated: false)
        
        fetchPlaceDetails(placeID: place.placeID) { [weak self] details in
            DispatchQueue.main.async {
                guard let details = details else { return }
                self?.showPlaceDetailsScreen(details: details)
            }
        }
    }
    
    func showPlaceDetailsScreen(details: GooglePlaceDetails) {
        MapViewController.currentAlertView?.removeFromSuperview()
        let alertWidth = MapViewController.customView.frame.width - 100
        let alertView = WorkSheduleAlert(
            frame: CGRect(x: 50, y: -150, width: alertWidth, height: 270),
            details: details
        )
        MapViewController.customView.addSubview(alertView)
        MapViewController.currentAlertView = alertView
        
        if !MapViewController.isAlertShown {
            UIView.animate(withDuration: 0.3, animations: {
                alertView.frame.origin.y = 100
            })
            MapViewController.isAlertShown = true
        } else {
            alertView.frame.origin.y = 100
        }
    }
}

