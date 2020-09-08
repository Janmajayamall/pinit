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
    var imageManager: ImageManager?
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
        self.imageManager?.$image.sink { (image) in
            guard let image = image else {return}
            
            // create and add image scene node as a child node to self & make isImageNodeLoaded as true
            self.addImageSCNNode(withImage: image)
            self.isImageNodeLoaded = true
            
        }.store(in: &cancellables)
        
        // loading the image
        self.imageManager?.load()
    }
    
    init(post: PostModel, postImage: UIImage, scenePosition: SCNVector3?, locationService: ARSceneLocationService){
        self.post = post
        super.init()
        
        self.addImageSCNNode(withImage: postImage)
        self.isImageNodeLoaded = true
        self.optimisticUIPlaceNode(scenePosition: scenePosition, locationService: locationService)
    }
    
    func addImageSCNNode(withImage image: UIImage){
        // return if imageSCNNode has already been added
        guard self.isImageNodeLoaded == false else {return}
        
        let imageNode = ImageSCNNode(image: image, description: self.post.description, username: self.post.username, userProfilePictureUrl: self.post.userProfilePicture)
        
        // define billboard constraint so that 2D plane always points towards the point of view
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        self.constraints = [billboardConstraint]
        
        // addingage scene node to the post node
        self.addChildNode(imageNode)
    }
    
    func optimisticUIPlaceNode(scenePosition: SCNVector3?, locationService: ARSceneLocationService){
        
        guard let scenePosition = scenePosition else {
            return
        }
        
        //Start scene transaction
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        
        //translate the image from current position
        print("Used this pos")
        self.position = SCNVector3(
            scenePosition.x + 0,
            scenePosition.y + 0,
            scenePosition.z + 0
        )
        
        // FIXME: decide on the z axis to make it look in front
        
        SCNTransaction.commit()
    }
    

    func updatePostNode(locationService: ARSceneLocationService, scenePosition: SCNVector3?, firstTime: Bool) {
        // getting current location & scene position
        guard let currentLocation = locationService.currentLocation, let scenePosition = scenePosition else {return}
        //Start scene transaction
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        print(scenePosition, ": this")
        // position would be set only for the first time
        if (true){
            // getting translation in vector form
            let translateCurrentLocationBy = currentLocation.getTranslation(to: self.location)
            print(self.location.distance(from: currentLocation), " :distance |", "with id: \(translateCurrentLocationBy.latitudeTranslation) \(translateCurrentLocationBy.longitudeTranslation) \(translateCurrentLocationBy.altitudeTranslation)")
            //translate the image from current position
            self.position = SCNVector3(
                scenePosition.x+Float(0),
                scenePosition.y+Float(0),
                scenePosition.z+Float(1)
            )
//            self.position = SCNVector3(
//                scenePosition.x + Float(translateCurrentLocationBy.longitudeTranslation),
//                scenePosition.y + Float(translateCurrentLocationBy.altitudeTranslation),
//                scenePosition.z - Float(translateCurrentLocationBy.latitudeTranslation)
//            )
        }
//
//        // scale the child
//        let givenScale = self.scale
//        self.scale = SCNVector3(1, 1, 1)
//        print(givenScale, ": wee")
//        // apply the given scale to child
//        self.childNodes.forEach { (node) in
//            node.scale = givenScale
//            node.childNodes.forEach { (grandChildNode) in
//                grandChildNode.scale = givenScale
//            }
//        }
//
//
        
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
    
    private var maximumDistanceFromUser: CLLocationDistance = 200
    
}

class ImageSCNNode: SCNNode {
    var imageList: Array<UIImage> = [UIImage(named: "image1")!, UIImage(named: "image2")!, UIImage(named: "image3")!, UIImage(named: "image4")!, UIImage(named: "image5")!]
    var descriptionText: String
    var username: String
    var userProfilePicture: UIImage?
    var userProfilePictureManager: ImageManager
    
    var indexOfImageInFocus = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(image: UIImage, description: String, username: String, userProfilePictureUrl: String) {
        self.descriptionText = description
        self.username = username
        self.userProfilePictureManager = ImageManager(url: URL(string: userProfilePictureUrl))
        super.init()
        
        // load profile image
        self.userProfilePictureManager.$image.sink { (image) in
            guard let image = image else {return}
            self.userProfilePicture = image
        }.store(in: &cancellables)
        self.userProfilePictureManager.load()
        
        // setup image scene node
        self.switchDisplayedImage()
        
    }
    
    func getScaledDimensions(forImage image: UIImage) -> CGSize{
        let imageOriginalDims = image.size
        
        let width = self.fixedImageWidth
        let height = (imageOriginalDims.height * width)/imageOriginalDims.width
        print(width, height, "this should be constant", imageOriginalDims, description)
        return CGSize(width: width, height: height)
    }
    
    func addImageAsPlaneGeometry(withImage image: UIImage) {
        // getting scaled dims for the original image
        let scaledDims = self.getScaledDimensions(forImage: image)
        
        // create plane for adding as geometry to the node
        let plane = SCNPlane(width: scaledDims.width, height: scaledDims.height)
        plane.cornerRadius = 0.1
        
        // texturing the plane with the image
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        
        // adding to the node's geometry
        self.geometry = plane
    }
    
    func switchDisplayedImage(){
        // getting the image
        let image = self.imageList[self.indexOfImageInFocus]
        
        // adding the image as geometry
        self.addImageAsPlaneGeometry(withImage: image)
        
        self.indexOfImageInFocus = (self.indexOfImageInFocus + 1) % self.imageList.count
    }
        
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let fixedImageWidth: CGFloat = 1
}
