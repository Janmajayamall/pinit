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
import FirebaseAuth
import CoreLocation

protocol AppSCNNode {
    func nextPost() -> Void
    func previousPost() -> Void
    var position: SCNVector3 { get set }
    func localTranslate(by translation: SCNVector3) -> Void
    func scaleNodePlane(withValue scale: CGFloat) -> Void
    func displayPostInfo() -> Void
    func toggleVolumeIfVideoContentBeingOnDisplay() -> Void
}

class GroupSCNNode: SCNNode, Identifiable, AppSCNNode {
    
    var nodeDirection: NodeDirection
    
    var postList: Array<PostDisplayNodeModel> = []
    var postDisplayType: PostDisplayType
    
    var user: User?
    
    var currentPostIndex: Int = -1
    
    var currentLocation: CLLocation?
    
    var blockedUsers: Array<BlockedUserModel> = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(scenePosition: SCNVector3?, direction: NodeDirection, user: User?, postDisplayType: PostDisplayType){
        self.nodeDirection = direction
        self.user = user
        self.postDisplayType = postDisplayType
       
        super.init()
        
        // subscribe to publishers
        self.subscribeToGroupSCNNodePublishers()
        self.subcribeToAuthenticationServicePublishers()
        self.subscribeToEstimatedUserLocationServicePublishers()
        self.subscribeToBlockUsersServicePublishers()
        
        // add constraints to the nodeO
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        self.constraints = [billboardConstraint]
        
        self.placeNode(scenePosition: scenePosition)
        self.loadInitialPostDisplay()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getScaledDim(forSize size: CGSize) -> CGSize{
        let width = self.fixedImageWidth
        let height = (size.height * width)/size.width
        
        return CGSize(width: width, height: height)
    }
    
    func addImageAsGeometry(image: UIImage){
        // getting scaled dims for the original image
        let scaledDims = self.getScaledDim(forSize: image.size)
        
        // create plane for adding as geometry to the node
        let plane = SCNPlane(width: scaledDims.width, height: scaledDims.height)
        plane.cornerRadius = 0.1 * scaledDims.width
        
        // texturing the plane with the image
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        
        
        // adding to the node's geometry
        self.geometry = plane
    }
    
    func addVideoAsGeometry(withAVPlayer avPlayer: AVPlayer) {
        // getting scaled dims for uiScreen
        let scaledDims = self.getScaledDim(forSize: UIScreen.main.bounds.size)
        
        // create plane for adding as geometry to the node
        let plane = SCNPlane(width: scaledDims.width, height: scaledDims.height)
        plane.cornerRadius = 0.1 * scaledDims.width
        // texturing the plane with the image
        plane.firstMaterial?.diffuse.contents = avPlayer
        let translation = SCNMatrix4MakeTranslation(-1, 0, 0)
        let rotation = SCNMatrix4MakeRotation(-(Float.pi / 2), 0, 0, 1)
        let transform = SCNMatrix4Mult(translation, rotation)
        plane.firstMaterial?.diffuse.contentsTransform = transform
        plane.firstMaterial?.lightingModel = .constant
        
        // playing the queuePlayer
        avPlayer.isMuted = true
        avPlayer.play()
        
        // adding to the node's geometry
        self.geometry = plane
    }
    
    func isPostValidForRender(_ postDisplay: PostDisplayNodeModel) -> Bool {
        // check for blocked user
        guard !self.blockedUsers.contains(where: { (blockedUserModel) -> Bool in
            return blockedUserModel.blockedUID == postDisplay.post.userId
        }) else {
            return false
        }
        
        guard let currentLocation = self.currentLocation else {
            return false
        }
        
        let post = postDisplay.post
        let postLocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: post.geolocation.latitude, longitude: post.geolocation.longitude), altitude: post.altitude, horizontalAccuracy: post.horizontalAccuracy, verticalAccuracy: post.verticalAccuracy, timestamp: .init())
        
        guard self.postDisplayType == .privatePosts else {
            // check whether post is in valid distance and altitude range current
            if (currentLocation.checkIsInValidDistanceRange(forLocation: postLocation)){
                return postDisplay.isReadyToDisplay
            }else{
                return false
            }
        }
        
        // if post display type is private, then check whether the post belongs to the user. If it does not then return false
        guard let user = self.user, user.uid == postDisplay.post.userId else {
            return false
        }
        
