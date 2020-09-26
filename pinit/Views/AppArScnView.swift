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
    var postsWithLoadedDisplayData: Int = 0
    
    var debug: Bool = false
    
    // for pangesture
    var lastPanLocation: SCNVector3?
    var draggingNode: GroupSCNNode?
    var prePanZ: CGFloat?
    
    private var touchedNodeDirectionHistory: Array<NodeDirection> = []
    
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
        self.subscribeToUploadPostServicePublishers()
        self.subscribeToArViewPublishers()
        self.subscribeToGroupSCNNodePublishers()
        
        // setup ui gesture recognizers
        self.setupUIGestureRecognizers()
    }
    
    func setupUIGestureRecognizers() {
        // adding UITapGestureRecogniser
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(sender:)))
        self.addGestureRecognizer(tapGestureRecogniser)
        
        //        let GestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleViewTap(sender:)))
        //        GestureRecogniser.numberOfTapsRequired = 2
        //        self.addGestureRecognizer(GestureRecogniser)
        //
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
    
    func handleBackIconTouch() {
        guard let nodeDirection = self.touchedNodeDirectionHistory.popLast() else {return}
        
        // call previous post of group scn node in the node direction
        self.groupNodes[nodeDirection]?.previousPost()
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
        self.touchedNodeDirectionHistory.append(node.nodeDirection)
        
        // create event
        AnalyticsService.logNodeTap(inDirection: node.nodeDirection)
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
        self.session.pause()
    }
    
    func setupGroupNodes() {
        
        removeGroupNodes()
        
        self.groupNodes[.front] = GroupSCNNode(scenePosition: self.currentPosition, direction: .front)
        
        self.groupNodes[.frontRight] = GroupSCNNode(scenePosition: self.currentPosition, direction: .frontRight)
        
        self.groupNodes[.frontLeft] = GroupSCNNode(scenePosition: self.currentPosition, direction: .frontLeft)
        
        // adding the nodes
        self.groupNodes.values.forEach { (node) in
            self.mainSceneNode?.addChildNode(node)
        }
    }
    
    func removeGroupNodes() {        
        // remove children of mainSceneNode
        self.mainSceneNode?.childNodes.forEach({ (node) in
            node.removeFromParentNode()
        })
        
        // empty groupNodes dict, exisiting posts & rest
        self.groupNodes.removeAll()
        self.exisitingPosts.removeAll()
        self.addPostToGroupOfDirection = .front
        self.postsWithLoadedDisplayData = 0
    }
    
    func resetGroupNodesPositions() {
        self.groupNodes.values.forEach { (node) in
            node.placeNode(scenePosition: self.currentPosition)
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
        // adding it to the front group node
        self.groupNodes[.front]?.optimisticAddPost(optimisticPostModel)
        self.exisitingPosts[id] = optimisticPostModel.postModel
    }
    
    func checkPostsExistForCurrentLocation() {
        guard self.exisitingPosts.count == 0 else {return}
        
        // notify that the posts at location do not exist
        NotificationCenter.default.post(name: .generalFunctionPostsDoNotExistForCurrentLocation, object: true)
        
    }
    
}

// extension for susbcribing to publishers
extension AppArScnView {
    
    // RetrievePostService
    func subscribeToRetrievePostServicePublishers(){
        Publishers.retrievePostServiceDidReceivePostsForGeohashes.sink { (posts) in
            
            posts.forEach { (post) in
                print("POST RCVV \(post.geohash)")
                self.addPostToGroupNode(post: post)
            }
            
            // check whether the post exists at current geolocation
            self.checkPostsExistForCurrentLocation()
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
            self.resetGroupNodesPositions()
        }.store(in: &cancellables)
        
        Publishers.aRViewDidTapBackIconPublisher.sink { (value) in
            guard value == true else {return}
            self.handleBackIconTouch()
        }.store(in: &cancellables)
    }

    // subscribe to Group SCN node Publisher
    func subscribeToGroupSCNNodePublishers() {
        Publishers.groupSCNNodeDidLoadPostDisplayData.sink { (value) in
            guard self.postsWithLoadedDisplayData == 0 else {return}
            
            self.postsWithLoadedDisplayData += 1
            
            // notify the loader to decrease initial task
            NotificationCenter.default.post(name: .generalFunctionManipulateTaskForLoadIndicator, object: -1)
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

