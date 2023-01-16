//
//  HistoryView.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import SwiftUI
import MapKit

struct HistoryView: View {
	
	@Environment(\.managedObjectContext) var managedObjContext
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment (\.dismiss) var dismiss
	@State var showActionSheet = false
	@State var selectedItem: GpsSession? = nil
	@FetchRequest(sortDescriptors: [SortDescriptor(\.recordedAt, order: .reverse)])
	var sessions: FetchedResults<GpsSession>

    var body: some View {
		VStack{
			NavigationView{
				List{
					ForEach(sessions){ session in
						if(horizontalSizeClass == .compact && verticalSizeClass == .regular){
								HistoryExpandableCardView(portrait: true, session: session)

						}else{
								HistoryExpandableCardView(portrait: false, session: session)
						}
					}.onDelete(perform: deleteSession)
					.listRowSeparator(.hidden)
				}
				.listStyle(.plain)
				.navigationViewStyle(.automatic)
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.navigationTitle("History")
    }
	
	func deleteSession(offsets: IndexSet){
		withAnimation{
			offsets.map{
				sessions[$0]
			}.forEach(managedObjContext.delete)
			do{
				try managedObjContext.save()
			}catch{
				print("Problem with saving context after deleting sessions")
			}
		}
	}
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}


struct HistoryExpandableCardView: View{
	
	@Environment (\.dismiss) var dismiss
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	var portrait: Bool = true
	@State private var expanded: Bool = false
	var session: GpsSession
	
	var body: some View {
		HStack{
			
			VStack{
				HStack{

					Text("Your session at:" )
						.font(.title)
						.padding([.top, .leading])
						.foregroundColor(.orange)
//					if(portrait || expanded){
						Spacer()
//					}
				}
				HStack{
					Text("\(session.recordedAt?.formatted() ?? "NO DATA" )")
						.font(.title3)
						.foregroundColor(Color.primary)
						.padding(.leading)
//					if(portrait || expanded){
						Spacer()
//					}
					
					
				}

				if(expanded){
					Section{
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
				}else{
					Spacer()
					Image(systemName: "arrow.up.and.down.text.horizontal")
						.font(.largeTitle)
						.foregroundColor(.orange)
					Spacer()
				}
				
				
				if(portrait){
					MapView(
						region: session.middleRegion,
						direction: CLLocationDirection(0),
						showMarker: false,
						staticMap: expanded,
						directionPreference: expanded ? .Free : .CenteredNorthUp,
						polylineCoordinates: session.polyLineLocations,
						speeds: session.locationSpeeds,
						checkpointCoordinates: session.checkpointLocations,
						scrollEnabled: expanded
					)
					.frame(minHeight: 300)
				}
				
			}
			if(!portrait){
				MapView(
					region: session.middleRegion,
					direction: CLLocationDirection(0),
					showMarker: false,
					staticMap: expanded,
					directionPreference: expanded ? .Free : .CenteredNorthUp,
					polylineCoordinates: session.polyLineLocations,
					speeds: session.locationSpeeds,
					checkpointCoordinates: session.checkpointLocations,
					scrollEnabled: expanded
				)
				.frame(minHeight: !expanded ? 300 : 400)

			}
		}
		
		.background(Color(uiColor: .systemBackground))
		.cornerRadius(15)
		.padding([.leading, .bottom, .trailing])
		.shadow(color: .secondary.opacity(0.8), radius: 1)
		.onTapGesture {
			expanded.toggle()
	  }
	}
	
}
