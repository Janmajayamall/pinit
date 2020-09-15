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
    var currentLocation: CLLocation?
    var currentLocationGeohash: String?
    
    private var postCollectionRef: CollectionReference = Firestore.firestore().collection("posts")
    private var storageRef = Storage.storage().reference()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {}
    
    func uploadPostWithImage(withRequestModel requestModel: RequestCreatePostWithImageModel) {
        
        guard let userProfile = self.userProfile else {
            return
        }
        guard let currentLocation = self.currentLocation else {
            return
        }
        guard let currentLocationGeohash = self.currentLocationGeohash else {
            return
        }
        
        // generating image data from uiImage
        guard let postImageData = requestModel.image.jpegData(compressionQuality: 0.8) else {
            print("Unable to convert uImage to Image Data")
            return
        }
        // creating image upload ref
        let postImageUploadRef = self.storageRef.child("images/\(userProfile.id!)-\(UUID().uuidString).jpeg")
        let postImageUploadMeta = StorageMetadata()
        postImageUploadMeta.contentType = "image/jpeg"
        
        postImageUploadRef.putData(postImageData, metadata: postImageUploadMeta) {(metadata, error) in
            guard let metadata = metadata else {
                print("Image upload failed with error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            postImageUploadRef.downloadURL { (url, error) in
                guard let url = url else {
                    print("Image upload downloadUrl failed with error: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                // creating post model
                let postModel = PostModel(
                    imageName: metadata.name,
                    imageUrl: url.absoluteString,
                    description: requestModel.description,
                    isActive: true,
                    geolocation: GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude),
                    geohash: currentLocationGeohash,
                    altitude: currentLocation.altitude,
                    isPublic: requestModel.isPublic,
                    userId: userProfile.id!,
                    username: userProfile.username)
                
                // creating new post
                do {
                    // Notify that a post will be created
                    if let postUIImage = UIImage(data: postImageData) {
                        NotificationCenter.default.post(name: .uploadPostServiceDidUploadPost, object: OptimisticUIPostModel(postModel: postModel, image: postUIImage, postContentType: .image))
                    }
                    
                    _ = try self.postCollectionRef.document(postModel.id!).setData(from: postModel)
                    
                }catch{
                    print("upload post with image failed with error \(error)")
                }
            }
        }
    }
    
    func uploadPostWithVideo(withRequestModel requestModel: RequestCreatePostWithVideoModel) {
        guard let userProfile = self.userProfile else {
            return
        }
        guard let currentLocation = self.currentLocation else {
            return
        }
        guard let currentLocationGeohash = self.currentLocationGeohash else {
            return
        }
        
        // creating holder ref for video file
        let postVideoUplaodRef = self.storageRef.child(("videos/\(userProfile.id!)-\(UUID().uuidString).mp4"))
        let postVideoMetadata = StorageMetadata()
        postVideoMetadata.contentType = "video/mp4"
        
        // uploding the video file
        postVideoUplaodRef.putFile(from: requestModel.videoFilePathUrl, metadata: postVideoMetadata) {(metadata, error) in
            
            guard let metadata = metadata else {
                print("Video upload failed with error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            postVideoUplaodRef.downloadURL { (url, error) in
                guard let url = url else {
                    print("Video upload downloadUrl failed with error: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                // crating post model
                let postModel = PostModel(
                    videoName: metadata.name,
                    videoUrl: url.absoluteString,
                    description: requestModel.description,
                    isActive: true,
                    geolocation: GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude),
                    geohash: currentLocationGeohash,
                    altitude: currentLocation.altitude,
                    isPublic: requestModel.isPublic,
                    userId: userProfile.id!,
                    username: userProfile.username)
                
                // creating new post
                do {
                    // Notify that a post will be created
                    NotificationCenter.default.post(name: .uploadPostServiceDidUploadPost, object: OptimisticUIPostModel(postModel: postModel, videoFilePathUrl: requestModel.videoFilePathUrl, postContentType: .video))
                                        
                    _ = try self.postCollectionRef.document(postModel.id!).setData(from: postModel)
                }catch{
                    print("upload post with image failed with error \(error)")
                }
            }
        }
    }
    
    func setupService() {
        // setting up the subscribers
        self.subscribeToUploadPostServicePublishers()
        self.subscribeToUserProfileServicePublishers()
        self.subscribeToEstimatedUserLocationServicePublishers()
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
    
    func subscribeToEstimatedUserLocationServicePublishers() {
        // uncomment it after dev
        //        Publishers.estimatedUserLocationServiceDidUpdateLocation.sink { (location) in
        //            self.currentLocation = location
        //            self.currentLocationGeohash = GeohashingService.getGeohash(forCoordinates: location.coordinate)
        //        }.store(in: &cancellables)
        
        // for dev purposes
        Publishers.locationServiceDidUpdateLocationPublisher.sink { (location) in
            self.currentLocation = location
            self.currentLocationGeohash = GeohashingService.getGeohash(forCoordinates: location.coordinate)
        }.store(in: &cancellables)
    }
    
    
}
