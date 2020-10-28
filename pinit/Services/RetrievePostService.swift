//
//  RetrievePostService.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Combine
import FirebaseAuth

class RetrievePostService: ObservableObject {
    var user: User?
    
    private var documentsForGeohashesListener: ListenerRegistration?
    private var allDocumentsListener: ListenerRegistration?
    
    private var postCollectionRef: CollectionReference = Firestore.firestore().collection("posts")
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {}
    
    func listenToPostsForGeohashes(_ geohashes: Array<String>){
        self.stopListeningToPostForGeohashes()
        
        
        self.documentsForGeohashesListener = self.postCollectionRef.whereField("geohash", in: geohashes).addSnapshotListener({ (querySnapshot, error) in
            self.handleReceivedPostDocuments(withQuerySnapshot: querySnapshot, withError: error, forNotificationName: .retrievePostServiceDidReceivePostsForGeohashes)
        })
    }
    
    func listenToUserPosts() {
        guard let user = self.user else {return}
        
        self.postCollectionRef.whereField("userId", isEqualTo: user.uid).addSnapshotListener({ (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {return}
            
            var posts: Array<PostModel> = []
            
            documents.forEach { (queryDocumentSnapshot) in
                guard let post = try? queryDocumentSnapshot.data(as: PostModel.self) else {return}
                posts.append(post)
            }
            
            // notify about user posts
            self.postNotification(for: .retrievePostServiceDidReceiveUserPosts, withObject: posts)
        })
    }
    
    func handleReceivedPostDocuments(withQuerySnapshot querySnapshot: QuerySnapshot?, withError error: Error?, forNotificationName notificationName: Notification.Name){
        guard let documents = querySnapshot?.documents else {
            if (notificationName == .retrievePostServiceDidReceivePostsForGeohashes){
                // notify the loader to decrease initial task
                NotificationCenter.default.post(name: .generalFunctionManipulateTaskForLoadIndicator, object: -1)
            }
            return
        }
        
        var posts: Array<PostModel> = []
        
        documents.forEach { (queryDocumentSnapshot) in
            guard let post = try? queryDocumentSnapshot.data(as: PostModel.self) else { 
                return
            }
            posts.append(post)
        }
        
        // notify according to the notification name
        self.postNotification(for: notificationName, withObject: posts)
    }
    
    func postNotification(for notificationName: Notification.Name, withObject object: Any){
        NotificationCenter.default.post(name: notificationName, object: object)
    }
    
    func stopListeningToPostForGeohashes(){
        if let documentsForGeohashesListener = self.documentsForGeohashesListener {
            documentsForGeohashesListener.remove()
        }
    }
    
    func setupService(){
        // setting up subscribers
        self.subscribeToGeohasingServicePublishers()
        self.subscribeToAuthenticationServicePublishers()
                
    }
    
}

// for subscribers
extension RetrievePostService {
    func subscribeToGeohasingServicePublishers(){
        Publishers.geohasingServiceDidUpdateGeohashPublisher.sink { (geohashModel) in
            print("did recv geohash \(geohashModel)")
            self.listenToPostsForGeohashes(geohashModel.currentAreaGeohashes)
        }.store(in: &cancellables)
    }
    
    func subscribeToAuthenticationServicePublishers(){
        Publishers.authenticationServiceDidAuthStatusChangePublisher.sink { (user) in
            self.user = user
            
            // when user is not nil, then listen to its posts
            if (self.user != nil){
                self.listenToUserPosts()
            }else {
                // make the usersPostCount in setting view model as zero
                self.postNotification(for: .retrievePostServiceDidReceiveUserPosts, withObject: [])
            }
                        
        }.store(in: &cancellables)
    }
}
