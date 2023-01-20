//
//  OptionsView.swift
//  IFound
//
//  Created by Edgar Vildt on 21.12.2022.
//

import SwiftUI

struct OptionsView: View {
	
	@State  var number: Int
	@State  var sendUpdates: Bool
	@EnvironmentObject var prefController: PreferenceController
	@Environment (\.managedObjectContext) var managedObjContext
	@Environment (\.dismiss) var dismiss
	
	
	
	var body: some View {
		NavigationView{
			
			VStack{
				Spacer()
				HStack{
					Text("Choose update frequency(amount of locations)")
					Spacer()
					Picker("Update frequency", selection: $number){
						ForEach(Array(stride(from: 5, to: 60, by: 5)), id:\.self){ number in
							Text("\(number)")
						}
					}.pickerStyle(.wheel)
				}.padding()
				
				Toggle("Send updates", isOn: $sendUpdates)
					.toggleStyle(.switch)
					.padding()
				

				Spacer()
				Button("Save preferences", action: {
					prefController.updateFrequency = number
					prefController.sendUpdatesActive = sendUpdates
					DataRepository().savePrefs(preft: prefController, context: managedObjContext)
					dismiss()
				})
				.padding()
				.buttonStyle(.bordered)
				.font(.title)
				.foregroundColor(.orange)
			}.frame(maxWidth: 600)
			
		}.onAppear{
			let n = prefController.updateFrequency
			number = n
			let s = prefController.sendUpdatesActive
			sendUpdates = s
		}.navigationViewStyle(.stack)
			.navigationTitle("Settings")
	}
}





