//
//  OnboardingSCNNode.swift
//  pinit
//
//  Created by Janmajaya Mall on 26/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import Combine

class OnboardingSCNNode: SCNNode, Identifiable, AppSCNNode {
    var nodeDirection: NodeDirection
    var onboardingDisplayModels: Array<OnboardingDisplayModel> = []
    
    var currentIndex: Int = 0
    
    init(scenePosition: SCNVector3?, nodeDirection: NodeDirection, onboardingNodeModels: Array<OnboardingNodeModel>) {
        self.nodeDirection = nodeDirection
        
        super.init()
        
        self.setupDisplayModels(forNodes: onboardingNodeModels)
 
        // add constraints to the node
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        self.constraints = [billboardConstraint]
        
        self.placeNode(scenePostion: scenePosition)
        self.addCurrentIndexAsGeometry()
    }
    
    func setupDisplayModels(forNodes onboardingNodeModels: Array<OnboardingNodeModel>) {
        onboardingNodeModels.forEach { (node) in
            self.onboardingDisplayModels.append(OnboardingDisplayModel(model: node))
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("THIS HAPPENED")
    }
    
    func placeNode(scenePostion: SCNVector3?){
        guard let scenePosition = scenePostion else {return}
        
        switch self.nodeDirection {
        case .front:
            self.position = SCNVector3(
                scenePosition.x + Float(0),
                scenePosition.y + self.defaultYCoordDis,
                scenePosition.z + -self.defaultZCoordDis)
        case .frontRight:
            self.position = SCNVector3(
                scenePosition.x + self.defaultXCoordDis,
                scenePosition.y + self.defaultYCoordDis,
                scenePosition.z + -self.defaultZCoordDis + 0.5)
        case .frontLeft:
            self.position = SCNVector3(
                scenePosition.x + -self.defaultXCoordDis,
                scenePosition.y + self.defaultYCoordDis,
                scenePosition.z + -self.defaultZCoordDis + 0.5)
        }
    }
    
    func resetNodePos(scenePosition: SCNVector3?){
        self.placeNode(scenePostion: scenePosition)
        
        self.fixedImageWidth = 1
        self.addCurrentIndexAsGeometry()
    }
    
    func nextPost(){
        self.currentIndex = (self.currentIndex + 1) % self.onboardingDisplayModels.count
        self.addCurrentIndexAsGeometry()
    }
    
    func previousPost(){
        self.currentIndex = (self.currentIndex - 1) % self.onboardingDisplayModels.count
        if (self.currentIndex < 0){
            self.currentIndex = self.currentIndex + self.onboardingDisplayModels.count
        }
        
        self.addCurrentIndexAsGeometry()
    }
    
    func scaleNodePlane(withValue scale: CGFloat){
        guard scale > 0 else {return}
        
        if (scale > 1){
            self.fixedImageWidth += 0.05
        }else {
            if (self.fixedImageWidth > 0.1){
                self.fixedImageWidth -= 0.05
            }
        }
        
        self.addCurrentIndexAsGeometry()
    }
    
    func displayPostInfo() {
        let postDisplayInfo = PostDisplayInfoModel(username: "FinchIt", description: self.onboardingDisplayModels[self.currentIndex].onboardingNodeModel.descriptionText)
        
        NotificationCenter.default.post(name: .groupSCNNodeDidRequestCurrentPostDisplayInfo, object: postDisplayInfo)
    }
    
    func toggleVolumeIfVideoContentBeingOnDisplay(){
        
    }
    
    func getScaledDim(forSize size: CGSize) -> CGSize {
        let width = self.fixedImageWidth
        let height = (size.height * width)/size.width
        
        return CGSize(width: width, height: height)
    }
    
    func addCurrentIndexAsGeometry() {
        let node = self.onboardingDisplayModels[self.currentIndex]
        
        if (node.contentType == .image){
            guard let image = node.image else {return}
            self.addImageAsGeometry(image: image)
        }else if (node.contentType == .video){
            guard let avPlayer = node.avPlayer else {return}
            self.addVideoAsGeoemetry(withAVPlayer: avPlayer)
        }
    }
    
    func addImageAsGeometry(image: UIImage){
        let scaledDims = self.getScaledDim(forSize: image.size)
        
        let plane = SCNPlane(width: scaledDims.width, height: scaledDims.height)
        plane.cornerRadius = 0.1 * scaledDims.width
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        
        // adding plane to the geometry of the scn node
        self.geometry = plane
    }
    
    func addVideoAsGeoemetry(withAVPlayer avPlayer: AVPlayer){
        let scaledDims = self.getScaledDim(forSize: UIScreen.main.bounds.size)
        
        // create plane for adding as geometry to the node
        let plane = SCNPlane(width: scaledDims.width, height: scaledDims.height)
        plane.cornerRadius = 0.1 * scaledDims.width
        // texturing the plane with the image
        plane.firstMaterial?.diffuse.contents = avPlayer
        plane.firstMaterial?.lightingModel = .constant
        
        avPlayer.isMuted = true
        avPlayer.play()
        
        self.geometry = plane
    }
    
    private var defaultZCoordDis: Float = 2.5
    private var defaultXCoordDis: Float = 1
    private var defaultYCoordDis: Float = -1
    private var fixedImageWidth: CGFloat = 1
}


class OnboardingDisplayModel: NSObject {
    
    var image: UIImage?
    
    var avPlayer: AVPlayer?
    var avPlayerContext = 0
    
    var onboardingNodeModel: OnboardingNodeModel
    
    var contentType: PostContentType {
        return self.onboardingNodeModel.contentType
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(model: OnboardingNodeModel){
        self.onboardingNodeModel = model
        
        super.init()
        
        self.setupContent()
    }
    
    func setupContent() {
        if (self.onboardingNodeModel.contentType == .image){
            self.image = self.onboardingNodeModel.image!
        }else if (self.onboardingNodeModel.contentType == .video){
            self.avPlayer = AVPlayer(url: self.onboardingNodeModel.videoPathUrl!)
            self.avPlayer?.isMuted = true
            self.setupVideoForLoop()
        }
    }
    
    func setupVideoForLoop() {
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
//                self.isReadyToDisplay = true
//                self.postContentType = .video
//                self.notifyDataDidLoad()
                print("avQueuePlayer status is readyToDisplay")
            case .failed:
                print("avQueuePlayer status failed to load media")
            default:
                print("avQueuePlayer status unknown")
            }
        }
    }
    
    deinit {
        print("IG OT SSSSS")
        self.avPlayer?.removeObserver(self, forKeyPath:  #keyPath(AVQueuePlayer.status), context: &avPlayerContext)
        print("IG JIODJAOIDOI")
    }
}
