//
//  GpsLocation+CoreDataProperties.swift
//  IFound
//
//  Created by Edgar Vildt on 25.12.2022.
//
//

import Foundation
import CoreData


extension GpsLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GpsLocation> {
        return NSFetchRequest<GpsLocation>(entityName: "GpsLocation")
    }

    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var speed: Double
    @NSManaged public var alt: Double
	@NSManaged public var accuracy: Double
    @NSManaged public var sequenceNr: Int16
    @NSManaged public var recordedAt: Date?
    @NSManaged public var verticalAccuracy: Double
    @NSManaged public var locationId: String?
    @NSManaged public var session: GpsSession?
    @NSManaged public var type: GpsLocationType?

}

extension GpsLocation : Identifiable {

}
