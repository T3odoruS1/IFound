//
//  PreferenceData+CoreDataProperties.swift
//  IFound
//
//  Created by Edgar Vildt on 19.01.2023.
//
//

import Foundation
import CoreData


extension PreferenceData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreferenceData> {
        return NSFetchRequest<PreferenceData>(entityName: "PreferenceData")
    }

    @NSManaged public var updateFreq: Int16
    @NSManaged public var sendUpdates: Bool

}

extension PreferenceData : Identifiable {

}
