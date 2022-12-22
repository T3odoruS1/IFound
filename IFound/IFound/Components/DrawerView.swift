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
					
					DrawerButtons().environmentObject(locationManager)
					
					HStack{
						Text("Total stats")
							.padding(.leading)
							.foregroundColor(.secondary)
						Spacer()
					}
					DrawerElement(heading1: "Distance traveled: ",
								  heading2: "Time spent: ",
								  heading3: "Average speed: ",
								  value1: locationManager.overallDistance,
								  value2: locationManager.overallTime,
								  value3: locationManager.overallAvgSpeed)
					
					HStack{
						Text("From the last checkpoint")
							.padding([.leading, .top])
							.foregroundColor(.secondary)
						Spacer()
					}
					DrawerElement(heading1: "Distance traveled: ",
								  heading2: "Straight line distance: ",
								  heading3: "Average speed: ",
								  value1: locationManager.fromCheckpointDistanceTraveled,
								  value2: locationManager.fromCheckpointDistanceStraight,
								  value3: locationManager.fromCheckpointAvgSpeed)

					HStack{
						Text("To next waypoint")
							.padding([.leading, .top])
							.foregroundColor(.secondary)
						Spacer()
					}
					DrawerElement(heading1: "Distance traveled: ",
								  heading2: "Straight line distance: ",
								  heading3: "Average speed: ",
								  value1: locationManager.fromWaypointDistanceTraveled,
								  value2: locationManager.toWayPointDistance,
								  value3: locationManager.sinceWaypointSetAvgSpeed)
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
