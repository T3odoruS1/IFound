//
//  LoginView.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import SwiftUI

struct LoginView: View {
	@State var userLogedIn: Bool = false
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	@EnvironmentObject var authenticationManager: AuthenticationaManager
	@Environment (\.managedObjectContext) var managedObjContext

	
	@State var email: String = ""
	@State var password: String = ""
	@State var firstName: String = ""
	@State var lastName: String = ""
	@State var isLogin: Bool = true
	
	var body: some View {
		
		NavigationView{
			if(!authenticationManager.userLogedIn){
				VStack{
					Section{
						if(verticalSizeClass != .compact){
							Spacer()
							
						}

					}
					Section{
						
						Picker(selection: $isLogin, label: Text("Login or register")){
							Text("Login").tag(true)
								.padding()
								.font(.title)
							Text("Register").tag(false)
								.padding()
								.font(.title)
						}
						.pickerStyle(SegmentedPickerStyle())
						.cornerRadius(8)
						.foregroundColor(.orange)
						.padding()
						
						VStack{
							
							HStack{
								Text("Email")
									.padding(.leading)
									.font(Font.title3.bold())
									.foregroundColor(.orange)
								
								Spacer()
							}.padding(.trailing)
							TextField("yourEmail@example.com", text: $email)
								.padding([.bottom, .leading])
								.textFieldStyle(.roundedBorder)
								.autocapitalization(.none)
								.font(.title3)
							
							HStack{
								Text("Password")
									.padding(.leading)
									.font(Font.title3.bold())
									.foregroundColor(.orange)
								Spacer()
							}.padding(.trailing)
							SecureField("Yourp5ssw0rd", text: $password)
								.padding([.bottom, .leading])
								.textFieldStyle(.roundedBorder)
								.font(.title3)
							
							if(!isLogin){
								
								HStack{
									Text("First Name")
										.padding(.leading)
										.font(Font.title3.bold())
										.foregroundColor(.orange)
									Spacer()
								}.padding(.trailing)
								TextField("yourEmail@example.com", text: $firstName)
									.padding([.bottom, .leading])
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.font(.title3)
									
								
								HStack{
									Text("Last Name")
										.padding(.leading)
										.font(Font.title3.bold())
										.foregroundColor(.orange)
									Spacer()
								}.padding(.trailing)
								TextField("yourEmail@example.com", text: $lastName)
									.padding([.bottom, .leading])
									.textFieldStyle(.roundedBorder)
									.autocapitalization(.none)
									.font(.title3)
							}
							Spacer()

						}
					}
					.frame(maxWidth: 600)
					
					Section{

						HStack{
							if(isLogin){
								Button("Login", action: {
									Task{
										authenticationManager.loginRequest(email: email,
																		   password: password,
																		   context: managedObjContext
										)
										
									}
									
								})
								.padding()
								.buttonStyle(.bordered)
								.font(.title)
								.foregroundColor(.orange)
								
							}
							if(!isLogin){
								Button("Register", action: {
									// reg acitons
									Task{
										authenticationManager.registerRequest(email: email,
																			  password: password,
																			  lastName: lastName,
																			  firstName: firstName,
																			context: managedObjContext
										)
									}
									
								})
								.padding()
								.buttonStyle(.bordered)
								.font(.title)
								.foregroundColor(.orange)
							}
						}
					}
					Spacer()
					Spacer()
				}
			}
			UserPageView()
				.environmentObject(authenticationManager)
				.environment(\.managedObjectContext, managedObjContext)
		}.navigationViewStyle(.stack)
			.navigationTitle(!authenticationManager.userLogedIn ? (isLogin ? "Login" : "Register") : "Profile")
	}
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
	}
}


