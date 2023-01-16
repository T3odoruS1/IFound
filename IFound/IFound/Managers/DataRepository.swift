//
//  DataRepository.swift
//  IFound
//
//  Created by Edgar Vildt on 16.01.2023.
//

import Foundation
import CoreData
import CoreLocation

class DataRepository: ObservableObject{
	
	
	@Published var WPtype: GpsLocationType? = nil
	@Published var CPtype: GpsLocationType? = nil
	@Published var LOCtype: GpsLocationType? = nil
	@Published var types: [GpsLocationType] = []
	@Published var WP = "WP"
	@Published var CP = "CP"
	@Published var LOC = "LOC"
	
	func save(context: NSManagedObjectContext){
		do {
			try context.save()
			print("Data saved")
		}catch{
			print("Saving error")
		}
	}
	
	
	func loadLocationTypesFromApi(context: NSManagedObjectContext){
		
		// Can only be used with internet connection. json file is better option
		// var urlString = "https://sportmap.akaver.com/api/v1.0/GpsLocationTypes"
		
		// Using local json file. Can be used without internet connection.
		if(types.count != 0){
			return
		}
		guard let sourcesURL = Bundle.main.url(forResource: "locationTypes", withExtension: "json") else {
			fatalError("No file with location types found")
		}
		let urlString = sourcesURL.absoluteString
		
		if let url = URL(string: urlString) {
			if let data = try? Data(contentsOf: url){
				printJson(data)
				let items = self.parse(json: data)
				for item in items {
					let type = GpsLocationType(context: context)
					type.name = item.name
					type.nameId = item.nameId
					type.descr = item.descr
					type.descrId = item.descrId
					type.typeId = item.typeId
					self.save(context: context)
					print("type saved \(type)")
				}
			}
		}
	}
	
	func parse(json: Data) -> [LocaionTypeData] {
		var items: [LocaionTypeData] = []
		let decoder = JSONDecoder()
		if let jsonData = try? decoder.decode([LocaionTypeData].self, from: json){
			items.append(contentsOf: jsonData)
		}
		return items
	}
	
	func addSession(
		context: NSManagedObjectContext,
		appUserId: String? = nil
	) -> GpsSession{
		let session = GpsSession(context: context)
		
		// Setting the parameters
		session.appUserId = appUserId
		session.sessionId = UUID().description
		session.recordedAt = Date()
		
		save(context: context)
		print("Session was saved to the database \(String(describing: session.sessionId))")
		return session
	} // Add session
	
	func edtiSession(
		session: GpsSession,
		context: NSManagedObjectContext,
		description: String? = nil,
		name: String? = nil,
		speed: Double? = nil,
		climb: Double? = nil,
		descend: Double? = nil,
		distance: Double? = nil,
		duration: Double? = nil,
		paceMax: Double? = nil,
		paceMin: Double? = nil,
		appUserId: String? = nil
	){
		
		// Updating the parameters
		session.descr = description
		session.name = name
		session.speed = speed ?? session.speed
		session.climb = climb ?? session.climb
		session.descend = descend ?? session.descend
		session.distance = distance ?? session.distance
		session.duration = duration ?? session.duration
		session.paceMax = paceMax ?? session.paceMax
		session.paceMin = paceMin ?? session.paceMin
		session.appUserId = appUserId ?? ""
		save(context: context)
		print("Session was updated \(String(describing: session.sessionId?.description))")
	} // edit Session
	
	
	func addLocation(
		session: GpsSession,
		context: NSManagedObjectContext,
		locationType: GpsLocationType,
		sequenceNr: Int16,
		lat: Double,
		lon: Double,
		accuracy: Double,
		alt: Double,
		speed: Double,
		verticalAccuracy: Double
	) {
		let location = GpsLocation(context: context)
		location.locationId = UUID().description
		location.session = session
		location.recordedAt = Date()
		location.speed = speed
		location.sequenceNr = sequenceNr
		location.lat = lat
		location.lon = lon
		location.verticalAccuracy = verticalAccuracy
		location.alt = alt
		location.accuracy = accuracy
		location.type = locationType
		
		save(context: context)
		print("Location added")
		
	}
	
	// Add location type to the database
	func addLocationType(
		context: NSManagedObjectContext,
		id: String,
		name: String,
		nameId: String,
		description: String,
		descriptionId: String
	){
		
		let locationType = GpsLocationType(context: context)
		locationType.name = name
		locationType.descr = description
		locationType.typeId = id
		locationType.nameId = nameId
		locationType.descrId = descriptionId
		
		save(context: context)
		print("location type saved \(String(describing: locationType.typeId?.description))")
		
	}
	
	func removeSession(session: GpsSession, context: NSManagedObjectContext){
		context.delete(session)
		do{
			try context.save()
			print("session deleted")
			
		}catch{
			print("not deleted")
		}
		
	}
	
	func getSessions(context: NSManagedObjectContext) -> [GpsSession]{
		let fetchRequest = GpsSession.fetchRequest() as NSFetchRequest<GpsSession>
		do{
			let gpsSessions = try context.fetch(fetchRequest)
			let sortedSessions = gpsSessions.sorted { (s1, s2) -> Bool in
				return s1.recordedAt! > s2.recordedAt!
			}
			return sortedSessions
		}catch{
			print("Fetch request not successfull")
			return []
		}
	}
	
	func getTypes(context: NSManagedObjectContext) -> [GpsLocationType]{
		let fetchRequest = GpsLocationType.fetchRequest() as NSFetchRequest<GpsLocationType>
		let types = try? context.fetch(fetchRequest)
		return types ?? []
		
	}
	
	func checkForEmptySessions(context: NSManagedObjectContext){
		let request = GpsSession.fetchRequest() as NSFetchRequest<GpsSession>
		let gpsSessions = try? context.fetch(request)
		if let sessionArray = gpsSessions {
			for session in sessionArray {

				if(session.wrappedLocations.count == 0){
					context.delete(session)
					print("Empty session deleted")
				}

			}
		}
	}


	
	
	enum LocationManagerErrors: Error{
		case InvalidLocationTypeError(type: String)
	}
	
	
	func printJson(_ data: Data){
		do {
			let jsonObject = try JSONSerialization.jsonObject(with: data)
			guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
				print("Error: Cannot convert JSON object to Pretty JSON data")
				return
			}
			guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
				print("Error: Could print JSON in String")
				return
			}
			
			print(prettyPrintedJson)
		} catch {
			print("Error: Trying to convert JSON data to string")
			return
		}
	}
	
}
