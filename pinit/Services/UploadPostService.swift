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
    var currentRequestCreatePost: RequestCreatePostModel?
    
    private var postCollectionRef: CollectionReference = Firestore.firestore().collection("posts")
    private var storageRef = Storage.storage().reference()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {}
        
    func uploadPost(withRequestModel requestCreatePost: RequestCreatePostModel){
        
        guard self.userProfile != nil && self.currentLocationGeohash != nil && self.currentLocation != nil && self.currentRequestCreatePost == nil else {return}
        self.currentRequestCreatePost = requestCreatePost
        
        // initiating upload image
        self.uploadPostImage()
    }
    
    func uploadPostImage() {
        
        guard let userProfile = self.userProfile else {
            self.resetCurrentRequestCreatePost()
            return
        }
        guard let image = self.currentRequestCreatePost?.image else {
            self.resetCurrentRequestCreatePost()
            return
        }
        
        // generating image data from uiImage
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Unable to convert uImage to Image Data")
            self.resetCurrentRequestCreatePost()
            return
        }
        // creating image upload ref
        let imageUploadRef = self.storageRef.child("images/\(userProfile.userId)-\(UUID().uuidString).jpeg")
        let imageUploadMeta = StorageMetadata()
        imageUploadMeta.contentType = "image/jpeg"
        
        imageUploadRef.putData(imageData, metadata: imageUploadMeta) {(metadata, error) in
            guard let metadata = metadata else {
                print("Image upload failed with error: \(String(describing: error?.localizedDescription))")
                self.resetCurrentRequestCreatePost()
                return
            }
            
            imageUploadRef.downloadURL { (url, error) in
                guard let url = url else {
                    print("Image upload downloadUrl failed with error: \(String(describing: error?.localizedDescription))")
                    self.resetCurrentRequestCreatePost()
                    return
                }
                
                self.uploadPostModel(withImageMetaData: metadata, withImageDownloadUrl: url)
            }
        }
    }
    
    func uploadPostModel(withImageMetaData imageMetadata: StorageMetadata, withImageDownloadUrl imageDownloadUrl: URL) {
        
        guard let userProfile = self.userProfile else {
            self.resetCurrentRequestCreatePost()
            return
        }
        guard let currentLocation = self.currentLocation else {
            self.resetCurrentRequestCreatePost()
            return
        }
        guard let currentLocationGeohash = self.currentLocationGeohash else {
            self.resetCurrentRequestCreatePost()
            return
        }
        guard let currentRequestCreatePost = self.currentRequestCreatePost else {
            self.resetCurrentRequestCreatePost()
            return
        }
                        
        // creating Post Model
        let postModel = PostModel(
            imageName: imageMetadata.name ?? "",
            imageUrl: imageDownloadUrl.absoluteString,
            description: currentRequestCreatePost.description,
            isActive: true,
            geolocation: GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude),
            geohash: currentLocationGeohash,
            altitude: currentLocation.altitude,
            isPublic: currentRequestCreatePost.isPublic,
            userId: userProfile.userId,
            username: userProfile.username,
            userProfilePicture: userProfile.profileImageUrl)
                    
        do {
            _ = try self.postCollectionRef.addDocument(from: postModel)
        }catch {
            print("Post model upload failed with error: \(error.localizedDescription)")
        }
        
        self.resetCurrentRequestCreatePost()
    }
    
    func resetCurrentRequestCreatePost() {
        self.currentRequestCreatePost = nil
    }
    
    func setupService() {
        // setting up the subscribers
        self.subscribeToLocationServicePublishers()
        self.subscribeToUploadPostServicePublishers()
        self.subscribeToUserProfileServicePublishers()
    }
    
}

// for subscribing to publishers of different services
extension UploadPostService {
    
    func subscribeToUploadPostServicePublishers() {
        Publishers.uploadPostServiceDidRequestCreatePostPublisher.sink { (requestCreatePost) in
            self.uploadPost(withRequestModel: requestCreatePost)
        }.store(in: &cancellables)
    }
    
    func subscribeToLocationServicePublishers() {
        Publishers.locationServiceDidUpdateLocationPublisher.sink { (location) in
            self.currentLocation = location
            self.currentLocationGeohash = GeohashingService.getGeohash(forCoordinates: location.coordinate)
        }.store(in: &cancellables)
    }
    
    func subscribeToUserProfileServicePublishers() {
        Publishers.userProfileServiceDidUpdateUserProfilePublisher.sink { (userProfile) in
            self.userProfile = userProfile
        }.store(in: &cancellables)
    }
}
