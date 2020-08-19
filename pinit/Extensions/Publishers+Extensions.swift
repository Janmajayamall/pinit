//
//  Publishers+Extensions.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Combine
import FirebaseAuth
import CoreLocation

extension Publishers {
    
    // publishers for Authentication
    static var authenticationServiceDidAuthStatusChangePublisher: AnyPublisher<User, Never> {
        NotificationCenter
            .default
            .publisher(for: .authenticationServiceDidAuthStatusChange)
            .compactMap({ (notification) -> User? in
                if let user = notification.object as? User {
                    return user
                }
                else{
                    return nil
                }
            })
            .eraseToAnyPublisher()
    }
    
    // publishers for location services
    static var locationServiceDidUpdateLocationPublisher: AnyPublisher<CLLocation, Never> {
        NotificationCenter
            .default
            .publisher(for: .locationServiceDidUpdateLocation)
            .compactMap { (notification) -> CLLocation? in
                guard let location = notification.object as? CLLocation else {return nil}
                return location
        }.eraseToAnyPublisher()
    }
    static var locationServiceDidUpdateHeadingPublisher: AnyPublisher<CLHeading, Never> {
        NotificationCenter
            .default
            .publisher(for: .locationServiceDidUpdateHeading)
            .compactMap { (notification) -> CLHeading? in
                guard let heading = notification.object as? CLHeading else {
                    return nil
                }
                return heading
        }
        .eraseToAnyPublisher()
    }
    
    // publishers for geohasing service
    static var geohasingServiceDidUpdateGeohashPublisher: AnyPublisher<GeohashModel, Never> {
        NotificationCenter
            .default
            .publisher(for: .geohasingServiceDidUpdateGeohash)
            .compactMap { (notification) -> GeohashModel? in
                guard let geohash = notification.object as? GeohashModel else {return nil}
                return geohash
        }
        .eraseToAnyPublisher()
    }
    
    // publishers for aRSceneLocationService
    static var aRSceneLocationServiceDidUpdateLocationEstimatesPublisher: AnyPublisher<CLLocation, Never> {
        NotificationCenter
            .default
            .publisher(for: .aRSceneLocationServiceDidUpdateLocationEstimates)
            .compactMap { (notification) -> CLLocation? in
                guard let locationEstimates = notification.object as? CLLocation else {return nil}
                return locationEstimates
        }.eraseToAnyPublisher()
    }
    
    // publishers for imageSCNNode
    static var imageSCNNodeDidLoadImagePublisher: AnyPublisher<String, Never> {
        NotificationCenter
            .default
            .publisher(for: .imageSCNNodeDidLoadImage)
            .compactMap { (notification) -> String? in
                guard let id = notification.object as? String else {return nil}
                return id
        }
        .eraseToAnyPublisher()
    }
}
