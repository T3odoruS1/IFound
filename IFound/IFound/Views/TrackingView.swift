//
//  TrackingView.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import SwiftUI
import MapKit
import Drawer

struct TrackingView: View {
	
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	@EnvironmentObject var locationManager: AppLocationManager
	@Environment (\.managedObjectContext) var managedObjContext


	@State var radius = 10
	@State var heights = [CGFloat(50), CGFloat(200), CGFloat(660)]
	
	@State private var region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
		span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
//	@FetchRequest(sortDescriptors: [SortDescriptor(\.typeId, order: .reverse)])
//				var types: FetchedResults<GpsLocationType>
	
	var body: some View {
		
		VStack{

			ZStack{
				MapView(
					region: locationManager.region,
					direction: locationManager.currentDirecion,
					directionPreference: locationManager.directionPreference,
					polylineCoordinates: locationManager.polyLineCoordinates,
					speeds: locationManager.speeds,
					checkpointCoordinates: locationManager.checkpointCoordinates,
					mapType: locationManager.mapType,
					waypointCoords: locationManager.wayPointCoords
					
				)
				.alert(isPresented: .constant(true)){
					Alert(title: Text("For move accurate results start tracking only when you are about to start moving."), dismissButton:
							.default(Text("Got it!")))
			 }
				
				
				
				if(horizontalSizeClass == .compact && verticalSizeClass == .regular){
					VStack(spacing: 4){
						DrawerView(heights: .constant([CGFloat(100), CGFloat(200), CGFloat(660)]))
							.environmentObject(locationManager)
					
				} // VStack
				}else if(verticalSizeClass == .compact){
					HStack(spacing: 4){
						

						Spacer().frame(width: 30, height: 30)
						DrawerView(heights: .constant([CGFloat(100), CGFloat(200), CGFloat(330)]))
							.environmentObject(locationManager)
							.padding(.leading)
						
						Spacer()



					}.padding(.leading) // VStack
				}else if(verticalSizeClass == .regular && horizontalSizeClass == .regular){
					HStack(spacing: 4){
						
						DrawerView(heights: .constant([CGFloat(60), CGFloat(200), CGFloat(660)]))
							.padding(.leading)
							.environmentObject(locationManager)
						
						Spacer()


					}
					
				}
					
				
			} // ZStack
			.ignoresSafeArea()
			
			
						
			
				
			
		}// VStack
		.onDisappear{
			
			// Code to be used if desireb behaviour is turning off location updates when leaving the view.
//			if(locationManager.updateRunning){
//				locationManager.toggleLocationUpdates()
//			}
		}
//		.ignoresSafeArea()
			
			
	} // View
}

			

struct TrackingView_Previews: PreviewProvider {
	
	static var previews: some View {
		TrackingView().environmentObject(AppLocationManager())
    }
}



//
//	.ignoresSafeArea()
//			.safeAreaInset(edge: .top, spacing: 5){
//					Text(" ")
//						.frame(height: 10)
//						.padding(.bottom)
//						.frame(maxWidth: .infinity)
//						.background(.ultraThinMaterial)
