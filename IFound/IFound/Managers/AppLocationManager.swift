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
	@Published var wayPointCoords: CLLocationCoordinate2D? = nil
	@Published var fromWaypointDistanceStraight: Double = 0
	@Published var fromWaypointDistanceTraveled: Double = 0
	@Published var sinceWaypointSetAvgSpeed: Double = 0
	var fromWPSpeeds: [CLLocationSpeed] = []
	
	
	@Published var directionPreference: ECameraType = .CenteredNorthUp
	@Published var polyLineCoordinates: [CLLocationCoordinate2D] = []
	@Published var currentDirecion: CLLocationDirection = CLLocationDirection(0)
	
	
	@Published var updateRunning: Bool = false
	@Published var region: MKCoordinateRegion? = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
		span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
	@Published var locationCount: Int = 0
	@Published var mapType:MKMapType = .standard
	
	@Published var showCompass: Bool = false
	
	@Published var session: GpsSession?
	private var sequenceNr: Int = 0
	var context: NSManagedObjectContext?
	private var mapTypeList:[MKMapType] = [.standard, .mutedStandard, .hybrid, .hybridFlyover, .satellite, .satelliteFlyover]
	let reachability = try! Reachability()
	
	var locationBuffer: LocationBuffer? = nil
	var token: String? = nil
	private let	locationManager: CLLocationManager
	var Ltypes: [GpsLocationType]?
	var locType: GpsLocationType?
	var wpType: GpsLocationType?
	var cpType: GpsLocationType?
	var repo: DataRepository = DataRepository()
	let APIMapper : APIRepositoryMapper = APIRepositoryMapper()
	var updateInterval = 0
	var sendUpdates: Bool = true
	
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
	
	func prepareForApiCalls(token: String, updateInterval: Int, sendUpdates: Bool){
		self.token = token
		self.updateInterval = updateInterval
		self.sendUpdates = sendUpdates
		print("Token set")
		
		locationBuffer = LocationBuffer(context: context!, token: token)
		locationBuffer!.updateFrequency = updateInterval
		locationBuffer!.updateApi = sendUpdates
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
				if(lastSeenLocation!.distance(from: curLocation) > 40){
					// FIltering jumps
					return
				}
				overallDistance += lastSeenLocation!.distance(from: curLocation)
				sequenceNr += 1
				if(checkpointCoordinates.count != 0){
					
					fromCheckpointDistanceTraveled += lastSeenLocation!.distance(from: curLocation)
					fromCheckpointDistanceStraight = lastSeenLocation!.distance(from: checkpointCoordinates.last.unsafelyUnwrapped)
				}
				if(wayPointCoords != nil){
					fromWaypointDistanceTraveled += lastSeenLocation!.distance(from: curLocation)
				}
				
				if(updateRunning){
					polyLineCoordinates.append(curLocation.coordinate)
				}
				if(directionPreference != .Free){
					currentDirecion = curLocation.course
				}
				lastSeenLocation = curLocation

				//				print(currentDirecion)
				
				
			}else{
				lastSeenLocation = curLocation
				if(directionPreference != .Free){
					currentDirecion = curLocation.course
				}				
			} // If
			
			
			let location = repo.addLocation(
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

			if(reachability.connection != .unavailable && sendUpdates && session?.appUserId != nil){
				if(token != nil){
					locationBuffer?.addLocation(location: location)
				}
				
			}
			if(checkpointCoordinates.count > 0){
				fromCheckpointDistanceStraight = lastSeenLocation!.distance(from: checkpointCoordinates.last!)
			}
			if(wayPointCoords != nil){
				fromWaypointDistanceStraight = lastSeenLocation!.distance(from: CLLocation(latitude: wayPointCoords!.latitude, longitude: wayPointCoords!.longitude))
			}
			speeds.append(lastSeenLocation!.speed * 3.6)
			if(!checkpointCoordinates.isEmpty){
				fromCheckPointSpeeds.append(lastSeenLocation!.speed * 3.6)
				
			}
			if(wayPointCoords != nil){
				fromWPSpeeds.append(lastSeenLocation!.speed * 3.6)
				fromWaypointDistanceStraight = lastSeenLocation!.distance(from: CLLocation(latitude: wayPointCoords!.latitude, longitude: wayPointCoords!.longitude))
			}
			overallTime.end = Date()
			if(speeds.count > 3){
				//				print(speeds)
				var sum = 0.0
				for speed in speeds {
					sum += speed as Double
				}
				
				session!.speed = 3600 / overallAvgSpeed
				session!.distance = overallDistance
				session!.duration = overallTime.duration.binade
				session!.paceMax = 3600 / (speeds.max() != 0 ? speeds.max() as Double? ?? 1000 : 1000)
				session!.paceMin = 3600 / (speeds.min() != 0 ? speeds.max() as Double? ?? 1000 : 1000)
				
				overallAvgSpeed = sum / Double(speeds.count)
				if(checkpointCoordinates.count != 0){
					var sumCh = 0.0
					for sp in fromCheckPointSpeeds {
						sumCh += sp as Double
					}
					fromCheckpointAvgSpeed = sumCh / Double(fromCheckPointSpeeds.count)
				}
				if(!fromWPSpeeds.isEmpty){
					var suum = 0.0
					for sp in fromWPSpeeds {
						suum += sp as Double
					}
					sinceWaypointSetAvgSpeed = suum / Double(fromWPSpeeds.count)
				}
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
		showCompass = false
		updateRunning.toggle()
		if(updateRunning){
			locationManager.startUpdatingLocation()
			resetParameters()
			overallTime.start = Date()
			session = repo.addSession(context: context!)
			if(reachability.connection != .unavailable && sendUpdates){
				if(token != nil){
					session = APIMapper.saveSession(session: session!, token: token!, context: context!)
					
				}
			}
			locationBuffer?.session = session

			
			print("Location started updating")
		}else{
			locationManager.stopUpdatingLocation()
			repo.edtiSession(session: session!,
							 context: context!,
							 speed: 3600 / overallAvgSpeed,
							 distance: overallDistance,
							 duration: overallTime.duration.binade,
							 paceMax: 3600 / (speeds.max() != 0 ? speeds.max() as Double? ?? 1000 : 1000),
							 paceMin: 3600 / (speeds.min() != 0 ? speeds.max() as Double? ?? 1000 : 1000)
			)
			if(reachability.connection != .unavailable && sendUpdates && session?.appUserId != nil){
				if(token != nil){
					locationBuffer?.sendToBackend()
					APIMapper.updateSession(session: session!, token: token!, context: context!)
				}
			}

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
				let location = repo.addLocation(
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
				if(reachability.connection != .unavailable && sendUpdates && session?.appUserId != nil){
					if(token != nil){
						APIMapper.saveLocation(location: location, token: token!, context: context!)
					}
				}

				fromCheckPointSpeeds = []
				fromCheckpointAvgSpeed = 0
				fromCheckpointDistanceStraight = 0
				fromCheckpointDistanceTraveled = 0
			}
			
		}
		
	}
	
	
	func setWayPoint(){
		wayPointCoords = lastSeenLocation?.coordinate
		fromWaypointDistanceTraveled = 0
		
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


