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

    // notifications for uploadPostService
    static let uploadPostServiceDidRequestCreatePostWithImage = Notification.Name("uploadPostServiceDidRequestCreatePostWithImage")
    static let uploadPostServiceDidUploadPost = Notification.Name("uploadPostServiceDidUploadPost")
    static let uploadPostServiceDidRequestCreatePostWithVideo = Notification.Name("uploadPostServiceDidRequestCreatePostWithVideo")
    
    
    // notifications for userProfileService
    static let userProfileServiceDidRequestUsernameChange = Notification.Name("userProfileServiceDidRequestUsernameChange")
    static let userProfileServiceDidUpdateUserProfile = Notification.Name("userProfileServiceDidUpdateUserProfile")
    static let userProfileServiceDidNotFindUserProfile = Notification.Name("userProfileServiceDidNotFindUserProfile")
    static let userProfileServiceDidRequestSetupUserProfile = Notification.Name("userProfileServiceDidRequestSetupUserProfile")
    
    // notifications for AR View
    static let aRViewDidRequestResetMainView = Notification.Name("aRViewDidRequestResetMainView")
    static let aRViewDidRequestResetGroupNodesPos = Notification.Name("aRViewDidRequestResetGroupNodesPos")
    static let aRViewUserDidTapView = Notification.Name("aRViewUserDidTapView")
    static let aRViewDidTapBackIcon = Notification.Name("aRViewDidTapBackIcon")
    
    // notification for GroupSCNNode
    static let groupSCNNodeDidLoadPostDisplayData = Notification.Name("groupSCNNodeDidLoadPostDisplayData")
    static let groupSCNNodeDidRequestCurrentPostDisplayInfo = Notification.Name("groupSCNNodeDidRequestCurrentPostDisplayInfo")
    static let groupSCNNodeDidRequestChangePostDisplayType = Notification.Name("groupSCNNodeDidRequestChangePostDisplayType")
    static let groupSCNNodeDidRequestReset = Notification.Name("groupSCNNodeDidRequestReset")
    
    
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
    static let retrievePostServiceDidReceiveUserPosts = Notification.Name("retrievePostServiceDidReceiveUserPosts")
    
    // notifications for PostDisplayNodeModel
    static let postDisplayNodeModelDidRequestMuteAVPlayer = Notification.Name("postDisplayNodeModelDidRequestMuteAVPlayer")
    
    // notifications for general function
    static let generalFunctionDidFailInternetConnection = Notification.Name("generalFunctionDidFailInternetConnection")
    static let generalFunctionManipulateTaskForUploadIndicator = Notification.Name("generalFunctionManipulateTaskForUploadIndicator")
    static let generalFunctionManipulateTaskForLoadIndicator = Notification.Name("generalFunctionManipulateTaskForLoadIndicator")    
    static let generalFunctionPostsDoNotExistForCurrentLocation = Notification.Name("generalFunctionPostsDoNotExistForCurrentLocation")
}
