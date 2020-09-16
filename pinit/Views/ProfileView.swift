//
//  ProfileView.swift
//  pinit
//
//  Created by Janmajaya Mall on 16/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    var parentSize:CGSize
    
    var viewSize:CGSize{
        return CGSize(width: self.parentSize.width * self.viewWidthRatio, height: self.parentSize.height * self.viewHeightRatio)
    }
        
    var offset:CGSize {
        if (self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .profile){
            return .zero
        }else {
            return CGSize(width: .zero, height: self.parentSize.height)
        }
    }
    
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                HStack{
                    Spacer()
                    Text(self.settingsViewModel.userProfile?.username ?? "")
                        .applyDefaultThemeToTextHeader(ofType: .h3)
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .editUsername)
                    }
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                HStack{
                    Spacer()
                    Text(" \(self.settingsViewModel.userPostCount) PINS")
                        .font(Font.custom("Avenir", size: 18))
                        .foregroundColor(Color.black)
                    Spacer()
                }
                Spacer()
            }.zIndex(1)
            VStack{
                HStack{
                    Image(systemName: "xmark")
                        .foregroundColor(Color.primaryColor)
                    .applyDefaultIconTheme()
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color.primaryColor)
                    .applyDefaultIconTheme()
                        .onTapGesture {
                            self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .settings)
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                Spacer()
            }.zIndex(1)
        }
        .frame(width: self.viewSize.width, height: self.viewSize.height)
        .background(Color.white)
        .cornerRadius(15)
        .offset(self.offset)
        .animation(.spring())
    }
    
    private let viewHeightRatio: CGFloat = 0.25
    private let viewWidthRatio: CGFloat = 0.8
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(parentSize: CGSize(width: 300, height: 800))
    }
}
//
//
//Image(uiImage: self.settingsViewModel.userProfileImage ?? UIImage(imageLiteralResourceName: "ProfileImage"))
//         .resizable().scaledToFit()
//         .frame(width: self.profileImageDim, height: self.profileImageDim, alignment: .center)
//         .overlay(Circle().stroke(Color.secondaryColor, lineWidth: 8).frame(width: self.profileImageDim, height: self.profileImageDim))
//         .cornerRadius(self.profileImageDim/2)
//         .clipped()
//         .onTapGesture {
//             self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.profileViewScreenService.switchTo(screenType: .editProfileImage)
//         }
//         .padding(.bottom, 10)
//
