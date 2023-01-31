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
	@EnvironmentObject var authenticationManager: AuthenticationaManager
	var APIMapper: APIRepositoryMapper = APIRepositoryMapper()
	let reachability = try! Reachability()
	
	
	
	@FetchRequest(sortDescriptors: [SortDescriptor(\.recordedAt, order: .reverse)])
	var sessions: FetchedResults<GpsSession>
	
	var body: some View {
		VStack{
			NavigationView{
				List{
					ForEach(sessions){ session in
						if(horizontalSizeClass == .compact && verticalSizeClass == .regular){
							HistoryExpandableCardView(portrait: true, session: session)
								.environmentObject(authenticationManager)
								.environment(\.managedObjectContext, managedObjContext)
							
							
							
						}else{
							HistoryExpandableCardView(portrait: false, session: session)
								.environmentObject(authenticationManager)
								.environment(\.managedObjectContext, managedObjContext)
							
							
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
				
				// Preform network, auth checks, check if saved and depete from backedn
				
			}.forEach { session in
				
				deleteFromBackend(session: session)
				managedObjContext.delete(session)
				do{
					try managedObjContext.save()
				}catch{
					print("Problem with saving context after deleting sessions")
				}
			}
			
		}
		
	}
	
	func deleteFromBackend(session: GpsSession){
		if(session.sessionId != nil && authenticationManager.userLogedIn && reachability.connection != .unavailable){
			APIMapper.deleteSession(session: session, token: authenticationManager.authResponse!.token!, context: managedObjContext)
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
	@Environment(\.managedObjectContext) var managedObjContext
	@EnvironmentObject var authenticationManager: AuthenticationaManager
	var APIMapper: APIRepositoryMapper = APIRepositoryMapper()
	@State var editMode: Bool = false
	let generator: GpxExporter = GpxExporter()
	
	var portrait: Bool = true
	@State private var expanded: Bool = false
	var session: GpsSession
	
	var body: some View {
		
		HStack{
			VStack{
				Section{
					HStack{
						
						Text("Your session at:" )
							.font(.title)
							.padding([.top, .leading])
							.foregroundColor(.orange)
						//					if(portrait || expanded){
						Spacer()
						
						
						Image(systemName: "arrow.up.and.down.text.horizontal")
							.font(.largeTitle)
							.foregroundColor(.orange)
							.onTapGesture {
								expanded.toggle()
							}
							.padding([.top, .leading])
							.offset(y: 10)
						
						Image(systemName: getCouldIcon())
							.padding([.top, .trailing])
							.offset(y: 10)
							.font(.title2)
						
						
						
						//					}
					}
					HStack{
						Text("\(session.recordedAt?.formatted() ?? "NO DATA" )")
							.font(.title3)
							.foregroundColor(Color.primary)
							.padding(.leading)
						Spacer()
					}
				}
				
				
				//
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
							Text("\(String(format: "%.2f", session.speedInMinPerKm)) min/km")
								.font(.title3)
								.foregroundColor(Color.primary)
								.padding(.leading)
							Spacer()
						}
						HStack{
							Text("\(String(format: "%.2f", session.speedInKmPerHour)) km/h")
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
							Text("\(session.distanceForDisplay)")
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
						HistoryEditable(session: session, edit: $editMode)
							.environmentObject(authenticationManager)
							.environment(\.managedObjectContext, managedObjContext)
						
					}
					Section{
						if(!editMode){

							Button(action: {
								generator.createGpx(session: session)
								
							}, label: {
								Image(systemName: "square.and.arrow.up")
								
							})
							.padding(.bottom)
							.buttonStyle(.bordered)
							.font(.title2)
							.foregroundColor(.orange)
							
						
							
							Button("Edit", action: {
								editMode.toggle()
							})
							.padding(.bottom)
							.buttonStyle(.bordered)
							.font(.title2)
							.foregroundColor(.orange)

							
							
						}
						if(!session.fullySaved && authenticationManager.userLogedIn){
							Button("Save to cloud", action: {
								APIMapper.preformSyncing(session: session, token: authenticationManager.authResponse!.token!, context: managedObjContext)
							})
								.padding(.bottom)
								.buttonStyle(.bordered)
								.font(.title2)
								.foregroundColor(.orange)
						}else if(authenticationManager.userLogedIn && session.fullySaved){
							Button("Unassign fron account", action: {
								DataRepository().save(context: managedObjContext)
								APIMapper.unassignSessionFromAccount(session: session, token: authenticationManager.authResponse!.token!, context: managedObjContext)
							})
							.padding(.bottom)
							.buttonStyle(.bordered)
							.font(.title2)
							.foregroundColor(.orange)
						}
						
						//						.padding()
						//						.buttonStyle(.bordered)
						//						.font(.title2)
						//						.foregroundColor(.orange)
						
					}
				}
				
				Section{
					
					
					if(portrait){
						MapView(
							region: session.middleRegion,
							direction: CLLocationDirection(0),
							showMarker: false,
							staticMap: true,
							directionPreference: expanded ? .Free : .CenteredNorthUp,
							polylineCoordinates: session.polyLineLocations,
							speeds: session.locationSpeeds,
							checkpointCoordinates: session.checkpointLocations,
							scrollEnabled: expanded
						)
						.frame(minHeight: 300)
					}
					//					if(!portrait){
					//						Spacer()
					//					}
					if(!portrait){
						MapView(
							region: session.middleRegion,
							direction: CLLocationDirection(0),
							showMarker: false,
							staticMap: true,
							directionPreference: expanded ? .Free : .CenteredNorthUp,
							polylineCoordinates: session.polyLineLocations,
							speeds: session.locationSpeeds,
							checkpointCoordinates: session.checkpointLocations,
							scrollEnabled: expanded
						)
						.frame(minHeight: !expanded ? 300 : 400)
						
					}
				}
			}
		}
		.background(Color(uiColor: .systemBackground))
		.cornerRadius(15)
		.padding(.bottom)
		.shadow(color: .secondary.opacity(0.8), radius: 1)
		
	}
	
	func getCouldIcon() -> String{
		if(session.saved && !session.fullySaved){
			return "exclamationmark.icloud"
		}
		if(session.fullySaved){
			return "checkmark.icloud"
		}
		return "icloud.slash"
	}
	
}


struct HistoryEditable: View {
	
	@State var session: GpsSession
	@Environment(\.managedObjectContext) var managedObjContext
	@EnvironmentObject var authenticationManager: AuthenticationaManager
	@State var name: String = ""
	@State var descr: String = ""
	@Binding var edit: Bool
	let reachability = try! Reachability()
	
	
	var body: some View{
		if(!edit){
			HStack{
				Text("Session name: " )
					.font(.title)
					.padding([.top, .leading])
					.foregroundColor(.orange)
				Spacer()
			}
			HStack{
				Text(name)
					.font(.title3)
					.foregroundColor(Color.primary)
					.padding(.leading)
				Spacer()
			}
			
			HStack{
				Text("Description: " )
					.font(.title)
					.padding([.top, .leading])
					.foregroundColor(.orange)
				Spacer()
			}
			HStack{
				Text(descr)
					.font(.title3)
					.foregroundColor(Color.primary)
					.padding(.leading)
				Spacer()
			}.onAppear{
				name = session.name ?? "No name"
				descr = session.descr ?? "No description"
			}
			
		}else{
			HStack{
				Text("Session name: " )
					.font(.title)
					.padding([.top, .leading])
					.foregroundColor(.orange)
				Spacer()
			}
			HStack{
				TextField("", text: $name)
					.font(.title3)
					.foregroundColor(Color.primary)
					.padding(.leading)
					.textFieldStyle(.roundedBorder)
				Spacer()
			}
			
			HStack{
				Text("Description: " )
					.font(.title)
					.padding([.top, .leading])
					.foregroundColor(.orange)
				Spacer()
			}
			HStack{
				TextField("", text: $descr)
					.font(.title3)
					.foregroundColor(Color.primary)
					.padding(.leading)
					.textFieldStyle(.roundedBorder)
				
				Spacer()
			}
			Button("Save", action: {
				session.name = name
				session.descr = descr
				DataRepository().save(context: managedObjContext)
				if(reachability.connection != .unavailable && authenticationManager.userLogedIn && session.fullySaved){
					APIRepositoryMapper().updateSession(session: session, token: authenticationManager.authResponse!.token!, context: managedObjContext)
				}
				edit.toggle()
			})
			.padding()
			.buttonStyle(.bordered)
			.font(.title2)
			.foregroundColor(.orange)
		}
		
		
	}
	
}
