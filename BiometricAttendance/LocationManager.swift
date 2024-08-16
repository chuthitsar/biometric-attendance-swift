//
//  LocationManager.swift
//  BiometricAttendance
//
//  Created by Chu Thit Sar on 8/6/24.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    var coordinatesPublisher = PassthroughSubject<CLLocationCoordinate2D, Error>()
        var deniedLocationAccessPublisher = PassthroughSubject<Void, Never>()

        private override init() {
            super.init()
        }
        static let shared = LocationManager()

        private lazy var locationManager: CLLocationManager = {
            let manager = CLLocationManager()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.delegate = self
            return manager
        }()

        func requestLocationUpdates() {
            switch locationManager.authorizationStatus {
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                
            default:
                deniedLocationAccessPublisher.send()
            }
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
                
            case .authorizedWhenInUse, .authorizedAlways:
                manager.startUpdatingLocation()
                
            default:
                manager.stopUpdatingLocation()
                deniedLocationAccessPublisher.send()
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            print(locations)
            guard let location = locations.last else { return }
            coordinatesPublisher.send(location.coordinate)
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            coordinatesPublisher.send(completion: .failure(error))
        }
}

