//
//  IFoundApp.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import SwiftUI

@main
struct IFoundApp: App {
	
	@StateObject var controller = DataController.shared
	@StateObject var authenticationManager =  AuthenticationaManager()
	
    var body: some Scene {
        WindowGroup {
			HomeView()
				.environment(\.managedObjectContext, controller.container.viewContext)
				.environmentObject(authenticationManager)
        }
    }
}
