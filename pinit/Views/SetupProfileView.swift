//
//  SetupProfileView.swift
//  pinit
//
//  Created by Janmajaya Mall on 25/8/2020.
//  Copyright © 2020 Janmajaya Mall. All rights reserved.
//

import SwiftUI

struct SetupProfileView: View {
    
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    var parentSize: CGSize
    
    var viewSize: CGSize {
        return CGSize(width: self.parentSize.width * self.viewWidthRatio, height: self.parentSize.height * self.viewHeightRatio)
    }
    
    
    var offset: CGSize {
        if self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.activeType == .setupProfile {
            return .zero
        }else{
            return CGSize(width: .zero, height: self.parentSize.height)
        }
    }
    
    var body: some View {
        
        VStack{
            Spacer()
            
            HStack{
              Text("Setup your profile")
                .applyDefaultThemeToTextHeader(ofType: .h3)
                    
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Spacer()
            
            Image(uiImage: self.settingsViewModel.setupProfileViewModel.profileImage)
                .resizable().scaledToFit()
                .frame(width: self.profileImageDim, height: self.profileImageDim, alignment: .center)
                .overlay(Circle().stroke(Color.secondaryColor, lineWidth: 8).frame(width: self.profileImageDim, height: self.profileImageDim))
                .cornerRadius(self.profileImageDim/2)
                .clipped()
                .onTapGesture {
                    self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.setupProfileViewScreenService.switchTo(screenType: .pickImage)
            }
//            .padding(.bottom, 10)
            
             Spacer()
            
            HStack{
                Spacer()
                VStack{
                    CustomTextFieldView(text: self.$settingsViewModel.setupProfileViewModel.username, placeholder: "Username")
                        .font(Font.custom("Avenir", size: 18))
                    Divider().background(Color.secondaryColor)
                }
                Spacer()
            }
            
             Spacer()
            
            Button(action: {
                self.settingsViewModel.setupProfileViewModel.setupProfile()
                
                // hiding the keyboard
                self.hideKeyboard()
                
                // switching the screen
                self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
            }, label: {
                Text("Done")
            })
                .buttonStyle(SecondaryColorButtonStyle())
            
            Spacer()
        }
            
        .frame(width: self.viewSize.width, height: self.viewSize.height)
        .background(Color.white)
        .cornerRadius(15)
        .offset(self.offset)
        .animation(.spring())
    }
    
    let viewHeightRatio: CGFloat = 0.4
    let viewWidthRatio: CGFloat = 0.8
    let profileImageDim: CGFloat = 100
}

struct SetupProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SetupProfileView(parentSize: .zero)
    }
}



