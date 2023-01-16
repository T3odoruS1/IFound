//
//  DrawerElement.swift
//  IFound
//
//  Created by Edgar Vildt on 21.12.2022.
//

import SwiftUI

struct DrawerElement: View {
	
	var heading1: String
	var heading2: String
	var heading3: String
	
	var value1: Double
	// This is time or distance
	var value2: Any
	var value3: Double

	
    var body: some View {
		
		VStack(spacing: 5){
			
			PairView(leftText: heading1, rightText: "\(value1.rounded()) m")
				.padding([.leading, .trailing, .top])
			PairView(leftText: heading2,
					 rightText: ViewHelper.getHeadingContentForDrawer(value: value2))
				.padding([.leading, .trailing])
			PairView(leftText: heading3, rightText: String(format: "%.2f", ceil(value3*100)/100) + "min/km")
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
		DrawerElement(heading1: "Distance traveled:",
					  heading2: "Time spent:",
					  heading3: "Average speed:",
					  value1: 1000.00, value2: 123.2, value3: 5.0)
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
