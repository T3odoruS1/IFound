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
			myAnnotation.coordinate = coord.coordinate
			let annotationView = MKPinAnnotationView(annotation: myAnnotation, reuseIdentifier: "myAnnotation")
			annotationView.canShowCallout = false
			view.addAnnotation(myAnnotation)
		}
		view.mapType = mapType
//		let polyline = MKPolyline(coordinates: polylineCoordinates, count: polylineCoordinates.count)
//		view.addOverlay(polyline)
//		view.removeOverlays(view.overlays.dropLast())
//		generatePolyline(locations: polylineCoordinates, speeds: speeds, in: view)
		
		var locations: [CLLocation] = []
		var i = 0
		for coordinate in polylineCoordinates {
			let location = CLLocation(
				coordinate: coordinate,
				altitude: CLLocationDistance(0),
				horizontalAccuracy: 0,
				verticalAccuracy: 0,
				course: 0,
				speed: speeds[i],
				timestamp: Date())
			
			locations.append(location)
			i += 1
			
		}
		let runRoute = GradientPolyline(locations: locations)
		view.addOverlay(runRoute)
//		let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(context.coordinator.markWaypoint))
//		gestureRecognizer.minimumPressDuration = 0.3
//		view.addGestureRecognizer(gestureRecognizer)
		
	}
	
	func calculateDistanceToTheCameraUsingRegion(reg: MKCoordinateRegion) -> CLLocationDistance{
		let distanceLatitude = reg.span.latitudeDelta * 111320.0
		let distanceLongitude = reg.span.longitudeDelta * 111320.0 * cos(reg.center.latitude)
		
		let centerCoordinateDistance = max(distanceLatitude, distanceLongitude)
		return pow(centerCoordinateDistance, 1.1) > 1000 ? pow(centerCoordinateDistance, 1.1) : 1000
	}
	
//	func generatePolyline(locations: [CLLocationCoordinate2D], speeds: [Double], in mapView: MKMapView){
//		var colorSegments: [(locations: [CLLocationCoordinate2D], color: UIColor)] = []
//		var currentSegmentLocations: [CLLocationCoordinate2D] = []
//		var currentSegmentColor: UIColor = .green
//		for (index, location) in locations.enumerated() {
//			let speed = speeds[index]
//			let color: UIColor
//			if speed < 10 {
//				color = .green
//			} else if speed < 6 {
//				color = .yellow
//			} else if speed < 3 {
//				color = .orange
//			} else{
//				color = .red
//			}
//			if color != currentSegmentColor {
//				colorSegments.append((locations: currentSegmentLocations, color: currentSegmentColor))
//				currentSegmentLocations = []
//				currentSegmentColor = color
//			}
//			currentSegmentLocations.append(location)
//		}
//		colorSegments.append((locations: currentSegmentLocations, color: currentSegmentColor))
//		for segment in colorSegments {
//			let polyline = MKPolyline(coordinates: segment.locations.map { $0 }, count: segment.locations.count)
//			let renderer = MKPolylineRenderer(polyline: polyline)
//			renderer.strokeColor = segment.color
//			mapView.addOverlay(polyline)
////			mapView.removeOverlays(mapView.overlays.dropLast())
//		}
//
//	}
	
}



class Coordinator: NSObject, MKMapViewDelegate {
	var parent: MapView
	
	init(_ parent: MapView) {
		self.parent = parent
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		
//		if let routePolyline = overlay as? MKPolyline {
//			let renderer =  MKPolylineRenderer(polyline: routePolyline)
//
//			renderer.strokeColor = UIColor.orange
//			renderer.lineWidth = 6
//			return renderer
//		}
		if overlay is GradientPolyline {
			let polyLineRender = GradidentPolylineRenderer(overlay: overlay)
			polyLineRender.lineWidth = 7
			return polyLineRender
		}

		
		return MKOverlayRenderer()
	}
	
	@objc func markWaypoint(_ sender: UILongPressGestureRecognizer){
		print("Registerd")
	}
	
}
