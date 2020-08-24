//
//  ProfileImageEditorView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct ProfileImageEditorView: View {
    @Binding var image: UIImage
    
    var size: CGSize {
        return CGSize(width: self.image.size.width * self.scale, height: self.image.size.height * self.scale)
    }
    
    @State var scale: CGFloat = 1
    @State var offset: CGSize = CGSize(width: 0, height: 0)
    
    // value by which image breaches upper boundary
    var upper: CGFloat {
        // upperValue can be -ve but upper can't. Hence, check & return if >= 0 else return 0 {goes same for lower, left, right}
        let upperValue = (self.size.height - ProfileImageEditorView.defaultImageDim)/2 - self.offset.height
        if upperValue > 0 {
            return upperValue
        }else{
            return 0
        }
    }
    
    // value by which image breaches the lower boundary
    var lower: CGFloat {
        let lowerValue = (self.size.height - ProfileImageEditorView.defaultImageDim)/2 + self.offset.height
        if lowerValue > 0 {
            return lowerValue
        }else {
            return 0
        }
        
    }
    
    // value by which image breaches the right boundary
    var right: CGFloat {
        let rightValue = (self.size.width - ProfileImageEditorView.defaultImageDim)/2 + self.offset.width
        if (rightValue > 0){
            return rightValue
        }else{
            return 0
        }
    }
    
    // value by which image breaches the left boundary
    var left: CGFloat {
        let leftValue = (self.size.width - ProfileImageEditorView.defaultImageDim)/2 - self.offset.width
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
    
    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .onChanged({ (magnitude) in
                if magnitude > 1 {
                    self.scale += 0.1
                }else {
                    self.scale -= 0.1
                    // TODO: can improve the offset thing later
                    self.offset = .zero
                }
                
                if (self.scale < 1){
                    self.scale = 1
                }
            })
        
        let dragGesture = DragGesture().onChanged({ (value) in
            self.translateImage(by: value.translation)
        })
        
        return
            
            VStack{
                Spacer()
                
                HStack{
                    ZStack{
                        Image(uiImage: self.image).resizable().scaledToFill().frame(width: self.size.width, height: self.size.height)
                            .offset(self.offset)
                            .animation(.easeIn)
                    }
                }
                
                Spacer()
                
                Text("duadiawuda").onTapGesture {
                    print("just got tapped")
                    self.getCroppedImage()
                }
                
                Spacer()
            }.frame(width: ProfileImageEditorView.defaultImageDim, height: ProfileImageEditorView.defaultImageDim, alignment: .center)
                .cornerRadius(ProfileImageEditorView.defaultImageDim/2)
                .clipped()
                .simultaneousGesture(magnificationGesture)
                .simultaneousGesture(dragGesture)
        
    }
    
    /// crops the original chosen image to what is present in the defaultImageDim box
    func getCroppedImage() {
        let image = self.image
        var editScale = self.scale
        
        let cgImage = image.cgImage!
        
        let scaleDiff: CGFloat
        if (cgImage.width < cgImage.height) {
            scaleDiff = CGFloat(cgImage.width) / ProfileImageEditorView.defaultImageDim
        }else {
            scaleDiff = CGFloat(cgImage.height) / ProfileImageEditorView.defaultImageDim
        }
        
        editScale = editScale / scaleDiff
        
        print(image.size, image.cgImage?.height, image.cgImage?.width, "this is here")
        
        let cropRect = CGRect(x: self.left/editScale, y: self.upper/editScale , width: ProfileImageEditorView.defaultImageDim/editScale, height: ProfileImageEditorView.defaultImageDim/editScale)
        
        
        let croppedImage = cgImage.cropping(to: cropRect)
        if let cropImage = croppedImage {
            self.image = UIImage(cgImage: cropImage)
        }
        
    }
    
    /// Resizes the image so that the smaller of width or height is equivalent to defaultImageDim
    ///
    /// By setting figuring out the lesser from width & height, we can figure out the scale difference between the smaller & defaultImageDim.
    /// Then we can scale down the smaller dimension (from width & height) as well as the longer one.
    static func resizeUIImageToDefaultSize (_ image: UIImage) -> UIImage? {
        
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
        guard let cgImage = image.cgImage else {return nil}
        // resizing the UIImage using the scale value
        let scaledImage = UIImage(cgImage: cgImage, scale: scaleDiff, orientation: image.imageOrientation)
        
        return scaledImage
    }
            
    static let defaultImageDim: CGFloat = 300
}
