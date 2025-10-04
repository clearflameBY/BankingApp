//
//  MapViewController.swift
//  Banking application
//
// 
//

import UIKit
import MapKit
import CoreLocation

// MARK: - MapViewController

class MapViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private let customView = MapView()
    private let service = ServiceForPoints()
    
    private var suggestions: [GooglePlaceSuggestion] = []
    private var placesATMs: [GooglePlace] = []
    private var placesBanks: [GooglePlace] = []
    static let googleApiKey = "AIzaSyCQ3rPW1TAZX1VDjzlT7ichtTaNeIeeOGw"
    private let defaultLocation = CLLocationCoordinate2D(latitude: 53.90454, longitude: 27.56152) // Минск, по умолчанию
    private var coordinate: CLLocationCoordinate2D {
        locationManager.location?.coordinate ?? defaultLocation
    }
    private let radius = 2000 // метров
    
    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        customView.tableView.isHidden = true
        let centerAction = UIAction(handler: { _ in
            self.centerOnUser()
        })
        
        let recognizerHideKeyboard = UITapGestureRecognizer(target: customView, action: #selector(customView.endEditing))
        recognizerHideKeyboard.cancelsTouchesInView = false
        customView.addGestureRecognizer(recognizerHideKeyboard)
        
        customView.locationButton.addAction(centerAction, for: .touchUpInside)

        customView.searchBar.delegate = self
        customView.tableView.delegate = self
        customView.tableView.dataSource = self
        customView.mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
        setupLocation()
        
        // Обновляем точки: сначала очищаем, затем подтягиваем оба типа
        //places.removeAll()
        fetchATMs()
        fetchBanks()
    }
    
    private func centerOnUser() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
            customView.mapView.setRegion(region, animated: true)
        }
    }
    
    private func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        customView.mapView.showsUserLocation = true
        // Используем текущее местоположение пользователя, если возможно
    }
    
//    // Добавить новые места к общему массиву без дубликатов по placeID
//    private func mergePlaces(_ new: [GooglePlace]) {
//        let existingIDs = Set(places.map { $0.placeID })
//        let filtered = new.filter { !existingIDs.contains($0.placeID) }
//        places.append(contentsOf: filtered)
//    }
    
    private func fetchATMs() {

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
                    // ДОБАВЛЯЕМ массив к другому массиву без дубликатов
                    self?.placesATMs = response.results
                    self?.addAnnotations()
                    self?.setupScrollCards()
                }
            } catch {
                print("Ошибка парсинга:", error)
            }
        }.resume()
    }
    
    private func fetchBanks() {

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
                    // ДОБАВЛЯЕМ массив к другому массиву без дубликатов
                    self?.placesBanks = response.results
                    self?.addAnnotations()
                    self?.setupScrollCards()
                }
            } catch {
                print("Ошибка парсинга:", error)
            }
        }.resume()
    }
    
    private func addAnnotations() {
        customView.mapView.removeAnnotations(customView.mapView.annotations)
        for place in placesATMs {
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.vicinity
            annotation.coordinate = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
            customView.mapView.addAnnotation(annotation)
        }
        if let first = placesATMs.first {
            customView.mapView.setRegion(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: first.geometry.location.lat, longitude: first.geometry.location.lng),
                    latitudinalMeters: 2000,
                    longitudinalMeters: 2000
                ), animated: true)
        }
        
        for place in placesBanks {
            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.vicinity
            annotation.coordinate = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
            customView.mapView.addAnnotation(annotation)
        }
        if let first = placesBanks.first {
            customView.mapView.setRegion(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: first.geometry.location.lat, longitude: first.geometry.location.lng),
                    latitudinalMeters: 2000,
                    longitudinalMeters: 2000
                ), animated: true)
        }
    }
    
    private func setupScrollCards() {
        customView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, place) in placesATMs.enumerated() {
            let card = UIButton()
            card.backgroundColor = .systemGray5
            card.layer.cornerRadius = 10
            card.setTitle(place.vicinity ?? place.name ?? "ATM", for: .normal)
            card.titleLabel?.font = .systemFont(ofSize: 14)
            card.titleLabel?.numberOfLines = 2
            card.tag = index
            card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
            card.widthAnchor.constraint(equalToConstant: 200).isActive = true
            customView.stackView.addArrangedSubview(card)
        }
    }
    
    @objc private func cardTapped(_ sender: UIButton) {
        let place = placesATMs[sender.tag]
        let coord = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
        customView.mapView.setCenter(coord, animated: false)
    }
}

extension MapViewController: UISearchBarDelegate  {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            suggestions.removeAll()
            customView.tableView.reloadData()
            customView.tableView.isHidden = true
        } else {
            service.fetchSuggestions(query: searchText) { [weak self] newSuggestions in
                DispatchQueue.main.async {
                    self?.suggestions = newSuggestions
                    self?.customView.tableView.reloadData()
                    self?.customView.tableView.isHidden = false
                    self?.customView.tableView.isHidden = newSuggestions.isEmpty
                }
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Не перекрашивать пользовательский "синий кружок"
        if annotation is MKUserLocation { return nil }

        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")

        // Найдём объект в массиве placesATMs по координате
        if placesATMs.first(where: {
            $0.geometry.location.lat == annotation.coordinate.latitude &&
            $0.geometry.location.lng == annotation.coordinate.longitude
        }) != nil {
                annotationView.markerTintColor = .systemRed
            }
        
        // Найдём объект в массиве placesBanks по координате
        if placesBanks.first(where: {
            $0.geometry.location.lat == annotation.coordinate.latitude &&
            $0.geometry.location.lng == annotation.coordinate.longitude
        }) != nil {
                annotationView.markerTintColor = .systemBlue
            }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let places = placesATMs + placesBanks
        
        guard let annotation = view.annotation,
              let index = places.firstIndex(where: {
                  $0.geometry.location.lat == annotation.coordinate.latitude &&
                  $0.geometry.location.lng == annotation.coordinate.longitude
              }) else { return }
        
        let xOffset = CGFloat(index) * 210 // ширина карточки + spacing
        customView.scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
    }
}

extension MapViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row].description
        return cell
    }
}

extension MapViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let suggestion = suggestions[indexPath.row]

        service.fetchPlaceDetails(placeID: suggestion.placeID) { [weak self] placeDetails in
            DispatchQueue.main.async {
                guard let self = self, let placeDetails = placeDetails else { return }
                
                // Перемещаем карту на найденную точку
                let coordinate = CLLocationCoordinate2D(
                    latitude: placeDetails.geometry.location.lat,
                    longitude: placeDetails.geometry.location.lng)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.customView.mapView.setRegion(region, animated: true)
                
                // Добавляем маркер
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = placeDetails.name
                annotation.subtitle = placeDetails.formattedAddress
                self.customView.mapView.addAnnotation(annotation)
                
                // ✅ Скрываем список подсказок
                self.suggestions.removeAll()
                tableView.reloadData()
                tableView.isHidden = true
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    // MARK: (если нужно использовать)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Можно автоматически центрировать на пользователе при старте
    }
}
