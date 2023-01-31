//
//  ContentView.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import SwiftUI

struct HomeView: View {
	
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	@EnvironmentObject var authenticationManager: AuthenticationaManager
	@Environment (\.managedObjectContext) var managedObjContext
	@FetchRequest(sortDescriptors: []) var types: FetchedResults<GpsLocationType>
	@StateObject var locationManager: AppLocationManager = AppLocationManager()
	@StateObject var repo = DataRepository()
	@StateObject var prefController = PreferenceController()
	
	var body: some View {
		NavigationView{
			
			ScrollView{
				VStack{
					HStack{
						if(authenticationManager.userLogedIn){
							Text("Welcome, \(authenticationManager.authResponse!.firstName!)!")
								.font(.largeTitle)
						}
					}.padding(.top)
					
					
					Spacer().frame(width: 40, height: 30)
					NavigationCard(
						sysIcon: "figure.hiking",
						heading: "Start new activity",
						explanation: "Here you can start new activity",
						destination:  AnyView(ActivityView()
							.environmentObject(locationManager)))
					.foregroundColor(.primary)
					
					.simultaneousGesture(TapGesture()
						.onEnded {
							// Execute preparations
							locationManager.setContext(ctx: managedObjContext, repo: repo)
							if(repo.isTypesEmpty(context: managedObjContext)){
								repo.loadLocationTypesFromApi(context: managedObjContext)
							}
							if(authenticationManager.userLogedIn && authenticationManager.authResponse?.token != nil){
								locationManager.prepareForApiCalls(token: (authenticationManager.authResponse?.token!)!, updateInterval: prefController.updateFrequency, sendUpdates: prefController.sendUpdatesActive)
							}
							locationManager.setTypes(types: types.reversed())
						})
					
					NavigationCard(
						sysIcon: "person.crop.circle.fill",
						heading: !authenticationManager.userLogedIn ? "Login" : "Profile",
						explanation: !authenticationManager.userLogedIn ? "Login to sync your walks" : "User \(authenticationManager.authResponse!.firstName!) \(authenticationManager.authResponse!.lastName!) loged in",
						destination: AnyView(LoginView()
							.environment(\.managedObjectContext, managedObjContext)
							.environmentObject(authenticationManager)
						))
					.foregroundColor(.primary)
					
					NavigationCard(
						sysIcon: "clock",
						heading: "History",
						explanation: "Watch your old records",
						destination: AnyView(HistoryView()
							.environment(\.managedObjectContext, managedObjContext)
							.environmentObject(authenticationManager)
											 
						)
					)
					.simultaneousGesture(TapGesture().onEnded{
						if(authenticationManager.userLogedIn && !locationManager.updateRunning){
							APIRepositoryMapper().getUserId(token: authenticationManager.authResponse!.token!, context: managedObjContext) { userId in
								DispatchQueue.main.async {
									if(!userId.isEmpty){
										let sessions = APIRepositoryMapper().getAllSessions(token: authenticationManager.authResponse!.token!, context: managedObjContext, filteredBy: userId)
										
										print("Filtered sessions  from api \n")
										print(String(describing: sessions))
										print("\n")
										APIRepositoryMapper().filterSessionsFromOtherAccount(token: authenticationManager.authResponse!.token!, context: managedObjContext)
									}
								}
							}
							
						}
						else if(!authenticationManager.userLogedIn){
							DataRepository().deleteAccountSessions(context: managedObjContext)
						}
						DataRepository().checkForEmptySessions(context: managedObjContext)
					})
					
					.foregroundColor(.primary)
					
					NavigationCard(
						sysIcon: "gearshape.fill",
						heading: "Settings",
						explanation: "Change your preferences",
						destination: AnyView(OptionsView(number: prefController.updateFrequency, sendUpdates: prefController.sendUpdatesActive).environmentObject(prefController)
							.environment(\.managedObjectContext, managedObjContext)
						))
					.foregroundColor(.primary)
					
				} // VStack
				.navigationTitle("IFound")
				
			} // List
			.listStyle(.inset)
			
		} // Nav view
		.navigationViewStyle(StackNavigationViewStyle())
		.accentColor(.orange)
		//Initial configuration on app startup
		.onAppear{
			
			let prefs = repo.getPreferences(context: managedObjContext)
			if(prefs != nil){
				prefController.updateFrequency = Int(prefs!.updateFreq)
				prefController.sendUpdatesActive = prefs!.sendUpdates
			}
			print("Prefcontroller: ")
			print(prefController.sendUpdatesActive)
			print(prefController.updateFrequency)
			
			let session = repo.addSession(context: managedObjContext)
			repo.removeSession(session: session, context: managedObjContext)
			
			let userData = repo.getUserData(context: managedObjContext)
			if(userData != nil) {
				let jsonData = """
		{
		"token": "\(userData!.token!)",
		"firstName": "\(userData!.firstName!)",
		"lastName": "\(userData!.lastName!)",
		"status": "\(userData!.status!)"
		}
		""".data(using: .utf8)
				
				let decoder = JSONDecoder()
				do{
					let authRes = try decoder.decode(AuthResponse.self, from: jsonData!)
					authenticationManager.authResponse = authRes
					authenticationManager.userLogedIn = true
					authenticationManager.statusMessage = authRes.status!
				}catch {
					print("Couldnt decode user data")
				}
				
				
			}
			
			
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView()
	}
}
