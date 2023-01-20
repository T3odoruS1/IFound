//
//  RequestHelper.swift
//  IFound
//
//  Created by Edgar Vildt on 18.01.2023.
//

import Foundation


class RequestHelper{

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

	func fetchDataAndDecode<T: Decodable>(request: URLRequest,
										  responseType type: T.Type,
										  completion: @escaping (T?) -> Void) {
		print("fetchDataAndDecode started executing")
		let task = URLSession.shared.dataTask(with: request) { data, _, error in
			guard let dataResp = data, error == nil else {
				print("fetchDataAndDecode: Error occured \(String(describing: error))")
				completion(nil)
				return
			}
			do {
				if(data != nil){
					self.printJson(data!)
				}
				let jsonDecoder = JSONDecoder()
				let response = try jsonDecoder.decode(type, from: dataResp)
//				print("SUCCESS DECODING = \(response)")
				completion(response)
			} catch {
				print("DECODE ERROR: \(String(describing: error))")
				if(data != nil){
					self.printJson(data!)
				}else{
					print("data was nil")
				}
				completion(nil)
			}
		}
		task.resume()
	}

	func preformPostOrPutRequest<T: Decodable>(requestType: RequestType ,
											   responseType type: T.Type,
											   url: URL,
											   dataDict: [String: AnyHashable]? = nil,
											   dictArray: [[String: AnyHashable]]? = nil,
											   token: String? = nil ,
											   completion: @escaping (T?) -> Void) {
		// Prepare request
		var request = URLRequest(url: url)
		print("Preforming \(requestType.rawValue) request for data \(dataDict ?? [:])")
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		// All requests are connected with acount with this token. After authorization provide this token to the funciton
		if(token != nil){
			request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
		}
		if(requestType != .PUT){
			if( requestType != .POST){
				print("Privided incorrect request type into funcion preformPostOrPutRequest")
				completion(nil)
			}
		}
		request.httpMethod = requestType.rawValue
		if(dataDict != nil){
			let data = try? JSONSerialization.data(withJSONObject: dataDict!)
			request.httpBody = data
			print("Data to be sent: ")
			print(dataDict!)
			print("To url: \(url.description)")
		}else if(dictArray != nil){
			let data = try? JSONSerialization.data(withJSONObject: dictArray!)
			request.httpBody = data
			print("Data to be sent: ")
			print(dictArray!)
		}
		
		fetchDataAndDecode(request: request, responseType: type, completion: completion)
	}
	
	
	
	func preformGetOrDeleteRequest<T: Decodable>(requestType: RequestType,
												 responseType type : T.Type,
												 url: URL,
												 urlParameters params: [String: AnyHashable],
												 token: String? = nil,
												 completion: @escaping (T?) -> Void) {
		// Url modification
		
		print("Preparing \(requestType.rawValue) request for url \(url.description)")
		if(requestType != .GET){
			if(requestType != .DELETE){
				print("Provided incorrect request type into funcion preformGetOrDeleteRequest")
				completion(nil)
			}
		}
		print(token ?? "NO TOKEN")
		var urlString = url.absoluteString
		if(params.count > 0){
			urlString += "?"
		}
		for entry in params {
			urlString += entry.key + "=" + entry.value.description + "&"
		}
		if(urlString.last == "&") {
			urlString.removeLast()
		}
		
		guard let urlWithParams = URL(string: urlString ) else { return }
		// Prapare request
		var request = URLRequest(url: urlWithParams)
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		// All requests are connected with acount with this token. After authorization provide this token to the funciton
		if(token != nil){
			request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
		}
		request.httpMethod = requestType.rawValue
		
		fetchDataAndDecode(request: request, responseType: type, completion: completion)
	}
	
}

enum RequestType: String {
	case GET = "GET"
	case DELETE = "DELETE"
	case POST = "POST"
	case PUT = "PUT"
}
