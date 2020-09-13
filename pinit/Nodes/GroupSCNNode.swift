//
//  GroupSCNNode.swift
//  pinit
//
//  Created by Janmajaya Mall on 10/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import Combine
import AVFoundation


class GroupSCNNode: SCNNode, Identifiable {
    
    var nodeDirection: NodeDirection
    
    var postList: Array<PostDisplayNodeModel> = []
    
//    var imageList: Array<UIImage>  = [UIImage(named: "image1")!, UIImage(named: "image2")!, UIImage(named: "image3")!, UIImage(named: "image4")!, UIImage(named: "image5")!]
    
    var currentPostIndex: Int = -1
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(scenePosition: SCNVector3?, direction: NodeDirection){
        self.nodeDirection = direction
        
        super.init()
        
        // subscribe to publishers
        self.subscribeToGroupSCNNodePublishers()
        
        // add constraints to the node
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        self.constraints = [billboardConstraint]
        
        self.placeNode(scenePosition: scenePosition)
        self.loadInitialPostDisplay()
        
        self.addAVPlayerAsGeometry()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getScaledDim(forImage image: UIImage) -> CGSize{
        let imageOriginalDims = image.size
        
        let width = self.fixedImageWidth
        let height = (imageOriginalDims.height * width)/imageOriginalDims.width
        
        return CGSize(width: width, height: height)
    }
    
    func addImageAsGeometry(image: UIImage){
        // getting scaled dims for the original image
        let scaledDims = self.getScaledDim(forImage: image)
        
        // create plane for adding as geometry to the node
        let plane = SCNPlane(width: scaledDims.width, height: scaledDims.height)
        plane.cornerRadius = 0.1 * scaledDims.width
        
        // texturing the plane with the image
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        
        // adding to the node's geometry
        self.geometry = plane
    }
    
    private var avPlayerContext = 0
    private var avPlayer: AVPlayer?
    
    func addAVPlayerAsGeometry() {
        guard let url = URL(string: "https://china-hatao.s3.ap-south-1.amazonaws.com/thisisit.mp4") else {return}
        
        self.avPlayer = AVPlayer(url: url)
        self.avPlayer?.externalPlaybackVideoGravity = .resize
        self.avPlayer!.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.old, .new], context: &avPlayerContext)
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
                guard let avPlayer = self.avPlayer else {return}
                // adding the audio visual file as content of plane and then adding plane to node's geometry
                let trialImage = UIImage(imageLiteralResourceName: "image1")
                let scaledDims = self.getScaledDim(forImage: trialImage)
                
                let plane = SCNPlane(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                plane.firstMaterial?.diffuse.contents = avPlayer
                 
                avPlayer.play()
                print("!!! started playing the video")
                self.geometry = plane
            case .failed:
                print("!!! failed to load media")
            default:
                print("!!! unknown")
            }
        }
    }
    
    func changePostDisplay(){
         
        guard self.postList.count > 0 && self.currentPostIndex >= 0 else {return}
        
        let refIndex = self.currentPostIndex
        repeat{
            // changing the index
            self.currentPostIndex = (self.currentPostIndex + 1) % self.postList.count
            
            // if current index == refIndex then break
            if (self.currentPostIndex == refIndex){
                break
            }
        }while self.postList[self.currentPostIndex].isReadyToDisplay == false
        
        
        
        // adding image at current index to as geometry for node
        self.addImageAsGeometry(image: self.postList[self.currentPostIndex].postImage!)
    }
    
    func scaleNodePlane(withValue scale: CGFloat){
        guard scale > 0 else {return}
        
        if (scale > 1){
            self.fixedImageWidth += 0.05
        }else {
            self.fixedImageWidth -= 0.05
        }
        
        self.addImageAsGeometry(image: self.postList[self.currentPostIndex].postImage!)
    }
    
    func displayPostInfo(){
        let post = self.postList[self.currentPostIndex].post
        
        // creating post display info model
        let postDisplayInfo = PostDisplayInfoModel(username: post.username, description: post.description)
        
        // post notification
        NotificationCenter.default.post(name: .groupSCNNodeDidRequestCurrentPostDisplayInfo, object: postDisplayInfo)
        
    }
    
    func placeNode(scenePosition: SCNVector3?){
        guard let scenePosition = scenePosition else {return}
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        
        switch self.nodeDirection {
        case .front:
            self.position = SCNVector3(
                scenePosition.x + Float(0),
                scenePosition.y + self.defaultYCoordDis,
                scenePosition.z + -self.defaultCoordDis - 1)
        case .frontRight:
            self.position = SCNVector3(
                scenePosition.x + (self.defaultCoordDis),
                scenePosition.y + self.defaultYCoordDis,
                scenePosition.z + -self.defaultCoordDis)
        case .frontLeft:
            self.position = SCNVector3(
                scenePosition.x + (-self.defaultCoordDis),
                scenePosition.y + self.defaultYCoordDis,
                scenePosition.z + -self.defaultCoordDis)
        }
        
        SCNTransaction.commit()
    }
    
    func addPost(_ post: PostModel) {
        // creating new post display node model
        let model = PostDisplayNodeModel(post: post)
        
        // adding it to list
        self.postList.append(model)
    }
    
    func loadInitialPostDisplay() {
        print("here I go, \(self.postList.count)")
        guard self.currentPostIndex == -1 && self.postList.count > 0 && self.postList[0].isReadyToDisplay == true else {return}
        
        self.addImageAsGeometry(image: self.postList[0].postImage!)
        self.currentPostIndex += 1
        
    }
    
    
    private var defaultCoordDis: Float = 1.5
    private var defaultYCoordDis: Float = -0.8
    private var fixedImageWidth: CGFloat = 1
}

// for subscribing to publishers
extension GroupSCNNode {
    func subscribeToGroupSCNNodePublishers() {
        Publishers.groupSCNNodeDidLoadPostDisplayData.sink { (value) in
            guard value == true else {return}
            print("it did load")
            self.loadInitialPostDisplay()
        }.store(in: &cancellables)
    }
}

enum NodeDirection {
    case front
    case frontRight
    case frontLeft
}
