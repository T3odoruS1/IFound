//
//  RoundIconButton.swift
//  IFound
//
//  Created by Edgar Vildt on 21.12.2022.
//

import SwiftUI

struct RoundIconButton: View {
	
	var iconName: String
	var selected: Bool
	
	var body: some View {
		Button(action: {
			// Action
		}, label: {
			Text("")
			Label("", systemImage: iconName).font(.largeTitle).frame(width: 55, height: 55)
		})
		.buttonStyle(.bordered)
		.foregroundColor(selected ? .orange : .primary)
		.background(.thickMaterial)
		.clipShape(Circle())
	}
}

struct RoundIconButton_Previews: PreviewProvider {
    static var previews: some View {
		RoundIconButton(iconName: "playpause", selected: true)
    }
}
