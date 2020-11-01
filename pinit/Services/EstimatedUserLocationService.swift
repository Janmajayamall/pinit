//
//  EstimatedUserLocationService.swift
//  pinit
//
//  Created by Janmajaya Mall on 10/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

class EstimatedUserLocationService: ObservableObject {
    
    init() {
        self.setupService()
    }
    
    var currentLocation: CLLocation? {
        if let horizontalLocation = self.locationData.sorted(by: {
            if $0.horizontalAccuracy == $1.horizontalAccuracy {
                return $0.timestamp > $1.timestamp
            }
            return $0.horizontalAccuracy < $1.horizontalAccuracy
        }).first, let verticalLocation = self.locationData.sorted(by: {
            if $0.verticalAccuracy == $1.verticalAccuracy {
                return $0.timestamp > $1.timestamp
            }
            return $0.verticalAccuracy < $1.verticalAccuracy
        }).first {
            return CLLocation(coordinate: horizontalLocation.coordinate, altitude: verticalLocation.altitude, horizontalAccuracy: horizontalLocation.horizontalAccuracy, verticalAccuracy: verticalLocation.verticalAccuracy, timestamp: Date.init())
        }
        return nil
    }
    var locationData: Array<CLLocation> = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    private func filterAndUpdateLocation(withLocation location: CLLocation) {
        // calculating how old is location data
        let locationAge = -1 * location.timestamp.timeIntervalSinceNow
        
        if (locationAge < 10) {
            // making sure desired accuracy of location is within limit (i.e. 100m )
            if (location.horizontalAccuracy < 100){
                // update the location data
                self.locationData.append(location)
                
                // remove old location estimates
                self.removeOldLocationEstimates()
                
                // notify that the location has been updated
                NotificationCenter.default.post(name: .estimatedUserLocationServiceDidUpdateLocation, object: self.currentLocation)
            }
        }
    }
    
    func notifyCurrentLocation() {
        self.removeOldLocationEstimates()
        // notify current location        
        NotificationCenter.default.post(name: .estimatedUserLocationServiceDidUpdateLocation, object: self.currentLocation)
    }
    
    private func removeOldLocationEstimates() {        
        self.locationData = self.locationData.filter({ (location) -> Bool in
            let locationAge = -1 * location.timestamp.timeIntervalSinceNow
            if (locationAge < 10) {
                return true
            }else {
                return false
            }
        })
    }
    
    func setupService() {
        self.subscribeToLocationService()
    }
    
    func stopService() {
        self.locationData.removeAll()
    }
    
    func startService(){
        self.stopService()
    }
}

// extensions for subscriptions
extension EstimatedUserLocationService {
    // subcribing to location services
    func subscribeToLocationService(){
        Publishers.locationServiceDidUpdateLocationPublisher.sink { (location) in            
            self.filterAndUpdateLocation(withLocation: location)
        }.store(in: &cancellables)
    }
}

