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
    
    init() {
    }
    
    func registerServiceForUser(_ user: User){
        
        // stopping user profile service for current user, if any
        self.stopServiceForCurrentUser()
        
        // setting up the new user
        self.user = user
        self.listenToUserProfile()
    }
    
    func stopServiceForCurrentUser(){
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
    
    func subscribeToImageManager(){
        
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
    
    func stopListeningToUserProfile(){
        if let listener = self.userProfileDocumentListener {
            listener.remove()
        }
    }
    
    func changeUsername(){
        
    }
    
    func changeProfileImage(){
        // first assing to profileImage publisher & then make the api call
    }
    
    /// Subscribes using closure to the publisher of  didAuthStatusChange notification
    func didAuthStatusChangeSubscribe(){
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
    
    private let userCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    
    
}
