//
//  OptionsView.swift
//  IFound
//
//  Created by Edgar Vildt on 21.12.2022.
//

import SwiftUI

struct OptionsView: View {
	
	@State private var number: Int = 10
	var body: some View {
		NavigationView{
			ScrollView{
				VStack{
					
					HStack{
						Spacer()
						Text("Choose update frequency")
						Picker("Update frequency", selection: $number){
							ForEach(Array(stride(from: 10, to: 60, by: 5)), id:\.self){ number in
								Text("\(number)")
							}
						}
						Spacer()
					}.padding()
				}.navigationTitle("Settings")
			}
		}
	}
}

struct OptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OptionsView()
    }
}



