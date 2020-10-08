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
import CoreLocation
import FirebaseFirestoreSwift
import FirebaseFirestore

class UserProfileService: ObservableObject {
    
    @Published var user: User?
    @Published var userProfile: ProfileModel?
    
    var currentLocation: CLLocation?
    
    private var cancellables: Set<AnyCancellable> = []
    
    var userProfileDocumentListener: ListenerRegistration?
    
    init() {}
    
    func registerServiceForUser(_ user: User) {
        
        // stopping user profile service for current user, if any
        self.stopServiceForCurrentUser()
        
        // setting up the new user
        self.user = user
        self.listenToUserProfile()
        
        // update last active for the user
       self.updateUserActiveData()
    }
    
    func stopServiceForCurrentUser() {
        self.user = nil
        self.userProfile = nil
        
        // stop listening to use profile
        self.stopListeningToUserProfile()
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
        var profile = ProfileModel(username: model.username, email: user.email ?? "")
        
        // upadting user's current geolocation
        if let currentLocation = self.currentLocation {
            let geopoint = GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            profile.createdAtLocation = geopoint
        }
        
        // creating user profile
        do {
            // adding doc to users collection
            _ = try self.userCollectionRef.document(user.uid).setData(from: profile)
        }catch {
            print("Setup User Profile failed with error: \(error.localizedDescription)")
        }
    }
    
    func setupUserActiveData() {
        guard let user = self.user else {return}
        
        // creating user active data model
        var activeDataModel = UserActiveDataModel(lastActive: Timestamp())
        
        // updating last location
        if let currentLocation = self.currentLocation {
            let geopoint = GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            activeDataModel.lastLocation = geopoint
        }
        
        // setup user active data
        do {
            _ = try self.userActiveDataCollectionRef.document(user.uid).setData(from: activeDataModel)
        }catch{
            print("Setup User Active Data failed with error: \(error.localizedDescription)")
        }
    }
    
    func updateUserActiveData() {
        guard let user = self.user else {return}
        
        let docRef = self.userActiveDataCollectionRef.document(user.uid)
        
        if let currentLocation = self.currentLocation {
            // updating lastActive and locatLocation
            docRef.updateData([
                "lastActive": Timestamp(),
                "lastLocation": GeoPoint(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            ])
        }else {
            // updating lastActive
            docRef.updateData([
                "lastActive": Timestamp()
            ])
        }
    }
    
    func updateLastUploadInUserActiveData() {
        guard let user = self.user else {return}
        
        let docRef = self.userActiveDataCollectionRef.document(user.uid)
        
        // updating lastActive
        docRef.updateData([
            "lastUpload": Timestamp()
        ])
        
        // update lastActive as well
        self.updateUserActiveData()
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
        self.subscribeToEstimatedUserLocationService()
        self.subscribeToUploadPostService()
    }

    func postNotification(for notificationType: Notification.Name, withObject object: Any){
        NotificationCenter.default.post(name: notificationType, object: object)
    }
    
    private let userCollectionRef: CollectionReference = Firestore.firestore().collection("users")
    private let userActiveDataCollectionRef: CollectionReference = Firestore.firestore().collection("userActiveData")
    private let storageRef = Storage.storage().reference()
    
    static func checkUsernameExists(for username: String, withCallback callback: @escaping (Bool) -> Void) {
        let userCollectionRef: CollectionReference = Firestore.firestore().collection("users")
        
        userCollectionRef.whereField("username", isEqualTo: username).getDocuments() {(querySnapshots, error) in
            if let error = error {
                print("Username already exists validation failed with error \(error)")
                return
            }
            
            let documents = querySnapshots!.documents            
            callback(documents.count > 0)
        }
    }
}

// for subscribing to publishers
extension UserProfileService {
    func subscribeToAuthenticationSeriverPublishers() {
        Publishers.authenticationServiceDidAuthStatusChangePublisher.sink { (newUser) in
            guard let newUser = newUser else {
                // log out the current user
                self.stopServiceForCurrentUser()
                return
            }
            
            self.registerServiceForUser(newUser)
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
            self.setupUserActiveData()
        }.store(in: &cancellables)
    }
    
    func subscribeToEstimatedUserLocationService() {
        Publishers.estimatedUserLocationServiceDidUpdateLocation.sink { (location) in
            self.currentLocation = location
        }.store(in: &cancellables)
    }
    
    func subscribeToUploadPostService() {
        Publishers.uploadPostServiceDidUploadPostPublisher.sink { (model) in
            self.updateLastUploadInUserActiveData()
        }.store(in: &cancellables)
    }
}
