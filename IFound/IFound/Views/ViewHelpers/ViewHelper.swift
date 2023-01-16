//
//  ViewHelper.swift
//  IFound
//
//  Created by Edgar Vildt on 13.01.2023.
//

import Foundation

struct ViewHelper{
	
	static public func getTimeStringFromDoubleInSec(timeInSeconds: Double) -> String{
		let timeInterval: TimeInterval = timeInSeconds // 1 hour in seconds
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.hour, .minute, .second]
		formatter.unitsStyle = .positional
		formatter.zeroFormattingBehavior = .pad
		let formattedString = formatter.string(from: timeInterval)
		return formattedString ?? "00:00:00"
	}
	
	
	static public func getHeadingContentForDrawer(value: Any) -> String{
		if(type(of: value) == Double.self){
			let typedVal = value as! Double
			return String(typedVal.rounded()) + " m"
		}else if(type(of: value) == DateInterval.self){
			let typedVal = value as! DateInterval
			let components = Calendar.current.dateComponents([.hour, .minute, .second], from: typedVal.start, to: typedVal.end)
			let hours = components.hour ?? 0
			let hourString = hours > 9 ? String(hours) : "0" + String(hours)

			let minutes = components.minute ?? 0
			let minuteString = minutes > 9 ? String(minutes) : "0" + String(minutes)

			let seconds = components.second ?? 0
			let secondString = seconds > 9 ? String(seconds) : "0" + String(seconds)
			return "\(hourString):\(minuteString):\(secondString)"
		}
		return "Data not converted \(type(of: value))"
	}
	
}
