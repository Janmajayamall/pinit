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

class RetrievePostService: ObservableObject {
    
    private var documentsListener: ListenerRegistration?
    private var postCollectionRef: CollectionReference = Firestore.firestore().collection("posts")
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var retrievedPosts: Array<PostModel> = []
    
    init() {}
    
    func listenToPostsForGeohashes(_ geohashes: Array<String>){
        self.stopListeningToPosts()
        print("geohashes, \(geohashes)")
        
        self.documentsListener = self.postCollectionRef.whereField("geohash", in: geohashes).addSnapshotListener({ (querySnapshot, error) in
            self.handleReceivedPostDocuments(withQuerySnapshot: querySnapshot, withError: error)
        })
        
    }
    
    func handleReceivedPostDocuments(withQuerySnapshot querySnapshot: QuerySnapshot?, withError error: Error?){
        guard let documents = querySnapshot?.documents else {return}

        var posts: Array<PostModel> = []

        documents.forEach { (queryDocumentSnapshot) in
            guard let post = try? queryDocumentSnapshot.data(as: PostModel.self) else {
                print("something went wrong")
                return
            }
            posts.append(post)
        }
        print("final posts: \(posts)")
        self.retrievedPosts = posts
    }
    
    func stopListeningToPosts(){
        if let documentsListener = self.documentsListener {
            documentsListener.remove()
        }
    }
    
    func setupService(){
        // setting up subscribers
        self.subscribeToGeohasingServicePublishers()
    }
}

// for subscribers
extension RetrievePostService {
    func subscribeToGeohasingServicePublishers(){
        Publishers.geohasingServiceDidUpdateGeohashPublisher.sink { (geohashModel) in
            self.listenToPostsForGeohashes(geohashModel.currentAreaGeohashes)
        }.store(in: &cancellables)
    }
}
