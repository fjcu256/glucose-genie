//
//  GroceryStoreViewModel.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 4/14/25.
//

import Foundation
import MapKit
import _MapKit_SwiftUI

class GroceryStoreViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    //used for the map view
    @Published var cameraPosition: MapCameraPosition = .automatic
    
    @Published var isLocationAuthorized = false


    //initialized to Apple HQ coordinates
    private var userRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))


    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            isLocationAuthorized = true
            manager.startUpdatingLocation()
        }
        else {
            isLocationAuthorized = false
        }
    }

    //location updater
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            let region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self.cameraPosition = .region(region)
        }
        
        userRegion = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    //getter so the store searcher knows what region to search in
    func getRegion() -> MKCoordinateRegion {
        return userRegion
    }
}

