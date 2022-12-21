//
//  DrawerView.swift
//  IFound
//
//  Created by Edgar Vildt on 21.12.2022.
//

import SwiftUI
import Drawer


struct DrawerView: View {
	@EnvironmentObject var locationManager: AppLocationManager
	@Binding var heights : [CGFloat]

	
    var body: some View {
		Drawer(heights: $heights){
			VStack{
				
				
				RoundedRectangle(cornerRadius: 12)
					.background(.secondary)
					.cornerRadius(12)
					.frame(width: 70, height: 5, alignment: .center)
					.padding()
				ScrollView{
					
					DrawerButtons()
					
					HStack{
						Text("Total stats")
							.padding(.leading)
							.foregroundColor(.secondary)
						Spacer()
					}
					DrawerElement(buttonText: "Start/Stop", distance: locationManager.distance)
					
					HStack{
						Text("From the last checkpoint")
							.padding([.leading, .top])
							.foregroundColor(.secondary)
						Spacer()
					}
					DrawerElement(buttonText: "Checkpoint", distance: 1234.4243)

					HStack{
						Text("From the last waypoint")
							.padding([.leading, .top])
							.foregroundColor(.secondary)
						Spacer()
					}
					DrawerElement(buttonText: "Waypoint", distance: 48488.432)
					Spacer().frame(height: 55)
				}
				

				
			}.background(.ultraThinMaterial)
				.frame(maxWidth: .infinity)
				.cornerRadius(20)
		} // Drawer
		.frame(maxWidth: 430)
    }
}

struct DrawerView_Previews: PreviewProvider {
    static var previews: some View {
		DrawerView(
			heights: .constant([CGFloat(50), CGFloat(200), CGFloat(660)]))
		.environmentObject(AppLocationManager())
    }
}
