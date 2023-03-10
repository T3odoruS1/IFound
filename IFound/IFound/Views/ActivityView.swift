//
//  ActivityView.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import SwiftUI
import CoreLocation

struct ActivityView: View {
	@Environment (\.managedObjectContext) var managedObjContext
	@EnvironmentObject var locationManager: AppLocationManager
	
    var body: some View {
		switch locationManager.authorizationStatus {
		case .notDetermined:
			Text("Location permission not determined")
				.onAppear {
					locationManager.requestPermissions()
			}
		case .restricted:
			Text("Location services restricted")
		case .denied:
			Text("Location services denied")
		case .authorizedAlways , .authorizedWhenInUse:
			
			TrackingView()
				.environmentObject(locationManager)
				.environment(\.managedObjectContext, managedObjContext)
			// Display tracking view
			
		default:
			Text("Unexpected status \(locationManager.authorizationStatus.rawValue)")
		
		} // Switch
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView()
    }
}
