//
//  LocationService.swift
//  pinit
//
//  Created by Janmajaya Mall on 17/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func locationService(didUpdateLocation location: CLLocation)
    func locationService(didFailWithError error: Error)
}

class LocationService: NSObject {
    
    var manager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var currentHeading: CLHeading?
    
    
    override init() {
        
        super.init()
        
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.distanceFilter = kCLDistanceFilterNone
        self.manager.headingFilter = kCLHeadingFilterNone
        
        //take care of authorization
        // TODO: MAKE REQUEST AUTHRORIZATION PROPER
        self.manager.requestWhenInUseAuthorization()
    }
    
    func activateHeadingUpdates(){
        self.manager.startUpdatingHeading()
    }
    
    func activateLocationUpdates(){
        self.manager.startUpdatingLocation()
    }
    
    func setupService(){
        self.activateLocationUpdates()
    }
    
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { (location) in
            self.currentLocation = location
            NotificationCenter.default.post(name: .locationServiceDidUpdateLocation, object: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.currentHeading = newHeading
        NotificationCenter.default.post(name: .locationServiceDidUpdateHeading, object: newHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Service manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
}
