//
//  DecodableStructs.swift
//  IFound
//
//  Created by Edgar Vildt on 18.01.2023.
//

import Foundation


struct GpsSessionResponse: Decodable {
	let id: String?
	let name: String?
	let description: String?
	// Date as string
	let recordedAt: String?
	let duration: Double?
	let speed: Double?
	let distance: Double?
	let climb: Double?
	let descent: Double?
	let paceMin: Double?
	let paceMax: Double?
	let gpsSessionTypeId: String?
	let gpsSessionType: String?
	let gpsLocationsCount: Int?
	let userFirstLastName: String?
	let appUserId: String?
	let userId: String?
	let type: String?
	let title: String?
	let status: Int?
	let detail: String?
	let instance: String?
	let messages: [String]?
	let additionalProp1: [String: String]?
	let additionalProp2: [String: String]?
	let additionalProp3: [String: String]?

	private enum CodingKeys: String, CodingKey {
		case id, name, description, recordedAt, duration, speed, distance, climb, descent, paceMin, paceMax, gpsSessionTypeId, gpsLocationsCount, userFirstLastName, appUserId, type, title, status, detail, instance, additionalProp1, additionalProp2, additionalProp3, messages, gpsSessionType, userId
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decodeIfPresent(String.self, forKey: .id)
		gpsSessionType = try container.decodeIfPresent(String.self, forKey: .gpsSessionType)
		name = try container.decodeIfPresent(String.self, forKey: .name)
		description = try container.decodeIfPresent(String.self, forKey: .description)
		recordedAt = try container.decodeIfPresent(String.self, forKey: .recordedAt)
		duration = try container.decodeIfPresent(Double.self, forKey: .duration)
		messages = try container.decodeIfPresent([String].self, forKey: .messages)
		speed = try container.decodeIfPresent(Double.self, forKey: .speed)
		distance = try container.decodeIfPresent(Double.self, forKey: .distance)
		climb = try container.decodeIfPresent(Double.self, forKey: .climb)
		descent = try container.decodeIfPresent(Double.self, forKey: .descent)
		paceMin = try container.decodeIfPresent(Double.self, forKey: .paceMin)
		paceMax = try container.decodeIfPresent(Double.self, forKey: .paceMax)
		gpsSessionTypeId = try container.decodeIfPresent(String.self, forKey: .gpsSessionTypeId)
		gpsLocationsCount = try container.decodeIfPresent(Int.self, forKey: .gpsLocationsCount)
		userFirstLastName = try container.decodeIfPresent(String.self, forKey: .userFirstLastName)
		appUserId = try container.decodeIfPresent(String.self, forKey: .appUserId)
		userId = try container.decodeIfPresent(String.self, forKey: .userId)
		type = try container.decodeIfPresent(String.self, forKey: .type)
		title = try container.decodeIfPresent(String.self, forKey: .title)
		status = try container.decodeIfPresent(Int.self, forKey: .status)
		detail = try container.decodeIfPresent(String.self, forKey: .detail)
		instance = try container.decodeIfPresent(String.self, forKey: .instance)
		do {
			additionalProp1 = try container.decodeIfPresent([String: String].self, forKey: .additionalProp1)
		} catch {
			additionalProp1 = nil
		}
		do {
			additionalProp2 = try container.decodeIfPresent([String: String].self, forKey: .additionalProp2)
		} catch {
			additionalProp2 = nil
		}
		do {
			additionalProp3 = try container.decodeIfPresent([String: String].self, forKey: .additionalProp3)
		} catch {
			additionalProp3 = nil
		}
	}
}



struct AuthResponse: Decodable {
	let type: String?
	let title: String?
	let traceId: String?
	let errors: [String: [String]]?
	let token: String?
	let firstName: String?
	let lastName: String?
	let messages: [String]?
	let status: String?
	
	private enum CodingKeys: String, CodingKey {
		case type
		case title
		case traceId
		case errors
		case token
		case firstName
		case lastName
		case messages
		case status
	}

	init(from decoder:Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.type = try container.decodeIfPresent(String.self, forKey: .type)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		self.traceId = try container.decodeIfPresent(String.self, forKey: .traceId)
		self.errors = try container.decodeIfPresent([String: [String]].self, forKey: .errors)
		self.token = try container.decodeIfPresent(String.self, forKey: .token)
		self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
		self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
		self.messages = try container.decodeIfPresent([String].self, forKey: .messages)
		do{
			self.status = try container.decodeIfPresent(String.self, forKey: .status)
		}catch {
			print("status not decoded")
			self.status = nil
		}
		
	}
	
	
}


struct GpsLocationTypeResponse: Decodable {
	let id: String
	let nameId: String
	let name: String
	let descriptionId: String
	let description: String
}


struct GpsLocationResponse: Decodable {
	let id: String
	let recordedAt: String
	let latitude: Double
	let longitude: Double
	let accuracy: Double
	let altitude: Double
	let verticalAccuracy: Double
	let appUserId: String
	let gpsSessionId: String
	let gpsLocationTypeId: String
	
	private enum CodingKeys: String, CodingKey {
		case id
		case recordedAt
		case latitude
		case longitude
		case accuracy
		case altitude
		case verticalAccuracy
		case appUserId
		case gpsSessionId
		case gpsLocationTypeId
	}
}


struct GpsLocationBulkResponse: Decodable {
	let locationsAdded: Int
	let locationsReceived: Int
	let gpsSessionId: String
	
	private enum CodingKeys: String, CodingKey {
		case locationsAdded
		case locationsReceived
		case gpsSessionId
	}
}
