//
//  LocationManager.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import Foundation
import CoreLocation
import MapKit
import CoreData


class AppLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
	
	@Published var authorizationStatus: CLAuthorizationStatus
	@Published var lastSeenLocation: CLLocation?
	
	// Overall stats
	@Published var overallDistance: Double = 0
	@Published var overallTime: DateInterval = DateInterval(start: Date(), end: Date())
	@Published var overallAvgSpeed: Double = 0
	@Published var speeds: [CLLocationSpeed] = []
	
	// Last checkpoint
	@Published var fromCheckpointDistanceTraveled: Double = 0
	@Published var fromCheckpointDistanceStraight: Double = 0
	@Published var checkpointCoordinates: [CLLocation] = []
	@Published var fromCheckpointAvgSpeed: Double = 0
	var fromCheckPointSpeeds: [CLLocationSpeed] =  []
	
	// To next Waypoint
	@Published var fromWaypointDistanceTraveled: Double = 0
	@Published var toWayPointDistance: Double = 0
	@Published var sinceWaypointSetAvgSpeed: Double = 0
	
	@Published var directionPreference: ECameraType = .CenteredNorthUp
	@Published var polyLineCoordinates: [CLLocationCoordinate2D] = []
	@Published var currentDirecion: CLLocationDirection = CLLocationDirection(0)
	
	
	@Published var updateRunning: Bool = false
	@Published var region: MKCoordinateRegion? = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
		span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
	@Published var locationCount: Int = 0
	@Published var mapType:MKMapType = .standard
	
	@Published var session: GpsSession?
	private var sequenceNr: Int = 0
	var context: NSManagedObjectContext?
	private var mapTypeList:[MKMapType] = [.standard, .mutedStandard, .hybrid, .hybridFlyover, .satellite, .satelliteFlyover]
	
	private let	locationManager: CLLocationManager
	var Ltypes: [GpsLocationType]?
	var locType: GpsLocationType?
	var wpType: GpsLocationType?
	var cpType: GpsLocationType?
	var repo: DataRepository = DataRepository()
	
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
//		locationManager.requestLocation()
		
		
		
	}
	
	func setTypes(types: [GpsLocationType]){
		Ltypes = types
		for type in types {
			if(type.name == "LOC"){
				locType = type
				continue
			}
			if(type.name == "WP"){
			wpType = type
				continue
			}
			if(type.name == "CP"){
				cpType = type
				continue
			}
		}
	}
	
	// Request permissions from user
	func requestPermissions(){
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestAlwaysAuthorization()
	}
	
	func setContext(ctx: NSManagedObjectContext, repo: DataRepository){
		context = ctx
		self.repo = repo
		print("context set for location manager")
		print("correct data repo added")
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
				sequenceNr += 1
				if(checkpointCoordinates.count != 0){
					fromCheckpointDistanceTraveled += lastSeenLocation!.distance(from: curLocation)
					fromCheckpointDistanceStraight = lastSeenLocation!.distance(from: checkpointCoordinates.last.unsafelyUnwrapped)
				}
				
				if(updateRunning){
					polyLineCoordinates.append(curLocation.coordinate)
				}
				lastSeenLocation = curLocation
				currentDirecion = curLocation.course
//				print(currentDirecion)


			}else{
				lastSeenLocation = curLocation
				currentDirecion = curLocation.course
				sequenceNr += 1
			} // If
			speeds.append(16.666666667 / lastSeenLocation!.speed)
			fromCheckPointSpeeds.append(16.666666667 / lastSeenLocation!.speed)
			repo.addLocation(
				session: session!,
				context: context!,
				locationType: locType!,
				sequenceNr: Int16(sequenceNr),
				lat: lastSeenLocation!.coordinate.latitude,
				lon: lastSeenLocation!.coordinate.longitude,
				accuracy: lastSeenLocation!.horizontalAccuracy,
				alt: lastSeenLocation!.altitude,
				speed: lastSeenLocation!.speed,
				verticalAccuracy: lastSeenLocation!.verticalAccuracy
			)
			
			overallTime.end = Date()
			var sum = 0.0
			for speed in speeds {
				sum += speed as Double
			}
			overallAvgSpeed = sum / Double(speeds.count)
			if(checkpointCoordinates.count != 0){
				var sumCh = 0.0
				for sp in fromCheckPointSpeeds {
					sumCh += sp as Double
				}
				fromCheckpointAvgSpeed = sumCh / Double(fromCheckPointSpeeds.count)
			}
			
			
			
			
		}
		// For
		if(directionPreference != .Free){
			if let mapCenter = lastSeenLocation?.coordinate {
				if(region == nil){
					region = MKCoordinateRegion(
						center: mapCenter,
						span: MKCoordinateSpan(
							latitudeDelta: CLLocationDegrees(0.001),
							longitudeDelta: CLLocationDegrees(0.001)
						)
					)
				}
				region!.center = mapCenter
				region!.span = MKCoordinateSpan(
					latitudeDelta: CLLocationDegrees(0.001),
					longitudeDelta: CLLocationDegrees(0.001)
				)
		}
		}else{
			region = nil
		}
	} // func
	

	func toggleLocationUpdates(){
		updateRunning.toggle()
		if(updateRunning){
			locationManager.startUpdatingLocation()
			resetParameters()
			overallTime.start = Date()
			session = repo.addSession(context: context!)
			
			print("Location started updating")
		}else{
			locationManager.stopUpdatingLocation()
			repo.edtiSession(session: session!,
										 context: context!,
										 speed: overallAvgSpeed,
										 distance: overallDistance,
										 duration: overallTime.duration.binade)
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
		fromCheckPointSpeeds =  []
		polyLineCoordinates = []
	}
    
	
	func locationManager(
		_ manager: CLLocationManager,
		didFailWithError error: Error
	){
		
	}
	
	func center(){
		print("Camera centered")
		locationManager.requestLocation()
		
		region = MKCoordinateRegion(center: (lastSeenLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)), span: MKCoordinateSpan(
			latitudeDelta: CLLocationDegrees(0.001)
				  , longitudeDelta: CLLocationDegrees(0.001)))
	}
	
	func setCheckPoint(){
		if (lastSeenLocation?.coordinate) != nil{
			if(updateRunning){
				checkpointCoordinates.append(lastSeenLocation!)
				repo.addLocation(
					session: session!,
					context: context!,
					locationType: cpType!,
					sequenceNr: 0,
					lat: lastSeenLocation!.coordinate.latitude,
					lon: lastSeenLocation!.coordinate.longitude,
					accuracy: lastSeenLocation!.horizontalAccuracy,
					alt: lastSeenLocation!.altitude,
					speed: lastSeenLocation!.speed,
					verticalAccuracy: lastSeenLocation!.verticalAccuracy)
				fromCheckPointSpeeds = []
				fromCheckpointAvgSpeed = 0
				fromCheckpointDistanceStraight = 0
				fromCheckpointDistanceTraveled = 0
			}
			
		}
		
	}
	
	func toggleMapType(){
		let currentIndex = mapTypeList.firstIndex(of: mapType)
		if(currentIndex == mapTypeList.count - 1){
			mapType = mapTypeList[0]
		}else{
			mapType = mapTypeList[currentIndex! + 1]
		}
	}
}


enum ECameraType{
	case Free
	case CenteredNorthUp
	case CenteredDirectionUp
}


