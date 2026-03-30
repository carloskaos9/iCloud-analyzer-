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
    private var isUpdating = false
    
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
        guard !isUpdating else { return }
        
        if CLLocationManager.locationServicesEnabled() {
            isUpdating = true
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        isUpdating = false
        locationManager.stopUpdatingLocation()
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.location = location.coordinate
        
        // Stop updating after first successful location
        stopUpdatingLocation()
        
        // Reverse geocode to get city and country
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self?.city = placemark.locality ?? "Desconhecido"
                    self?.country = placemark.country ?? "Desconhecido"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
        if manager.authorizationStatus == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
    
    deinit {
        stopUpdatingLocation()
    }
}
