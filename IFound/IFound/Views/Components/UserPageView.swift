//
//  UserPageView.swift
//  IFound
//
//  Created by Edgar Vildt on 16.01.2023.
//

import SwiftUI

struct UserPageView: View {
	@EnvironmentObject var authenticationManager: AuthenticationaManager
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment (\.dismiss) var dismiss

	
    var body: some View {
		VStack{
			Text("Welcome Edgar Vildt!")
				.font(.largeTitle)
				.padding()
			
			Text("User test.test@test.com created and logged in.")
				.foregroundColor(.primary)
				
			Spacer()

			Text("While you are loged in all your sessions will be sent to the **Swagger** website")
			
			Button("Logout", action:
					{
				authenticationManager.logout()
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
