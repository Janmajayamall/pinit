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
            guard self.mainSceneNode != nil else {return}
            
            self.groupNodes.values.forEach { (node) in
                self.mainSceneNode!.addChildNode(node)
            }
        }
    }
    
    var currentPosition: SCNVector3? {
        guard let pointOfView = self.pointOfView else {return nil}
        return self.scene.rootNode.convertPosition(pointOfView.position, to: mainSceneNode)
    }
    
    var groupNodes: Dictionary<NodeDirection, GroupSCNNode> = [:]
    var exisitingPosts: Dictionary<String, PostModel> = [:]
    var addPostToGroupOfDirection: NodeDirection = .front
    
    var debug: Bool = false
    
    // for pangesture
    var lastPanLocation: SCNVector3?
    var draggingNode: GroupSCNNode?
    var prePanZ: CGFloat?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(){
                
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width), options: nil)
        
        // adding group scene nodes
        self.setupGroupNodes()
        
        //setting up debug options
        if (self.debug){
            self.debugOptions = ARSCNDebugOptions(arrayLiteral: [.showWorldOrigin, .showFeaturePoints])
            self.showsStatistics = true
        }
        
        // TODO: Change delegate afterwards - when you need to have a delegate for this class
        self.delegate = self
        
        // Setting up subscribers
        self.subscribeToRetrievePostServicePublishers()
        self.subscribeToUploadPostServicePublishers()
        self.subscribeToArViewPublishers()
        
        // adding UITapGestureRecogniser
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(sender:)))
        self.addGestureRecognizer(tapGestureRecogniser)
        
        let GestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(sender:)))
        GestureRecogniser.numberOfTapsRequired = 2
         self.addGestureRecognizer(GestureRecogniser)
        
        // adding UIPanGestureRecognizer
        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(sender:)))
        self.addGestureRecognizer(panGestureRecogniser)

        // adding UIPinchGestureRecognizer
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(sender:)))
        self.addGestureRecognizer(pinchGestureRecognizer)
        
        // adding UILongPressGestureRecognizer
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(sender:)))
        self.addGestureRecognizer(longPressGestureRecognizer)
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleViewTap(sender: UITapGestureRecognizer){
        // checking whether the touch is from class of type SCNView or not
        guard let view = sender.view as? SCNView else {return}
        
        // posting notification that user tapped on ar view
        NotificationCenter.default.post(name: .aRViewUserDidTapView, object: true)
        
        // getting the touch location as 2 coordinates on screen
        let coordinates = sender.location(in: view)
        // getting the nodes with which the ray sent along the path of touchpoint would have interacted
        guard let touchedHitResult = view.hitTest(coordinates).first, let node = touchedHitResult.node as? GroupSCNNode else {return}
        
        // change the image
        node.nextPost()
    }
    
    @objc func handlePanGesture(sender: UIPanGestureRecognizer){
        // checking whether the touch is from class of type SCNView or not
        guard let view = sender.view as? SCNView else {return}
        
        // touch coordinates
        let touchCoordinates = sender.location(in: view)
        
        switch sender.state {
        case .began:
            // getting the node touched
            guard let touchedHitResult = view.hitTest(touchCoordinates, options: nil).first, let node = touchedHitResult.node as? GroupSCNNode else {return}
            
            // setting it up
            self.draggingNode = node
            self.lastPanLocation = node.position
            self.prePanZ = CGFloat(view.projectPoint(self.lastPanLocation!).z)
            
        case .changed:
            guard let draggingNode = self.draggingNode, let prePanZ = self.prePanZ, let lastPanLocation = self.lastPanLocation else {return}
            let worldTouchLocation = view.unprojectPoint(SCNVector3(touchCoordinates.x, touchCoordinates.y, prePanZ))
            let translation = SCNVector3(
                worldTouchLocation.x - lastPanLocation.x,
                worldTouchLocation.y - lastPanLocation.y,
                worldTouchLocation.z - lastPanLocation.z
            )
            
            draggingNode.localTranslate(by: translation)
            
            self.lastPanLocation = worldTouchLocation
        default:
            self.draggingNode = nil
            self.lastPanLocation = nil
            self.prePanZ = nil
            
        }
        
    }
    
    @objc func handlePinchGesture(sender: UIPinchGestureRecognizer){
        guard let view = sender.view as? SCNView else {return}
        
        if (sender.state == .changed){
            // getting touched coordinates
            let touchedCoordinates = sender.location(in: view)
            
            // getting the node
            guard let touchedHitResult = view.hitTest(touchedCoordinates, options: nil).first, let node = touchedHitResult.node as? GroupSCNNode else {return}
            
            // scaling current index image with sender scale
            node.scaleNodePlane(withValue: sender.scale)
        }
    }
    
    @objc func handleLongPressGesture(sender: UILongPressGestureRecognizer){
        guard let view = sender.view as? SCNView else {return}
        
        if (sender.state == .began){
            // getting touched location
                   let touchedCoordinates = sender.location(in: view)
                   
                   // getting the touched node with hit test
                   guard let touchedHitResult = view.hitTest(touchedCoordinates, options: nil).first, let node = touchedHitResult.node as? GroupSCNNode else {return}
                   
                   // displaying info text
                   node.displayPostInfo()                   
                   node.toggleVolumeIfVideoContentBeingOnDisplay()
        }
    }
    
    func startSession(){
        
        print("AR scene session started")
        
        //configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        
        configuration.worldAlignment = .gravity
        
        //run the session
        self.session.run(configuration)

    }
    
    func pauseSession(){
        print("Pause ar session")
        self.session.pause()
    }
    
    func setupGroupNodes() {
        if (self.groupNodes[.front] == nil){
            self.groupNodes[.front] = GroupSCNNode(scenePosition: self.currentPosition, direction: .front)
        }else {
            self.groupNodes[.front]?.placeNode(scenePosition: self.currentPosition)
        }
        
        if (self.groupNodes[.frontRight] == nil){
            self.groupNodes[.frontRight] = GroupSCNNode(scenePosition: self.currentPosition, direction: .frontRight)
        }else{
            self.groupNodes[.frontRight]?.placeNode(scenePosition: self.currentPosition)
        }
        
        if (self.groupNodes[.frontLeft] == nil){
            self.groupNodes[.frontLeft] = GroupSCNNode(scenePosition: self.currentPosition, direction: .frontLeft)
        }else {
            self.groupNodes[.frontLeft]?.placeNode(scenePosition: self.currentPosition)
        }
            
        // adding the nodes
        self.groupNodes.values.forEach { (node) in
            self.mainSceneNode?.addChildNode(node)
        }
    }
    
    func addPostToGroupNode(post: PostModel) {
        // checking whether post already exits in one of the group nodes or not
        guard let id = post.id, self.exisitingPosts[id] == nil else {
            print("Post with ID: \(post.id!) rejected - normal")
            return
        }
        
        // adding it to one of the group nodes
        self.groupNodes[self.addPostToGroupOfDirection]?.addPost(post)
        self.exisitingPosts[id] = post
        print("Post with ID: \(id) added - normal;")
        // changing direction
        switch self.addPostToGroupOfDirection {
        case .front:
            self.addPostToGroupOfDirection = .frontRight
        case .frontRight:
            self.addPostToGroupOfDirection = .frontLeft
        case .frontLeft:
            self.addPostToGroupOfDirection = .front
        }
    }
    
    func optimisticUIAddPostToGroupNode(optimisticPostModel: OptimisticUIPostModel) {
        guard let id = optimisticPostModel.postModel.id, self.exisitingPosts[id] == nil else {return}
        print("Post with ID: \(id) added - optimistic")
        // adding it to the front group node
        self.groupNodes[.front]?.optimisticAddPost(optimisticPostModel)
        self.exisitingPosts[id] = optimisticPostModel.postModel
    }

}

// extension for susbcribing to publishers
extension AppArScnView {
    
    // RetrievePostService
    func subscribeToRetrievePostServicePublishers(){
        Publishers.retrievePostServiceDidReceivePostsForGeohashes.sink { (posts) in
            posts.forEach { (post) in
                self.addPostToGroupNode(post: post)
            }
        }.store(in: &cancellables)
    }
    
    // subscribe to uploadPostService publishers
    func subscribeToUploadPostServicePublishers(){
        Publishers.uploadPostServiceDidUploadPostPublisher.sink { (optimisticUIPostModel) in
            self.optimisticUIAddPostToGroupNode(optimisticPostModel: optimisticUIPostModel)
        }.store(in: &cancellables)
    }
    
    // subscribe to arView publishers
    func subscribeToArViewPublishers() {
        Publishers.aRViewDidRequestResetGroupNodesPosPublisher.sink { (value) in
            guard value == true else {return}
            print("Received")
            self.setupGroupNodes()
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
