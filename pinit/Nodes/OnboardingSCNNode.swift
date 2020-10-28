//
//  OnboardingSCNNode.swift
//  pinit
//
//  Created by Janmajaya Mall on 26/10/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class OnboardingSCNNode: SCNNode, Identifiable, AppSCNNode {
    var nodeDirection: NodeDirection
    var onboardingNodeModels: Array<OnboardingNodeModel> = []
    
    var currentIndex: Int = 0
    
    init(scenePosition: SCNVector3?, nodeDirection: NodeDirection, modelsList: Array<OnboardingNodeModel>) {
        self.nodeDirection = nodeDirection
        self.onboardingNodeModels = modelsList
        
        super.init()
        
        //        if (self.onboardingNodeModels.count >= 2){
        //            self.addCurrentIndexAsGeometry()
        //        }
        
        // add constraints to the node
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .Y
        self.constraints = [billboardConstraint]
        
        self.placeNode(scenePostion: scenePosition)
        self.addCurrentIndexAsGeometry()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func placeNode(scenePostion: SCNVector3?){
        guard let scenePosition = scenePostion else {return}
        
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
    }
    
    func nextPost(){
        self.currentIndex = (self.currentIndex + 1) % self.onboardingNodeModels.count
        self.addCurrentIndexAsGeometry()
    }
    
    func previousPost(){
        self.currentIndex = (self.currentIndex - 1) % self.onboardingNodeModels.count
        if (self.currentIndex < 0){
            self.currentIndex = self.currentIndex + self.onboardingNodeModels.count
            
        }
        
        self.addCurrentIndexAsGeometry()
    }
    
    func scaleNodePlane(withValue scale: CGFloat){
        guard scale > 0 else {return}
        
        if (scale > 1){
            self.fixedImageWidth += 0.05
        }else {
            if (self.fixedImageWidth > 0.1){
                self.fixedImageWidth -= 0.05
            }
        }
        
        self.addCurrentIndexAsGeometry()
    }
    
    func displayPostInfo() {
        let postDisplayInfo = PostDisplayInfoModel(username: "FinchIt", description: self.onboardingNodeModels[self.currentIndex].descriptionText)
        
        NotificationCenter.default.post(name: .groupSCNNodeDidRequestCurrentPostDisplayInfo, object: postDisplayInfo)
    }
    
    func toggleVolumeIfVideoContentBeingOnDisplay(){
        
    }
    
    func getScaledDim(forSize size: CGSize) -> CGSize {
        let width = self.fixedImageWidth
        let height = (size.height * width)/size.width
        
        return CGSize(width: width, height: height)
    }
    
    func addCurrentIndexAsGeometry() {
        let node = self.onboardingNodeModels[self.currentIndex]
        
        if (node.contentType == .image){
            self.addImageAsGeometry(image: node.image!)
        }
    }
    
    func addImageAsGeometry(image: UIImage){
        let scaledDims = self.getScaledDim(forSize: image.size)
        
        let plane = SCNPlane(width: scaledDims.width, height: scaledDims.height)
        plane.cornerRadius = 0.1 * scaledDims.width
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        
        // adding plane to the geometry of the scn node
        self.geometry = plane
    }
    
    func addVideoAsGeoemetry(){
        
    }
    
    
    
    private var defaultZCoordDis: Float = 2.5
    private var defaultXCoordDis: Float = 1
    private var defaultYCoordDis: Float = -1
    private var fixedImageWidth: CGFloat = 1
}
