//
//  UserData+CoreDataProperties.swift
//  IFound
//
//  Created by Edgar Vildt on 19.01.2023.
//
//

import Foundation
import CoreData


extension UserData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserData> {
        return NSFetchRequest<UserData>(entityName: "UserData")
    }

    @NSManaged public var token: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var status: String?

}

extension UserData : Identifiable {

}
