//
//  DrawerButtons.swift
//  IFound
//
//  Created by Edgar Vildt on 21.12.2022.
//

import SwiftUI

struct DrawerButtons: View {
    var body: some View {
		ScrollView(.horizontal, showsIndicators: false){
			HStack{
				VStack{
					Text("Start/Stop")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						// Action
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
						// Action
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
					Text("Compass")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						// Action
					}, label: {
						Text("")
						Label("", systemImage: "safari").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(.orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
				
				
				
				
				VStack{
					Text("Reset")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						// Action
					}, label: {
						Text("")
						Label("", systemImage: "arrow.uturn.backward").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(.orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
				
				VStack{
					Text("North up")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						// Action
					}, label: {
						Text("")
						Label("", systemImage: "safari.fill").font(.largeTitle).frame(width: 55, height: 55)
					})
					.buttonStyle(.bordered)
					.foregroundColor(.orange)
					.background(.secondary)
					.clipShape(Circle())
				}.padding(.bottom)
				
				
				VStack{
					Text("Options")
						.padding(.top)
						.foregroundColor(.secondary)
					Button(action: {
						// Action
					}, label: {
						Text("")
						Label("", systemImage: "gear").font(.largeTitle).frame(width: 55, height: 55)
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
