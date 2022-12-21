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
	@State var radius = 10
	@State var heights = [CGFloat(50), CGFloat(200), CGFloat(660)]
	
	@State private var region = MKCoordinateRegion(
		center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
		span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))

	var body: some View {
		VStack{
			ZStack{
				MapView(
					region: locationManager.region,
					polyLineCoordinates: locationManager.polyLineCoordinates)
				
				
				if(horizontalSizeClass == .compact && verticalSizeClass == .regular){
					VStack(spacing: 4){
					
						DrawerView(heights: .constant([CGFloat(60), CGFloat(200), CGFloat(660)])).environmentObject(locationManager)
					
				} // VStack
				}else if(verticalSizeClass == .compact){
					HStack(spacing: 4){
						DrawerView(heights: .constant([CGFloat(60), CGFloat(200), CGFloat(330)])).padding(.leading).environmentObject(locationManager)
						Spacer()
					
				} // VStack
				}else if(verticalSizeClass == .regular && horizontalSizeClass == .regular){
					HStack(spacing: 4){
						DrawerView(heights: .constant([CGFloat(60), CGFloat(200), CGFloat(660)])).padding(.leading).environmentObject(locationManager)
						Spacer()
					}
					
				}
					
				
			} // ZStack
			.ignoresSafeArea()
			
						
			
				
			
		}// VStack
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
