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
    @State var isDoneIconVisible: Bool = false
    
    
    var parentSize: CGSize
    
    var offset: CGSize {
        if(self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.activeType == .editProfileImage || self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.setupProfileViewScreenService.activeType == .pickImage){
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
                    .applyDefaultThemeToTextHeader(ofType: .h3)
                
                Spacer()
                
                VStack{
                    Spacer()
                    HStack{
                        Image(uiImage: self.imageCropViewModel.image)
                            .resizable().scaledToFill()
                            .frame(width: self.imageCropViewModel.size.width, height: self.imageCropViewModel.size.height, alignment: .center)
                            .offset(self.imageCropViewModel.offset)
                            .animation(.linear)
                    }
                    Spacer()
                }
                .frame(width: self.imageCropViewModel.defaultImageDim, height: self.imageCropViewModel.defaultImageDim)
                .clipped()
                .cornerRadius(self.imageCropViewModel.defaultImageDim/2)
                .simultaneousGesture(MagnificationGesture().onChanged({ (magnitude) in
                    self.imageCropViewModel.magnifyBy(magnitude: magnitude)
                }))
                    .simultaneousGesture(DragGesture().onChanged({ (value) in
                        self.imageCropViewModel.dragBy(translation: value.translation)
                    }))
                
                Spacer()
                
                HStack{
                    Spacer()
                    Image(systemName: "photo.fill")
                        .font(Font.system(size: 35, weight: .bold))
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            self.isImagePickerOpen = true
                    }
                    Spacer()
                    Image(systemName: "camera")
                        .font(Font.system(size: 35, weight: .bold))
                        .foregroundColor(Color.primaryColor)
                    Spacer()
                }
                
                Spacer()
            }
            
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .foregroundColor(Color.primaryColor)
                        .applyDefaultIconTheme()                        
                        .onTapGesture {
                            self.closeEditProfileImageView()
                    }
                    .applyTopLeftPaddingToIcon()
                    
                    Spacer()
                    
                    if self.imageCropViewModel.isDoneIconVisible == true {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.primaryColor)
                            .applyDefaultIconTheme()
                            .onTapGesture {                                                                                             
                                // finalise the image & notify accordingly
                                if (self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.activeType == .editProfileImage) {
                                    self.imageCropViewModel.finaliseImage(for: .edit)
                                }else if (self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.setupProfileViewScreenService.activeType == .pickImage){
                                    self.imageCropViewModel.finaliseImage(for: .setup)
                                }
                                
                                self.closeEditProfileImageView()
                        }
                        .applyTopRightPaddingToIcon()
                    }
                }.gesture(DragGesture())
                
                Spacer()
            }
        }
        .sheet(isPresented: self.$isImagePickerOpen, content: {
            UIKitImagePicker(sourceType: .photoLibrary, image: self.$imageCropViewModel.image, isOpen: self.$isImagePickerOpen)
        })
            .background(Color.white)
            .offset(self.offset)
            .animation(.spring())
    }
    
    func closeEditProfileImageView(){
        // switching for all possible cases
        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .normal)
        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.setupProfileViewScreenService.switchTo(screenType: .normal)
    }
}

struct EditProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileImageView(imageCropViewModel: ImageCropViewModel(image: UIImage(imageLiteralResourceName: "ProfileImage")), parentSize: CGSize(width: 400, height: 1000))
    }
}
