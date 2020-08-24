//
//  Notification+Extensions.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Combine

extension Notification.Name {
    
    // notifications for Authentication
    static let authenticationServiceDidAuthStatusChange = Notification.Name("authenticationServiceDidAuthStatusChange")
    
    // notifications for location services
    static let locationServiceDidUpdateLocation = Notification.Name("locationServiceDidUpdateLocation")
    static let locationServiceDidUpdateHeading = Notification.Name("locationServiceDidUpdateHeading")
    
    // notifications for geohasing service
    static let geohasingServiceDidUpdateGeohash = Notification.Name("geohasingServiceDidUpdateGeohash")
    
    // notifications for aRSceneLocationService
    static let aRSceneLocationServiceDidUpdateLocationEstimates = Notification.Name("aRSceneLocationServiceDidUpdateLocationEstimates")
    
    // notifications for ImageSCNNodes
    static let imageSCNNodeDidLoadImage = Notification.Name("imageSCNNodeDidLoadImage")
    
    // notifications for upoadPostService
    static let uploadPostServiceDidRequestCreatePost = Notification.Name("uploadPostServiceDidRequestCreatePost")
    
    // notifications for userProfileService
    static let userProfileServiceDidRequestUsernameChange = Notification.Name("userProfileServiceDidRequestUsernameChange")
    static let userProfileServiceDidRequestProfileImageChange = Notification.Name("userProfileServiceDidRequestProfileImageChange")
    static let userProfileServiceDidUpdateUserProfile = Notification.Name("userProfileServiceDidUpdateUserProfile")
    static let userProfileServiceDidNotFindUserProfile = Notification.Name("userProfileServiceDidNotFindUserProfile")
    static let userProfileServiceDidSetupProfileImage = Notification.Name("userProfileServiceDidSetupProfileImage")
}
