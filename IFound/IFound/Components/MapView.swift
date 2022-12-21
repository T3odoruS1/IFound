//
//  MapView.swift
//  IFound
//
//  Created by Edgar Vildt on 20.12.2022.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
	
	let region : MKCoordinateRegion
	let polyLineCoordinates: [CLLocationCoordinate2D]
	
	func makeUIView(context: Context) -> MKMapView {
			let mapView = MKMapView()
			mapView.delegate = context.coordinator
			mapView.region = region
			mapView.showsUserLocation = true

		let polyLine = MKPolyline(coordinates: polyLineCoordinates, count: polyLineCoordinates.count)
		mapView.addOverlay(polyLine)
		mapView.removeOverlays(mapView.overlays.dropLast())
			return mapView
		}
	
	func makeCoordinator() -> Coordinator {
			Coordinator(self)
		}
	
	func updateUIView(_ view: MKMapView, context: Context) {
			view.setRegion(region, animated: true)
			let polyline = MKPolyline(coordinates: polyLineCoordinates, count: polyLineCoordinates.count)
			view.addOverlay(polyline)
		// Remove every polyline except the last
			view.removeOverlays(view.overlays.dropLast())
		}
	
	
}



class Coordinator: NSObject, MKMapViewDelegate {
	var parent: MapView

	init(_ parent: MapView) {
		self.parent = parent
	}

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
			
		if let routePolyline = overlay as? MKPolyline {
			let renderer = MKPolylineRenderer(polyline: routePolyline)
			renderer.strokeColor = UIColor.orange
			renderer.lineWidth = 10
			return renderer
		}
		 
		return MKOverlayRenderer()
		
	}

}
