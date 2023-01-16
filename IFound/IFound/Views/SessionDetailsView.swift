//
//  SessionDetailsView.swift
//  IFound
//
//  Created by Edgar Vildt on 13.01.2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct SessionDetailsView: View {
	@Environment(\.managedObjectContext) var managedObjContext
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment (\.dismiss) var dismiss
	
	
	var session: GpsSession
	
    var body: some View {
		ScrollView{
			VStack{
				Section{
					HStack{
						Text("Your session at:" )
							.font(.title)
							.padding([.top, .leading])
							.foregroundColor(.orange)
						Spacer()
					}
					HStack{
						Text("\(session.recordedAt?.formatted() ?? "NO DATA" )")
							.font(.title3)
							.foregroundColor(Color.primary)
							.padding(.leading)
						Spacer()
					}
					HStack{
						Text("Average speed: " )
							.font(.title)
							.padding([.top, .leading])
							.foregroundColor(.orange)
						Spacer()
					}
					HStack{
						Text("\(String(format: "%.2f", session.speed)) min/km")
							.font(.title3)
							.foregroundColor(Color.primary)
							.padding(.leading)
						Spacer()
					}
					HStack{
						Text("\(session.speed != 0 ? String(format: "%.2f", 60 / session.speed)  + " km/h" : "0 km/h")")
							.font(.title3)
							.foregroundColor(Color.primary)
							.padding(.leading)
						Spacer()
					}
					HStack{
						Text("Distance: " )
							.font(.title)
							.padding([.top, .leading])
							.foregroundColor(.orange)
						Spacer()
					}
					HStack{
						Text("\(String(format: "%.2f", session.distance)) m")
							.font(.title3)
							.foregroundColor(Color.primary)
							.padding(.leading)
						Spacer()
					}
					HStack{
						Text("Duration: " )
							.font(.title)
							.padding([.top, .leading])
							.foregroundColor(.orange)
						Spacer()
					}
					HStack{
						Text("\(ViewHelper.getTimeStringFromDoubleInSec(timeInSeconds: session.duration))")
							.font(.title3)
							.foregroundColor(Color.primary)
							.padding(.leading)
						Spacer()
					}
				}
				Section{
					MapView(
						region: session.middleRegion,
						direction: CLLocationDirection(0),
						showMarker: false,
						staticMap: true,
						directionPreference: .CenteredNorthUp,
						polylineCoordinates: session.polyLineLocations,
						checkpointCoordinates: session.checkpointLocations,
						scrollEnabled: true)
					.frame(minHeight: 300)
					.cornerRadius(15)
					.padding()
					
					HStack{
						Spacer()
						Button(action: {
							managedObjContext.delete(session)
							dismiss()
							
							
						}, label: {
							Text("Delete")
								.font(.title)
								.foregroundColor(.red)
								.padding([.trailing, .leading])
							
						}).buttonStyle(.bordered)
						Spacer()
					}
				}
			}
		}
//		}.onAppear {
//			shouldReload = true
//	 }.onDisappear {
//		 shouldReload = false
//	 }
    }
}

struct SessionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
		Text("Session details")
//		SessionDetailsView(session: GpsSession(), shouldReloadChildView: false)
    }
}
