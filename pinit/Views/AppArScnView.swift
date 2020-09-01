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
    var mainSceneNode: SCNNode? {
        didSet{
            // return if mainSceneNode is still nil
            guard self.mainSceneNode != nil else {return}
            
            // getting current location
            guard let currentLocation = self.aRSceneLocationService.currentLocation else {return}
            
            self.postSceneNodes.forEach { (id, node) in
                guard node.isImageNodeLoaded else {return}
                
                guard node.checkNodeRenderValidity(withCurrentLocation: currentLocation) else {return}
                
                node.updatePostNode(locationService: self.aRSceneLocationService, scenePosition: self.currentPosition, firstTime: true)
                
                self.mainSceneNode?.addChildNode(node)
            }
        }
    }
    
    var currentPosition: SCNVector3? {
        guard let pointOfView = self.pointOfView else {return nil}
        return self.scene.rootNode.convertPosition(pointOfView.position, to: mainSceneNode)
    }
    
    var aRSceneLocationService = ARSceneLocationService()
    var geohashingService = GeohashingService()
    var retrievePostService = RetrievePostService()

    var postSceneNodes: Dictionary<String, PostSCNNode> = [:]
    
    var debug: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(parentSize: CGSize){
        super.init(frame: CGRect(x: 0, y: 0, width: parentSize.width, height: parentSize.height), options: nil)
        
        //setting up debug options
        if (self.debug){
            self.debugOptions = ARSCNDebugOptions(arrayLiteral: [.showWorldOrigin, .showFeaturePoints])
            self.showsStatistics = true
        }
        
        // TODO: Change delegate afterwards - when you need to have a delegate for this class
        self.delegate = self
        
        // setting up self as delegate
        self.aRSceneLocationService.delegate = self
        
        // Setting up subscribers
        self.subscribeToRetrievePostServicePublishers()
        self.subscribeToArSceneLocationServicePublishers()
        
        // setup services
        self.retrievePostService.setupService()
        self.geohashingService.setupService()
        self.aRSceneLocationService.setupService()
        
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
        guard let touchedNode = view.hitTest(coordinates).first else {return}
        
        //TODO: notify the delegate of touched node.
                
    }
    
    func startSession(){
        
        print("AR scene session started")
        
        //configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = false
        configuration.worldAlignment = .gravityAndHeading
        
        //start other services
        self.aRSceneLocationService.start()
        
        //run the session
        self.session.run(configuration)
    }
    
    func pauseSession(){
        print("Pause ar session")
        self.session.pause()
        
        //stop other services as well
        self.retrievePostService.stopListeningToPosts()
        self.aRSceneLocationService.stop()
    }
    
    
    func updateSceneNodes(){
        guard let currentLocation = self.aRSceneLocationService.currentLocation else {return}
        
        self.postSceneNodes.forEach { (id, node) in
            guard node.isImageNodeLoaded else {return}
            
            // checking whether the node is valid to be rendered
            guard node.checkNodeRenderValidity(withCurrentLocation: currentLocation) else {
                node.removeFromParentNode()
                return
            }
            
            // checking whether this node is being loaded first time (if the node was removed because it was declared not valid & is declared valid again its will act as firstTime)
            let firstTime = !(self.mainSceneNode?.childNodes.contains(node) ?? false)
            
            node.updatePostNode(locationService: self.aRSceneLocationService, scenePosition: self.currentPosition, firstTime: firstTime)
            
            // add node to mainSceneNode if it is loaded for the first time
            if (firstTime){
                print("node added")
                self.mainSceneNode?.addChildNode(node)
            }
        }
  
    }
    
    /// removes all placed child nodes from the main scene node &
    /// empties placed & buffer list of nodes
    func resetMainScene(){

        // remove all child nodes of main scene nodes
        self.mainSceneNode?.childNodes.forEach({ (node) in
            node.removeFromParentNode()
        })
    }
}

// extension for susbcribing to publishers
extension AppArScnView {
    
    // ARSceneLocationService
    func subscribeToArSceneLocationServicePublishers(){
        Publishers.aRSceneLocationServiceDidUpdateLocationEstimatesPublisher.sink { (location) in
            self.updateSceneNodes()
        }.store(in: &cancellables)
    }
    
    // RetrievePostService
    func subscribeToRetrievePostServicePublishers(){
        self.retrievePostService.$retrievedPosts.sink { (posts) in
            posts.forEach { (post) in
                guard let id = post.id, self.postSceneNodes[id] == nil else {
                    return
                }
                self.postSceneNodes[id] = PostSCNNode(post: post)
            }
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


