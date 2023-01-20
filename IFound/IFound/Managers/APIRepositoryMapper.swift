//
//  APIRepositoryMapper.swift
//  IFound
//
//  Created by Edgar Vildt on 18.01.2023.
//

import Foundation
import CoreData

class APIRepositoryMapper {
	private let apiRepo: APIRepository = APIRepository()
	private let dbRepo: DataRepository = DataRepository()
	private let dateFormatter = DateFormatter()
	
	init(){
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	}
	
	// Goes through every session in the db and every session if api call. If session from api call not in db it is saved. If in db then updated.
	func getAllSessions(token: String, context: NSManagedObjectContext, filteredBy userId: String) ->[GpsSession]{
		var result: [GpsSession] = []
		apiRepo.getAllSessions(token: token) { fetchedSessions in
			
			DispatchQueue.main.async {
				for fetchedResult in fetchedSessions {
					if(fetchedResult.userId != userId){ continue }
					print(fetchedResult)
					
					let mappedSession = self.mapSession(fetchedResult: fetchedResult, context: context)
					mappedSession.saved = true
					
					
					self.getAllLocationsForSession(session: mappedSession, token: token, context: context) { locations in
						DispatchQueue.main.async {
							let locationsFromDb = self.dbRepo.getSessionById(sessionId: fetchedResult.id!, context: context)?.locations
							if(locationsFromDb?.count ?? 0 > locations.count){
								
							}else{
								for location in locations {
									mappedSession.addToLocations(location)
								}
								
							}
						}
					}
					
					result.append(mappedSession)
					self.dbRepo.save(context: context)

				}

			}
			
		}
		return result
	}
	
	func filterSessionsFromOtherAccount(token: String, context: NSManagedObjectContext){
		print("Executing filtering function ")
		getUserId(token: token, context: context){ resp in
			DispatchQueue.main.async {
				
				let sessionfToCheck = self.dbRepo.getSessions(context: context)
				print("App user if for filtering \(resp)")
				for check in sessionfToCheck {
					if(!resp.isEmpty){
						print("canditate: \(check)")
						if(check.appUserId != nil && check.appUserId != resp ){
							context.delete(check)
							self.dbRepo.save(context: context)
						}
					}

				}
			}
			
		}
	}
	
//	func getSession(id: String ,token: String, context: NSManagedObjectContext) -> GpsSession? {
//		var session: GpsSession? = nil
//		apiRepo.getSession(sessionId: id, token: token) { fetchedResult in
//			DispatchQueue.main.async {
//				session = self.mapSession(fetchedResult: fetchedResult!, context: context)
//				self.dbRepo.save(context: context)
//			}
//		}
//		return session
//	}
	
	func saveSession(session: GpsSession, token: String, context: NSManagedObjectContext, additionalFields: [String: AnyHashable]? = nil) -> GpsSession {
		apiRepo.saveSession(session: session, token: token) { updatedSessionFormApi in
			DispatchQueue.main.async {
				
				self.updateSessionFields(session: session, fetchedResult: updatedSessionFormApi, additionalFields: additionalFields)
				print("Updated session after API call: \(session.description)")
				self.dbRepo.save(context: context)
			}
		}
		
		return session
	}
	
	// Check if session is full saved(all locations and session saved) or partially (session saved, locations not)
	// on full send save session -> update locally -> send locations
	// on partial -> update session -> update locatlly -> send locations
	func preformSyncing(session: GpsSession, token: String, context: NSManagedObjectContext){
		
		if(session.sessionId == nil){
			fullSync(session: session, token: token, context: context)
			return
		}
		if(session.saved && !session.fullySaved){
			partialSync(session: session, token: token, context: context)
			return
		}else{
			return
		}
	}
	
	private func partialSync(session: GpsSession, token: String, context: NSManagedObjectContext){
		updateSession(session: session, token: token, context: context)
		var locationsToSend: [GpsLocation] = []
		for loc in session.wrappedLocations {
			if(!loc.saved){
				loc.session = session
				locationsToSend.append(loc)
			}
		}
		dbRepo.save(context: context)
		if(!locationsToSend.isEmpty){
			self.saveLocationsBulk(locations: locationsToSend, token: token, context: context)
		}

	}
	
