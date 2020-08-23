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
                    return
            }
            
            self.userProfile = profile
            self.profileImageManager = ImageManager(url: URL(string: profile.profileImageUrl))
            self.subscribeToImageManager()
            self.profileImageManager?.load()
            
        }
    }
    
    func subscribeToImageManager() {
        
        // call self objectWillChange whenever profileImageManager publishes -- sink: subscribes to publishers with closures
        if let imageManagerCancellable = self.profileImageManager?.objectWillChange.sink(receiveValue: { (_) in
            print("this worked")
            self.objectWillChange.send()
        }){
            self.cancellables.insert(imageManagerCancellable)
        }
        
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
    
    private let userCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    
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
    }
}
