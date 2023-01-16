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
							//							if(isLogin){
							//								Image(systemName: "person.icloud")
							//									.font(.system(size: 70))
							//									.padding()
							//									.foregroundColor(.orange)
							//							}
							//							HStack{
							//								Text("\(isLogin ? "Login now" : "Register now")")
							//									.font(.title)
							//									.bold()
							//
							//							}.padding()
							Text("\(isLogin ? "Enter your email and password to login" : "Fill the registration form to register")")
								.font(.subheadline)
								.padding(.horizontal)
							//							Text("User loged in: \(serviceManager.userLogedIn.description)")
							Text(authenticationManager.statusMessage)
								.padding()
								.foregroundColor(authenticationManager.userLogedIn ? .green : .red)
							
						}
						
						if(isLogin){
							Spacer()
							Spacer()
						}
					}
					Section{
						
						Picker(selection: $isLogin, label: Text("Login or register")){
							Text("Login").tag(true).padding()
							Text("Register").tag(false).padding()
						}
						.pickerStyle(SegmentedPickerStyle())
						.background(.orange)
						.cornerRadius(8)
						.padding()
						
						VStack{
							
							FieldView(fieldValue: $email, placeHolderText: "Email")
							
							SecureField("", text: $password)
								.padding([.bottom, .trailing, .leading])
								.textFieldStyle(.plain)
								.offset(y:17)
								.placeholder(when: password.isEmpty, placeholder: {
									Text("Password")
										.fontWeight(.bold)
										.font(.title3)
										.padding([.top, .leading])
										.offset(y:17)
								})
							
							Rectangle ()
								.frame (minWidth: 350, minHeight: 3, maxHeight: 3)
								.padding([.leading, .trailing, .bottom])
								.foregroundColor (.orange)
							
							if(!isLogin){
								
								FieldView(fieldValue: $firstName, placeHolderText: "First name")
								
								FieldView(fieldValue: $lastName, placeHolderText: "Last name")
							}
						}
					}
					.frame(maxWidth: 600)
					
					Section{
						HStack{
							if(isLogin){
								Button("Login", action: {
									Task{
										authenticationManager.loginRequest(email: email,
																		   password: password)
										
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
																			  firstName: firstName)
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
		}.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView()
	}
}


