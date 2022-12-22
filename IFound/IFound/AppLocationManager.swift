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
	
	// Overall stats
	@Published var overallDistance: Double = 0
	@Published var overallTime: DateInterval = DateInterval(start: Date(), end: Date())
	@Published var overallAvgSpeed: Double = 0
	
	// Last checkpoint
	@Published var fromCheckpointDistanceTraveled: Double = 0
	@Published var fromCheckpointDistanceStraight: Double = 0
	@Published var fromCheckpointAvgSpeed: Double = 0
	
	// To next Waypoint
	@Published var fromWaypointDistanceTraveled: Double = 0
	@Published var toWayPointDistance: Double = 0
	@Published var sinceWaypointSetAvgSpeed: Double = 0
	var speeds: [CLLocationSpeed] = []
	
	
	@Published var polyLineCoordinates: [CLLocationCoordinate2D] = []

	
	
	@Published var updateRunning: Bool = false
	@Published var region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
		span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
	@Published var locationCount: Int = 0
	
	
	private let	locationManager: CLLocationManager
	
	override init() {
		locationManager = CLLocationManager()
		
		// Crashes preview
		locationManager.allowsBackgroundLocationUpdates = true
		authorizationStatus = locationManager.authorizationStatus
		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		// Request updates
//		overallTime.start = Date()
//		locationManager.startUpdatingLocation()
		locationManager.requestLocation()
		

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
		print("Did update location")
		locationCount += locations.count
		
		for curLocation in locations {
			if(lastSeenLocation != nil){
				overallDistance += lastSeenLocation!.distance(from: curLocation)
				polyLineCoordinates.append(curLocation.coordinate)
			} // If
			
			lastSeenLocation = curLocation
			
			overallTime.end = Date()
			
			speeds.append(contentsOf: locations.map{$0.speed})
			let sum = speeds.reduce(0, {x, y in
				x + y})
			overallAvgSpeed = sum / Double(speeds.count)
			
		}
		// For
		if let mapCenter = lastSeenLocation?.coordinate {
			region.center = mapCenter
			region.span = MKCoordinateSpan(
				latitudeDelta: CLLocationDegrees(0.005)
				, longitudeDelta: CLLocationDegrees(0.005))
		}
	} // func
	

	func toggleLocationUpdates(){
		updateRunning.toggle()
		if(updateRunning){
			locationManager.startUpdatingLocation()
			resetParameters()
			overallTime.start = Date()
			print("Location started updating")
		}else{
			locationManager.stopUpdatingLocation()
			print("Location stopped updating")
		}
	}
	
	
	func resetParameters(){
		overallDistance = 0
		overallTime = DateInterval(start: Date(), end: Date())
		overallAvgSpeed = 0
		
		// Last checkpoint
		fromCheckpointDistanceTraveled = 0
		fromCheckpointDistanceStraight = 0
		fromCheckpointAvgSpeed = 0
		
		// To next Waypoint
		fromWaypointDistanceTraveled = 0
		toWayPointDistance = 0
		sinceWaypointSetAvgSpeed = 0
		speeds = []
		
		
		polyLineCoordinates = []
	}
    
	
	func locationManager(
		_ manager: CLLocationManager,
		didFailWithError error: Error
	){
		
	}

}


enum ECameraType{
	case Centere
	case Free
	case NorthUp
}
