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
    
    var avPlayer: AVPlayer?
    var avPlayerContext = 0
    
    var isReadyToDisplay: Bool = false
    var postContentType: PostContentType?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(post: PostModel) {
        self.post = post
        
        super.init()
        self.subscribeToPostDisplayNodeModelPublishers()
        
        // setup post data content
        self.setupPostContent()
    }
    
    init(optimisticPostModel: OptimisticUIPostModel){
        self.post = optimisticPostModel.postModel
        
        super.init()
        self.subscribeToPostDisplayNodeModelPublishers()
        
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
        self.avPlayer = AVPlayer(url: videoFilePathUrl)
        self.avPlayerSetupLoopForVideo()
        
        // by default volume will be mute
        self.avPlayer?.isMuted = true
        
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
            
        }else if let videoUrlString = self.post.videoUrl, let videoUrl = URL(string: videoUrlString)  {
            self.avPlayer = AVPlayer(url: videoUrl)
            
            // by default volume will be muted
            self.avPlayer?.isMuted = true
            
            self.avPlayerSetupLoopForVideo()
        }
    }
    
    func avPlayerSetupLoopForVideo(){
        guard let avPlayer = self.avPlayer else {return}
        avPlayer.addObserver(self, forKeyPath: #keyPath(AVQueuePlayer.status), options: [.old, .new], context: &avPlayerContext)
        
        // setting up loop for video by adding notification for end time
        avPlayer.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }
    
    @objc func avPlayerItemDidReachEnd(notification: Notification){
        self.avPlayer?.seek(to: CMTime.zero)
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

// for subscribing to publishers
extension PostDisplayNodeModel {
    func subscribeToPostDisplayNodeModelPublishers() {
        Publishers.postDisplayNodeModelDidRequestMuteAVPLayerPublisher.sink { (exceptionId) in
            guard let avPlayer = self.avPlayer, let id = self.post.id else {return}
            
            if let exceptionId = exceptionId, exceptionId == id {
                return
            }else {
                avPlayer.isMuted = true
            }                   
        }.store(in: &cancellables)
    }
}

enum PostContentType: String {
    case video
    case image
}
