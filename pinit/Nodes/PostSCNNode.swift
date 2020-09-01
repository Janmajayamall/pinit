//
//  PostSCNNode.swift
//  pinit
//
//  Created by Janmajaya Mall on 1/9/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SceneKit
import Combine
import SDWebImageSwiftUI
import CoreLocation


class PostSCNNode: SCNNode, Identifiable {
    var post: PostModel
    var imageManager: ImageManager
    var isImageNodeLoaded: Bool = false
    
    var location: CLLocation {
        let geoLocation = self.post.geolocation
        let coordinates = CLLocationCoordinate2D(latitude: geoLocation.latitude, longitude: geoLocation.longitude)
        let altitude = self.post.altitude
        let timestampDateValue = self.post.timestamp.dateValue()
        
        return CLLocation(coordinate: coordinates, altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: timestampDateValue)
    }
    var id: String {
        return self.post.id!
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(post: PostModel) {
        self.post = post
        self.imageManager = ImageManager(url: URL(string: self.post.imageUrl))
        
        super.init()
        
        // configure the class
        // subscribing to image manager's image propeorty
        self.imageManager.$image.sink { (image) in
            guard let image = image else {return}
            
            // create and add image scene node as a child node to self & make isImageNodeLoaded as true
            self.addImageSCNNode(withImage: image)
            self.isImageNodeLoaded = true
            
        }.store(in: &cancellables)
        
        // loading the image
        self.imageManager.load()
    }
    
    func addImageSCNNode(withImage image: UIImage){
        // return if imageSCNNode has already been added
        guard self.isImageNodeLoaded == false else {return}
        
        let imageNode = ImageSCNNode(image: image)
        
        // define billboard constraint so that 2D plane always points towards the point of view
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        self.constraints = [billboardConstraint]
        
        // addingage scene node to the post node
        self.addChildNode(imageNode)
    }
    
    func updatePostNode(locationService: ARSceneLocationService, scenePosition: SCNVector3?, firstTime: Bool) {
        
        
        
        // getting current location & scene position
        guard let currentLocation = locationService.currentLocation, let scenePosition = scenePosition else {return}
        print(self.location.distance(from: currentLocation), ":distance")
        //Start scene transaction
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        
        // position would be set only for the first time
        if (firstTime){
            // getting translation in vector form
            let translateCurrentLocationBy = currentLocation.getTranslation(to: self.location)
            
            //translate the image from current position
            self.position = SCNVector3(
                scenePosition.x + Float(translateCurrentLocationBy.longitudeTranslation),
                scenePosition.y + Float(translateCurrentLocationBy.altitudeTranslation),
                scenePosition.z - Float(translateCurrentLocationBy.latitudeTranslation)
            )
        }
        
        // scale the child
        let givenScale = self.scale
        self.scale = SCNVector3(x: 1, y: 1, z: 1)
        // apply the given scale to child
        self.childNodes.forEach { (node) in
            node.scale = givenScale
            node.childNodes.forEach { (grandChildNode) in
                grandChildNode.scale = scale
            }
        }
        
        SCNTransaction.commit()
    }
    
    func checkNodeRenderValidity(withCurrentLocation currentLocation: CLLocation) -> Bool {
        let distance = self.location.distance(from: currentLocation)
        
        if (distance < self.maximumDistanceFromUser){
            return true
        }else {
            return false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var maximumDistanceFromUser: CLLocationDistance = 50
}

class ImageSCNNode: SCNNode {
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
        
        super.init()
        
        // setup image scene node
        self.addImageAsPlaneGeometry()
        
    }
    
    func getScaledDimensionsForImage() -> CGSize{
        let imageOriginalDims = self.image.size
        
        let width = self.fixedImageWidth
        let height = (imageOriginalDims.height * width)/imageOriginalDims.width
        
        return CGSize(width: width, height: height)
    }
    
    func addImageAsPlaneGeometry() {
        // getting scaled dims for the original image
        let scaledDims = self.getScaledDimensionsForImage()
        print("scaledDims: \(scaledDims)")
        // create plane for adding as geometry to the node
        let plane = SCNPlane(width: scaledDims.width, height: scaledDims.height)
        
        // texturing the plane with the image
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        
        // adding to the node's geometry
        self.geometry = plane
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let fixedImageWidth: CGFloat = 5
}
