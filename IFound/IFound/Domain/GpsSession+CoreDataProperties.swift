//
//  GpsSession+CoreDataProperties.swift
//  IFound
//
//  Created by Edgar Vildt on 25.12.2022.
//
//

import Foundation
import CoreData
import MapKit

extension GpsSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GpsSession> {
        return NSFetchRequest<GpsSession>(entityName: "GpsSession")
    }

    @NSManaged public var name: String?
    @NSManaged public var recordedAt: Date?
    @NSManaged public var descr: String?
    @NSManaged public var sessionId: String?
	// in seconds
    @NSManaged public var duration: Double
	// in seconds pre km
    @NSManaged public var speed: Double
	// in meters
    @NSManaged public var distance: Double
	// in meters
    @NSManaged public var climb: Double
	// in meters
    @NSManaged public var descend: Double
    @NSManaged public var paceMax: Double
    @NSManaged public var paceMin: Double
    @NSManaged public var appUserId: String?
    @NSManaged public var locations: NSSet?
	
	public var wrappedLocations: [GpsLocation] {
		let locations = locations as? Set<GpsLocation> ?? []
		return locations.sorted {
			$0.sequenceNr < $1.sequenceNr
		}
	}
	
	public var lastSeenRegion: MKCoordinateRegion {
		let coords = wrappedLocations.last
		let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: coords!.lat, longitude: coords!.lon), span: MKCoordinateSpan(
			latitudeDelta: CLLocationDegrees(0.005),
						longitudeDelta: CLLocationDegrees(0.005)))
		return region
	}
	
	public var middleRegion: MKCoordinateRegion {
		var minLat = 90.0
		var minLon = 180.0
		var maxLat = -90.0
		var maxLon = -180.0

		for location in wrappedLocations {
			minLat = min(minLat, location.lat)
			minLon = min(minLon, location.lon)
			maxLat = max(maxLat, location.lat)
			maxLon = max(maxLon, location.lon)
		}
		
		let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
		let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLon - minLon) * 1.3)
		if(center.latitude == 0.00000000 || center.latitude == 0.00000000 || span.latitudeDelta < 0 || span.longitudeDelta < 0){
			return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
		}
		return MKCoordinateRegion(center: center, span: span)
	}
	
	public var polyLineLocations : [CLLocationCoordinate2D]{
		var polyLineLocations: [CLLocationCoordinate2D] = []
		for loc in wrappedLocations {
			if(loc.type?.name == "LOC"){
				polyLineLocations.append(CLLocationCoordinate2D(latitude: loc.lat, longitude: loc.lon))
			}
		}
		return polyLineLocations
	}
	
	public var locationSpeeds: [Double]{
		var speeds: [Double] = []
		for location in wrappedLocations {
			speeds.append(location.speed)
		}
		return speeds
	}
	
	public var checkpointLocations : [CLLocation]{
		var checkpointLocs: [CLLocation] = []
		for loc in wrappedLocations {
			if(loc.type?.name == "CP"){
				checkpointLocs.append(CLLocation(latitude: loc.lat, longitude: loc.lon))
			}
		}
		return checkpointLocs
	}

}

// MARK: Generated accessors for locations
extension GpsSession {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: GpsLocation)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: GpsLocation)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

extension GpsSession : Identifiable {

}
