//
//  AppArScnView.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import Combine

class AppArScnView: ARSCNView {
    
    /// The first node of  ARSCNView scene's rootNode.
    /// Did this for convenience; To avoid refering to the rootNode of view's secene again and again
    /// Main root node and `mainSceneNode` have same position (i.e. the origin of 3d scene coordinate )
    var mainSceneNode: SCNNode?{
        didSet{
            self.addDummyNodes()
        }
    }
    
    var currentPosition: SCNVector3? {
        guard let pointOfView = self.pointOfView else {return nil}
        return self.scene.rootNode.convertPosition(pointOfView.position, to: mainSceneNode)
    }
    
    var postSceneNodes: Array<PostSCNNode> = []
    
    var debug: Bool = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(){
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width), options: nil)
        
        //setting up debug options
        if (self.debug){
            self.debugOptions = ARSCNDebugOptions(arrayLiteral: [.showWorldOrigin, .showFeaturePoints])
            self.showsStatistics = true
        }
        
        // TODO: Change delegate afterwards - when you need to have a delegate for this class
        self.delegate = self
        
        // Setting up subscribers
        self.subscribeToRetrievePostServicePublishers()
        self.subscribeToArSceneLocationServicePublishers()
        self.subscribeToUploadPostServicePublishers()
        
        
        // adding UITapGestureRecogniser
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(sender:)))
        self.addGestureRecognizer(gestureRecogniser)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleViewTap(sender: UITapGestureRecognizer){
        // checking whether the touch is from class og type SCNView or not
        guard let view = sender.view as? SCNView else {return}
        
        // getting the touch location as 2 coordinates on screen
        let coordinates = sender.location(in: view)
        // getting the nodes with which the ray sent along the path of touchpoint would have interacted
        guard let touchedHitResult = view.hitTest(coordinates).first, let node = touchedHitResult.node as? ImageSCNNode else {return}
        
        node.increaseSize()
    }
    
    func startSession(){
        
        print("AR scene session started")
        
        //configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        configuration.worldAlignment = .gravity
        
        //run the session
        self.session.run(configuration)
        
        // start the timer
        self.start()
    }
    
    func pauseSession(){
        print("Pause ar session")
        self.session.pause()
    }
    
    func addDummyNodes() {
        let node1 = PostSCNNode(scenePosition: self.currentPosition, directionView: .front)
        let node2 = PostSCNNode(scenePosition: self.currentPosition, directionView: .right)
        let node3 = PostSCNNode(scenePosition: self.currentPosition, directionView: .left)
        let node4 = PostSCNNode(scenePosition: self.currentPosition, directionView: .back)
        self.mainSceneNode?.addChildNode(node1)
        self.mainSceneNode?.addChildNode(node2)
        self.mainSceneNode?.addChildNode(node3)
        self.mainSceneNode?.addChildNode(node4)
        self.postSceneNodes.append(node1)
        self.postSceneNodes.append(node2)
        self.postSceneNodes.append(node3)
        self.postSceneNodes.append(node4)
        
    }
    
    func updateNodes() {
        self.postSceneNodes.forEach { (node) in
            node.placeItDummy(scenePosition: self.currentPosition)
        }
    }
    
    func start() {
        Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().sink { _ in
            self.updateNodes()
        }.store(in: &cancellables)
    }
}

// extension for susbcribing to publishers
extension AppArScnView {
    
    // ARSceneLocationService
    func subscribeToArSceneLocationServicePublishers(){
        Publishers.aRSceneLocationServiceDidUpdateLocationEstimatesPublisher.sink { (location) in
            
        }.store(in: &cancellables)
    }
    
    // RetrievePostService
    func subscribeToRetrievePostServicePublishers(){
        //        Publishers.retrievePostServiceDidReceivePostsForGeohashes.sink { (posts) in
        //            posts.forEach { (post) in
        //                guard let id = post.id else {return}
        //                print("came in id--: \(id)")
        //                guard self.postSceneNodes[id] == nil else {
        //                    print("rejected Id--: \(id)")
        //                    return
        //                }
        //                self.postSceneNodes[id] = PostSCNNode(post: post)
        //            }
        //        }.store(in: &cancellables)
    }
    
    // subscribe to uploadPostService publishers
    func subscribeToUploadPostServicePublishers(){
        Publishers.uploadPostServiceDidUploadPostPublisher.sink { (optimisticUIPostModel) in
            guard optimisticUIPostModel.postModel.id != nil else {return}
            
            
            
            
        }.store(in: &cancellables)
    }
}

extension AppArScnView: ARSceneLocationServiceDelegate {
    
    var scenePosition: SCNVector3? {
        return self.currentPosition
    }
    
}

extension AppArScnView: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if(self.mainSceneNode == nil){
            self.mainSceneNode = SCNNode()
            
            //adding the mainSceneNode as the first child of root node of the scene
            scene.rootNode.addChildNode(mainSceneNode!)
        }
    }
}

//
//
//
//func updateSceneNodes(){
//      guard let currentLocation = self.aRSceneLocationService.currentLocation else {return}
//
//      self.postSceneNodes.forEach { (id, node) in
//          guard node.isImageNodeLoaded else {return}
//
//          // checking whether the node is valid to be rendered
//          guard node.checkNodeRenderValidity(withCurrentLocation: currentLocation) else {
//              print("node -- remove -> \(node.id)")
//              node.removeFromParentNode()
//              return
//          }
//
//          // checking whether this node is being loaded first time (if the node was removed because it was declared not valid & is declared valid again its will act as firstTime)
//          let firstTime = !(self.mainSceneNode?.childNodes.contains(node) ?? false)
//
//
//              node.updatePostNode(locationService: self.aRSceneLocationService, scenePosition: self.currentPosition, firstTime: firstTime)
//
//
//
//          // add node to mainSceneNode if it is loaded for the first time
//          if (firstTime){
//              print("node -- added -> \(node.id)")
//              self.mainSceneNode?.addChildNode(node)
//          }
//      }
//
//  }



// FIXME: Uncomment this
//        // checking whether the progile picture has been loaded or not
//        guard let userProfilePicture = node.userProfilePicture else {return}
//
//        // creating PostDisplayInfoModel for displaying on screen
//        let model = PostDisplayInfoModel(username: node.username, description: node.descriptionText, userProfilePicture: userProfilePicture)
//
//        // post notification for post display info
//        NotificationCenter.default.post(name: .aRViewDidTouchImageSCNNode, object: model)
//
