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
        
//        .whereField("geohash", in: geohashes)
        self.documentsForGeohashesListener = self.postCollectionRef.addSnapshotListener({ (querySnapshot, error) in
            self.handleReceivedPostDocuments(withQuerySnapshot: querySnapshot, withError: error, forNotificationName: .retrievePostServiceDidReceivePostsForGeohashes)
        })
    }
    
    func listenToAllPosts(){
        self.stopListeningToAllPosts()
        
        self.allDocumentsListener = self.postCollectionRef.addSnapshotListener({ (querySnapshot, error) in
            self.handleReceivedPostDocuments(withQuerySnapshot: querySnapshot, withError: error, forNotificationName: .retrievePostServiceDidReceiveAllPosts)
        })
    }
    
    func handleReceivedPostDocuments(withQuerySnapshot querySnapshot: QuerySnapshot?, withError error: Error?, forNotificationName notificationName: Notification.Name){
        guard let documents = querySnapshot?.documents else {return}
        
        var posts: Array<PostModel> = []
        
        documents.forEach { (queryDocumentSnapshot) in
            guard let post = try? queryDocumentSnapshot.data(as: PostModel.self) else {
                print("something went wrong")
                return
            }
            posts.append(post)
        }
       
        // notify according to the notification name
//        NotificationCenter.default.post(name: notificationName, object: posts)
        
    }
    
    func stopListeningToAllPosts(){
        if let allDocumentsListener = self.allDocumentsListener {
            allDocumentsListener.remove()
        }
    }
    
    func stopListeningToPostForGeohashes(){
        if let documentsForGeohashesListener = self.documentsForGeohashesListener {
            documentsForGeohashesListener.remove()
        }
    }
    
    func setupService(){
        // setting up subscribers
        self.subscribeToGeohasingServicePublishers()
        
        // start listening to all posts
        self.listenToAllPosts()
    }
    
}

// for subscribers
extension RetrievePostService {
    func subscribeToGeohasingServicePublishers(){
        Publishers.geohasingServiceDidUpdateGeohashPublisher.sink { (geohashModel) in
            self.listenToPostsForGeohashes(geohashModel.currentAreaGeohashes)
        }.store(in: &cancellables)
    }
    
    func subscribeToAuthenticationServicePublishers(){
        Publishers.authenticationServiceDidAuthStatusChangePublisher.sink { (user) in
            self.user = user
        }.store(in: &cancellables)
    }
}
