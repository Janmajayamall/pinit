//
//  ImageSCNNode.swift
//  pinit
//
//  Created by Janmajaya Mall on 17/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import Foundation
import SceneKit
import CoreLocation
import SDWebImageSwiftUI
import Combine

class ImageSCNNode: SCNNode {
    
    var location: CLLocation {
        let geoLocation = self.post.geolocation
        let coordinates = CLLocationCoordinate2D(latitude: geoLocation.latitude, longitude: geoLocation.longitude)
        let altitude = self.post.altitude
        let timestampDateValue = self.post.timestamp.dateValue()
        
        return CLLocation(coordinate: coordinates, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: timestampDateValue)
    }
    var id: String? {
        return self.post.id
    }
    var post: PostModel
    var imageManager: ImageManager
    
    private var cancellables: Set<AnyCancellable> = []

    /// With time, the accuracy of current location increases & it is possible that the nodes
    /// placed before were placed with lower accuracy. ---- NOT SURE IT THE ACCURACY DIFFERENCE IS SUBSTANTIAL
    /// Make this `True` for updating node position wiht more accuracy OR `False` for not updating it.
    /// Remember, the accuracy increase might not be substantial, but even a slight in image location change (image jumping around) after being rendered once will be bad experience for the user
    /// TODO: Test what works better.
    private var updateNodePositionAlways = false
    
    init(post: PostModel) {
        self.post = post
        self.imageManager = ImageManager(url: URL(string: post.imageUrl))
        
        super.init()
        
        self.subscribeToSDWebImageSwiftPublishers()
        self.imageManager.load()
    }
    
    func addImageAsGeometry(_ image: UIImage) {
        //creating 2D plane for texturing it with image
        let plane = SCNPlane(width: image.size.width, height: image.size.height)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        
        //add to the geometry of the node
        self.geometry = plane
        
        //setup rendering order to fix up flicker
        
        //add constraint so the 2D plane always points towards the pointOfView (i.e. the camera)
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        self.constraints = [billboardConstraint]
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Sets `updateNodePositionAlaways` to true
    func alwaysUpdatePostion(){
        self.updateNodePositionAlways = true
    }
    
    func updateSceneNodeWith(locationService: ARSceneLocationService, scenePostion: SCNVector3?, firstTime: Bool){
        
        guard let currentLocation = locationService.currentLocation else {return}
        guard let scenePostion = scenePostion else {return}
        
        let translateCurrentLocationBy = currentLocation.getTranslation(to: self.location)
        let distanceBetween = currentLocation.distance(from: self.location)
        
        //Start scene transaction
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        
        // for checking whether to render position (might change the position) of already rendered nodes again
        if (firstTime || self.updateNodePositionAlways){
            //translate the image from current position
            self.position = SCNVector3(
                scenePostion.x + Float(translateCurrentLocationBy.longitudeTranslation),
                scenePostion.y + Float(translateCurrentLocationBy.altitudeTranslation),
                scenePostion.z - Float(translateCurrentLocationBy.latitudeTranslation)
            )
        }
        
        // scale the position (SCALE should always change depending on the current location of user)
        // TODO: set the scale of by how distant the image is from the user
        
        //update the rendering order of the node
        self.renderingOrder = self.setRenderOrder(forDistance: distanceBetween)
        
        //End scene transaction
        SCNTransaction.commit()
    }
    
    /// Returns the render order for the node
    ///
    /// Nodes with greater render orders are rendered last.
    /// In our case, we want distant nodes to render before the near ones
    /// in order to avoid image flickering (if form the camera perspective one image overlays the other one)
    func setRenderOrder(forDistance distance: CLLocationDistance) -> Int{
        return Int.max - (1000 - Int(distance * 1000))
    }
    
}

extension ImageSCNNode {
    // SDWebImageSwiftUI
    func subscribeToSDWebImageSwiftPublishers(){
        self.imageManager.$image.sink(receiveValue: { (image) in
            
            //return if geometry already exists
            guard self.geometry == nil else {return}
            
            guard let image = image else {return}
            self.addImageAsGeometry(image)
            guard let id = self.id else {return}
            
            NotificationCenter.default.post(name: .imageSCNNodeDidLoadImage, object: id)
        }).store(in: &cancellables)
    }
}
