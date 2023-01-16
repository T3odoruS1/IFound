//
//  DrawerButtons.swift
//  IFound
//
//  Created by Edgar Vildt on 21.12.2022.
//

import SwiftUI

struct DrawerButtons: View {
	@EnvironmentObject var locationManager: AppLocationManager
	@Environment(\.managedObjectContext) var managedObjContext
	

	
    var body: some View {
		ScrollView(.horizontal, showsIndicators: false){
			HStack{
				VStack{
					Text("Start/Stop")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
//						locationManager.setContext(ctx: managedObjContext)
						locationManager.toggleLocationUpdates()
					}, label: {
						Text("")
						Label("", systemImage: "playpause").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(.orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
				
				VStack{
					Text("Checkpoint")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						if(locationManager.updateRunning){
							locationManager.setCheckPoint()
						}
						
					}, label: {
						Text("")
						Label("", systemImage: "flag.checkered").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(.orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
				
				
				
				VStack{
					Text("Waypoint")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						// Action
					}, label: {
						Text("")
						Label("", systemImage: "mappin.and.ellipse").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(.orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
			
				
				
				
				VStack{
					Text("Free view")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						if(locationManager.updateRunning){
							locationManager.directionPreference = .Free
						}
						
					}, label: {
						Text("")
						Label("", systemImage: "arrow.up.and.down.and.arrow.left.and.right").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(locationManager.directionPreference == .Free ? .red : .orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
				
				VStack{
					Text("North up")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						if(locationManager.updateRunning){
							locationManager.directionPreference = .CenteredNorthUp
							locationManager.center()
						}
						

					}, label: {
						Text("")
						Label("", systemImage: "safari.fill").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(locationManager.directionPreference == .CenteredNorthUp ? .red : .orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
				
				
				VStack{
					Text("Direction Up")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						if(locationManager.updateRunning){
							locationManager.directionPreference = .CenteredDirectionUp
							locationManager.center()
						}
						
					}, label: {
						Text("")
						Label("", systemImage: "arrow.up").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(locationManager.directionPreference == .CenteredDirectionUp ? .red : .orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
				
				
				VStack{
					Text("Map type")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						locationManager.toggleMapType()
					}, label: {
						Text("")
						Label("", systemImage: "rectangle.2.swap").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(.orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
				
				
			} // Hstack 1
			
		}.frame(maxWidth: .infinity, minHeight: 100)
			.background(.secondary)
			.cornerRadius(20)
			.padding([.leading, .trailing])
		
    }
}

struct DrawerButtons_Previews: PreviewProvider {
    static var previews: some View {
        DrawerButtons()
    }
}
