//
//  UploadPostService.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Combine
import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreLocation

class UploadPostService {
    
    var userProfile: ProfileModel?
    var currentLocationGeohashModel: GeohashModel?
    var currentLocation: CLLocation?
    
    private var postCollectionRef: CollectionReference = Firestore.firestore().collection("posts")
    private var storageRef = Storage.storage().reference()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        
        // setting up max retry time for storage ref
        self.storageRef.storage.maxUploadRetryTime = 15
        self.storageRef.storage.maxDownloadRetryTime = 15
        
        self.setupService()
    }
    
    func uploadPostWithImage(withRequestModel requestModel: RequestCreatePostWithImageModel) {
        
        guard let userProfile = self.userProfile else {
            return
        }
        guard let currentLocationGeohashModel = self.currentLocationGeohashModel, let currentLocation = self.currentLocation else {return}
        
        // creating post model
        var postModel = PostModel(
            description: requestModel.description,
            isActive: true,
            geolocation: GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude),
            geohash: currentLocationGeohashModel.currentLocationGeohash,
            altitude: currentLocation.altitude,
            isPublic: requestModel.isPublic,
            horizontalAccuracy: currentLocation.horizontalAccuracy,
            verticalAccuracy: currentLocation.verticalAccuracy,
            userId: userProfile.id!,
            username: userProfile.username)
        
        // post notification for new post --> Latency compensation
        NotificationCenter.default.post(name: .uploadPostServiceDidUploadPost, object: OptimisticUIPostModel(postModel: postModel, image: requestModel.image, postContentType: .image))
        
        // notify loader for adding task
        NotificationCenter.default.post(name: .generalFunctionManipulateTaskForUploadIndicator, object: 1)
        
        // generating image data from uiImage
        guard let postImageData = requestModel.image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        // creating image upload ref
        let postImageUploadRef = self.storageRef.child("images/\(userProfile.id!)-\(UUID().uuidString).jpeg")
        let postImageUploadMeta = StorageMetadata()
        postImageUploadMeta.contentType = "image/jpeg"
        
        // upload image data
        postImageUploadRef.putData(postImageData, metadata: postImageUploadMeta) {(metadata, error) in
            
            guard let metadata = metadata else {
                
                // handle upload task failed
                self.handleFinishUploadTaskNotification(forContent: .image, didSucceed: false)
                return
                
            }
            
            // get download url
            postImageUploadRef.downloadURL { (url, error) in
                
                guard let url = url else {
                    
                    // handle upload task failed
                    self.handleFinishUploadTaskNotification(forContent: .image, didSucceed: false)
                    return
                    
                }
                
                // updating the content for uploading post
                postModel.updatePostContent(withContentUrl: url.absoluteString, withName: metadata.name ?? "", contentType: .image)
                
                // creating new post
                do {
                    
                    _ = try self.postCollectionRef.document(postModel.id!).setData(from: postModel)
                    
                    // handle upload task success
                    self.handleFinishUploadTaskNotification(forContent: .image, didSucceed: true)
                    
                }catch{
                    
                    // handle upload task failed
                    self.handleFinishUploadTaskNotification(forContent: .image, didSucceed: false)
                    
                }
            }
        }
    }
    
    func uploadPostWithVideo(withRequestModel requestModel: RequestCreatePostWithVideoModel) {
        guard let userProfile = self.userProfile else {
            return
        }
        guard let currentLocationGeohashModel = self.currentLocationGeohashModel, let currentLocation = self.currentLocation else {return}
        
        // creating post model
        var postModel = PostModel(
            description: requestModel.description,
            isActive: true,
            geolocation: GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude),
            geohash: currentLocationGeohashModel.currentLocationGeohash,
            altitude: currentLocation.altitude,
            isPublic: requestModel.isPublic,
            horizontalAccuracy: currentLocation.horizontalAccuracy,
            verticalAccuracy: currentLocation.verticalAccuracy,
            userId: userProfile.id!,
            username: userProfile.username
            )
        
        // Notify that a post will be created --> For latency compensation
        NotificationCenter.default.post(name: .uploadPostServiceDidUploadPost, object: OptimisticUIPostModel(postModel: postModel, videoFilePathUrl: requestModel.videoFilePathUrl, postContentType: .video))
        
        // notify loader for adding task
        NotificationCenter.default.post(name: .generalFunctionManipulateTaskForUploadIndicator, object: 1)
        
        // UPLOADING THE POST
        // creating holder ref for video file
        let postVideoUplaodRef = self.storageRef.child(("videos/\(userProfile.id!)-\(UUID().uuidString).mp4"))
        let postVideoMetadata = StorageMetadata()
        postVideoMetadata.contentType = "video/mp4"
        
        // uploding the video file
        postVideoUplaodRef.putFile(from: requestModel.videoFilePathUrl, metadata: postVideoMetadata) {(metadata, error) in
            
            guard let metadata = metadata else {
                
                // handle upload task failed
                self.handleFinishUploadTaskNotification(forContent: .video, didSucceed: false)
                return
                
            }
            
            // get download url
            postVideoUplaodRef.downloadURL { (url, error) in
                
                guard let url = url else {
                    
                    // handle upload task failed
                    self.handleFinishUploadTaskNotification(forContent: .video, didSucceed: false)
                    return
                    
                }
                
                // updating post model with content for uploding it
                postModel.updatePostContent(withContentUrl: url.absoluteString, withName: metadata.name ?? "", contentType: .video)
                
                // creating new post
                do {
                    
                    _ = try self.postCollectionRef.document(postModel.id!).setData(from: postModel)
                    
                    // handle upload task success
                    self.handleFinishUploadTaskNotification(forContent: .video, didSucceed: true)
                    
                }catch{
                    
                    // handle upload task failed
                    self.handleFinishUploadTaskNotification(forContent: .video, didSucceed: false)
                    
                }
            }
        }
    }
    
    func handleFinishUploadTaskNotification(forContent contentType: PostContentType,didSucceed
        success: Bool){
        
        // notification for deducting upload task indicator
        NotificationCenter.default.post(name: .generalFunctionManipulateTaskForUploadIndicator, object: -1)
        
        if (success == true){
            // analytics
            AnalyticsService.logUserDidPost(withContentType: contentType)
        }else {
            // post notification about the error
            NotificationCenter.default.post(name: .generalFunctionDidFailInternetConnection, object: true)
        }
    }
    
    func setupService() {
        // setting up the subscribers
        self.subscribeToUploadPostServicePublishers()
        self.subscribeToUserProfileServicePublishers()
        self.subscribeToGeohashingServicePublisehers()
        self.subscribeToEstimateduserLocationService()
    }
    
    func resetCurrentUserProfile() {
        self.userProfile = nil
    }
    
}

