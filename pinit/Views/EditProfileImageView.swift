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
    
    @State var image: UIImage? = UIImage(imageLiteralResourceName: "ProfileImage")
    @State var isImagePickerOpen: Bool = false
    @State var croppedImage: UIImage?
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
        
        VStack{
            HStack{
                Image(systemName: "xmark")
                    .font(Font.system(size: 15, weight: .bold))
                    .foregroundColor(Color.primaryColor)
                    .onTapGesture {
                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .normal)
                }
                .padding(EdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 0))
                
                Spacer()
                
                if self.isDoneIconVisible == true {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 15, weight: .bold))
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            print("code")
                    }
                    .padding(EdgeInsets(top: 30, leading: 0, bottom: 0, trailing: 10))
                }
            }
            Spacer()
            Text("Choose your pic")
                .font(Font.custom("Acenir", size: 25))
                .padding(.bottom, 20)
            ProfileImageEditorView(
                image: ProfileImageEditorView.resizeUIImageToDefaultSize(self.image!)!,
                croppedImage: self.$croppedImage
            ).padding(.bottom, 30)
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
            Spacer()
        }.sheet(isPresented: self.$isImagePickerOpen, content: {
            UIKitImagePicker(sourceType: .photoLibrary, image: self.$image, isOpen: self.$isImagePickerOpen)
        })
            .background(Color.white)
            .offset(self.offset)
            .animation(.spring())
    }
}

struct EditProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileImageView(parentSize: CGSize(width: 400, height: 1000))
    }
}
