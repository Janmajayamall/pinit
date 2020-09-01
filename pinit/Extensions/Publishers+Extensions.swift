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
    static var uploadPostServiceDidRequestCreatePostPublisher: AnyPublisher<RequestCreatePostModel, Never> {
        NotificationCenter
            .default
            .publisher(for: .uploadPostServiceDidRequestCreatePost)
            .compactMap { (notification) -> RequestCreatePostModel? in
                guard let requestCreatePost = notification.object as? RequestCreatePostModel else {return nil}
                return requestCreatePost
        }
        .eraseToAnyPublisher()
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
    
    // publishers for postDisplayType service
    static var postDisplayTypeServiceDidChangeTypePublisher: AnyPublisher<PostDisplayType, Never>{
        NotificationCenter
            .default
            .publisher(for: .postDisplayTypeServiceDidChangeType)
            .compactMap { (notification) -> PostDisplayType? in
                guard let type = notification.object as? PostDisplayType else {return nil}
                return type
        }.eraseToAnyPublisher()
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
    
    // publishers for camera feed
    static var cameraFeedSwitchInUseCameraPublisher: AnyPublisher<Bool, Never>{
        NotificationCenter
        .default
            .publisher(for: .cameraFeedSwitchInUseCamera)
            .compactMap { (notification) -> Bool? in
                guard let object = notification.object as? Bool else {return nil}
                return object
        }.eraseToAnyPublisher()
    }
    
}
