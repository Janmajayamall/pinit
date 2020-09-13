//
//  UIKitAVPlayerView.swift
//  pinit
//
//  Created by Janmajaya Mall on 13/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI

class UIViewPlayer: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    init(frame: CGRect, videoFilePathUrl: URL) {
        super.init(frame: frame)
        
        // creating a new av player item
        let playerItem = AVPlayerItem(url: videoFilePathUrl)
        // creating av queue player
        let queuePlayer = AVQueuePlayer()
        
        // add av player to player layer
        self.playerLayer.player = queuePlayer
        self.layer.addSublayer(self.playerLayer)
        
        // setting up looper
        self.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        // playing the player
        queuePlayer.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.playerLayer.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct UIKitAVPlayerView: UIViewRepresentable {
    
    let frame: CGRect
    let videoFilePathUrl: URL
   
    func makeUIView(context: Context) -> UIViewPlayer {
        let playerView = UIViewPlayer(frame: self.frame, videoFilePathUrl: self.videoFilePathUrl)
        
        // start playing the video
        return playerView
    }
    
    func updateUIView(_ uiView: UIViewPlayer, context: Context) {
        
    }
}
