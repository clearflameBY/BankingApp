//
//  MapViewComtroller.swift
//  Banking application
//
//  Created by Илья Степаненко on 2.08.25.
//
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            suggestions.removeAll()
            customView.tableView.isHidden = true
            customView.tableView.reloadData()
            return
        }
        
        fetchSuggestions(query: query) { items in
            print(items) // здесь уже массив DgisSuggestItem
        }
    }
    
    private let locationManager = CLLocationManager()
    private let customView = MapView()
    
    var suggestions: [DgisSuggestItem] = []
    private var places: [DgisPlace] = [] // Модель банкоматов
    private let apiKey = "666718af-29db-461a-967f-9b0cb1cc20e5"
    
    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let centerAction = UIAction(handler: { _ in
            self.centerOnUser()
        })
        
        customView.locationButton.addAction(centerAction, for: .touchUpInside)

        customView.searchBar.delegate = self
        customView.tableView.delegate = self
        customView.tableView.dataSource = self
        customView.mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Запросить разрешение
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
                
        setupLocation()
        fetchATMs()
    }
    
    private func centerOnUser() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
            customView.mapView.setRegion(region, animated: true)
        }
    }
    
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        customView.mapView.showsUserLocation = true
    }
    
    private func fetchATMs() {
        let query = "Банкомат"
        let fields = "items.point,items.address"
        let urlString = "https://catalog.api.2gis.com/3.0/items?q=\(query)&fields=\(fields)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Ошибка запроса:", error)
                return
            }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(DgisResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.places = response.result.items
                    self?.addAnnotations()
                    self?.setupScrollCards()
                }
            } catch {
                print("Ошибка парсинга:", error)
            }
        }.resume()
    }
    
    private func addAnnotations() {
        for place in places {
            let annotation = MKPointAnnotation()
            annotation.title = "Банкомат"
            annotation.subtitle = place.address_name
            annotation.coordinate = CLLocationCoordinate2D(latitude: place.point.lat, longitude: place.point.lon)
            customView.mapView.addAnnotation(annotation)
        }
        if let first = places.first {
            customView.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: first.point.lat, longitude: first.point.lon),
                                                 latitudinalMeters: 2000,
                                                 longitudinalMeters: 2000), animated: true)
        }
    }
    
    private func setupScrollCards() {
        customView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, place) in places.enumerated() {
            let card = UIButton()
            card.backgroundColor = .systemGray5
            card.layer.cornerRadius = 10
            card.setTitle(place.address_name, for: .normal)
            card.titleLabel?.font = .systemFont(ofSize: 14)
            card.titleLabel?.numberOfLines = 2
            card.tag = index
            card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
            card.widthAnchor.constraint(equalToConstant: 200).isActive = true
            customView.stackView.addArrangedSubview(card)
        }
    }
    
    // MARK: - Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            suggestions.removeAll()
            customView.tableView.reloadData()
            customView.tableView.isHidden = true
        } else {
            fetchSuggestions(query: searchText) { [weak self] newSuggestions in
                DispatchQueue.main.async {
                    self?.suggestions = newSuggestions
                    self?.customView.tableView.reloadData()
                    self?.customView.tableView.isHidden = newSuggestions.isEmpty
                }
            }
        }
     }
    
    func fetchPlaceDetails(id: String, completion: @escaping (DgisPlace?) -> Void) {
        let apiKey = "666718af-29db-461a-967f-9b0cb1cc20e5"
        let urlString = "https://catalog.api.2gis.com/3.0/items?id=\(id)&fields=items.point,items.name&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let response = try JSONDecoder().decode(DgisItemResponse.self, from: data)
                completion(response.result.items.first)
            } catch {
                print("Ошибка парсинга места:", error)
                completion(nil)
            }
        }.resume()
    }
    
    @objc private func cardTapped(_ sender: UIButton) {
        let place = places[sender.tag]
        let coord = CLLocationCoordinate2D(latitude: place.point.lat, longitude: place.point.lon)
        customView.mapView.setCenter(coord, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation,
              let index = places.firstIndex(where: { $0.address_name == annotation.subtitle }) else { return }
        let xOffset = CGFloat(index) * 210 // ширина карточки + spacing
        customView.scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
    }
}

extension MapViewController {
    func fetchSuggestions(query: String, completion: @escaping ([DgisSuggestItem]) -> Void) {
        let apiKey = "666718af-29db-461a-967f-9b0cb1cc20e5"
        let urlString = "https://catalog.api.2gis.com/3.0/suggests?q=\(query)&key=\(apiKey)"
        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            do {
                let response = try JSONDecoder().decode(DgisSuggestResponse.self, from: data)
                completion(response.result!.items)
            } catch {
                print("Ошибка парсинга подсказок:", error)
                completion([])
            }
        }.resume()
    }
}

extension MapViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let id = suggestion.id else {
            print("Нет ID для подсказки")
            return
        }
        
        fetchPlaceDetails(id: id) { [weak self] place in
            DispatchQueue.main.async {
                guard let self = self, let place = place else { return }
                
                // Перемещаем карту на найденную точку
                let coordinate = CLLocationCoordinate2D(latitude: place.point.lat, longitude: place.point.lon)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.customView.mapView.setRegion(region, animated: true)
                
                // Добавляем маркер
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = place.name
                self.customView.mapView.addAnnotation(annotation)
                
                // ✅ Скрываем список подсказок
                self.suggestions.removeAll()
                tableView.reloadData()
                tableView.isHidden = true
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate (опционально для слежки)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Можно автоматически центрировать на пользователе при старте
    }
}