        // check whether post is in valid altitude range or not
        if (currentLocation.checkIsInValidDistanceRange(forLocation: postLocation)){
            return postDisplay.isReadyToDisplay
        }else{
            return false
        }
    }
    
    func nextPost(){
        guard self.postList.count > 0 && self.currentPostIndex >= 0 else {return}
        
        let refIndex = self.currentPostIndex
        repeat{
            // changing the index
            self.currentPostIndex = (self.currentPostIndex + 1) % self.postList.count
            
            // if current index == refIndex then break
            if (self.currentPostIndex == refIndex){
                break
            }
        }while self.isPostValidForRender(self.postList[self.currentPostIndex]) == false
        
        if (refIndex != self.currentPostIndex){
            self.preparePostNodeOffloadFromGeometry(forIndex: refIndex)
            self.addCurrentPostAsGeometry()
        }
    }
    
    func previousPost() {
        guard self.postList.count > 0 && self.currentPostIndex >= 0 else {return}
        
        let refIndex = self.currentPostIndex
        repeat{
            // changing the index         
            self.currentPostIndex = (self.currentPostIndex - 1) % self.postList.count
            if (self.currentPostIndex < 0){
                self.currentPostIndex = self.currentPostIndex + self.postList.count
            }
            
            // if current index == refIndex then break
            if (self.currentPostIndex == refIndex){
                break
            }
        }while self.isPostValidForRender(self.postList[self.currentPostIndex]) == false
        
        if (refIndex != self.currentPostIndex){
            self.preparePostNodeOffloadFromGeometry(forIndex: refIndex)
            self.addCurrentPostAsGeometry()
        }
    }
    
    func addCurrentPostAsGeometry() {
        // checking content type
        let postNode = self.postList[self.currentPostIndex]
        
        switch postNode.postContentType {
        case .video:
            guard let avPlayer = postNode.avPlayer else {return}
            self.addVideoAsGeometry(withAVPlayer: avPlayer)
        case .image:
            guard let image = postNode.image else {return}
            self.addImageAsGeometry(image: image)
        default:
            break
        }
    }
    
    func preparePostNodeOffloadFromGeometry(forIndex index: Int) {
        let postNode = self.postList[index]
        
        if (postNode.postContentType == .video){
            guard let avPlayer = postNode.avPlayer else {return}
            avPlayer.isMuted = true
            avPlayer.pause()
        }
    }
    
    func scaleNodePlane(withValue scale: CGFloat){
        guard scale > 0 else {return}
        
        if (scale > 1){
            self.fixedImageWidth += 0.05
        }else {
            if (self.fixedImageWidth > 0.05){
                self.fixedImageWidth -= 0.05
            }
        }
        
        self.addCurrentPostAsGeometry()
    }
    
    func displayPostInfo(){
        let post = self.postList[self.currentPostIndex].post
        
        // creating post display info model
        let postDisplayInfo = PostDisplayInfoModel(username: post.username, description: post.description)
        
        // post notification
        NotificationCenter.default.post(name: .groupSCNNodeDidRequestCurrentPostDisplayInfo, object: postDisplayInfo)
        
    }
    
    func toggleVolumeIfVideoContentBeingOnDisplay() {
        guard let avPlayer = self.postList[self.currentPostIndex].avPlayer, let id = self.postList[self.currentPostIndex].post.id else {return}
        avPlayer.isMuted = !avPlayer.isMuted
        NotificationCenter.default.post(name: .postDisplayNodeModelDidRequestMuteAVPlayer, object: id)
        
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
                               
        SCNTransaction.commit()
    }
    
    func resetNodePos(scenePosition: SCNVector3?) {        
        
        self.placeNode(scenePosition: scenePosition)
        
        // set fixedImageWidth to 1 again
        if (self.currentPostIndex != -1 && self.isPostValidForRender(self.postList[self.currentPostIndex % self.postList.count])){
            // reset plane dimensions
            self.fixedImageWidth = 1
            self.addCurrentPostAsGeometry()
            
        }
    }
    
    func addPost(_ post: PostModel) {
        // creating new post display node model
        let model = PostDisplayNodeModel(post: post)
        
        // adding it to list
        self.postList.append(model)
    }
    
    func optimisticAddPost(_ optimisticPostModel: OptimisticUIPostModel) {
        // creating new post display node model
        let model = PostDisplayNodeModel(optimisticPostModel: optimisticPostModel)
        
        // adding it to post list
        // if the optimistic post is the first post then increase currentIndex by 1 to initiate the process of placing nodes
        if (self.currentPostIndex == -1){
            self.currentPostIndex += 1
        }
        self.postList.insert(model, at: self.currentPostIndex)
        
        self.addCurrentPostAsGeometry()
    }
    
    func resetNode() {
        // remove current post content (i.e. geometry)
        self.geometry = nil
        
        // reset the currentPostIndex
        self.currentPostIndex = -1
        self.loadInitialPostDisplay()
    }
    
    func loadInitialPostDisplay() {
        guard self.currentPostIndex == -1 && self.postList.count > 0 else {return}
        
        for index in 0..<self.postList.count {
            if self.isPostValidForRender(self.postList[index]) {
                self.currentPostIndex = index
                self.addCurrentPostAsGeometry()
            }
        }
    }
    
    private var defaultZCoordDis: Float = 2.5
    private var defaultXCoordDis: Float = 1
    private var defaultYCoordDis: Float = -1
    private var fixedImageWidth: CGFloat = 1
}


// for subscribing to publishers
extension GroupSCNNode {
    func subscribeToGroupSCNNodePublishers() {
        Publishers.groupSCNNodeDidLoadPostDisplayData.sink { (value) in
            guard value == true else {return}
            self.loadInitialPostDisplay()
        }.store(in: &cancellables)
        
        Publishers.groupSCNNodeDidRequestChangePostDisplayTypePublisher.sink { (postDisplayType) in
            self.postDisplayType = postDisplayType
            
            // reset the node
            self.resetNode()
        }.store(in: &cancellables)
        
        Publishers.groupSCNNodeDidRequestResetPublisher.sink { (value) in
            guard value == true else {return}
            
            self.resetNode()
        }.store(in: &cancellables)
    }
    
    func subcribeToAuthenticationServicePublishers() {
        Publishers.authenticationServiceDidAuthStatusChangePublisher.sink { (user) in
            self.user = user
        }.store(in: &cancellables)
    }
    
    func subscribeToEstimatedUserLocationServicePublishers() {
        Publishers.estimatedUserLocationServiceDidUpdateLocation.sink { (location) in
            self.currentLocation = location
            self.loadInitialPostDisplay()
        }.store(in: &cancellables)
    }
    
    func subscribeToBlockUsersServicePublishers() {
        Publishers.blockUsersServiceDidUpdateBlockedUsersPublisher.sink { (models) in
            self.blockedUsers = models
        }.store(in: &cancellables)
    }
}

enum NodeDirection: String {
    case front
    case frontRight
    case frontLeft
}

enum PostDisplayType {
    case privatePosts
    case allPosts
}
