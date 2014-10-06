//
//  ViewController.swift
//  Weather
//
//  Created by Lynn on 14/10/3.
//  Copyright (c) 2014年 Jerry. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var loadingMessage: UILabel!
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        
        let background = UIImage(named:"background.png")
        self.view.backgroundColor = UIColor(patternImage: background)
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action:"handleSingleTap:")
        self.view.addGestureRecognizer(singleFingerTap)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        loading.startAnimating()
        
        if(ios8()){
            println("ios8")
            locationManager.requestAlwaysAuthorization()
        }

        locationManager.startUpdatingLocation()
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer){
        locationManager.startUpdatingLocation()
    }

    func ios8() -> Bool {
        var version = UIDevice.currentDevice().systemVersion
        println(version);
        return version == "8.0";
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location: CLLocation = locations[locations.count-1] as CLLocation
        if(location.horizontalAccuracy > 0){
            println(location.coordinate.latitude);
            println(location.coordinate.longitude);
            
            updateWeatherInfo(location.coordinate.latitude, longitude:location.coordinate.longitude)
            locationManager.stopUpdatingLocation();
            
        }
    }
    
    func updateWeatherInfo(latitude:CLLocationDegrees, longitude:CLLocationDegrees){
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        
        let params = ["lat": latitude, "lon": longitude, "cnt" :0]
        
        manager.GET(url,
            parameters: params,
            success: { (operation:
                AFHTTPRequestOperation!,
                responseObject:AnyObject!) in
                println("json: " + responseObject.description!)
                
                self.updateUISucess(responseObject as NSDictionary)
                },
            failure: { (operation:AFHTTPRequestOperation!,
                error:NSError!) in
                println("Error: " + error.localizedDescription)
                
                self.loadingMessage.text = "无法定位"
            })
    }
    
    func updateUISucess(jsonResult:NSDictionary){
        self.loadingMessage.text = nil
        self.loading.hidden = true
        self.loading.stopAnimating()
        
        if let tempResult = ((jsonResult["main"]? as NSDictionary)["temp"] as? Double){
            var temperature:Double
            if let sys = (jsonResult["sys"]? as? NSDictionary){
                if let country = (sys["country"] as? String){
                    if (country == "US"){
                        temperature = round((tempResult - 237.15) * 1.8 + 32)
                    }
                    else {
                        temperature = round(tempResult-237.15);
                    }
                    
                    self.temperature.text = "\(temperature)°"
                }
                
                if let countryName = (jsonResult["name"] as? String){
                    self.location.text = countryName
                }
                
                if let weather = (jsonResult["weather"]? as? NSArray){
                    var condition = (weather[0] as NSDictionary)["id"] as Int
                    var sunrise = sys["sunrise"] as Double
                    var sunset = sys["sunset"] as Double
                    var nightTime = false
                    
                    var now = NSDate().timeIntervalSince1970
                    if(now < sunrise && now > sunset){
                        nightTime = true
                    }
                    self.updateWeatherIcon(condition, nightTime:nightTime)
                    return
                }
            }
        }
        self.loadingMessage.text = "暂无法加载，请稍候再试..."
        return
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error);
        self.loadingMessage.text = "Can't get your location!"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateWeatherIcon(condition:Int, nightTime:Bool){
        if(condition<300){
            if nightTime {
                self.icon.image = UIImage(named:"tstorm1_night")
            } else {
                self.icon.image = UIImage(named:"tstorm1")
            }
        }
            // Drizzle
        else if (condition < 500) {
            self.icon.image = UIImage(named: "light_rain")
        }
            // Rain / Freezing rain / Shower rain
        else if (condition < 600) {
            self.icon.image = UIImage(named: "shower3")
        }
            // Snow
        else if (condition < 700) {
            self.icon.image = UIImage(named: "snow4")
        }
            // Fog / Mist / Haze / etc.
        else if (condition < 771) {
            if nightTime {
                self.icon.image = UIImage(named: "fog_night")
            } else {
                self.icon.image = UIImage(named: "fog")
            }
        }
            // Tornado / Squalls
        else if (condition < 800) {
            self.icon.image = UIImage(named: "tstorm3")
        }
            // Sky is clear
        else if (condition == 800) {
            if (nightTime){
                self.icon.image = UIImage(named: "sunny_night") // sunny night?
            }
            else {
                self.icon.image = UIImage(named: "sunny")
            }
        }
            // few / scattered / broken clouds
        else if (condition < 804) {
            if (nightTime){
                self.icon.image = UIImage(named: "cloudy2_night")
            }
            else{
                self.icon.image = UIImage(named: "cloudy2")
            }
        }
            // overcast clouds
        else if (condition == 804) {
            self.icon.image = UIImage(named: "overcast")
        }
            // Extreme
        else if ((condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)) {
            self.icon.image = UIImage(named: "tstorm3")
        }
            // Cold
        else if (condition == 903) {
            self.icon.image = UIImage(named: "snow5")
        }
            // Hot
        else if (condition == 904) {
            self.icon.image = UIImage(named: "sunny")
        }
            // Weather condition is not available
        else {
            self.icon.image = UIImage(named: "dunno")
        }
    }
}

