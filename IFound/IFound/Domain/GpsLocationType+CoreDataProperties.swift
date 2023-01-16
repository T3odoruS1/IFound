//
//  GpsLocationType+CoreDataProperties.swift
//  IFound
//
//  Created by Edgar Vildt on 25.12.2022.
//
//

import Foundation
import CoreData


extension GpsLocationType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GpsLocationType> {
        return NSFetchRequest<GpsLocationType>(entityName: "GpsLocationType")
    }

    @NSManaged public var descr: String?
    @NSManaged public var name: String?
    @NSManaged public var typeId: String?
    @NSManaged public var nameId: String?
    @NSManaged public var descrId: String?
    @NSManaged public var locations: NSSet?

}

// MARK: Generated accessors for locations
extension GpsLocationType {

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: GpsLocation)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: GpsLocation)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSSet)

}

extension GpsLocationType : Identifiable {

}
