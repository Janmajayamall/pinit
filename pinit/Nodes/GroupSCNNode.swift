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

class GroupSCNNode: SCNNode, Identifiable {
    
    var nodeDirection: NodeDirection
    
    var imageList: Array<UIImage>  = [UIImage(named: "image1")!, UIImage(named: "image2")!, UIImage(named: "image3")!, UIImage(named: "image4")!, UIImage(named: "image5")!]
    
    var currentImageIndex: Int = -1
    
    init(scenePosition: SCNVector3?, direction: NodeDirection){
        self.nodeDirection = direction
        
        super.init()
        
        // add constraints to the node
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        self.constraints = [billboardConstraint]
        
        self.placeNode(scenePosition: scenePosition)
        self.changeImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getScaledDim(forImage image: UIImage) -> CGSize{
        let imageOriginalDims = image.size
        
        let width = self.fixedImageWidth
        let height = (imageOriginalDims.height * width)/imageOriginalDims.width
        
        return CGSize(width: width, height: height)
    }
    
    func addImageAsGeometry(image: UIImage){
        // getting scaled dims for the original image
        let scaledDims = self.getScaledDim(forImage: image)
        
        // create plane for adding as geometry to the node
        let plane = SCNPlane(width: scaledDims.width, height: scaledDims.height)
        plane.cornerRadius = 0.1 * scaledDims.width
        
        // texturing the plane with the image
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        
        // adding to the node's geometry
        self.geometry = plane
    }
    
    func changeImage(){
        
        // changing the index
        self.currentImageIndex = (self.currentImageIndex + 1) % self.imageList.count
        
        // adding image at current index to as geometry for node
        self.addImageAsGeometry(image: self.imageList[self.currentImageIndex])
    }
    
    func scaleImage(withValue scale: CGFloat){
        guard scale > 0 else {return}
        
                if (scale > 1){
                    self.fixedImageWidth += 0.05
                }else {
                    self.fixedImageWidth -= 0.05
                }
        
        self.addImageAsGeometry(image: self.imageList[self.currentImageIndex])
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
                scenePosition.z + -self.defaultCoordDis)
        case .right:
            self.position = SCNVector3(
                scenePosition.x + self.defaultCoordDis,
                scenePosition.y + self.defaultYCoordDis,
                scenePosition.z + -self.defaultCoordDis)
        case .left:
            self.position = SCNVector3(
                scenePosition.x + -self.defaultCoordDis,
                scenePosition.y + self.defaultYCoordDis,
                scenePosition.z + -self.defaultCoordDis)
        case .back:
            self.position = SCNVector3(
                scenePosition.x + Float(0),
                scenePosition.y + 1.5,
                scenePosition.z + -self.defaultCoordDis)
        }
        
        SCNTransaction.commit()
    }
    
    
    private var defaultCoordDis: Float = 2
    private var defaultYCoordDis: Float = -1
    private var fixedImageWidth: CGFloat = 1
}

enum NodeDirection {
    case front
    case back
    case right
    case left
}
