//
//  ImageCropViewModel.swift
//  pinit
//
//  Created by Janmajaya Mall on 24/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI
import Combine

class ImageCropViewModel: ObservableObject {

    @Published var image: UIImage {
        didSet{
            self.setupModel()
        }
    }
    @Published var scale: CGFloat
    @Published var offset: CGSize
    @Published var isDoneIconVisible: Bool = false
    
    init(image: UIImage) {
        self.image = image
        self.scale = 1
        self.offset = .zero
    }
    
    func setupModel(){
        self.scale = 1
        self.offset = .zero
        self.isDoneIconVisible = true
    }
    
    
    var size: CGSize {
        let scaleDiff = self.calculateImageScaleDiff(for: self.image, against: self.defaultImageDim)
        
        return CGSize(width: self.image.size.width * self.scale * scaleDiff, height: self.image.size.height * self.scale * scaleDiff)
    }
    
    // value by which image breaches upper boundary
    var upper: CGFloat {
        // upperValue can be -ve but upper can't. Hence, check & return if >= 0 else return 0 {goes same for lower, left, right}
        let upperValue = (self.size.height - self.defaultImageDim)/2 - self.offset.height
        if upperValue > 0 {
            return upperValue
        }else{
            return 0
        }
    }
    
    // value by which image breaches the lower boundary
    var lower: CGFloat {
        let lowerValue = (self.size.height - self.defaultImageDim)/2 + self.offset.height
        if lowerValue > 0 {
            return lowerValue
        }else {
            return 0
        }
        
    }
    
    // value by which image breaches the right boundary
    var right: CGFloat {
        let rightValue = (self.size.width - self.defaultImageDim)/2 + self.offset.width
        if (rightValue > 0){
            return rightValue
        }else{
            return 0
        }
    }
    
    // value by which image breaches the left boundary
    var left: CGFloat {
        let leftValue = (self.size.width - self.defaultImageDim)/2 - self.offset.width
        if (leftValue > 0){
            return leftValue
        }else{
            return 0
        }
    }
    
    func translateImage(by translation: CGSize){
        
        //translate offset by
        var height: CGFloat = .zero
        var width: CGFloat = .zero
        
        // checking for height translation
        if (translation.height > 0){
            // if translation is down
            
            // only apply tanslation if there is upper space left to translate from
            if upper > 0 {
                height = translation.height
                
                //if height down translation is greater the available upper space, then reduce the translation value to upper value
                if height > upper {
                    height = upper
                }
            }
        }else if (translation.height < 0){
            // if translation is up
            
            // only apply translation if there is down space left to translate from
            if lower > 0 {
                height = translation.height
                
                //if height up translation is greater than available down space, then reduce the translation value to down value
                if (height * -1) > lower {
                    height = -1 * lower
                }
            }
        }
        
        // checking for width translation
        if (translation.width > 0){
            // if translation is right
            
            // only apple translation if there is left space left to translate from
            if left > 0 {
                width = translation.width
                
                //if width right translation is greater than available left space, then reduce the translation value to left value
                if (width > left){
                    width = left
                }
            }
        }else if (translation.width < 0){
            // if translation is left
            
            // only apply translation if there is right space left to translate from
            if right > 0 {
                width = translation.width
                
                //if width left translation is greater than available right space, then reduce the translation value to right value
                if (-1 * width) > right {
                    width = -1 * right
                }
            }
        }
        
        //translate the offset, by adding them to the current height & widht offset values
        self.offset = CGSize(width: self.offset.width + width, height: self.offset.height + height)
        
    }
    
    /// Resizes the image so that the smaller of width or height is equivalent to defaultImageDim
    ///
    /// By setting figuring out the lesser from width & height, we can figure out the scale difference between the smaller & defaultImageDim.
    /// Then we can scale down the smaller dimension (from width & height) as well as the longer one.
    func resizeUIImageToDefaultSize (_ image: UIImage) -> UIImage? {
        
        let imageSize: CGSize = image.size
        
        //figuring out the scale difference between smaller of width & height and the defaultImageDim
        let scaleDiff: CGFloat
        if imageSize.width < imageSize.height {
            scaleDiff = imageSize.width / self.defaultImageDim
        }else {
            scaleDiff = imageSize.height / self.defaultImageDim
        }
        
        // convering UIImage to data
        guard let imageData = image.jpegData(compressionQuality: 1) else {return nil}
        // resizing the UIImage using the scale value
        guard let scaledImage = UIImage(data: imageData, scale: scaleDiff) else {return nil}
        
        return scaledImage
    }
    
    /// crops the original chosen image to what is present in the defaultImageDim box
    func getCropImage() -> UIImage? {
        let image = self.image
        let editScale = self.scale
    
        // getting scale difference between default size and image
        let scaleDiff = self.calculateImageScaleDiff(for: image, against: self.defaultImageDim)
       
        let cropRect = CGRect(
            x: (self.left/editScale)/scaleDiff,
            y: (self.upper/editScale)/scaleDiff,
            width: (self.defaultImageDim/editScale)/scaleDiff,
            height: (self.defaultImageDim/editScale)/scaleDiff
        )
                
        guard let croppedCGImage = image.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        let croppedUIImage = UIImage(cgImage: croppedCGImage)
        
        return croppedUIImage
    }
    
    func calculateImageScaleDiff(for image: UIImage, against length: CGFloat) -> CGFloat {
        
        let imageSize = image.size
        
        let scaleDiff: CGFloat
        if imageSize.width < imageSize.height {
            scaleDiff = length / imageSize.width
        }else{
            scaleDiff = length / imageSize.height
        }
        return scaleDiff
    }
    
    func magnifyBy(magnitude: CGFloat) {
        // make done icon visible
        self.isDoneIconVisible = true
        
        if magnitude > 1 {
            self.scale += 0.1
        }else {
            self.scale -= 0.1
            
            // TODO: can improve the zoom out offset thing late
            self.offset = .zero
        }
        
        if (self.scale < 1){
            self.scale = 1
        }
    }
    
    func dragBy(translation: CGSize) {
        // make done icon visible
        self.isDoneIconVisible = true
        
        self.translateImage(by: translation)
    }
    
    func finaliseImage(for service: ImageCropViewModelServiceType){
        
        // getting the final cropped image
        guard let finalImage = self.getCropImage() else {return}
        
        switch service {
        case .edit:
            self.postNotification(for: .userProfileServiceDidRequestProfileImageChange, withObject: finalImage)
        case .setup:
            self.postNotification(for: .userProfileServiceDidSetupProfileImage, withObject: finalImage)
        }
        
    }
    
    func postNotification(for notificationType: Notification.Name, withObject object: Any){
        NotificationCenter.default.post(name: notificationType, object: object)
    }
    
    
    let defaultImageDim: CGFloat = 300
}

enum ImageCropViewModelServiceType {
    case setup
    case edit
}