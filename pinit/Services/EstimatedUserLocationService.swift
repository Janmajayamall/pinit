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
    
    var currentLocation: CLLocation?
    
    private var cancellables: Set<AnyCancellable> = []
    
    
    
}

// extensions for subscriptions
extension EstimatedUserLocationService {
    // subcribing to location services
    func subscribeToLocationService(){
        Publishers.locationServiceDidUpdateLocationPublisher.sink { (location) in
            self.currentLocation
        }.store(in: &cancellables)
    }
}

