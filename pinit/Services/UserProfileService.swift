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
    }
    
    func listenToUserProfile() {
        
        self.stopListeningToUserProfile()
        
        guard let user = self.user else {return}
        
        self.userCollectionRef.document(user.uid).addSnapshotListener { (documentSnapshot, error) in
            
            guard let document = documentSnapshot else {
                print("User doc listen failed with error: \(error!)")
                return
            }
            
            guard let profile = try? document.data(as: ProfileModel.self) else {
                print("User Profile does not exists")
                
                // posting notification that user profile does not exits
                self.postNotification(for: .userProfileServiceDidNotFindUserProfile, withObject: user)
                return
            }
            
            self.userProfile = profile
                        
            // notify that user profile changed
            self.postNotification(for: .userProfileServiceDidUpdateUserProfile, withObject: profile)
        }
    }

    func stopListeningToUserProfile() {
        if let listener = self.userProfileDocumentListener {
            listener.remove()
        }
    }
    
        
    func setupUserProfile(withModel model: RequestSetupUserProfileModel) {
        guard let user = self.user, self.userProfile == nil else {return}
        
        // creating profile model
        let profile = ProfileModel(username: model.username)
        
        // creating user profile
        do {
            // adding doc to users collection
            _ = try self.userCollectionRef.document(user.uid).setData(from: profile)
        }catch {
            print("Setup User Profile failed with error: \(error.localizedDescription)")
        }
        
    }
    
    /// updates the username of the user in database
    ///
    /// Updates the username in db.
    /// Note: No need to handle `latency compensation` because firestore
    /// handles it for you. Any local changes updates snapshots listeners
    /// before data is sent over network to database
    /// - Parameters:
    ///     - username: new username
    func changeUsername(to username: String) {
        guard let userProfile = self.userProfile, let userId = userProfile.id else {return}
        
        // getting reference to user's document in collection
        let userDocRef = self.userCollectionRef.document(userId)
        // updating username in document
        userDocRef.updateData([
            "username": username
        ]){ error in
            if let error = error {
                print("Username update failed with error: \(error)")
            }
        }
    }
    
    func setupService() {
        // setting up subscribers
        self.subscribeToAuthenticationSeriverPublishers()
        self.subscribeToUserProfileServicePublishers()
    }

    func postNotification(for notificationType: Notification.Name, withObject object: Any){
        NotificationCenter.default.post(name: notificationType, object: object)
    }
    
    private let userCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    private let storageRef = Storage.storage().reference()
    
    static func checkUsernameExists(for username: String, withCallback callback: @escaping (Bool) -> Void) {
        let userCollectionRef: CollectionReference = Firestore.firestore().collection("users")
        
        userCollectionRef.whereField("username", isEqualTo: username).getDocuments() {(querySnapshots, error) in
            if let error = error {
                print("Username already exists validation failed with error \(error)")
                return
            }
            
            let documents = querySnapshots!.documents
            print("--Username document \(documents)")
            callback(documents.count > 0)
        }
    }
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
        
        Publishers.userProfileServiceDidRequestSetupUserProfilePublisher.sink { (requestModel) in
            self.setupUserProfile(withModel: requestModel)
        }.store(in: &cancellables)
        
    }        
}
//
//
//func uploadImage(withImage image: UIImage, withCallback callback: @escaping (String) -> Void){
//    guard let user = self.user else {return}
//
//    // generating image data from uiImage
//    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//        print("Generating JPEG data for profile image failed with error")
//        return
//    }
//
//    // image upload ref
//    let imageUploadRef = self.storageRef.child("profileImages/\(user.uid)-\(UUID().uuidString).jpeg")
//    let imageUploadMeta = StorageMetadata()
//    imageUploadMeta.contentType = "image/jpeg"
//
//    imageUploadRef.putData(imageData, metadata: imageUploadMeta) {(metadata, error) in
//        guard error == nil else {
//            print("User profile image upload failed withe error: \(String(describing: error?.localizedDescription))")
//            return
//        }
//
//        imageUploadRef.downloadURL { (url, error) in
//            guard let url = url else {
//                print("User profile image upload downloadUrl failed with error: \(String(describing: error?.localizedDescription))")
//                return
//            }
//
//            // calling the callback passed by the caller
//            callback(url.absoluteString)
//        }
//
//    }
//}
//
