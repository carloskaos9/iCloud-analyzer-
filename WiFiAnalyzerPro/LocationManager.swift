import Foundation
import CoreLocation
import Combine

@MainActor
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    @Published var city: String = "Desconhecido"
    @Published var country: String = "Desconhecido"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkAuthorizationStatus()
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.location = location.coordinate
        
        // Reverse geocode to get city and country
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self?.city = placemark.locality ?? "Desconhecido"
                    self?.country = placemark.country ?? "Desconhecido"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
        if manager.authorizationStatus == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
}
