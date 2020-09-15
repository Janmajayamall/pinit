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
    
    @State var noteText: String = ""
    
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
    
    @State var forceRenderBool: Bool = true
    
    var body: some View {
        // binding for username
        let usernameBinding = Binding<String>(
            get: {
                self.settingsViewModel.setupProfileViewModel.username
        }, set: {
            
            var username = $0.lowercased()
            username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            self.settingsViewModel.setupProfileViewModel.username = String(username.prefix(30))
            
            // forcing render UI
            self.forceRenderBool.toggle()
        }
        )
        
        return VStack{
            Spacer()
            
            HStack{
                Text("Setup your profile")
                    .applyDefaultThemeToTextHeader(ofType: .h3)
                
            }.padding(EdgeInsets(top: self.forceRenderBool ? 0 : 0, leading: 0, bottom: 0, trailing: 0))
            
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
                    CustomTextFieldView(text: usernameBinding, placeholder: "Username", noteText: self.$settingsViewModel.setupProfileViewModel.usernameError)
                        .font(Font.custom("Avenir", size: 18))
                        .foregroundColor(Color.black)                    
                }
                Spacer()
            }
            
            Spacer()
            
            Button(action: {
                self.settingsViewModel.setupProfileViewModel.initiateSetupProfile { success in
                    if (success == true){
                        // hiding the keyboard
                        self.hideKeyboard()
                        
                        // switching the screen
                        self.settingsViewModel.screenManagementService.mainScreenService.mainArViewScreenService.switchTo(screenType: .normal)
                    }else {
                        self.forceRenderBool.toggle()
                    }
                }
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



