//
//  Current.swift
//  Stormy
//
//  Created by Cade Ward on 11/10/14.
//  Copyright (c) 2014 Cade Ward. All rights reserved.
//

import Foundation
import UIKit

struct Current {
    
    var currentTime: String?
    var temperature: Int
    var humidity: Double
    var precipitationProbability: Double
    var summary: String
    var icon: UIImage?
    var city: String
    
    init(weatherJSON: NSDictionary) {
        let current = weatherJSON["currently"] as NSDictionary
        
        temperature = current["temperature"] as Int
        humidity = current["humidity"] as Double
        precipitationProbability = current["precipProbability"] as Double
        summary = current["summary"] as String
        city = "Logan, UT"
        icon = stringToIcon(current["icon"] as String)
        currentTime = dateStringFromUnixTime(current["time"] as Int)
    }
    
    func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let date = NSDate(timeIntervalSince1970: timeInSeconds)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(date)
    }
    
    func stringToIcon(iconString: String) -> UIImage {
        var imageName: String
        
        switch iconString {
            case "clear-day":
                imageName = "clear-day"
            case "clear-night":
                imageName = "clear-night"
            case "rain":
                imageName = "rain"
            case "snow":
                imageName = "snow"
            case "sleet":
                imageName = "sleet"
            case "wind":
                imageName = "wind"
            case "fog":
                imageName = "fog"
            case "cloudy":
                imageName = "cloudy"
            case "partly-cloudy-day":
                imageName = "partly-cloudy"
            case "partly-cloudy-night":
                imageName = "cloudy-night"
            default:
                imageName = "default"
        }
        
        var iconImage = UIImage(named: imageName)
        return iconImage!
    }
    
}