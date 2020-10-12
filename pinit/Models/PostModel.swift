//
//  PostModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct PostModel: Codable {
    
    var imageName: String?
    var imageUrl: String?
    var videoName: String?
    var videoUrl: String?
    var description: String
    var timestamp: Timestamp = Timestamp()
    var isActive: Bool
    var geolocation: GeoPoint
    var geohash: String
    var altitude: Double
    var isPublic: Bool
    var horizontalAccuracy: Double
    var verticalAccuracy: Double
    
    var userId: String
    var username: String
    
    @DocumentID var id: String? = UUID().uuidString
    
    // function to update content
    mutating func updatePostContent(withContentUrl url: String, withName name: String, contentType type: PostContentType) {
        switch type {
        case .video:
            self.videoUrl = url
            self.videoName = name
        case .image:
            self.imageUrl = url
            self.imageName = name
        }
    }
}
