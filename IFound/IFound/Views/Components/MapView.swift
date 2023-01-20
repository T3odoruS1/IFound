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
	
	let region : MKCoordinateRegion?
	let direction: CLLocationDirection
	var showMarker: Bool = true
	var staticMap: Bool = false
	var directionPreference: ECameraType = .CenteredNorthUp
	var polylineCoordinates: [CLLocationCoordinate2D] = []
	var speeds: [Double] = []
	var checkpointCoordinates: [CLLocation] = []
	var mapType: MKMapType = .standard
	var scrollEnabled: Bool = true
	var waypointCoords: CLLocationCoordinate2D? = nil
	
	
	
	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		let camera = MKMapCamera()
		mapView.delegate = context.coordinator
		if let reg = region{
			if(directionPreference != .Free){
				
				mapView.setRegion(reg, animated: true)
				
				camera.centerCoordinate = reg.center
				if(!staticMap){
					camera.centerCoordinateDistance = 1300
				}else{
					camera.centerCoordinateDistance = calculateDistanceToTheCameraUsingRegion(reg: reg)
				}
				
				if(directionPreference == .CenteredDirectionUp){
					camera.heading = direction
					camera.pitch = 45
				}else{
					camera.heading = 0
				}
				mapView.setCamera(camera, animated: true)
				mapView.mapType = mapType
			}
			
		}
		
		mapView.isRotateEnabled = true
		mapView.isScrollEnabled = scrollEnabled
		mapView.showsUserLocation = showMarker
		
		mapView.showsCompass = true
		mapView.showsScale = true
		let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(context.coordinator.markWaypoint))
		gestureRecognizer.minimumPressDuration = 0.3
		mapView.addGestureRecognizer(gestureRecognizer)
		
		
		
		
		
		return mapView
	}
	
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	
	
	
	
	func updateUIView(_ view: MKMapView, context: Context) {
		let camera = MKMapCamera()
		if let reg = region{
			if(directionPreference != .Free){
				
				view.setRegion(reg, animated: true)
				
				camera.centerCoordinate = reg.center
				if(!staticMap){
					camera.centerCoordinateDistance = 1300
				}else{
					camera.centerCoordinateDistance = calculateDistanceToTheCameraUsingRegion(reg: reg)
				}
				if(directionPreference == .CenteredDirectionUp){
					camera.heading = direction
					camera.pitch = 45
				}else{
					camera.heading = 0
				}
				view.setCamera(camera, animated: true)
			}
		}
		
		
		for coord in checkpointCoordinates{
			//			let pin = MKPlacemark(coordinate: coord.coordinate, addressDictionary: nil)
			let myAnnotation = MKPointAnnotation()
			myAnnotation.title = "CP"
			myAnnotation.coordinate = coord.coordinate
			let annotationView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: "myAnnotation")
			annotationView.canShowCallout = false
			view.addAnnotation(myAnnotation)
		}
		
		if let wpCoords = waypointCoords {
			for annotation in view.annotations {
				if(annotation.title == "WP") {
					view.removeAnnotation(annotation)
					break;
				}
			}
			let myAnnotation = MKPointAnnotation()
			myAnnotation.title = "WP"
			myAnnotation.coordinate = wpCoords
			let annotationView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: "Waypoint")
			annotationView.canShowCallout = false
			
			view.addAnnotation(myAnnotation)
		}
		
		view.mapType = mapType
		
		let polyline = MKPolyline(coordinates: polylineCoordinates, count: polylineCoordinates.count)
		view.addOverlay(polyline)
		view.removeOverlays(view.overlays.dropLast())
		
	}
	
	func calculateDistanceToTheCameraUsingRegion(reg: MKCoordinateRegion) -> CLLocationDistance{
		let distanceLatitude = reg.span.latitudeDelta * 111320.0
		let distanceLongitude = reg.span.longitudeDelta * 111320.0 * cos(reg.center.latitude)
		
		let centerCoordinateDistance = max(distanceLatitude, distanceLongitude)
		return pow(centerCoordinateDistance, 1.1) > 1000 ? pow(centerCoordinateDistance, 1.1) : 1000
	}

	
}



class Coordinator: NSObject, MKMapViewDelegate {
	var parent: MapView
	
	init(_ parent: MapView) {
		self.parent = parent
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		
		if let routePolyline = overlay as? MKPolyline {
			let renderer =  MKPolylineRenderer(polyline: routePolyline)

			renderer.strokeColor = UIColor.orange
			renderer.lineWidth = 6
			return renderer
		}

		return MKOverlayRenderer()
	}
	
	@objc func markWaypoint(_ sender: UILongPressGestureRecognizer){
		print("Registerd")
	}
	
}
