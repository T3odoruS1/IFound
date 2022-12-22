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
				PairView(leftText: heading2, rightText: getHeadingContent(value: value2))
				.padding([.leading, .trailing])
				PairView(leftText: heading3, rightText: "\(value1.rounded()) km/h")
				.padding([.leading, .trailing, .bottom])
			
			
		} // Hstack 1
		.frame(maxWidth: .infinity, minHeight: 100)
		.background(.secondary)
		.cornerRadius(20)
		.padding([.leading, .trailing])
		
    }
	
	
	func getHeadingContent(value: Any) -> String{
		if(type(of: value) == Double.self){
			let typedVal = value as! Double
			return String(typedVal.rounded()) + " m"
		}else if(type(of: value) == DateInterval.self){
			let typedVal = value as! DateInterval
			let components = Calendar.current.dateComponents([.hour, .minute, .second], from: typedVal.start, to: typedVal.end)
			return "\(components.hour ?? 0):\(components.minute ?? 0):\(components.second ?? 0)"
		}
		return "Data not converted \(type(of: value))"
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
