//
//  EditProfileImageView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct EditProfileImageView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @ObservedObject var imageCropViewModel: ImageCropViewModel
    
    @State var isImagePickerOpen: Bool = false    
    @State var isDoneIconVisible: Bool = true // TODO: make it false initially
    
    var parentSize: CGSize
    
    var offset: CGSize {
        if(self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.activeType == .editProfileImage){
            return .zero
        }else {
            return CGSize(width: .zero, height: self.parentSize.height)
        }
    }
    
    var body: some View {
        
        ZStack{
            VStack{
                Spacer()
                Text("Choose your pic")
                    .font(Font.custom("Acenir", size: 25))
                    .padding(.bottom, 20)
                
                VStack{
                    Spacer()
                    HStack{
                        Image(uiImage: self.imageCropViewModel.image!)
                            .resizable().scaledToFill()
                            .frame(width: self.imageCropViewModel.size.width, height: self.imageCropViewModel.size.height)
                            .clipped()
                            .offset(self.imageCropViewModel.offset)
                            .animation(.easeIn)
                    }
                    Spacer()
                }
                .frame(width: self.imageCropViewModel.defaultImageDim, height: self.imageCropViewModel.defaultImageDim)
                .clipped()
                .cornerRadius(self.imageCropViewModel.defaultImageDim/2)
                .simultaneousGesture(MagnificationGesture().onChanged({ (magnitude) in
                    print(magnitude)
                    self.imageCropViewModel.magnifyBy(magnitude: magnitude)
                }))
                    .simultaneousGesture(DragGesture().onChanged({ (value) in
                        self.imageCropViewModel.dragBy(translation: value.translation)
                    }))
                Spacer()
            }
            
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .foregroundColor(Color.primaryColor)
                        .applyDefaultIconTheme()
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .normal)
                    }
                    .applyTopLeftPaddingToIcon()
                    
                    Spacer()
                    
                    if self.isDoneIconVisible == true {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.primaryColor)
                            .applyDefaultIconTheme()
                            .onTapGesture {
                                // finalise the image
                                self.imageCropViewModel.cropImage()
                                
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                                    self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .normal)
//                                })
                        }
                        .applyTopRightPaddingToIcon()
                    }
                }.gesture(DragGesture())
                
                Spacer()
                
                HStack{
                    Spacer()
                    Image(systemName: "photo.fill")
                        .font(Font.system(size: 35, weight: .bold))
                        .foregroundColor(Color.secondaryColor)
                        .onTapGesture {
                            self.isImagePickerOpen = true
                    }
                    Spacer()
                    Image(systemName: "camera")
                        .font(Font.system(size: 35, weight: .bold))
                        .foregroundColor(Color.secondaryColor)
                    Spacer()
                }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 40, trailing: 0))
                
            }
        }
        .sheet(isPresented: self.$isImagePickerOpen, content: {
            UIKitImagePicker(sourceType: .photoLibrary, image: self.$imageCropViewModel.originalImage, isOpen: self.$isImagePickerOpen)
        })
            .background(Color.white)
            .offset(self.offset)
            .animation(.spring())
    }
}
    
    struct EditProfileImageView_Previews: PreviewProvider {
        static var previews: some View {
            EditProfileImageView(imageCropViewModel: ImageCropViewModel(image: UIImage(imageLiteralResourceName: "ProfileImage")), parentSize: CGSize(width: 400, height: 1000))
        }
}
