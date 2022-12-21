//
//  LocationManager.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import Foundation
import CoreLocation
import MapKit

class AppLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus
	@Published var lastSeenLocation: CLLocation?
	@Published var distance: Double = 0
	@Published var locationCount: Int = 0
	
	@Published var region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
		span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
	
	@Published var polyLineCoordinates: [CLLocationCoordinate2D] = []
	
    private let locationManager: CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
		
		// Crashes preview
        locationManager.allowsBackgroundLocationUpdates = true
        authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        // Request updates
    }
    
    // Request permissions from user
    func requestPermissions(){
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    // On auth change
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
        authorizationStatus = manager.authorizationStatus
    }
    
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
		locationCount += locations.count
		
		for curLocation in locations {
			if(lastSeenLocation != nil){
				distance += lastSeenLocation!.distance(from: curLocation)
				polyLineCoordinates.append(curLocation.coordinate)
			} // If
			
			lastSeenLocation = curLocation
			
		} // For
		if let mapCenter = lastSeenLocation?.coordinate {
			region.center = mapCenter
			region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.005), longitudeDelta: CLLocationDegrees(0.005))
		}
	} // func
	
	
    
}
