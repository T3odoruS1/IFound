//
//  ServiceManager.swift
//  IFound
//
//  Created by Edgar Vildt on 25.12.2022.
//

import Foundation


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

extension AuthResponse {
	func toString() -> String {
		if let errors = errors {
			let errorsString = errors.reduce("") { result, error in
				return result + "\n - " + error.value.joined(separator: "\n - ")
			}
			return errorsString
		} else if let messages = messages {
			let messagesString = messages.reduce("") { result, message in
				return result + "\n - " + message
			}
			return messagesString
		} else {
			return "Registration complete"
		}
	}
}


class AuthenticationaManager: ObservableObject {
	@Published var userLogedIn: Bool = false
	@Published var authResponse: AuthResponse? = nil
	@Published var statusMessage: String = ""
	private let baseUrl: String = "https://sportmap.akaver.com/api/v1.0/"
	
	
	func registerRequest(email: String, password: String, lastName: String, firstName: String) {
		
		let registerUrl = baseUrl + "account/register"
		guard let url = URL(string: registerUrl) else { return }
		
		let jsonDict: [String: String] = [
			"email": email,
			"password": password,
			"lastName": lastName,
			"firstName": firstName
		]
		
		processResponse(url: url, jsonDict: jsonDict)
	}
	
	func loginRequest(email: String, password: String){
		let registerUrl = baseUrl + "account/login"
		guard let url = URL(string: registerUrl) else { return }
		
		let jsonDict: [String: String] = [
			"email": email,
			"password": password
		]
		processResponse(url: url, jsonDict: jsonDict)
		
	}
	
	func processResponse(url: URL, jsonDict: [String: AnyHashable]){
		preformPostRequest(url: url, dataDict: jsonDict) { response in
			DispatchQueue.main.async {
				// Next lines of code here
				print("RESPONCSE RECIEVED: \(String(describing: response))")
				self.authResponse = response
				self.statusMessage = response?.toString() ?? "NO STATUS"
				
				if(self.authResponse?.token != nil){
					self.userLogedIn = true
					print("AuthManager: User is now loged in")
				}
			}
		}
	}
	
	
	func preformPostRequest(url: URL, dataDict: [String: AnyHashable], completion: @escaping (AuthResponse?) -> Void) {
		print("Preparing this for POST request: ")
		print(dataDict.description)
		
		// Prepare request
		var request = URLRequest(url: url)
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpMethod = "POST"
		request.httpBody = try? JSONSerialization.data(withJSONObject: dataDict)
		
		// Fetch json and decode into AuthResponse struct
		let task = URLSession.shared.dataTask(with: request) { data, _, error in
			guard let data = data, error == nil else {
				completion(nil)
				return
			}
			do {
				
//				 For printing
				let response2 = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
				print("Response 2 for reference: \(response2)")
				
//				self.printJson(data)
				let jsonDecoder = JSONDecoder()
				let response = try jsonDecoder.decode(AuthResponse.self, from: data)
				print("SUCCESS DECODING = \(response)")
				completion(response)
			} catch {
				print("DECODE ERROR in preformPostRequest: \(String(describing: error))")
				completion(nil)
			}
		}
		task.resume()
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
	
	func logout(){
		self.authResponse = nil
		self.userLogedIn = false
	}
}

