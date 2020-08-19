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
            //return if mainSceneNode is still nil
            guard self.mainSceneNode != nil else {return}
            
            self.placedImageNodes.forEach { (id, node) in
                
                node.updateSceneNodeWith(locationService: self.aRSceneLocationService, scenePostion: self.currentPosition ,firstTime: true)
                
                self.mainSceneNode?.addChildNode(node)
            }
        }
    }
    var currentPosition: SCNVector3? {
        guard let pointOfView = self.pointOfView else {return nil}
        return self.scene.rootNode.convertPosition(pointOfView.position, to: mainSceneNode)
    }
    
    var aRSceneLocationService = ARSceneLocationService()
    var retrievePostService = RetrievePostService()
    var geohashingService = GeohashingService()
    
    var placedImageNodes: Dictionary<String , ImageSCNNode> = [:]
    var bufferImageNodes: Dictionary<String , ImageSCNNode> = [:]
    
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
        
        // Setting up subscribers
        self.subscribeToRetrievePostServicePublishers()
        self.subscribeToArSceneLocationServicePublishers()
        self.subscribeToImageSCNNodePublishers()
        
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
        self.session.pause()
        
        //stop other services as well
        self.retrievePostService.stopListeningToPosts()
        self.aRSceneLocationService.stop()
    }
    
    func addSceneNode(withId id: String){
        
        if self.bufferImageNodes[id] != nil {
            
            self.placedImageNodes[id] = self.bufferImageNodes[id]
            self.bufferImageNodes.removeValue(forKey: id)
            
            self.placedImageNodes[id]?.updateSceneNodeWith(locationService: self.aRSceneLocationService, scenePostion: self.currentPosition, firstTime: true)
                       
            self.mainSceneNode?.addChildNode(self.placedImageNodes[id]!)
        }
    
        
    }
    
    func updateSceneNodes(){
        
        self.placedImageNodes.forEach { (id, node) in
            node.updateSceneNodeWith(locationService: self.aRSceneLocationService, scenePostion: self.currentPosition, firstTime: false)
        }
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
                guard let id = post.id, self.bufferImageNodes[id] == nil && self.placedImageNodes[id] == nil else {return}
                let postNode = ImageSCNNode(post: post)
                self.bufferImageNodes[id] = postNode
            }
        }.store(in: &cancellables)
    }
    
    // ImageSCNNode
    func subscribeToImageSCNNodePublishers(){
        Publishers.imageSCNNodeDidLoadImagePublisher.sink { (id) in
            self.addSceneNode(withId: id)
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




