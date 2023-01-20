//
//  PreferenceController.swift
//  IFound
//
//  Created by Edgar Vildt on 19.01.2023.
//

import Foundation

class PreferenceController: ObservableObject {
	@Published var updateFrequency: Int = 10
	@Published var sendUpdatesActive: Bool = true
	
}
