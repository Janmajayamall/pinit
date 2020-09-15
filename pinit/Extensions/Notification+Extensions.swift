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
    
    // notifications for estimated user location service
    static let estimatedUserLocationServiceDidUpdateLocation = Notification.Name("estimetedUserLocationServiceDidUpdateLocation")
    
    
    // notifications for aRSceneLocationService
    static let aRSceneLocationServiceDidUpdateLocationEstimates = Notification.Name("aRSceneLocationServiceDidUpdateLocationEstimates")
    
    
    // notifications for uploadPostService
    static let uploadPostServiceDidRequestCreatePostWithImage = Notification.Name("uploadPostServiceDidRequestCreatePostWithImage")
    static let uploadPostServiceDidUploadPost = Notification.Name("uploadPostServiceDidUploadPost")
    static let uploadPostServiceDidRequestCreatePostWithVideo = Notification.Name("uploadPostServiceDidRequestCreatePostWithVideo")
    
    
    // notifications for userProfileService
    static let userProfileServiceDidRequestUsernameChange = Notification.Name("userProfileServiceDidRequestUsernameChange")
    static let userProfileServiceDidRequestProfileImageChange = Notification.Name("userProfileServiceDidRequestProfileImageChange")
    static let userProfileServiceDidUpdateUserProfile = Notification.Name("userProfileServiceDidUpdateUserProfile")
    static let userProfileServiceDidNotFindUserProfile = Notification.Name("userProfileServiceDidNotFindUserProfile")
    static let userProfileServiceDidSetupProfileImage = Notification.Name("userProfileServiceDidSetupProfileImage")
    static let userProfileServiceDidRequestSetupUserProfile = Notification.Name("userProfileServiceDidRequestSetupUserProfile")
    
    
    // notifications for AR View
    static let aRViewDidRequestResetMainView = Notification.Name("aRViewDidRequestResetMainView")
    static let aRViewDidRequestResetGroupNodesPos = Notification.Name("aRViewDidRequestResetGroupNodesPos")
    static let aRViewUserDidTapView = Notification.Name("aRViewUserDidTapView")
    
    // notification for GroupSCNNode
    static let groupSCNNodeDidLoadPostDisplayData = Notification.Name("groupSCNNodeDidLoadPostDisplayData")
    static let groupSCNNodeDidRequestCurrentPostDisplayInfo = Notification.Name("groupSCNNodeDidRequestCurrentPostDisplayInfo")
    
    
    // notifications for camera feed
    static let cameraFeedSwitchInUseCamera = Notification.Name("cameraFeedSwitchInUseCamera")
    static let cameraFeedSwitchFlashMode = Notification.Name("cameraFeedSwitchFlashMode")
    static let cameraFeedDidRequestCaptureImage = Notification.Name("cameraFeedDidRequestCaptureImage")
    static let cameraFeedDidCaptureImage = Notification.Name("cameraFeedDidCaptureImage")
    static let cameraFeedSwitchCameraOutputType = Notification.Name("cameraFeedSwitchCameraOutputType")
    static let cameraFeedDidRequestToggleRecordingVideo = Notification.Name("cameraFeedDidRequestToggleRecordingVideo")
    static let cameraFeedDidCaptureVideo = Notification.Name("cameraFeedDidCaptureVideo")
    
    
    // notification for retrieve post service
    static let retrievePostServiceDidReceivePostsForGeohashes = Notification.Name("retrievePostServiceDidReceivePostsForGeohashes")
    static let retrievePostServiceDidReceiveAllPosts = Notification.Name("retrievePostServiceDidReceiveAllPosts")
    
    // notifications for PostDisplayNodeModel
    static let postDisplayNodeModelDidRequestMuteAVPlayer = Notification.Name("postDisplayNodeModelDidRequestMuteAVPlayer")
}
