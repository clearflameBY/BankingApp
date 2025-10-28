//
//  MapViewController.swift
//  Banking application
//
// 
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    static let customView = MapView()
    private let service: InformationForMapServiceInterface
    
    private var suggestions: [GooglePlaceSuggestion] = []
    static var placesATMs: [GooglePlace] = []
    static var placesBanks: [GooglePlace] = []
    static var places: [GooglePlace] = []
    static let googleApiKey = "AIzaSyCQ3rPW1TAZX1VDjzlT7ichtTaNeIeeOGw"
    static var isAlertShown: Bool = false
    static var currentAlertView: WorkSheduleAlert?
    
    init(service: InformationForMapServiceInterface) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    override func loadView() {
        view = MapViewController.customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Карта"

        MapViewController.customView.tableView.isHidden = true
        let centerAction = UIAction(handler: { _ in
            self.centerOnUser()
        })
        
        MapViewController.customView.filterPoints.addAction(UIAction { [self] _ in
            switch MapViewController.customView.filterPoints.selectedSegmentIndex {
            case 0:
                MapViewController.customView.mapView.removeAnnotations(MapViewController.customView.mapView.annotations)
                MapViewController.customView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                service.addATMsAnnotations()
                service.setupATMsScrollCards()
                service.addBanksAnnotations()
                service.setupBanksScrollCards()
            case 1:
                MapViewController.customView.mapView.removeAnnotations(MapViewController.customView.mapView.annotations)
                MapViewController.customView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                service.addBanksAnnotations()
                service.setupBanksScrollCards()
            case 2:
                MapViewController.customView.mapView.removeAnnotations(MapViewController.customView.mapView.annotations)
                MapViewController.customView.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
                service.addATMsAnnotations()
                service.setupATMsScrollCards()
            default:
                return
            }
        }, for: .valueChanged)
        
        let recognizerHideKeyboard = UITapGestureRecognizer(target: MapViewController.customView, action: #selector(MapViewController.customView.endEditing))
        recognizerHideKeyboard.cancelsTouchesInView = false
        MapViewController.customView.addGestureRecognizer(recognizerHideKeyboard)
        
        MapViewController.customView.locationButton.addAction(centerAction, for: .touchUpInside)

        MapViewController.customView.searchBar.delegate = self
        MapViewController.customView.tableView.delegate = self
        MapViewController.customView.tableView.dataSource = self
        MapViewController.customView.mapView.delegate = self
        
        service.locationManager.delegate = self
        service.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
        setupLocation()
        service.fetchATMs()
        service.fetchBanks()
    }
    
    private func centerOnUser() {
        if let location = service.locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
            MapViewController.customView.mapView.setRegion(region, animated: true)
        }
    }
    
    private func setupLocation() {
        service.locationManager.requestWhenInUseAuthorization()
        service.locationManager.startUpdatingLocation()
        MapViewController.customView.mapView.showsUserLocation = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MapViewController: UISearchBarDelegate  {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            suggestions.removeAll()
            MapViewController.customView.tableView.reloadData()
            MapViewController.customView.tableView.isHidden = true
        } else {
            service.fetchSuggestions(query: searchText) { [weak self] newSuggestions in
                DispatchQueue.main.async {
                    self?.suggestions = newSuggestions
                    MapViewController.customView.tableView.reloadData()
                    MapViewController.customView.tableView.isHidden = false
                    MapViewController.customView.tableView.isHidden = newSuggestions.isEmpty
                }
            }
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't recolor the custom "blue circle"
        if annotation is MKUserLocation { return nil }

        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "something")

        // Find an object in the placesATMs array by coordinate
        if MapViewController.placesATMs.first(where: {
            $0.geometry.location.lat == annotation.coordinate.latitude &&
            $0.geometry.location.lng == annotation.coordinate.longitude
        }) != nil {
                annotationView.markerTintColor = .systemRed
            }
        
        // Find an object in the placesBanks array by coordinate
        if MapViewController.placesBanks.first(where: {
            $0.geometry.location.lat == annotation.coordinate.latitude &&
            $0.geometry.location.lng == annotation.coordinate.longitude
        }) != nil {
                annotationView.markerTintColor = .systemBlue
            }
        
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        MapViewController.places = MapViewController.placesATMs + MapViewController.placesBanks
        
        guard let annotation = view.annotation,
              let index = MapViewController.places.firstIndex(where: {
                  $0.geometry.location.lat == annotation.coordinate.latitude &&
                  $0.geometry.location.lng == annotation.coordinate.longitude
              }) else { return }
        
        let xOffset = CGFloat(index) * 210 // card width + spacing
        MapViewController.customView.scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
        
        // Load details and open the operating mode screen
        let place = MapViewController.places[index]
        service.fetchPlaceDetails(placeID: place.placeID) { [weak self] details in
            DispatchQueue.main.async {
                guard let details = details else { return }
                self?.service.showPlaceDetailsScreen(details: details)
            }
        }
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
                
                // Move the map to the found point
                let coordinate = CLLocationCoordinate2D(
                    latitude: placeDetails.geometry.location.lat,
                    longitude: placeDetails.geometry.location.lng)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                MapViewController.customView.mapView.setRegion(region, animated: true)
                
                // Add a marker
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = placeDetails.name
                annotation.subtitle = placeDetails.formattedAddress
                MapViewController.customView.mapView.addAnnotation(annotation)
                
                // ✅ Hide the list of suggestions
                self.suggestions.removeAll()
                tableView.reloadData()
                tableView.isHidden = true
                
                // Open the screen with the operating mode
                self.service.showPlaceDetailsScreen(details: placeDetails)
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    // MARK: (if needed to use)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Can be automatically centered on the user on startup
    }
}

