//
//  LocationTypeData.swift
//  IFound
//
//  Created by Edgar Vildt on 25.12.2022.
//

import Foundation

struct ResponseData: Decodable {
	var types: [LocaionTypeData]
}

class LocaionTypeData: Codable {
	
	public var descr: String?
	public var name: String?
	public var typeId: String?
	public var nameId: String?
	public var descrId: String?
	
	
	enum CodingKeys: String, CodingKey{
		case name = "name"
		case nameId = "nameId"
		case descr = "description"
		case descrId = "descriptionId"
		case typeId = "id"
	}
	
	func loadFromJson(filename: String) -> [LocaionTypeData]? {
		if let url = Bundle.main.url(forResource: filename, withExtension: "json"){
			do{
				let data = try Data(contentsOf: url)
				let decoder = JSONDecoder()
				let jsonData = try decoder.decode(ResponseData.self, from: data)
				print("json data in location data type class : \(jsonData)")
				return jsonData.types
			}catch{
				print("error \(error)")
			}
		}
		return nil
	}
	
}
