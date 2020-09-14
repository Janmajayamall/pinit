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
import AVFoundation

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
    
    // publishers for estimated user location service
    static var estimatedUserLocationServiceDidUpdateLocation: AnyPublisher<CLLocation, Never> {
        NotificationCenter
        .default
            .publisher(for: .estimatedUserLocationServiceDidUpdateLocation)
            .compactMap { (notification) -> CLLocation? in
                guard let location = notification.object as? CLLocation else {return nil}
                return location
        }.eraseToAnyPublisher()
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

    
    // publishers for keyboard height
    static var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter
                .default
                .publisher(for:UIResponder.keyboardWillShowNotification)
                .compactMap{
                    $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            }
            .map({ $0.height }),
            NotificationCenter
                .default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map({ _ in CGFloat(0)})
        ).eraseToAnyPublisher()
    }
    
    // publishers for uploadPostService
    static var uploadPostServiceDidRequestCreatePostWithImagePublisher: AnyPublisher<RequestCreatePostWithImageModel, Never> {
        NotificationCenter
            .default
            .publisher(for: .uploadPostServiceDidRequestCreatePostWithImage)
            .compactMap { (notification) -> RequestCreatePostWithImageModel? in
                guard let requestCreatePost = notification.object as? RequestCreatePostWithImageModel else {return nil}
                return requestCreatePost
        }
        .eraseToAnyPublisher()
    }
    static var uploadPostServiceDidUploadPostPublisher: AnyPublisher<OptimisticUIPostModel, Never>{
        NotificationCenter
        .default
            .publisher(for: .uploadPostServiceDidUploadPost)
            .compactMap { (notification) -> OptimisticUIPostModel? in
                guard let post = notification.object as? OptimisticUIPostModel else {return nil}
                return post
        }.eraseToAnyPublisher()
    }
    static var uploadPostServiceDidRequestCreatePostWithVideoPublisher: AnyPublisher<RequestCreatePostWithVideoModel, Never> {
        NotificationCenter
        .default
            .publisher(for: .uploadPostServiceDidRequestCreatePostWithVideo)
            .compactMap { (notification) -> RequestCreatePostWithVideoModel? in
                guard let requestPostModel = notification.object as? RequestCreatePostWithVideoModel else {return nil}
                return requestPostModel
        }.eraseToAnyPublisher()
    }
    
    // publishers for userProfileService
    static var userProfileServiceDidRequestUsernameChangePublisher: AnyPublisher<String, Never> {
        NotificationCenter
            .default
            .publisher(for: .userProfileServiceDidRequestUsernameChange)
            .compactMap { (notification) -> String? in
                guard let username = notification.object as? String else {return nil}
                return username
        }
        .eraseToAnyPublisher()
    }
    static var userProfileServiceDidRequestProfileImageChangePublisher: AnyPublisher<UIImage, Never> {
        NotificationCenter
            .default
            .publisher(for: .userProfileServiceDidRequestProfileImageChange)
            .compactMap { (notification) -> UIImage? in
                guard let profileImage = notification.object as? UIImage else {return nil}
                return profileImage
        }
        .eraseToAnyPublisher()
    }
    static var userProfileServiceDidUpdateUserProfilePublisher: AnyPublisher<ProfileModel, Never>{
        NotificationCenter
            .default
            .publisher(for: .userProfileServiceDidUpdateUserProfile)
            .compactMap { (notification) -> ProfileModel? in
                guard let userProfile = notification.object as? ProfileModel else {return nil}
                return userProfile
        }
        .eraseToAnyPublisher()
    }
    static var userProfileServiceDidNotFindUserProfilePublisher: AnyPublisher<User, Never> {
        NotificationCenter
            .default
            .publisher(for: .userProfileServiceDidNotFindUserProfile)
            .compactMap { (notification) -> User? in
                guard let user = notification.object as? User else {return nil}
                return user
        }.eraseToAnyPublisher()
    }
    static var userProfileServiceDidSetupProfileImagePublisher: AnyPublisher<UIImage, Never>{
        NotificationCenter
            .default
            .publisher(for: .userProfileServiceDidSetupProfileImage)
            .compactMap { (notification) -> UIImage? in
                guard let image = notification.object as? UIImage else {return nil}
                return image
        }.eraseToAnyPublisher()
    }
    static var userProfileServiceDidRequestSetupUserProfilePublisher: AnyPublisher<RequestSetupUserProfileModel, Never>{
        NotificationCenter
            .default
            .publisher(for: .userProfileServiceDidRequestSetupUserProfile)
            .compactMap { (notification) -> RequestSetupUserProfileModel? in
                guard let requestModel = notification.object as? RequestSetupUserProfileModel else {return nil}
                return requestModel
        }
        .eraseToAnyPublisher()
    }
    
    
    // publishers for ar view
    static var aRViewDidRequestResetMainView: AnyPublisher<Bool, Never>{
        NotificationCenter
        .default
            .publisher(for: .aRViewDidRequestResetMainView)
            .compactMap { (notificatoin) -> Bool? in
                guard let value = notificatoin.object as? Bool else {return nil}
                return value
        }
    .eraseToAnyPublisher()
    }
    static var aRViewDidRequestResetGroupNodesPosPublisher: AnyPublisher<Bool, Never>{
        NotificationCenter
        .default
            .publisher(for: .aRViewDidRequestResetGroupNodesPos)
            .compactMap { (notification) -> Bool? in
                guard let value = notification.object as? Bool else {return nil}
                return value
        }.eraseToAnyPublisher()
    }
    
    // publishers for group scn node
    static var groupSCNNodeDidLoadPostDisplayData: AnyPublisher<Bool, Never>{
        NotificationCenter
        .default
            .publisher(for: .groupSCNNodeDidLoadPostDisplayData)
            .compactMap { (notification) -> Bool? in
                guard let value = notification.object as? Bool else {return nil}
                return value
        }.eraseToAnyPublisher()
    }
    static var groupSCNNodeDidRequestCurrentPostDisplayInfoPublisher: AnyPublisher<PostDisplayInfoModel, Never> {
        NotificationCenter
        .default
            .publisher(for: .groupSCNNodeDidRequestCurrentPostDisplayInfo)
            .compactMap { (notification) -> PostDisplayInfoModel? in
                guard let model = notification.object as? PostDisplayInfoModel else {return nil}
                return model
        }.eraseToAnyPublisher()
    }
    
    // publishers for camera feed
    static var cameraFeedSwitchInUseCameraPublisher: AnyPublisher<CameraFeedController.CameraInUsePosition, Never>{
        NotificationCenter
        .default
            .publisher(for: .cameraFeedSwitchInUseCamera)
            .compactMap { (notification) -> CameraFeedController.CameraInUsePosition? in
                guard let object = notification.object as? CameraFeedController.CameraInUsePosition else {return nil}
                return object
        }.eraseToAnyPublisher()
    }
    static var cameraFeedSwitchFlashModePublisher: AnyPublisher<AVCaptureDevice.FlashMode, Never>{
        NotificationCenter
        .default
            .publisher(for: .cameraFeedSwitchFlashMode)
            .compactMap { (notification) -> AVCaptureDevice.FlashMode? in
                guard let object = notification.object as? AVCaptureDevice.FlashMode else {return nil}
                return object
        }.eraseToAnyPublisher()
    }
    static var cameraFeedDidRequestCaptureImagePublisher: AnyPublisher<Bool, Never>{
        NotificationCenter
        .default
            .publisher(for: .cameraFeedDidRequestCaptureImage)
            .compactMap { (notification) -> Bool? in
                guard let object = notification.object as? Bool else {return nil}
                return object
        }.eraseToAnyPublisher()
    }
    static var cameraFeedDidCaptureImagePublisher: AnyPublisher<UIImage, Never>{
        NotificationCenter
        .default
            .publisher(for: .cameraFeedDidCaptureImage)
            .compactMap { (notification) -> UIImage? in
                guard let image = notification.object as? UIImage else {return nil}
                return image
        }.eraseToAnyPublisher()
    }
    static var cameraFeedSwitchCameraOutputTypePublishser: AnyPublisher<CameraFeedController.CameraOutputType, Never> {
        NotificationCenter
        .default
            .publisher(for: .cameraFeedSwitchCameraOutputType)
            .compactMap { (notification) -> CameraFeedController.CameraOutputType? in
                guard let outputType = notification.object as? CameraFeedController.CameraOutputType else {return nil}
                return outputType
        }.eraseToAnyPublisher()
    }
    static var cameraFeedDidRequestToggleRecordingVideoPublisher: AnyPublisher<Bool, Never> {
        NotificationCenter
        .default
            .publisher(for: .cameraFeedDidRequestToggleRecordingVideo)
            .compactMap { (notification) -> Bool? in
                guard let value = notification.object as? Bool else {return nil}
                return value
        }.eraseToAnyPublisher()
    }
    static var cameraFeedDidCaptureVideoPublisher: AnyPublisher<URL, Never> {
        NotificationCenter
        .default
            .publisher(for: .cameraFeedDidCaptureVideo)
            .compactMap { (notification) -> URL? in
                guard let videoUrl = notification.object as? URL else {return nil}
                return videoUrl
        }.eraseToAnyPublisher()
    }
    
    // publishers for retrieve post serice
    static var retrievePostServiceDidReceivePostsForGeohashes: AnyPublisher<Array<PostModel>, Never>{
        NotificationCenter
        .default
            .publisher(for: .retrievePostServiceDidReceivePostsForGeohashes)
            .compactMap { (notification) -> Array<PostModel>? in
                guard let models = notification.object as? Array<PostModel> else {
                    return nil
                }
                return models
        }.eraseToAnyPublisher()
    }
    static var retrievePostServiceDidReceiveAllPosts: AnyPublisher<Array<PostModel>, Never>{
        NotificationCenter
        .default
            .publisher(for: .retrievePostServiceDidReceiveAllPosts)
            .compactMap { (notification) -> Array<PostModel>? in
                guard let models = notification.object as? Array<PostModel> else {
                    return nil
                }
                return models
        }.eraseToAnyPublisher()
    }
    
    // publishers for postDisplayNodeModel
    static var postDisplayNodeModelDidRequestMuteAVPLayerPublisher: AnyPublisher<String, Never> {
        NotificationCenter
        .default
            .publisher(for: .postDisplayNodeModelDidRequestMuteAVPlayer)
            .compactMap { (notification) -> String? in
                guard let exceptionId = notification.object as? String else {return nil}
                return exceptionId
        }.eraseToAnyPublisher()
    }
    
}
