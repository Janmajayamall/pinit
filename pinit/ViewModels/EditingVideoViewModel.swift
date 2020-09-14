//
//  EditingVideoViewModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 13/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import Firebase
import CoreLocation
import FirebaseFirestore
import Combine

class EditingVideoViewModel: ObservableObject {
    @Published var videoOutputFileUrl: URL
    @Published var descriptionText: String = ""
    
    init(videoOutputFileUrl: URL) {
        self.videoOutputFileUrl = videoOutputFileUrl
    }
    
    func uploadPost() {
        // request model
        let requestCreatePost = RequestCreatePostWithVideoModel(videoFilePathUrl: self.videoOutputFileUrl, description: self.descriptionText, isPublic: true)
        
        NotificationCenter.default.post(name: .uploadPostServiceDidRequestCreatePostWithVideo, object: requestCreatePost)
    }
        
}

