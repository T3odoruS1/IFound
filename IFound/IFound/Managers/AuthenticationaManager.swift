//
//  ServiceManager.swift
//  IFound
//
//  Created by Edgar Vildt on 25.12.2022.
//

import Foundation
import CoreData


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

	
	func registerRequest(email: String, password: String, lastName: String, firstName: String, context: NSManagedObjectContext) {
		
		let registerUrl = baseUrl + "account/register"
		guard let url = URL(string: registerUrl) else { return }
		
		let jsonDict: [String: String] = [
			"email": email,
			"password": password,
			"lastName": lastName,
			"firstName": firstName
		]
		
		processResponse(url: url, jsonDict: jsonDict, context: context)
	}
	
	func loginRequest(email: String, password: String, context: NSManagedObjectContext){
		let registerUrl = baseUrl + "account/login"
		guard let url = URL(string: registerUrl) else { return }
		
		let jsonDict: [String: String] = [
			"email": email,
			"password": password
		]
		processResponse(url: url, jsonDict: jsonDict, context: context)
		
	}
	
	func processResponse(url: URL, jsonDict: [String: AnyHashable], context: NSManagedObjectContext){
		RequestHelper().preformPostOrPutRequest(requestType: RequestType.POST ,responseType: AuthResponse.self, url: url, dataDict: jsonDict) { response in
			DispatchQueue.main.async {
				print("RESPONCSE RECIEVED: \(String(describing: response))")
				self.authResponse = response
				self.statusMessage = response?.toString() ?? "NO STATUS"
				
				if(self.authResponse?.token != nil){
					self.userLogedIn = true
					DataRepository().saveUserData(authResponse: self.authResponse!, context: context)
					print("AuthManager: User is now loged in")
				}
			}
		}
	}
	
	func logout(context: NSManagedObjectContext){
		self.authResponse = nil
		self.userLogedIn = false
		let data = DataRepository().getUserData(context: context)
		if(data != nil){
			context.delete(data!)
		}
		DataRepository().save(context: context)
	}
}

