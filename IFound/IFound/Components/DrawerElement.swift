//
//  DrawerElement.swift
//  IFound
//
//  Created by Edgar Vildt on 21.12.2022.
//

import SwiftUI

struct DrawerElement: View {
	
	var buttonText: String
	var distance: Double
	
    var body: some View {
		
		VStack(spacing: 5){
			
			PairView(leftText: "Distance traveled:", rightText: "\(distance.rounded()) m")
				.padding([.leading, .trailing, .top])
				PairView(leftText: "Time spent:", rightText: "10 min")
				.padding([.leading, .trailing])
				PairView(leftText: "Average speed:", rightText: "5 km/h")
				.padding([.leading, .trailing, .bottom])
			
			
		} // Hstack 1
		.frame(maxWidth: .infinity, minHeight: 100)
		.background(.secondary)
		.cornerRadius(20)
		.padding([.leading, .trailing])
		
    }
}

struct DrawerElement_Previews: PreviewProvider {
    static var previews: some View {
		DrawerElement(buttonText: "Start/Stop", distance: 104.1324)
    }
}


struct PairView: View {
	let leftText: String
	let rightText: String

	var body: some View {
		HStack {
			
			Text(leftText)
			Spacer()
			Text(rightText)
		}
	}
}
