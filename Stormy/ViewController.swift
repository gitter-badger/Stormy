//
//  ViewController.swift
//  Stormy
//
//  Created by Cade Ward on 11/10/14.
//  Copyright (c) 2014 Cade Ward. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var percipitationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    
    private let API_KEY: String = "f9ba6b0f5179e294e924d941ee4dabf0"
    var CURRENT_COORDS: String!
    var CITY: String!
    var STATE: String!
    
    var locationManager:CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set buttons to loading state
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
        refreshButton.hidden = true
        
        ///////////////////
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        ///////////////////


    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
        
        CURRENT_COORDS = "\(coord.latitude),\(coord.longitude)"
        
        // location code via geocoder
        var encoder = CLGeocoder()
        encoder.reverseGeocodeLocation(manager.location, completionHandler: { (place, error) -> Void in
            if (error != nil) {
                println(error)
            }
            
            self.locationManager.stopUpdatingLocation()
            let pm: CLPlacemark = place[0] as CLPlacemark
            
            self.CITY = "\(pm.locality)"
            self.STATE = "\(pm.administrativeArea)"
            
        })
        
        getCurrentWeatherData()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // unable to connect to internet...
        let networkError = UIAlertController(title: "Error", message: "Unable to get your current location.", preferredStyle: .Alert)
        
        // okay button
        let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        networkError.addAction(okayButton)
        
        // present to user
        self.presentViewController(networkError, animated: true, completion: nil)
        
        println(error)
    }

    func getCurrentWeatherData() -> Void {
        // coordinates for USU
        let coords = CURRENT_COORDS
        
        
        let baseURL = NSURL(string: "https://api.forecast.io/forecast/\(API_KEY)/")
        let forecastURL = NSURL(string: "\(coords)", relativeToURL: baseURL)
        
        let sharedSession = NSURLSession.sharedSession()
        
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(forecastURL!, completionHandler: { (location:NSURL!, response:NSURLResponse!, error:NSError!) -> Void in
            if (error == nil) {
                let dataObj = NSData(contentsOfURL: location)
                let weatherJSON: NSDictionary = NSJSONSerialization.JSONObjectWithData(dataObj!, options: nil, error: nil) as NSDictionary
                let currentWeather = Current(weatherJSON: weatherJSON)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.temperatureLabel.text = "\(currentWeather.temperature)"
                    self.iconView.image = currentWeather.icon!
                    self.cityLabel.text = "\(self.CITY), \(self.STATE)"
                    self.currentTime.text = "\(currentWeather.currentTime!)"
                    self.humidityLabel.text = "\(currentWeather.humidity)"
                    self.percipitationLabel.text = "\(Int(currentWeather.precipitationProbability * 100))%"
                    self.summaryLabel.text = "\(currentWeather.summary)"
                    
                    // put buttons back to normal
                    self.refreshButton.hidden = false
                    self.refreshActivityIndicator.stopAnimating()
                    self.refreshActivityIndicator.hidden = true
                })
            } else {
//                println(error)
                // unable to connect to internet...
                let networkError = UIAlertController(title: "Error", message: "Unable to update weather.", preferredStyle: .Alert)

                // okay button
                let okayButton = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                networkError.addAction(okayButton)
                
                self.presentViewController(networkError, animated: true, completion: nil)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // put buttons back to normal
                    self.refreshButton.hidden = false
                    self.refreshActivityIndicator.stopAnimating()
                    self.refreshActivityIndicator.hidden = true
                })
            }
        })
        downloadTask.resume()
    }
    
    @IBAction func refresh() {
        refreshButton.hidden = true
        refreshActivityIndicator.hidden = false
        refreshActivityIndicator.startAnimating()
        
        getCurrentWeatherData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

