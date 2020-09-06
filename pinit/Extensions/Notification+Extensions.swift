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
    static let uploadPostServiceDidUploadPost = Notification.Name("uploadPostServiceDidUploadPost")
    
    // notifications for userProfileService
    static let userProfileServiceDidRequestUsernameChange = Notification.Name("userProfileServiceDidRequestUsernameChange")
    static let userProfileServiceDidRequestProfileImageChange = Notification.Name("userProfileServiceDidRequestProfileImageChange")
    static let userProfileServiceDidUpdateUserProfile = Notification.Name("userProfileServiceDidUpdateUserProfile")
    static let userProfileServiceDidNotFindUserProfile = Notification.Name("userProfileServiceDidNotFindUserProfile")
    static let userProfileServiceDidSetupProfileImage = Notification.Name("userProfileServiceDidSetupProfileImage")
    static let userProfileServiceDidRequestSetupUserProfile = Notification.Name("userProfileServiceDidRequestSetupUserProfile")
    
    // notifications for post display type service
    static let postDisplayTypeServiceDidChangeType = Notification.Name("postDisplayTypeServiceDidChangeType ")
    
    // notifications for AR View
    static let aRViewDidRequestResetMainView = Notification.Name("aRViewDidRequestResetMainView")
    static let aRViewDidTouchImageSCNNode = Notification.Name("aRViewDidTouchImageSCNNode")
    
    // notifications for camera feed
    static let cameraFeedSwitchInUseCamera = Notification.Name("cameraFeedSwitchInUseCamera")
    static let cameraFeedSwitchFlashMode = Notification.Name("cameraFeedSwitchFlashMode")
    static let cameraFeedDidRequestCaptureImage = Notification.Name("cameraFeedDidRequestCaptureImage")
    static let cameraFeedDidCaptureImage = Notification.Name("cameraFeedDidCaptureImage")
    
    // notification for retrieve post service
    static let retrievePostServiceDidReceivePostsForGeohashes = Notification.Name("retrievePostServiceDidReceivePostsForGeohashes")
    static let retrievePostServiceDidReceiveAllPosts = Notification.Name("retrievePostServiceDidReceiveAllPosts")
}
