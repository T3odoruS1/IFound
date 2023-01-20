//
//  APIRepository.swift
//  IFound
//
//  Created by Edgar Vildt on 18.01.2023.
//

import Foundation


class APIRepository {
	
	private let baseUrl: String = "https://sportmap.akaver.com/api/v1.0/"
	let dateFormatter = DateFormatter()
	init(){
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"

	}
	
	func getAllSessions(token: String, completion: @escaping ([GpsSessionResponse]) -> Void){
		let urlString = baseUrl + "GpsSessions/"
		guard let url = URL(string: urlString) else { return }
		RequestHelper().preformGetOrDeleteRequest(requestType: RequestType.GET ,
												  responseType: [GpsSessionResponse].self,
												  url: url,
												  urlParameters: ["minLocationsCount": 1,
																  "minDuration" : 0,
																  "minDistance": 0],
												  token: token) { response in
			DispatchQueue.main.async {
//				print("Sessions fetched from API : \(response as Any)")
				completion(response ?? [])
			}
		}
		
	}

	func getSession(sessionId:String, token: String, completion: @escaping (GpsSessionResponse?) -> Void) {
		let urlString = baseUrl + "GpsSessions/\(sessionId)"
		guard let url = URL(string: urlString) else { return}
		RequestHelper().preformGetOrDeleteRequest(requestType: RequestType.GET ,
												  responseType: GpsSessionResponse.self,
												  url: url,
												  urlParameters: [:],
												  token: token) { response in
			DispatchQueue.main.async {
				print("Session fetched from API : \(response as Any)")
				completion(response)
			}
		}
	}
	
	func saveSession(session: GpsSession, token: String, completion: @escaping (GpsSessionResponse) -> Void) {
		let urlString = baseUrl + "GpsSessions/"
//		let result: GpsSessionResponse? = nil
		let url = URL(string: urlString)

		let dataDict: [String: AnyHashable] = [
			"name": "defaultName",
			"description": "defaultDescription",
			"recordedAt": dateFormatter.string(from: session.recordedAt!),
			"paceMin": 60,
			"paceMax": 100
		]
		
		
		RequestHelper().preformPostOrPutRequest(requestType: .POST,
												responseType: GpsSessionResponse.self,
												url: url!,
												dataDict: dataDict,
												token: token) {response in
			DispatchQueue.main.async {
				completion(response!)
			}
		}
//		print("Response to saving session: \(result as Any)")
//		completion(result!)
	}
	
	
	func deleteSession(sessionId: String, token: String, completion: @escaping (GpsSessionResponse?) -> Void){
		let urlString = baseUrl + "GpsSessions/\(sessionId)"
		guard let url = URL(string: urlString) else { return }
		RequestHelper().preformGetOrDeleteRequest(requestType: RequestType.DELETE ,
												  responseType: GpsSessionResponse.self,
												  url: url,
												  urlParameters: [:],
												  token: token) { response in
			DispatchQueue.main.async {
				completion(response)
			}
		}

	}
	
	func updateSession(session: GpsSession, token: String){
		if(session.sessionId == nil){
			print("Session has no session id")
			return
		}
		let urlString = baseUrl + "GpsSessions/\(session.sessionId ?? "")"
		guard let url = URL(string: urlString) else { return }
		
		let dataDict: [String: AnyHashable] = [
			"id": session.sessionId,
			"name": session.name,
			"description": session.descr,
			"recordedAt":dateFormatter.string(from: session.recordedAt!),
			"duration": session.duration,
			"speed": session.speed == .infinity ? 100000: session.speed,
			"distance": session.distance,
			"climb": session.climb,
			"descent": session.descend,
			"paceMin": session.paceMin,
			"paceMax": session.paceMax,
			"gpsSessionTypeId": session.typeId,
			"appUserId": session.appUserId!
		]
		
		
		RequestHelper().preformPostOrPutRequest(requestType: .PUT,
												responseType: GpsSessionResponse.self,
												url: url,
												dataDict: dataDict,
												token: token) {response in
			DispatchQueue.main.async {
				print(response as Any)
			}
		}
	}
	
	
	func getLocationTypes(token: String, completion: @escaping ([GpsLocationTypeResponse]) -> Void) {
		
			let urlString = baseUrl + "GpsLocationTypes/"
			var result: [GpsLocationTypeResponse] = []
			guard let url = URL(string: urlString) else { return }
			RequestHelper().preformGetOrDeleteRequest(requestType: RequestType.GET ,
													  responseType: [GpsLocationTypeResponse].self,
													  url: url,
													  urlParameters: [:],
													  token: token) { response in
				DispatchQueue.main.async {
					result = response ?? []
				}
			}
			print("Location types fetched from API : \(result)")
			completion(result)
	}
	
	func getAllLocationsForSession(sessionId: String, token: String, completion: @escaping ([GpsLocationResponse]) -> Void){
		let urlString = baseUrl + "GpsLocations/"
		guard let url = URL(string: urlString) else { return }
		RequestHelper().preformGetOrDeleteRequest(requestType: RequestType.GET ,
												  responseType: [GpsLocationResponse].self,
												  url: url,
												  urlParameters: ["gpsSessionId":sessionId],
												  token: token) { response in
			DispatchQueue.main.async {
				completion(response ?? [])
			}
		}
		
	}
	
	func saveLocation(location: GpsLocation, token: String, completion: @escaping (GpsLocationResponse?) -> Void){
		let urlString = baseUrl + "GpsLocations/"
		var result: GpsLocationResponse? = nil
		guard let url = URL(string: urlString) else { return }
		
		let dataDict: [String: AnyHashable] = [
			"id": location.locationId,
			"recordedAt": dateFormatter.string(from: location.recordedAt!),
			"latitude": location.lat,
			"longitude": location.lon,
			"accuracy": location.accuracy,
			"verticalAccuracy": location.verticalAccuracy,
			"appUserId": location.session!.appUserId,
			"gpsSessionId": location.session!.sessionId,
			"gpsLocationTypeId": location.type!.typeId
		]
		
		
		RequestHelper().preformPostOrPutRequest(requestType: .POST,
												responseType: GpsLocationResponse.self,
												url: url,
												dataDict: dataDict,
												token: token) {response in
			DispatchQueue.main.async {
				result = response
			}
		}
		print("Response to saving location: \(result as Any)")
		completion(result)
	}
	
	func saveLocationBulk(locations:[GpsLocation], token: String) {
		let urlString = baseUrl + "GpsLocations/bulkupload/\(locations[0].session!.sessionId!)"
		print("URL : \(urlString)")
		guard let url = URL(string: urlString) else { return }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ"
		var payload: [[String: AnyHashable]] = []
		for location in locations {
			let dataDict: [String: AnyHashable] = [
				"id": location.locationId,
				"recordedAt": dateFormatter.string(from: location.recordedAt!),
				"latitude": location.lat,
				"longitude": location.lon,
				"accuracy": location.accuracy,
				"verticalAccuracy": location.verticalAccuracy,
				"appUserId": location.session!.appUserId,
				"gpsSessionId": location.session!.sessionId,
				"gpsLocationTypeId": location.type!.typeId
			]
			payload.append(dataDict)
			
		}
		
		RequestHelper().preformPostOrPutRequest(requestType: .POST,
												responseType: GpsLocationBulkResponse.self,
												url: url,
												dictArray: payload,
												token: token) {response in
			DispatchQueue.main.async {
				print("Result of bulk location adding \(response as Any)")
			}
		}
		
	}
	
	
}




