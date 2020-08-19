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

class EditingViewModel: NSObject, ObservableObject {

    @Published var selectedImage: Image
    @Published var imageCanvasRect: CGRect = .zero
    @Published var imagePainting: ImagePaintingModel = ImagePaintingModel()
   
    var isPostPublic: Bool?
    var finalImage: UIImage?
    @Published var descriptionText: String = ""

    init(selectedImage :Image) {
        self.selectedImage = selectedImage
        super.init()
    }
    
    


//    func setFinalImage(){
//        self.finalImage = UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.rootViewController?.view.toImage(rect: self.imageCanvasRect)
//    }
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
}
