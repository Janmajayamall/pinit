//
//  EditingViewModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 19/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import Firebase
import CoreLocation
import FirebaseFirestore
import Combine

class EditingViewModel: NSObject, ObservableObject {

    @Published var selectedImage: Image
    @Published var imageRect: CGRect = .zero
    @Published var imagePainting: ImagePaintingModel = ImagePaintingModel()
    
    // FIXME: remove `true` declaration
    var isPostPublic: Bool? = true
    var finalImage: UIImage?
    @Published var descriptionText: String = ""

    init(selectedImage :Image) {
        self.selectedImage = selectedImage
        super.init()
    }
    
    /// Sets the final image as the core graphic of window's view
    ///
    /// Uses view's frame CGRect to convert the view in the rootController of
    /// window to UIImage
    /// - Parameters:
    ///     - window: UIApplicaton window
    func setFinalImage(withWindow window: UIWindow!){
        self.finalImage = window.rootViewController?.view.toImage(rect: self.imageRect)
    }
}

// functions of image painting
extension EditingViewModel {
    func changeSelectedColor(to color: Color, withYCoord yCoord: CGFloat){
        self.imagePainting.changeSelectedColor(to: color, withYCoord: yCoord)
    }
    
    func changeSelectedStrokeWidth(to strokeWidth: CGFloat, withYCoord yCoord: CGFloat){
        self.imagePainting.changeSelectedStrokeWidth(to: strokeWidth, withYCoord: yCoord)
    }
    
    func draw(atPoint point: CGPoint){
        self.imagePainting.draw(atPoint: point)
    }
    
    func startNewDrawing(){
        self.imagePainting.newDrawing()
    }
    
    func undoLastDrawing(){
        self.imagePainting.undoPathDrawing()
    }
    
    func uploadPost(){
        guard let image = self.finalImage else {return}
        guard let isPublic = self.isPostPublic else {return}
        print(image, "image is here")
        // requestCreatePost
        let requestCreatePost = RequestCreatePostModel(image: image, description: self.descriptionText, isPublic: isPublic)
        
        // publish request for upload the post with object post model
        NotificationCenter.default.post(name: .uploadPostServiceDidRequestCreatePost, object: requestCreatePost)
    }
}
