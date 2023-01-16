//
//  File.swift
//  IFound
//
//  Created by Edgar Vildt on 14.01.2023.
//

import Foundation
import MapKit
import CoreLocation

class GradientPolyline: MKPolyline {
	var hues: [CGFloat]?
	public func getHue(from index: Int) -> CGColor {
		return UIColor(hue: (hues?[index])!, saturation: 1, brightness: 1, alpha: 1).cgColor
	}
}

extension GradientPolyline {
	convenience init(locations: [CLLocation]) {
		let coordinates = locations.map( { $0.coordinate } )
		self.init(coordinates: coordinates, count: coordinates.count)

		let V_MAX: Double = 5.0, V_MIN = 2.0, H_MAX = 0.3, H_MIN = 0.03

		hues = locations.map({
			let velocity: Double = $0.speed

			if velocity > V_MAX {
				return CGFloat(H_MAX)
			}

			if V_MIN <= velocity || velocity <= V_MAX {
				return CGFloat((H_MAX + ((velocity - V_MIN) * (H_MAX - H_MIN)) / (V_MAX - V_MIN)))
			}

			if velocity < V_MIN {
				return CGFloat(H_MIN)
			}

			return CGFloat(velocity)
		})
	}
}
