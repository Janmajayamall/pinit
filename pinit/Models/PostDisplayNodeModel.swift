//
//  PostDisplayNodeModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 12/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Combine

class PostDisplayNodeModel {
    var post: PostModel
    var postImage: UIImage?
    var imageManager: ImageManager
    var isReadyToDisplay: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(post: PostModel) {
        self.post = post
        self.imageManager = ImageManager(url: URL(string: self.post.imageUrl))
        
        // subscribing to image load
        self.imageManager.$image.sink { (image) in
            guard let image = image else {return}
            self.setPostImage(to: image)
        }.store(in: &cancellables)
        
        // loading the image
        self.imageManager.load()
        
    }
    
    func setPostImage(to image: UIImage){
        guard self.isReadyToDisplay == false else {return}
        
        self.postImage = image
        self.isReadyToDisplay = true
        
        // generating a notification
        NotificationCenter.default.post(name: .groupSCNNodeDidLoadPostDisplayData, object: true)
    }
}