	private func fullSync(session: GpsSession, token: String, context: NSManagedObjectContext){
		let additionalFields: [String: AnyHashable] = [
			"name": session.name,
			"descr": session.descr,
			"recordedAt": session.recordedAt,
			"speed": session.speed,
			"paceMax": session.paceMax,
			"paceMin": session.paceMin,
			"distance": session.distance
		]
		
		apiRepo.saveSession(session: session, token: token) { response in
			DispatchQueue.main.async {
				
				self.updateSessionFields(session: session, fetchedResult: response, additionalFields: additionalFields)
				print("Updated session after API call: \(session.description)")
				self.dbRepo.save(context: context)
				self.updateSession(session: session, token: token, context: context)
				session.saved = true
				for loc in session.wrappedLocations{
					loc.session = session
				}
				self.dbRepo.save(context: context)

				self.saveLocationsBulk(locations: session.wrappedLocations, token: token, context: context)
				for loc in session.wrappedLocations{
					loc.saved = true
				}


			}
		}
	}
	
	
	
	
	func getUserId(token: String, context: NSManagedObjectContext, completion: @escaping(String) -> Void) {
		let session = GpsSession(context: context)
		session.recordedAt = Date()
		apiRepo.saveSession(session: session, token: token) { updatedSessionFormApi in
			DispatchQueue.main.async {
				context.delete(session)
				self.dbRepo.save(context: context)
				print("User id provided by backedn ")
				print(updatedSessionFormApi.appUserId!)
				self.apiRepo.deleteSession(sessionId: updatedSessionFormApi.id!, token: token ) { resp in
					print("Session deleted")
				}
				completion(updatedSessionFormApi.appUserId!)
			}
		}
		
	}
	
	func deleteSession(session: GpsSession, token: String, context: NSManagedObjectContext){
		if(session.sessionId == nil){
			print("Tried to delete session from backend without session id.")
			dbRepo.removeSession(session: session, context: context)
			return
		}
		apiRepo.deleteSession(sessionId: session.sessionId!, token: token){ session in
			
		}
		dbRepo.removeSession(session: session, context: context)
	}
	
	func unassignSessionFromAccount(session: GpsSession, token: String, context: NSManagedObjectContext){
		if(session.sessionId == nil){
			print("Tried to unassing session from account that is already unassigned")
			return
		}
		apiRepo.deleteSession(sessionId: session.sessionId!, token: token) { _ in
			session.saved = false
			session.sessionId = nil
			session.appUserId = nil
			self.dbRepo.save(context: context)
		}
	}
	
	
	func updateSession(session: GpsSession, token: String, context: NSManagedObjectContext){
		apiRepo.updateSession(session: session, token: token)
		session.saved = true
		dbRepo.save(context: context)
	}
	
	
	func getAllLocationsForSession(session: GpsSession, token: String, context: NSManagedObjectContext, completion: @escaping([GpsLocation]) -> Void){
		if(session.sessionId != nil){
			self.apiRepo.getAllLocationsForSession(sessionId: session.sessionId!, token: token) { fetchedLocations in
				DispatchQueue.main.async {
					print("Fetched locations for session session")
//					print(fetchedLocations)
					var locations: [GpsLocation] = []
					for fetchedLocation in fetchedLocations {
						
						let loca = self.setLocationFields(session: session, fetchedLocation: fetchedLocation, context: context)
						locations.append(loca)
//						print("location saved")
//						self.dbRepo.save(context: context)

					}
					completion(locations)
				}
			}

		}
	}
	
	func saveLocation(location: GpsLocation, token: String, context: NSManagedObjectContext){
		apiRepo.saveLocation(location: location, token: token) { locationFromApi in
			location.saved = true
			self.dbRepo.save(context: context)
		}

	}
	