// for subscribing to publishers of different services
extension UploadPostService {
    
    func subscribeToUploadPostServicePublishers() {
        Publishers.uploadPostServiceDidRequestCreatePostWithImagePublisher.sink { (requestCreatePost) in
            self.uploadPostWithImage(withRequestModel: requestCreatePost)
        }.store(in: &cancellables)
        
        Publishers.uploadPostServiceDidRequestCreatePostWithVideoPublisher.sink { (requestCreatePost) in
            self.uploadPostWithVideo(withRequestModel: requestCreatePost)
        }.store(in: &cancellables)
    }
    
    
    func subscribeToUserProfileServicePublishers() {
        Publishers.userProfileServiceDidUpdateUserProfilePublisher.sink { (userProfile) in
            self.userProfile = userProfile
        }.store(in: &cancellables)
    }
    
    
    func subscribeToGeohashingServicePublisehers() {
        Publishers.geohasingServiceDidUpdateGeohashPublisher.sink { (model) in
            self.currentLocationGeohashModel = model
        }.store(in: &cancellables)
    }
    
    func subscribeToEstimateduserLocationService() {
        Publishers.estimatedUserLocationServiceDidUpdateLocation.sink { (location) in
            self.currentLocation = location
        }.store(in: &cancellables)
    }
    
    
}
