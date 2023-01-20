//
//  DataController.swift
//  IFound
//
//  Created by Edgar Vildt on 24.12.2022.
//

import Foundation
import CoreData
import CoreLocation
import SwiftUI



class DataController: ObservableObject {

	let container: NSPersistentContainer
	static let shared = DataController()

	
	init(inMemory: Bool = false){
		
		container = NSPersistentContainer(name: "LocationModel")
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}
		container.loadPersistentStores(completionHandler: { (_, error) in
			print("persistance stroes are loaded")
			DataController.handleError(error)
		})
		
	} // Init
	
	static func handleError(_ error: Error?) {
		if let error = error as NSError? {
			fatalError("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
		}
	}

	
	enum LocationManagerErrors: Error{
		case InvalidLocationTypeError(type: String)
	}
	
	
}
