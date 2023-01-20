//
//  LocationBuffer.swift
//  IFound
//
//  Created by Edgar Vildt on 18.01.2023.
//

import Foundation
import CoreData

class LocationBuffer: ObservableObject {
	public var locations: [GpsLocation] = []
	let context: NSManagedObjectContext
	let token: String
	private let apiRepoMapper: APIRepositoryMapper = APIRepositoryMapper()
	var updateFrequency = 10
	@Published public var session: GpsSession? = nil
	let reachability = try! Reachability()
	var updateApi = true

	init(context: NSManagedObjectContext, token: String) {
		self.context = context
		self.token = token
	}
	
	func addLocation(location: GpsLocation){
		locations.append(location)
		if(locations.count == updateFrequency){
			if(updateApi){
				sendToBackend()
			}else{
				DataRepository().save(context: context)
			}
		}
	}

	
	func sendToBackend(){
		if(locations.count > 0){
			apiRepoMapper.saveLocationsBulk(locations: locations, token: token, context: context)
			apiRepoMapper.updateSession(session: session!, token: token, context: context)
			locations = []
		}
	}
	
}
