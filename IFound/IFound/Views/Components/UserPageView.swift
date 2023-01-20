//
//  UserPageView.swift
//  IFound
//
//  Created by Edgar Vildt on 16.01.2023.
//

import SwiftUI

struct UserPageView: View {
	@EnvironmentObject var authenticationManager: AuthenticationaManager
	@Environment (\.managedObjectContext) var managedObjContext
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment (\.dismiss) var dismiss

	
    var body: some View {
		VStack{
			Text("Welcome \(authenticationManager.authResponse?.firstName ?? "noname")!")
				.font(Font.title.bold())
				.padding()
			
			Text("You are loged in and can enjoy full functionality of this app 😎")
				.foregroundColor(.primary)
				.padding()
				
			Spacer()

			Text("While you are loged in all your sessions will be sent to the **sportmap.akaver.com** website").padding()
			
			Button("Logout", action:
					{
				authenticationManager.logout(context: managedObjContext)
				dismiss()
			})
			.padding()
			.buttonStyle(.bordered)
			.font(.title)
			.foregroundColor(.orange)
		}.padding()
    }
}

struct UserPageView_Previews: PreviewProvider {
    static var previews: some View {
        UserPageView()
    }
}
