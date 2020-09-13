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
import AVFoundation

class PostDisplayNodeModel: NSObject {
    var post: PostModel
    
    var imageManager: ImageManager?
    var image: UIImage?
    
    var queuePlayer: AVQueuePlayer?
    var playerItem: AVPlayerItem?
    var playerLooper: AVPlayerLooper?
    var avPlayerContext = 0
    
    var isReadyToDisplay: Bool = false
    var postContentType: PostContentType?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(post: PostModel) {
        self.post = post
        
        super.init()
        
        // setup post data content
        self.setupPostContent()
    }
    
    init(optimisticPostModel: OptimisticUIPostModel){
        self.post = optimisticPostModel.postModel
        
        super.init()
        
        switch optimisticPostModel.postContentType {
        case .video:
            guard let videoUrl = optimisticPostModel.videoFilePathUrl else {return}
            self.optimisticSetupVideoContent(withVideoFilePathUrl: videoUrl)
        case .image:
            guard let image = optimisticPostModel.image else {return}
            self.optimisiticSetupImageContent(withImage: image)
        }
    }
    
    func optimisiticSetupImageContent(withImage image: UIImage) {
        self.image = image
        
        self.isReadyToDisplay = true
        self.postContentType = .image
    }
    
    func optimisticSetupVideoContent(withVideoFilePathUrl videoFilePathUrl: URL){
        self.playerItem = AVPlayerItem(url: videoFilePathUrl)
        self.queuePlayer = AVQueuePlayer()
        self.playerLooper = AVPlayerLooper(player: self.queuePlayer!, templateItem: self.playerItem!)
        
        self.isReadyToDisplay = true
        self.postContentType = .video
    }
    
    func setupPostContent() {
        if let imageUrl = self.post.imageUrl {
            self.imageManager = ImageManager(url: URL(string: imageUrl))
            
            // subcribing to image load
            self.imageManager!.$image.sink { (image) in
                guard let image = image, self.isReadyToDisplay == false else {return}
                
                self.image = image
                self.isReadyToDisplay = true
                self.postContentType = .image
                
                self.notifyDataDidLoad()
            }.store(in: &cancellables)
            
            self.imageManager!.load()
            
        }else if let videoUrl = self.post.videoUrl {
            guard let videoURL = URL(string: videoUrl) else {return}
            
            self.playerItem = AVPlayerItem(url: videoURL)
            self.queuePlayer = AVQueuePlayer()
            self.playerLooper = AVPlayerLooper(player: self.queuePlayer!, templateItem: self.playerItem!)
            
            self.queuePlayer!.addObserver(self, forKeyPath: #keyPath(AVQueuePlayer.status), options: [.old, .new], context: &avPlayerContext)
        }else {
            print("Not a valid post")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &avPlayerContext else {return}
        
        if keyPath == #keyPath(AVPlayer.status){
            let status: AVPlayer.Status
            
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayer.Status(rawValue: statusNumber.intValue)!
            }else {
                status = .unknown
            }
            
            switch status {
            case .readyToPlay:
                self.isReadyToDisplay = true
                self.postContentType = .video
                
                self.notifyDataDidLoad()
            case .failed:
                print("avQueuePlayer status failed to load media")
            default:
                print("avQueuePlayer status unknown")
            }
        }
    }
    
    func notifyDataDidLoad() {
        NotificationCenter.default.post(name: .groupSCNNodeDidLoadPostDisplayData, object: true)
    }
    
}

enum PostContentType {
    case video
    case image
}
