//
//  UserProfileService.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Firebase
import Combine
import SDWebImageSwiftUI
import FirebaseStorage

class UserProfileService: ObservableObject {

    @Published var user: User?
    @Published var userProfile: ProfileModel?
    @Published var userProfileImage: UIImage?
    
    @Published var profileImageManager: ImageManager?
    
    private var cancellables: Set<AnyCancellable> = []
    
    var userProfileDocumentListener: ListenerRegistration?
    
    init() {}
    
    func registerServiceForUser(_ user: User) {
        
        // stopping user profile service for current user, if any
        self.stopServiceForCurrentUser()
        
        // setting up the new user
        self.user = user
        self.listenToUserProfile()
    }
    
    func stopServiceForCurrentUser() {
        self.user = nil
        self.userProfile = nil
        self.userProfileImage = nil
        self.profileImageManager = nil
    }
    
    
    func listenToUserProfile() {
        
        self.stopListeningToUserProfile()
        
        guard let user = self.user else {return}
        
        self.userCollectionRef.whereField("userId", isEqualTo: user.uid).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents,
                let firstDocument = documents.first,
                let profile = try? firstDocument.data(as: ProfileModel.self) else {
                    
                    print("Profile does not exists")
                    
                    // notify that the profile for user does not exists
                    self.postNotification(for: .userProfileServiceDidNotFindUserProfile, withObject: self.user!)
                    
                    return
            }
            
            self.userProfile = profile
            self.profileImageManager = ImageManager(url: URL(string: profile.profileImageUrl))
            self.subscribeToImageManager()
            self.profileImageManager?.load()
            
            // notify that user profile changed
            self.postNotification(for: .userProfileServiceDidUpdateUserProfile, withObject: profile)
            
        }
    }
    
    func subscribeToImageManager() {
        
        // call self objectWillChange whenever profileImageManager publishes -- sink: subscribes to publishers with closures
        self.profileImageManager?.objectWillChange.sink(receiveValue: { (_) in
            print("this worked")
            self.objectWillChange.send()
        }).store(in: &cancellables)
        
        // subscribing to profileImageManager's publishers for setting self properties
        self.profileImageManager?.$image.assign(to: \.userProfileImage, on: self).store(in: &cancellables)
    }
    
    func stopListeningToUserProfile() {
        if let listener = self.userProfileDocumentListener {
            listener.remove()
        }
    }
    
    func changeUsername(to username: String) {
        print("username changed to: \(username)")
    }
    
    func changeProfileImage(to profileImage: UIImage) {
        // first assing to profileImage publisher & then make the api call
        print("profileImage changed to: \(profileImage)")
        self.userProfileImage = profileImage
    }
    
    func setupService() {
        // setting up subscribers
        self.subscribeToAuthenticationSeriverPublishers()
        self.subscribeToUserProfileServicePublishers()
    }
    
    func setupUserProfile(withModel model: RequestSetupUserProfileModel) {
        // if user profile already exists then return
        guard self.userProfile == nil else {
            print("User Profile already exists; the request was not valid")
            return
        }
        
        // checking if the request is valid or not
        guard let user = self.user else {
            return
        }
        
        // upload the profile image & then upload profile model in users collection
        self.uploadImage(withImage: model.profileImage, withCallback: {urlString in
            
            // creating profile model
           let profile = ProfileModel(username: model.username, profileImageUrl: urlString, userId: user.uid)
            
            // creating user profile
            do {
                // adding doc to users collection
                _ = try self.userCollectionRef.addDocument(from: profile)
            }catch {
                print("Setup User Profile failed with error: \(error.localizedDescription)")
            }
        })
        
    }
    
    func uploadImage(withImage image: UIImage, withCallback callback: @escaping (String) -> Void){
        guard let user = self.user else {return}
        
        // generating image data from uiImage
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Generating JPEG data for profile image failed with error")
            return
        }
        
        // image upload ref
        let imageUploadRef = self.storageRef.child("profileImages/\(user.uid)-\(UUID().uuidString).jpeg")
        let imageUploadMeta = StorageMetadata()
        imageUploadMeta.contentType = "image/jpeg"
        
        imageUploadRef.putData(imageData, metadata: imageUploadMeta) {(metadata, error) in
            guard let metadata = metadata else {
                print("User profile image upload failed withe error: \(String(describing: error?.localizedDescription))")
                return
            }
            
            imageUploadRef.downloadURL { (url, error) in
                guard let url = url else {
                    print("User profile image upload downloadUrl failed with error: \(String(describing: error?.localizedDescription))")
                    return
                }
                
                // calling the callback passed by the caller
                callback(url.absoluteString)
            }
            
        }
    }
    
    func postNotification(for notificationType: Notification.Name, withObject object: Any){
        NotificationCenter.default.post(name: notificationType, object: object)
    }
    
    private let userCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    private let storageRef = Storage.storage().reference()
}

// for subscribing to publishers
extension UserProfileService {
    func subscribeToAuthenticationSeriverPublishers() {
        Publishers.authenticationServiceDidAuthStatusChangePublisher.sink { (user) in
            guard let currentUser = self.user else {
                self.registerServiceForUser(user)
                return
            }
            
            guard user.uid != currentUser.uid else {return}
            
            self.registerServiceForUser(user)
            return
        }.store(in: &cancellables)
    }
    
    func subscribeToUserProfileServicePublishers() {
        
        // subscribing to publisher for usernane change
        Publishers.userProfileServiceDidRequestUsernameChangePublisher.sink { (username) in
            self.changeUsername(to: username)
        }.store(in: &cancellables)
        
        // subscribing to pubilsher for profile image change
        Publishers.userProfileServiceDidRequestProfileImageChangePublisher.sink { (profileImage) in
            self.changeProfileImage(to: profileImage)
        }.store(in: &cancellables)
        
        // subscribing to publisher for setting up user profile
        Publishers.userProfileServiceDidRequestSetupUserProfilePublisher.sink { (requestModel) in
            self.setupUserProfile(withModel: requestModel)
        }.store(in: &cancellables)
    }
    
}
