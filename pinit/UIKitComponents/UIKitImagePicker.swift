//
//  UIKitImagePicker.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import Foundation

import SwiftUI

struct UIKitImagePicker: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
        
        @Binding var image: UIImage?
        @Binding var isOpen: Bool
        
        init(image: Binding<UIImage?>, isOpen: Binding<Bool>) {
            self._image = image
            self._isOpen = isOpen
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                self.image = uiImage
                self.isOpen = false
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.isOpen = false
        }
        
    }
    
    var sourceType: UIImagePickerController.SourceType
    @Binding var image: UIImage?
    @Binding var isOpen: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(image: self.$image, isOpen: self.$isOpen)
    }
}
