//
//  GpxExporter.swift
//  IFound
//
//  Created by Edgar Vildt on 20.01.2023.
//

import Foundation
import UIKit

class GpxExporter{
	
	
	func createGpx(session: GpsSession){
		
		// 2017-01-06T14:33:40Z
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-dd-MM'T'HH:mm:ss'Z'"
		var xml = """
 <?xml version='1.0' encoding='UTF-8'?>
		<gpx version='1.1' creator='Endomondo.com' xsi:schemaLocation='http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd http://www.garmin.com/xmlschemas/GpxExtensions/v3 http://www.garmin.com/xmlschemas/GpxExtensionsv3.xsd http://www.garmin.com/xmlschemas/TrackPointExtension/v1 http://www.garmin.com/xmlschemas/TrackPointExtensionv1.xsd' xmlns='http://www.topografix.com/GPX/1/1'>
	<metadata>
	  <author>
		<name>Ifound app</name>
		
	  </author>
	  <link href='http://www.endomondo.com'>
		<text>Exported track</text>
	  </link>
   <time>\(dateFormatter.string(from: session.recordedAt ?? Date()))</time></metadata>
"""
		
  for location in session.checkpointLocations{
	  xml += "<wpt lat='\(location.coordinate.latitude)' lon='\(location.coordinate.longitude)'></wpt>"
  }
		xml += """
	
	<trk>
	<type>RUNNING</type>


"""
		
		
		xml += "<trkseg>"
		for trackLocation in session.wrappedLocations{
			xml += "<trkpt lat='\(trackLocation.lat)' lon='\(trackLocation.lon)'></trkpt>"
		}

		xml.append("    </trkseg></trk> </gpx>")

		print(xml)

		exportStringToNotes(string: xml, fileName: "SessionName.gpx")
		
		
	}
	
	func exportStringToNotes(string: String, fileName: String) {
			let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
			let fileURL = documentsDirectory.appendingPathComponent(fileName)

			do {
				try string.write(to: fileURL, atomically: false, encoding: .utf8)
				let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
				UIApplication.shared.keyWindow?.rootViewController?.present(activityViewController, animated: true, completion: nil)
			} catch {
				print("Error saving file: (error.localizedDescription)")
			}
		}
	
}