	func saveLocationsBulk(locations: [GpsLocation], token: String, context: NSManagedObjectContext){
		apiRepo.saveLocationBulk(locations: locations, token: token)
		for location in locations {
			location.saved = true
			dbRepo.save(context: context)
		}
	}
	
	private func setLocationFields(session: GpsSession, fetchedLocation: GpsLocationResponse, context: NSManagedObjectContext) -> GpsLocation{
		let location = GpsLocation(context: context)
		location.type = dbRepo.getLocationTypeById(locationTypeId: fetchedLocation.gpsLocationTypeId, context: context)
		location.session = session
		location.recordedAt = self.getDate(string: fetchedLocation.recordedAt)
		location.lat = fetchedLocation.latitude
		location.lon = fetchedLocation.longitude
		location.accuracy = fetchedLocation.accuracy
		location.alt = fetchedLocation.altitude
		location.verticalAccuracy = fetchedLocation.verticalAccuracy
		location.saved = true
		var type = dbRepo.getLocationTypeById(locationTypeId: fetchedLocation.gpsLocationTypeId, context: context)
		if(type == nil){
			dbRepo.loadLocationTypesFromApi(context: context)
			type = dbRepo.getLocationTypeById(locationTypeId: fetchedLocation.gpsLocationTypeId, context: context)
		}
		location.type = type
//		print("Location made. \(location)")
		return location
		
	}
	
	
	
	private func mapSession(fetchedResult: GpsSessionResponse, context: NSManagedObjectContext) -> GpsSession{

		let sessionFromDb = dbRepo.getSessionById(sessionId: fetchedResult.id!, context: context)
		
		if(sessionFromDb != nil){
			dbRepo.edtiSession(session: sessionFromDb!,
							   context: context,
							   description: fetchedResult.description,
							   name: fetchedResult.name,
							   speed: fetchedResult.speed,
							   climb: fetchedResult.climb,
							   descend: fetchedResult.descent,
							   distance: fetchedResult.distance,
							   duration: fetchedResult.duration,
							   paceMax: fetchedResult.paceMax,
							   paceMin: fetchedResult.paceMin,
							   appUserId: fetchedResult.appUserId ?? fetchedResult.userId
			)
			return sessionFromDb!
		} else {
			let newSession = GpsSession(context: context)
			updateSessionFields(session: newSession, fetchedResult: fetchedResult)
			return newSession
		}
	}
	
	
	private func updateSessionFields(session: GpsSession, fetchedResult: GpsSessionResponse, additionalFields: [String: AnyHashable]? = nil){
		session.sessionId = fetchedResult.id
		session.name = additionalFields?["name"] as! String? ?? fetchedResult.name
		session.descr = additionalFields?["descr"] as! String? ?? fetchedResult.description
		session.recordedAt = session.recordedAt ?? getDate(string: fetchedResult.recordedAt)
		session.duration = additionalFields?["duration"] as! Double? ?? fetchedResult.duration!
		session.speed = additionalFields?["speed"] as! Double? ?? fetchedResult.speed!
		session.distance = additionalFields?["distance"] as! Double? ?? fetchedResult.distance!
		session.climb = additionalFields?["climb"] as! Double? ?? fetchedResult.climb!
		session.descend = additionalFields?["descend"] as! Double? ?? fetchedResult.descent!
		session.paceMax = additionalFields?["paceMax"] as! Double? ?? fetchedResult.paceMax!
		session.paceMin = additionalFields?["paceMin"] as! Double? ?? fetchedResult.paceMin!
		session.typeId = fetchedResult.gpsSessionTypeId ?? session.typeId
		session.type = fetchedResult.gpsSessionType ?? session.type
		session.saved = true
		session.appUserId = fetchedResult.appUserId ?? fetchedResult.userId ?? session.appUserId
		
	}
	
	private func getDate(string: String?) -> Date? {
		if(string == nil){
			return nil
		}
		var date = dateFormatter.date(from: string!)
		if(date == nil){
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
			date = dateFormatter.date(from: string!)
			if(date == nil){
				dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
				return nil
			}else{
				dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
				return date
			}

		}else{
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
			return date
		}
	}
	
	
}
